import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/completion_card.dart';
import '../../../../shared/widgets/disclosure.dart';
import '../../../../shared/widgets/mixed_arabic_text.dart';
import '../../../../shared/widgets/pill.dart';
import '../../../review/data/srs_repository.dart';
import '../../data/curriculum_repository.dart';
import '../../data/lesson_repository.dart';
import '../../domain/lesson_exercise.dart';

/// Full-screen modal takeover per docs/design-system.md — deliberately
/// not nested inside the bottom-nav shell (see core/router/app_router.dart,
/// where /lesson/:lessonId is a top-level route, not a branch of /learn).
/// Exit mid-lesson asks for confirmation so a stray back-gesture doesn't
/// silently drop progress on the exercise in view.
class LessonPlayerScreen extends ConsumerStatefulWidget {
  const LessonPlayerScreen({
    super.key,
    required this.lessonId,
    required this.unitId,
    required this.lessonTitle,
  });

  final int lessonId;
  final int unitId;
  final String lessonTitle;

  @override
  ConsumerState<LessonPlayerScreen> createState() => _LessonPlayerScreenState();
}

class _LessonPlayerScreenState extends ConsumerState<LessonPlayerScreen> {
  int _index = 0;
  bool _completed = false;
  int? _lessonAttemptId;

  /// Answers keyed by exercise index rather than held as one "current
  /// answer", so stepping back shows what was actually chosen instead of a
  /// blank card, and stepping forward again cannot score the same question
  /// twice. Both were possible while this was a pair of scalar fields.
  final Map<int, int> _quizAnswers = {};

  /// Graded outcomes keyed the same way. The score is derived from this
  /// rather than accumulated, which is what makes revisiting an exercise
  /// idempotent: re-answering overwrites, it does not add.
  final Map<int, bool> _results = {};

  /// Exercise ids already written to `exercise_attempts`. Walking back and
  /// forward over a card is navigation, not a fresh attempt, so it must not
  /// append another row.
  final Set<int> _recordedExerciseIds = {};

  int get _correct => _results.values.where((isCorrect) => isCorrect).length;
  int get _total => _results.length;

  int? get _selectedQuizOption => _quizAnswers[_index];
  bool get _quizAnswered => _quizAnswers.containsKey(_index);

  @override
  void initState() {
    super.initState();
    // Fire-and-track separately from the exercises fetch (via the
    // provider below) — the attempt row needs to exist before the first
    // answer can be recorded against it, but the UI doesn't need to block
    // on it the way it blocks on exercise content.
    ref.read(lessonRepositoryProvider).startLessonAttempt(widget.lessonId).then((id) {
      if (mounted) setState(() => _lessonAttemptId = id);
    });
  }

  /// Fire-and-forget: updating the SRS queue (exposure or quiz grading)
  /// shouldn't add latency to tapping "Next," and a transient failure
  /// here isn't worth interrupting the lesson over — recoverable, since
  /// the item is re-exposed next time this exercise is seen. Logged
  /// rather than silently swallowed: a fully silent failure here is
  /// exactly what made the earlier "review shows nothing due" bug slow
  /// to track down.
  void _exposeToSrs(Future<void> Function() call) {
    call().catchError((Object e) => debugPrint('SRS update failed: $e'));
  }

  Future<void> _advance(List<LessonExercise> exercises, {required bool graded, bool isCorrect = true}) async {
    final exercise = exercises[_index];
    final alreadyRecorded = _recordedExerciseIds.contains(exercise.id);

    if (graded) _results[_index] = isCorrect;

    // Errors here are surfaced, not swallowed like the SRS fire-and-forget
    // calls above — a failed exercise_attempt/lesson_attempt write is a
    // real "your progress didn't save" situation the user should know
    // about and can retry, not a low-stakes background update. This is
    // also what would have turned the earlier stale-exercise-id crash
    // (fixed by making exercisesForLessonProvider autoDispose) into a
    // recoverable message instead of an uncaught exception dump.
    try {
      final attemptId = _lessonAttemptId;
      if (attemptId != null && !alreadyRecorded) {
        await ref.read(lessonRepositoryProvider).recordExerciseAttempt(
              lessonAttemptId: attemptId,
              exerciseId: exercise.id,
              isCorrect: isCorrect,
            );
        _recordedExerciseIds.add(exercise.id);
      }

      if (_index + 1 >= exercises.length) {
        await _finish(attemptId);
      } else {
        setState(() => _index++);
      }
    } catch (e) {
      // Undo the local score, but leave any answer the user picked in place:
      // the write failed, not their choice, and blanking the card would make
      // a retry mean re-answering.
      if (graded) _results.remove(_index);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not save your progress. Please try again.\n$e')),
        );
      }
    }
  }

  /// Steps back one exercise. Records nothing: going back is navigation, and
  /// the answer already given is kept so the card is not blanked on return.
  void _goBack() {
    if (_index == 0) return;
    setState(() => _index--);
  }

  Future<void> _finish(int? attemptId) async {
    if (attemptId != null) {
      await ref.read(lessonRepositoryProvider).completeLessonAttempt(
            lessonAttemptId: attemptId,
            unitId: widget.unitId,
            correctCount: _correct,
            totalCount: _total,
          );
    }
    // The Learn tab's unit list (locked/in-progress/completed/mastered
    // icons) needs to reflect the just-finished lesson next time it's
    // visible — invalidate rather than leaving it stale until some
    // unrelated rebuild happens to refetch it.
    ref.invalidate(curriculumUnitsProvider);
    // The lesson list carries a per-lesson completed tick now, and it is the
    // screen the user returns to from here — without this it would still show
    // the lesson they just finished as unfinished.
    ref.invalidate(lessonsForUnitProvider(widget.unitId));
    if (mounted) setState(() => _completed = true);
  }

  Future<bool> _confirmExit() async {
    final leave = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Leave this lesson?'),
        content: const Text("Your progress on the current exercise won't be saved."),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Stay')),
          TextButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('Leave')),
        ],
      ),
    );
    return leave ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final exercisesAsync = ref.watch(exercisesForLessonProvider(widget.lessonId));

    return PopScope(
      canPop: _completed,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        if (await _confirmExit() && context.mounted) {
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        body: SafeArea(
          child: exercisesAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => Center(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.xl),
                child: Text(
                  'Could not load this lesson.\n$error',
                  textAlign: TextAlign.center,
                  style: AppTypography.label(fontSize: 14),
                ),
              ),
            ),
            data: (exercises) {
              if (_completed) {
                return CompletionCard(
                  headline: 'Lesson complete',
                  detailLines: [
                    if (_total > 0) '$_correct / $_total correct',
                    '+${_correct * 10} XP',
                  ],
                  onDone: () => Navigator.of(context).pop(),
                );
              }
              if (exercises.isEmpty) {
                return Center(
                  child: Text(
                    'This lesson has no exercises yet.',
                    style: AppTypography.label(fontSize: 14),
                  ),
                );
              }

              return Column(
                children: [
                  _DeckHeader(
                    total: exercises.length,
                    index: _index,
                    lessonTitle: widget.lessonTitle,
                    onClose: () async {
                      if (await _confirmExit() && context.mounted) Navigator.of(context).pop();
                    },
                    onBack: _index == 0 ? null : _goBack,
                  ),
                  Expanded(
                    // Rebuilds the card subtree from scratch on every
                    // exercise so its deal-in animation replays — without
                    // the key, two consecutive exercises of the same type
                    // reuse one element and the tween stays finished.
                    child: KeyedSubtree(
                      key: ValueKey(_index),
                      child: _buildExercise(exercises[_index], exercises),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildExercise(LessonExercise exercise, List<LessonExercise> all) {
    // Every view forwards this to _DeckCardScaffold, which drops the ghost
    // layers once there's nothing left stacked behind the current card.
    final isLast = _index == all.length - 1;

    switch (exercise) {
      case VocabCardExercise():
        return _VocabCardView(
          exercise: exercise,
          isLast: isLast,
          onNext: () {
            _exposeToSrs(() => ref.read(srsRepositoryProvider).exposeVocabItem(exercise.vocabItemId));
            _advance(all, graded: false);
          },
        );
      case ReadingPassageExercise():
        return _ReadingPassageView(
          exercise: exercise,
          isLast: isLast,
          onNext: () {
            // Only single-ayah cards (the line-by-line cards from
            // migration 0039) are their own SRS item — a multi-ayah
            // recap/full-surah passage isn't a single reviewable unit.
            if (exercise.ayat.length == 1) {
              _exposeToSrs(
                () => ref.read(srsRepositoryProvider).exposeAyah(exercise.ayat.single.ayahId),
              );
            }
            _advance(all, graded: false);
          },
        );
      case RecallQuizExercise():
        return _RecallQuizView(
          exercise: exercise,
          isLast: isLast,
          selectedOption: _selectedQuizOption,
          answered: _quizAnswered,
          // Keyed by exercise index so the answer survives stepping back to
          // this card, rather than the card returning blank.
          onSelect: (optionIndex) => setState(() => _quizAnswers[_index] = optionIndex),
          onNext: () {
            final isCorrect = _selectedQuizOption == exercise.correctOptionIndex;
            if (exercise.testedVocabItemId != null || exercise.testedLetterId != null) {
              _exposeToSrs(() => ref.read(srsRepositoryProvider).gradeFromQuiz(
                    vocabItemId: exercise.testedVocabItemId,
                    letterId: exercise.testedLetterId,
                    isCorrect: isCorrect,
                  ));
            }
            _advance(all, graded: true, isCorrect: isCorrect);
          },
        );
      case LetterCardExercise():
        return _LetterCardView(
          exercise: exercise,
          isLast: isLast,
          onNext: () {
            _exposeToSrs(() => ref.read(srsRepositoryProvider).exposeLetter(exercise.letterId));
            _advance(all, graded: false);
          },
        );
      case DiacriticIntroExercise():
        return _DiacriticIntroView(
          exercise: exercise,
          isLast: isLast,
          onNext: () => _advance(all, graded: false),
        );
      case GrammarExplanationExercise():
        return _GrammarExplanationView(
          exercise: exercise,
          isLast: isLast,
          onNext: () => _advance(all, graded: false),
        );
      case LetterChainExercise():
        return _LetterChainView(
          exercise: exercise,
          isLast: isLast,
          onNext: () => _advance(all, graded: false),
        );
      case KnowledgeCardExercise():
        return _KnowledgeCardView(
          exercise: exercise,
          isLast: isLast,
          onNext: () => _advance(all, graded: false),
        );
      case PrayerStepExercise():
        return _PrayerStepView(
          exercise: exercise,
          isLast: isLast,
          onNext: () => _advance(all, graded: false),
        );
      case UnsupportedExercise():
        return _UnsupportedView(
          exerciseType: exercise.exerciseType,
          isLast: isLast,
          onSkip: () => _advance(all, graded: false),
        );
    }
  }
}

/// Close button, per-exercise progress dots, and a counter — the chrome
/// every exercise view shares regardless of its content.
class _DeckHeader extends StatelessWidget {
  const _DeckHeader({
    required this.total,
    required this.index,
    required this.lessonTitle,
    required this.onClose,
    required this.onBack,
  });

  final int total;
  final int index;
  final String lessonTitle;
  final VoidCallback onClose;

  /// Null on the first exercise, where there is nothing to go back to.
  /// CircleIconButton renders a disabled control for a null callback, so the
  /// row keeps its width and the progress bar does not shift sideways as the
  /// deck advances.
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screenInset,
        AppSpacing.sm,
        AppSpacing.screenInset,
        0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleIconButton(icon: Icons.close_rounded, onPressed: onClose),
              const SizedBox(width: AppSpacing.sm),
              CircleIconButton(icon: Icons.west_rounded, onPressed: onBack),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Row(
                  children: [
                    for (var i = 0; i < total; i++) ...[
                      if (i > 0) const SizedBox(width: 5),
                      Expanded(
                        child: Container(
                          height: 3,
                          decoration: BoxDecoration(
                            color: i <= index ? AppColors.brandPrimary : AppColors.borderSubtle,
                            borderRadius: BorderRadius.circular(AppRadius.pill),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Text('${index + 1}/$total', style: AppTypography.label(fontSize: 11)),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(lessonTitle.toUpperCase(), style: AppTypography.eyebrow(color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}

/// The rounded card shell every exercise renders inside, with a kind pill
/// up top and (for graded/ungraded cards alike) a Next pill pinned below
/// it — the one visual idiom every exercise type shares regardless of
/// what's inside. [nextEnabled]/[nextLabel]/[nextColor] let the quiz view
/// gate and recolor the button after grading; every other view just takes
/// the defaults.
///
/// Two faint ghost layers sit behind the card so the lesson reads as a
/// deck of exercises still to come rather than a single page — see
/// [isLast] for the one case that has nothing left to stack.
class _DeckCardScaffold extends StatelessWidget {
  const _DeckCardScaffold({
    required this.kind,
    required this.child,
    required this.onNext,
    required this.isLast,
    this.nextEnabled = true,
    this.nextLabel = 'Next',
    this.nextColor,
    this.crossAxisAlignment = CrossAxisAlignment.center,
    this.scrollable = true,
  });

  /// The deck's ghost layers, front-most first: how far each is inset from
  /// the active card's sides, how far below its top edge it starts, and how
  /// far past its bottom edge it peeks out. Off the 8px grid on purpose —
  /// the stagger is a perspective cue, not spacing, and each step back is
  /// narrower and fainter than the one in front of it.
  static const _ghosts = [
    (inset: 32.0, top: 24.0, peek: 14.0, fill: 0.05, border: 0.08),
    (inset: 38.0, top: 30.0, peek: 10.0, fill: 0.03, border: 0.06),
  ];

  final String kind;
  final Widget child;
  final VoidCallback? onNext;

  /// Whether this is the final exercise. The ghosts are a count of what's
  /// still behind the current card, so the last one shows none.
  final bool isLast;

  final bool nextEnabled;
  final String nextLabel;
  final Color? nextColor;
  final CrossAxisAlignment crossAxisAlignment;

  /// Whether the card body scrolls and centers its content. Set false for
  /// a child that already scrolls and wants the full remaining height —
  /// the diacritic grid — since nesting its own scroll view inside this
  /// one gives it unbounded height.
  final bool scrollable;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.screenInset,
              AppSpacing.lg,
              AppSpacing.screenInset,
              0,
            ),
            child: Stack(
              // The ghosts hang past the card's bottom edge, into the gap
              // above the Next pill — that overhang is the whole effect.
              clipBehavior: Clip.none,
              // Hands the active card exactly the constraints it had
              // before the Stack existed, so a scrollable: false child
              // still gets a bounded height to hand its grid. Nothing here
              // pins a height: at large text scale the card grows with the
              // content rather than clipping it, and only the ghosts —
              // pure decoration, no text — are fixed-size.
              fit: StackFit.passthrough,
              children: [
                if (!isLast)
                  for (final ghost in _ghosts.reversed)
                    Positioned(
                      left: ghost.inset,
                      right: ghost.inset,
                      top: ghost.top,
                      bottom: -ghost.peek,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: AppColors.fillSubtle.withValues(alpha: ghost.fill),
                          borderRadius: BorderRadius.circular(AppRadius.card),
                          border: Border.all(color: AppColors.borderSubtle.withValues(alpha: ghost.border)),
                        ),
                      ),
                    ),
                // Deals the card in rather than swapping it: a cut that
                // only changes the text reads as the same card being
                // rewritten, which is exactly the wrong impression when
                // the deck behind it just got one shorter. Replays per
                // exercise via the ValueKey in the parent's build().
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: 1),
                  duration: const Duration(milliseconds: 340),
                  curve: Curves.ease,
                  builder: (context, t, child) => Opacity(
                    opacity: t,
                    child: Transform.translate(offset: Offset(0, (1 - t) * AppSpacing.md), child: child),
                  ),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl, vertical: AppSpacing.xxl),
                    decoration: BoxDecoration(
                      color: AppColors.bgSurface,
                      borderRadius: BorderRadius.circular(AppRadius.card),
                      border: Border.all(color: AppColors.borderSubtle),
                      // Separates the card from the ghosts, which share its
                      // radius and would otherwise read as one flat shape.
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.4),
                          blurRadius: 44,
                          offset: const Offset(0, 20),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        StatusPill(label: kind, foreground: AppColors.brandAccent),
                        Expanded(
                          child: scrollable
                              ? LayoutBuilder(
                                  builder: (context, constraints) => SingleChildScrollView(
                                    child: ConstrainedBox(
                                      constraints: BoxConstraints(minHeight: constraints.maxHeight),
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        crossAxisAlignment: crossAxisAlignment,
                                        children: [child],
                                      ),
                                    ),
                                  ),
                                )
                              : child,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.screenInset,
            AppSpacing.lg,
            AppSpacing.screenInset,
            AppSpacing.xl,
          ),
          child: Align(
            alignment: Alignment.centerRight,
            child: nextColor == null
                ? PillButton(
                    label: nextLabel,
                    icon: Icons.east_rounded,
                    onPressed: nextEnabled ? onNext : null,
                  )
                : FilledButton(
                    onPressed: nextEnabled ? onNext : null,
                    style: FilledButton.styleFrom(
                      backgroundColor: nextColor,
                      foregroundColor: AppColors.onPrimary,
                      minimumSize: const Size(0, 50),
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                      shape: const StadiumBorder(),
                      textStyle: AppTypography.label(fontSize: 15, fontWeight: FontWeight.w600),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(nextLabel),
                        const SizedBox(width: AppSpacing.sm),
                        const Icon(Icons.east_rounded, size: 20),
                      ],
                    ),
                  ),
          ),
        ),
      ],
    );
  }
}

class _DiacriticIntroView extends StatelessWidget {
  const _DiacriticIntroView({required this.exercise, required this.onNext, required this.isLast});

  final DiacriticIntroExercise exercise;
  final VoidCallback onNext;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return _DeckCardScaffold(
      kind: 'DIACRITIC',
      onNext: onNext,
      isLast: isLast,
      // The grid scrolls itself and wants the full remaining height.
      scrollable: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: AppSpacing.lg),
          Text(exercise.nameEn, style: AppTypography.display(fontSize: 28), textAlign: TextAlign.center),
          const SizedBox(height: AppSpacing.sm),
          Text(
            exercise.soundDescription,
            style: AppTypography.label(fontSize: 15, fontWeight: FontWeight.w400, color: AppColors.textPrimary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            exercise.explanationShort,
            style: AppTypography.label(fontSize: 13),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.lg),
          const Divider(),
          const SizedBox(height: AppSpacing.md),
          Expanded(
            // A Wrap of content-sized cells rather than a GridView.
            //
            // Every grid delegate wants the cell height up front — as an
            // aspect ratio of the column width, or as an explicit extent.
            // Both are a guess about how tall rendered text will be, and
            // the aspect ratio this used to carry was wrong by over 200px
            // once the user scaled text up. Computing the extent instead
            // just moves the guess: it still has to assume each font's
            // line height, and was still short by a couple of pixels.
            //
            // A Wrap asks each cell how tall it actually is and sizes the
            // run to the tallest, so the whole class of mismatch goes
            // away. Fine for a fixed 28-cell alphabet; it lays out every
            // child eagerly, so don't reach for this on a long list.
            child: LayoutBuilder(
              builder: (context, constraints) {
                const columns = 4;
                const spacing = 16.0;
                final cellWidth =
                    (constraints.maxWidth - spacing * (columns - 1)) / columns;

                return SingleChildScrollView(
                  child: Wrap(
                    spacing: spacing,
                    runSpacing: spacing,
                    children: [
                      for (final letterForm in exercise.allLetterForms)
                        SizedBox(
                          width: cellWidth,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Neither of these is stored anywhere — see
                              // DiacriticIntroExercise's doc comment for why.
                              Text(
                                letterForm.isolatedForm + exercise.markUnicode,
                                style: AppTypography.arabic(
                                  fontSize: AppTypography.arabicCompact,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: AppSpacing.xs),
                              Text(
                                (exercise.doublesConsonant ? letterForm.baseConsonant : '') +
                                    letterForm.baseConsonant +
                                    exercise.readingSuffix,
                                textAlign: TextAlign.center,
                                style: AppTypography.label(fontSize: 11),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _LetterCardView extends StatelessWidget {
  const _LetterCardView({required this.exercise, required this.onNext, required this.isLast});

  final LetterCardExercise exercise;
  final VoidCallback onNext;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return _DeckCardScaffold(
      kind: 'LETTER',
      onNext: onNext,
      isLast: isLast,
      child: Column(
        children: [
          Text(
            exercise.isolatedForm,
            style: AppTypography.arabic(fontSize: AppTypography.arabicXL, color: AppColors.textPrimary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.lg),
          // The letter's own Arabic name (e.g. أَلِف) leads the
          // transliteration, per design-system.md Brand Principle 2 —
          // the script is the subject here, not a gloss on the Latin.
          Text(
            exercise.nameArabic,
            style: AppTypography.arabic(
              fontSize: AppTypography.arabicSmall,
              color: AppColors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.xs),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(exercise.nameTransliteration, style: AppTypography.display(fontSize: 20)),
              if (exercise.isEmphatic) ...[
                const SizedBox(width: AppSpacing.sm),
                StatusPill(label: 'heavy', foreground: AppColors.brandAccent),
              ],
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(exercise.pronunciationGuide, style: AppTypography.label(fontSize: 14), textAlign: TextAlign.center),
          const SizedBox(height: AppSpacing.xl),
          _PositionalFormsRow(exercise: exercise),
          const SizedBox(height: AppSpacing.sm),
          // Collapsed by default — makhraj is advanced phonetic detail a
          // beginner doesn't need in order to recognize the letter.
          Disclosure(
            label: 'Where is this pronounced?',
            child: Text(
              exercise.articulationPoint,
              style: AppTypography.label(fontSize: 13),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}

/// Shows how the letter's shape changes depending on where it sits in a
/// word — the Qaida book's "Letter Positions" section (docs reference:
/// migration 0008). Non-connecting letters legitimately repeat the same
/// glyph across two or more columns (see the domain doc comment on
/// LetterCardExercise) — that's not a rendering bug.
class _PositionalFormsRow extends StatelessWidget {
  const _PositionalFormsRow({required this.exercise});

  final LetterCardExercise exercise;

  @override
  Widget build(BuildContext context) {
    final forms = [
      ('Beginning', exercise.initialForm),
      ('Middle', exercise.medialForm),
      ('End', exercise.finalForm),
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        for (final (label, form) in forms)
          // Each column takes a third of the row rather than its natural
          // width: "Beginning" is the widest label and, unflexed, three of
          // them overflow the row once the user's text size grows. An
          // equal share lets the label wrap instead.
          Expanded(
            child: Column(
              children: [
                Text(form, style: AppTypography.arabic(fontSize: AppTypography.arabicSmall)),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  label,
                  textAlign: TextAlign.center,
                  style: AppTypography.label(fontSize: 11),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _VocabCardView extends StatelessWidget {
  const _VocabCardView({required this.exercise, required this.onNext, required this.isLast});

  final VocabCardExercise exercise;
  final VoidCallback onNext;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return _DeckCardScaffold(
      kind: 'VOCABULARY',
      onNext: onNext,
      isLast: isLast,
      child: Column(
        children: [
          Text(
            exercise.arabicText,
            style: AppTypography.arabic(fontSize: AppTypography.arabicMedium, color: AppColors.textPrimary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            exercise.transliteration,
            style: AppTypography.label(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.brandPrimary),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            exercise.meaningEn,
            style: AppTypography.display(fontSize: 19),
            textAlign: TextAlign.center,
          ),
          if (exercise.rootLetters != null || exercise.waznPattern != null) ...[
            const SizedBox(height: AppSpacing.lg),
            Wrap(
              spacing: AppSpacing.sm,
              alignment: WrapAlignment.center,
              children: [
                if (exercise.rootLetters != null)
                  _MetaPill(label: 'Root: ${exercise.rootLetters}'),
                if (exercise.waznPattern != null)
                  _MetaPill(label: 'Pattern: ${exercise.waznPattern}'),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _MetaPill extends StatelessWidget {
  const _MetaPill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.pill),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Text(label, style: AppTypography.label(fontSize: 11)),
    );
  }
}

class _ReadingPassageView extends StatelessWidget {
  const _ReadingPassageView({required this.exercise, required this.onNext, required this.isLast});

  final ReadingPassageExercise exercise;
  final VoidCallback onNext;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return _DeckCardScaffold(
      kind: 'READING',
      onNext: onNext,
      isLast: isLast,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < exercise.ayat.length; i++) ...[
            if (i > 0) const Divider(height: 32),
            _AyahBlock(ayah: exercise.ayat[i]),
          ],
        ],
      ),
    );
  }
}

class _AyahBlock extends StatelessWidget {
  const _AyahBlock({required this.ayah});

  final ReadingPassageAyah ayah;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          '${ayah.textDiacritized} ﴿${ayah.ayahNumber}﴾',
          style: AppTypography.arabic(fontSize: AppTypography.arabicSmall, color: AppColors.textPrimary),
          textAlign: TextAlign.right,
          textDirection: TextDirection.rtl,
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          ayah.transliteration,
          style: AppTypography.label(fontSize: 14, fontWeight: FontWeight.w400, color: AppColors.textSecondary)
              .copyWith(fontStyle: FontStyle.italic),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(ayah.translationEn, style: AppTypography.display(fontSize: 16)),
      ],
    );
  }
}

class _RecallQuizView extends StatelessWidget {
  const _RecallQuizView({
    required this.exercise,
    required this.selectedOption,
    required this.answered,
    required this.onSelect,
    required this.onNext,
    required this.isLast,
  });

  final RecallQuizExercise exercise;
  final int? selectedOption;
  final bool answered;
  final ValueChanged<int> onSelect;
  final VoidCallback onNext;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final isCorrect = selectedOption == exercise.correctOptionIndex;

    return _DeckCardScaffold(
      kind: 'QUIZ',
      onNext: onNext,
      isLast: isLast,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      nextEnabled: answered,
      nextLabel: !answered ? 'Next' : (isCorrect ? 'Correct — Next' : 'Not quite — Next'),
      nextColor: !answered ? null : (isCorrect ? AppColors.success : AppColors.error),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          MixedArabicText(
            exercise.question,
            baseStyle: AppTypography.display(fontSize: 21),
            arabicFontSize: AppTypography.arabicSmall,
          ),
          const SizedBox(height: AppSpacing.xl),
          for (var i = 0; i < exercise.options.length; i++) ...[
            _QuizOptionButton(
              label: exercise.options[i],
              state: !answered
                  ? _QuizOptionState.neutral
                  : i == exercise.correctOptionIndex
                      ? _QuizOptionState.correct
                      : i == selectedOption
                          ? _QuizOptionState.incorrect
                          : _QuizOptionState.neutral,
              onTap: answered ? null : () => onSelect(i),
            ),
            const SizedBox(height: AppSpacing.sm),
          ],
        ],
      ),
    );
  }
}

enum _QuizOptionState { neutral, correct, incorrect }

class _QuizOptionButton extends StatelessWidget {
  const _QuizOptionButton({required this.label, required this.state, required this.onTap});

  final String label;
  final _QuizOptionState state;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final color = switch (state) {
      _QuizOptionState.neutral => null,
      _QuizOptionState.correct => AppColors.success,
      _QuizOptionState.incorrect => AppColors.error,
    };

    return Material(
      color: color?.withValues(alpha: 0.12) ?? Colors.transparent,
      borderRadius: BorderRadius.circular(AppRadius.xl),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.xl),
            border: Border.all(color: color ?? AppColors.borderSubtle, width: color != null ? 1.5 : 1),
          ),
          child: Text(label, style: AppTypography.display(fontSize: 16)),
        ),
      ),
    );
  }
}

class _GrammarExplanationView extends StatelessWidget {
  const _GrammarExplanationView({required this.exercise, required this.onNext, required this.isLast});

  final GrammarExplanationExercise exercise;
  final VoidCallback onNext;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return _DeckCardScaffold(
      kind: 'GRAMMAR',
      onNext: onNext,
      isLast: isLast,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(exercise.titleEn, style: AppTypography.display(fontSize: 24), textAlign: TextAlign.center),
          const SizedBox(height: AppSpacing.md),
          Text(
            exercise.explanationShort,
            style: AppTypography.label(fontSize: 15, fontWeight: FontWeight.w400, color: AppColors.textPrimary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.xs),
          Disclosure(
            label: 'Learn more',
            child: Text(
              exercise.explanationFull,
              style: AppTypography.label(fontSize: 13),
              textAlign: TextAlign.center,
            ),
          ),
          if (exercise.exampleAyahText != null) ...[
            const SizedBox(height: AppSpacing.lg),
            const Divider(),
            const SizedBox(height: AppSpacing.md),
            Text('EXAMPLE', style: AppTypography.eyebrow(color: AppColors.textSecondary)),
            const SizedBox(height: AppSpacing.sm),
            Text(
              exercise.exampleAyahText!,
              style: AppTypography.arabic(fontSize: AppTypography.arabicSmall, color: AppColors.textPrimary),
              textAlign: TextAlign.right,
              textDirection: TextDirection.rtl,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              exercise.exampleAyahTransliteration!,
              style: AppTypography.label(fontSize: 13, fontWeight: FontWeight.w400).copyWith(fontStyle: FontStyle.italic),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(exercise.exampleAyahTranslation!, style: AppTypography.display(fontSize: 15)),
          ],
        ],
      ),
    );
  }
}

/// Shows a short unvocalized letter chain (e.g. "كتب") joined together,
/// then the same letters broken apart underneath (isolated forms, right
/// to left, same reading order) — the same font/shaping engine renders
/// both from the same plain characters, so nothing here needs its own
/// stored "isolated form" data (see LetterChainExercise's doc comment).
class _LetterChainView extends StatelessWidget {
  const _LetterChainView({required this.exercise, required this.onNext, required this.isLast});

  final LetterChainExercise exercise;
  final VoidCallback onNext;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final letters = exercise.chainText.split('');

    return _DeckCardScaffold(
      kind: 'LETTER CHAIN',
      onNext: onNext,
      isLast: isLast,
      child: Column(
        children: [
          Text(
            exercise.chainText,
            style: AppTypography.arabic(fontSize: AppTypography.arabicLarge, color: AppColors.textPrimary),
            textAlign: TextAlign.center,
            textDirection: TextDirection.rtl,
          ),
          const SizedBox(height: AppSpacing.xl),
          Text('Same letters, joined together:', style: AppTypography.label(fontSize: 13)),
          const SizedBox(height: AppSpacing.md),
          Directionality(
            textDirection: TextDirection.rtl,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (var i = 0; i < letters.length; i++) ...[
                  if (i > 0)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                      child: Text('+', style: AppTypography.display(fontSize: 22)),
                    ),
                  Text(
                    letters[i],
                    style: AppTypography.arabic(fontSize: AppTypography.arabicCompact, color: AppColors.textPrimary),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Near-identical to _GrammarExplanationView minus the example-ayah
/// section (KnowledgeCardExercise has no such concept — see its domain
/// doc comment on why this is a separate type rather than reusing
/// grammar_explanation).
class _KnowledgeCardView extends StatelessWidget {
  const _KnowledgeCardView({required this.exercise, required this.onNext, required this.isLast});

  final KnowledgeCardExercise exercise;
  final VoidCallback onNext;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return _DeckCardScaffold(
      kind: 'KNOWLEDGE',
      onNext: onNext,
      isLast: isLast,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(exercise.titleEn, style: AppTypography.display(fontSize: 24), textAlign: TextAlign.center),
          const SizedBox(height: AppSpacing.md),
          Text(
            exercise.explanationShort,
            style: AppTypography.label(fontSize: 15, fontWeight: FontWeight.w400, color: AppColors.textPrimary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.xs),
          Disclosure(
            label: 'Learn more',
            child: Text(
              exercise.explanationFull,
              style: AppTypography.label(fontSize: 13),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}

/// One step of a physical+verbal procedure (Wudu, Salah): an
/// instruction, and — for steps that involve speech — an Arabic phrase
/// card with its transliteration, translation, and how many times to
/// repeat it. The Arabic card only renders when there's actually
/// something to say (most Wudu steps are pure action).
class _PrayerStepView extends StatelessWidget {
  const _PrayerStepView({required this.exercise, required this.onNext, required this.isLast});

  final PrayerStepExercise exercise;
  final VoidCallback onNext;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return _DeckCardScaffold(
      kind: 'STEP ${exercise.sequenceOrder}',
      onNext: onNext,
      isLast: isLast,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            exercise.instructionEn,
            style: AppTypography.display(fontSize: 20),
            textAlign: TextAlign.center,
          ),
          if (exercise.arabicText != null) ...[
            const SizedBox(height: AppSpacing.xl),
            Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: AppColors.fillSubtle,
                borderRadius: BorderRadius.circular(AppRadius.lg),
                border: Border.all(color: AppColors.borderSubtle),
              ),
              child: Column(
                children: [
                  if (exercise.repeatCount != null) ...[
                    StatusPill(label: 'x${exercise.repeatCount}', foreground: AppColors.brandAccent),
                    const SizedBox(height: AppSpacing.md),
                  ],
                  Text(
                    exercise.arabicText!,
                    style: AppTypography.arabic(fontSize: AppTypography.arabicSmall, color: AppColors.textPrimary),
                    textAlign: TextAlign.center,
                    textDirection: TextDirection.rtl,
                  ),
                  if (exercise.transliteration != null) ...[
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      exercise.transliteration!,
                      style: AppTypography.label(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.brandPrimary)
                          .copyWith(fontStyle: FontStyle.italic),
                      textAlign: TextAlign.center,
                    ),
                  ],
                  if (exercise.translationEn != null) ...[
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      exercise.translationEn!,
                      style: AppTypography.label(fontSize: 13),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ],
              ),
            ),
          ] else if (exercise.repeatCount != null) ...[
            const SizedBox(height: AppSpacing.lg),
            Center(child: StatusPill(label: 'x${exercise.repeatCount}', foreground: AppColors.brandAccent)),
          ],
        ],
      ),
    );
  }
}

class _UnsupportedView extends StatelessWidget {
  const _UnsupportedView({required this.exerciseType, required this.onSkip, required this.isLast});

  final String exerciseType;
  final VoidCallback onSkip;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return _DeckCardScaffold(
      kind: 'COMING SOON',
      onNext: onSkip,
      isLast: isLast,
      nextLabel: 'Skip',
      child: Text(
        '"$exerciseType" exercises aren\'t built in the app yet.',
        textAlign: TextAlign.center,
        style: AppTypography.label(fontSize: 14),
      ),
    );
  }
}
