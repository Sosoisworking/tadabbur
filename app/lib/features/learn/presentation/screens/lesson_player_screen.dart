import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_semantic_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/completion_card.dart';
import '../../../../shared/widgets/mixed_arabic_text.dart';
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
  int _correct = 0;
  int _total = 0;
  bool _completed = false;
  int? _lessonAttemptId;

  int? _selectedQuizOption;
  bool _quizAnswered = false;

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

    if (graded) {
      _total++;
      if (isCorrect) _correct++;
    }

    // Errors here are surfaced, not swallowed like the SRS fire-and-forget
    // calls above — a failed exercise_attempt/lesson_attempt write is a
    // real "your progress didn't save" situation the user should know
    // about and can retry, not a low-stakes background update. This is
    // also what would have turned the earlier stale-exercise-id crash
    // (fixed by making exercisesForLessonProvider autoDispose) into a
    // recoverable message instead of an uncaught exception dump.
    try {
      final attemptId = _lessonAttemptId;
      if (attemptId != null) {
        await ref.read(lessonRepositoryProvider).recordExerciseAttempt(
              lessonAttemptId: attemptId,
              exerciseId: exercise.id,
              isCorrect: isCorrect,
            );
      }

      if (_index + 1 >= exercises.length) {
        await _finish(attemptId);
      } else {
        setState(() {
          _index++;
          _selectedQuizOption = null;
          _quizAnswered = false;
        });
      }
    } catch (e) {
      if (graded) {
        _total--;
        if (isCorrect) _correct--;
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not save your progress. Please try again.\n$e')),
        );
      }
    }
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
        appBar: AppBar(title: Text(widget.lessonTitle)),
        body: SafeArea(
          child: exercisesAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => Center(child: Text('Could not load this lesson.\n$error', textAlign: TextAlign.center)),
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
              if (exercises.isEmpty) return const Center(child: Text('This lesson has no exercises yet.'));

              return Column(
                children: [
                  LinearProgressIndicator(value: (_index + 1) / exercises.length),
                  Expanded(child: _buildExercise(exercises[_index], exercises)),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildExercise(LessonExercise exercise, List<LessonExercise> all) {
    switch (exercise) {
      case VocabCardExercise():
        return _VocabCardView(
          exercise: exercise,
          onNext: () {
            _exposeToSrs(() => ref.read(srsRepositoryProvider).exposeVocabItem(exercise.vocabItemId));
            _advance(all, graded: false);
          },
        );
      case ReadingPassageExercise():
        return _ReadingPassageView(
          exercise: exercise,
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
          selectedOption: _selectedQuizOption,
          answered: _quizAnswered,
          onSelect: (optionIndex) => setState(() {
            _selectedQuizOption = optionIndex;
            _quizAnswered = true;
          }),
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
          onNext: () {
            _exposeToSrs(() => ref.read(srsRepositoryProvider).exposeLetter(exercise.letterId));
            _advance(all, graded: false);
          },
        );
      case DiacriticIntroExercise():
        return _DiacriticIntroView(
          exercise: exercise,
          onNext: () => _advance(all, graded: false),
        );
      case GrammarExplanationExercise():
        return _GrammarExplanationView(
          exercise: exercise,
          onNext: () => _advance(all, graded: false),
        );
      case LetterChainExercise():
        return _LetterChainView(
          exercise: exercise,
          onNext: () => _advance(all, graded: false),
        );
      case KnowledgeCardExercise():
        return _KnowledgeCardView(
          exercise: exercise,
          onNext: () => _advance(all, graded: false),
        );
      case PrayerStepExercise():
        return _PrayerStepView(
          exercise: exercise,
          onNext: () => _advance(all, graded: false),
        );
      case UnsupportedExercise():
        return _UnsupportedView(
          exerciseType: exercise.exerciseType,
          onSkip: () => _advance(all, graded: false),
        );
    }
  }
}

class _DiacriticIntroView extends StatelessWidget {
  const _DiacriticIntroView({required this.exercise, required this.onNext});

  final DiacriticIntroExercise exercise;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(AppSpacing.xl, AppSpacing.xl, AppSpacing.xl, AppSpacing.sm),
          child: Column(
            children: [
              Text(exercise.nameEn, style: AppTypography.accent(fontSize: 28, fontWeight: FontWeight.w600)),
              const SizedBox(height: AppSpacing.sm),
              Text(exercise.soundDescription, style: Theme.of(context).textTheme.bodyLarge, textAlign: TextAlign.center),
              const SizedBox(height: AppSpacing.sm),
              Text(exercise.explanationShort, style: Theme.of(context).textTheme.bodyMedium, textAlign: TextAlign.center),
            ],
          ),
        ),
        const Divider(height: 24),
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              mainAxisSpacing: 16,
              childAspectRatio: 0.8,
            ),
            itemCount: exercise.allLetterForms.length,
            itemBuilder: (context, index) {
              final letterForm = exercise.allLetterForms[index];
              // Neither of these is stored anywhere — see
              // DiacriticIntroExercise's doc comment for why.
              final combined = letterForm.isolatedForm + exercise.markUnicode;
              final reading = (exercise.doublesConsonant ? letterForm.baseConsonant : '') +
                  letterForm.baseConsonant +
                  exercise.readingSuffix;
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(combined, style: AppTypography.arabic(fontSize: AppTypography.arabicCompact)),
                  const SizedBox(height: AppSpacing.xs),
                  Text(reading, style: Theme.of(context).textTheme.bodySmall),
                ],
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: FilledButton(onPressed: onNext, child: const Text('Next')),
        ),
      ],
    );
  }
}

class _LetterCardView extends StatelessWidget {
  const _LetterCardView({required this.exercise, required this.onNext});

  final LetterCardExercise exercise;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(exercise.isolatedForm, style: AppTypography.arabic(fontSize: AppTypography.arabicXL), textAlign: TextAlign.center),
          const SizedBox(height: AppSpacing.lg),
          Text(exercise.nameArabic, style: AppTypography.arabic(fontSize: AppTypography.arabicSmall), textAlign: TextAlign.center),
          const SizedBox(height: AppSpacing.sm),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(exercise.nameTransliteration, style: Theme.of(context).textTheme.titleMedium),
              if (exercise.isEmphatic) ...[
                const SizedBox(width: AppSpacing.sm),
                Chip(
                  label: const Text('heavy'),
                  visualDensity: VisualDensity.compact,
                  backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
                ),
              ],
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(exercise.pronunciationGuide, style: Theme.of(context).textTheme.bodyLarge, textAlign: TextAlign.center),
          const SizedBox(height: AppSpacing.xl),
          _PositionalFormsRow(exercise: exercise),
          const SizedBox(height: AppSpacing.lg),
          // Collapsed by default — makhraj detail is advanced phonetic
          // information a beginner (this scaffold's Aisha persona)
          // doesn't need to see before recognizing the letter itself;
          // ExpansionTile manages its own open/closed state, so this
          // stays a StatelessWidget rather than needing to become
          // Stateful just for one optional section.
          Theme(
            data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
            child: ExpansionTile(
              title: const Text('Where is this pronounced?'),
              tilePadding: EdgeInsets.zero,
              childrenPadding: const EdgeInsets.only(bottom: AppSpacing.sm),
              children: [
                Text(
                  exercise.articulationPoint,
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          FilledButton(onPressed: onNext, child: const Text('Next')),
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
          Column(
            children: [
              Text(form, style: AppTypography.arabic(fontSize: AppTypography.arabicSmall)),
              const SizedBox(height: AppSpacing.xs),
              Text(label, style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
      ],
    );
  }
}

class _VocabCardView extends StatelessWidget {
  const _VocabCardView({required this.exercise, required this.onNext});

  final VocabCardExercise exercise;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(exercise.arabicText, style: AppTypography.arabic(fontSize: AppTypography.arabicMedium), textAlign: TextAlign.center),
          const SizedBox(height: AppSpacing.lg),
          Text(exercise.transliteration, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: AppSpacing.sm),
          Text(exercise.meaningEn, style: Theme.of(context).textTheme.bodyLarge, textAlign: TextAlign.center),
          if (exercise.rootLetters != null) ...[
            const SizedBox(height: AppSpacing.lg),
            Text('Root: ${exercise.rootLetters}', style: Theme.of(context).textTheme.bodySmall),
          ],
          if (exercise.waznPattern != null)
            Text('Pattern: ${exercise.waznPattern}', style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: AppSpacing.xxl),
          FilledButton(onPressed: onNext, child: const Text('Next')),
        ],
      ),
    );
  }
}

class _ReadingPassageView extends StatelessWidget {
  const _ReadingPassageView({required this.exercise, required this.onNext});

  final ReadingPassageExercise exercise;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.all(AppSpacing.xl),
            itemCount: exercise.ayat.length,
            separatorBuilder: (_, _) => const Divider(height: 32),
            itemBuilder: (context, index) {
              final ayah = exercise.ayat[index];
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    '${ayah.textDiacritized} ﴿${ayah.ayahNumber}﴾',
                    style: AppTypography.arabic(fontSize: AppTypography.arabicSmall),
                    textAlign: TextAlign.right,
                    textDirection: TextDirection.rtl,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    ayah.transliteration,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontStyle: FontStyle.italic),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(ayah.translationEn, style: Theme.of(context).textTheme.bodyMedium),
                ],
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: FilledButton(onPressed: onNext, child: const Text('Next')),
        ),
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
  });

  final RecallQuizExercise exercise;
  final int? selectedOption;
  final bool answered;
  final ValueChanged<int> onSelect;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final success = Theme.of(context).extension<AppSemanticColors>()!.success;

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          MixedArabicText(
            exercise.question,
            baseStyle: Theme.of(context).textTheme.titleLarge,
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
            const SizedBox(height: AppSpacing.md),
          ],
          const Spacer(),
          if (answered)
            FilledButton(
              onPressed: onNext,
              style: FilledButton.styleFrom(
                backgroundColor: selectedOption == exercise.correctOptionIndex ? success : scheme.error,
              ),
              child: Text(selectedOption == exercise.correctOptionIndex ? 'Correct — Next' : 'Not quite — Next'),
            ),
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
    final scheme = Theme.of(context).colorScheme;
    // "Correct" used to reuse scheme.primary — the same color as every
    // primary button/nav element in the app, not a distinct feedback
    // signal. The dedicated success token (docs/design-system.md
    // state.success) makes "you got this right" its own color, separate
    // from "this is a primary action."
    final success = Theme.of(context).extension<AppSemanticColors>()!.success;
    final color = switch (state) {
      _QuizOptionState.neutral => null,
      _QuizOptionState.correct => success,
      _QuizOptionState.incorrect => scheme.error,
    };

    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.all(AppSpacing.lg),
        side: color != null ? BorderSide(color: color, width: 2) : null,
      ),
      child: Text(label),
    );
  }
}

class _GrammarExplanationView extends StatelessWidget {
  const _GrammarExplanationView({required this.exercise, required this.onNext});

  final GrammarExplanationExercise exercise;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            exercise.titleEn,
            style: AppTypography.accent(fontSize: 26, fontWeight: FontWeight.w600),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(exercise.explanationShort, style: Theme.of(context).textTheme.bodyLarge, textAlign: TextAlign.center),
          const SizedBox(height: AppSpacing.sm),
          Theme(
            data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
            child: ExpansionTile(
              title: const Text('Learn more'),
              tilePadding: EdgeInsets.zero,
              childrenPadding: const EdgeInsets.only(bottom: AppSpacing.sm),
              children: [
                Text(exercise.explanationFull, style: Theme.of(context).textTheme.bodyMedium),
              ],
            ),
          ),
          if (exercise.exampleAyahText != null) ...[
            const SizedBox(height: AppSpacing.sm),
            const Divider(),
            const SizedBox(height: AppSpacing.sm),
            Text('Example', style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: AppSpacing.sm),
            Text(
              exercise.exampleAyahText!,
              style: AppTypography.arabic(fontSize: AppTypography.arabicSmall),
              textAlign: TextAlign.right,
              textDirection: TextDirection.rtl,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              exercise.exampleAyahTransliteration!,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontStyle: FontStyle.italic),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(exercise.exampleAyahTranslation!, style: Theme.of(context).textTheme.bodyMedium),
          ],
          const SizedBox(height: AppSpacing.xxl),
          FilledButton(onPressed: onNext, child: const Text('Next')),
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
  const _LetterChainView({required this.exercise, required this.onNext});

  final LetterChainExercise exercise;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final letters = exercise.chainText.split('');

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            exercise.chainText,
            style: AppTypography.arabic(fontSize: AppTypography.arabicLarge),
            textAlign: TextAlign.center,
            textDirection: TextDirection.rtl,
          ),
          const SizedBox(height: AppSpacing.xl),
          Text('Same letters, joined together:', style: Theme.of(context).textTheme.bodyMedium),
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
                      child: Text('+', style: Theme.of(context).textTheme.titleLarge),
                    ),
                  Text(letters[i], style: AppTypography.arabic(fontSize: AppTypography.arabicCompact)),
                ],
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xxl),
          FilledButton(onPressed: onNext, child: const Text('Next')),
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
  const _KnowledgeCardView({required this.exercise, required this.onNext});

  final KnowledgeCardExercise exercise;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            exercise.titleEn,
            style: AppTypography.accent(fontSize: 26, fontWeight: FontWeight.w600),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(exercise.explanationShort, style: Theme.of(context).textTheme.bodyLarge, textAlign: TextAlign.center),
          const SizedBox(height: AppSpacing.sm),
          Theme(
            data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
            child: ExpansionTile(
              title: const Text('Learn more'),
              tilePadding: EdgeInsets.zero,
              childrenPadding: const EdgeInsets.only(bottom: AppSpacing.sm),
              children: [
                Text(exercise.explanationFull, style: Theme.of(context).textTheme.bodyMedium),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xxl),
          FilledButton(onPressed: onNext, child: const Text('Next')),
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
  const _PrayerStepView({required this.exercise, required this.onNext});

  final PrayerStepExercise exercise;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Step ${exercise.sequenceOrder}',
            style: Theme.of(context).textTheme.labelLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            exercise.instructionEn,
            style: Theme.of(context).textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
          if (exercise.arabicText != null) ...[
            const SizedBox(height: AppSpacing.xl),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  children: [
                    if (exercise.repeatCount != null) ...[
                      Chip(
                        label: Text('x${exercise.repeatCount}'),
                        visualDensity: VisualDensity.compact,
                        backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
                      ),
                      const SizedBox(height: AppSpacing.md),
                    ],
                    Text(
                      exercise.arabicText!,
                      style: AppTypography.arabic(fontSize: AppTypography.arabicSmall),
                      textAlign: TextAlign.center,
                      textDirection: TextDirection.rtl,
                    ),
                    if (exercise.transliteration != null) ...[
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        exercise.transliteration!,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(fontStyle: FontStyle.italic),
                        textAlign: TextAlign.center,
                      ),
                    ],
                    if (exercise.translationEn != null) ...[
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        exercise.translationEn!,
                        style: Theme.of(context).textTheme.bodyMedium,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ] else if (exercise.repeatCount != null) ...[
            const SizedBox(height: AppSpacing.lg),
            Center(
              child: Chip(
                label: Text('x${exercise.repeatCount}'),
                visualDensity: VisualDensity.compact,
                backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.xxl),
          FilledButton(onPressed: onNext, child: const Text('Next')),
        ],
      ),
    );
  }
}

class _UnsupportedView extends StatelessWidget {
  const _UnsupportedView({required this.exerciseType, required this.onSkip});

  final String exerciseType;
  final VoidCallback onSkip;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '"$exerciseType" exercises aren\'t built in the app yet.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: AppSpacing.lg),
            FilledButton(onPressed: onSkip, child: const Text('Skip')),
          ],
        ),
      ),
    );
  }
}
