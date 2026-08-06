import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_typography.dart';
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

  /// Fire-and-forget: entering an item into the SRS queue shouldn't add
  /// latency to tapping "Next," and a transient failure here isn't worth
  /// interrupting the lesson over — the item just won't show up for
  /// review yet, which is recoverable (it'll be exposed again next time
  /// this exercise is seen).
  void _exposeToSrs(Future<void> Function() expose) {
    expose().catchError((_) {});
  }

  Future<void> _advance(List<LessonExercise> exercises, {required bool graded, bool isCorrect = true}) async {
    final exercise = exercises[_index];

    if (graded) {
      _total++;
      if (isCorrect) _correct++;
    }

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
              if (_completed) return _CompletionView(correct: _correct, total: _total);
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
          onNext: () => _advance(all, graded: false),
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
          onNext: () => _advance(
            all,
            graded: true,
            isCorrect: _selectedQuizOption == exercise.correctOptionIndex,
          ),
        );
      case LetterCardExercise():
        return _LetterCardView(
          exercise: exercise,
          onNext: () {
            _exposeToSrs(() => ref.read(srsRepositoryProvider).exposeLetter(exercise.letterId));
            _advance(all, graded: false);
          },
        );
      case UnsupportedExercise():
        return _UnsupportedView(
          exerciseType: exercise.exerciseType,
          onSkip: () => _advance(all, graded: false),
        );
    }
  }
}

class _LetterCardView extends StatelessWidget {
  const _LetterCardView({required this.exercise, required this.onNext});

  final LetterCardExercise exercise;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(exercise.isolatedForm, style: AppTypography.arabic(fontSize: 96), textAlign: TextAlign.center),
          const SizedBox(height: 16),
          Text(exercise.nameArabic, style: AppTypography.arabic(fontSize: 28), textAlign: TextAlign.center),
          const SizedBox(height: 8),
          Text(exercise.nameTransliteration, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Text(exercise.pronunciationGuide, style: Theme.of(context).textTheme.bodyLarge, textAlign: TextAlign.center),
          const SizedBox(height: 32),
          FilledButton(onPressed: onNext, child: const Text('Next')),
        ],
      ),
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
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(exercise.arabicText, style: AppTypography.arabic(fontSize: 48), textAlign: TextAlign.center),
          const SizedBox(height: 16),
          Text(exercise.transliteration, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Text(exercise.meaningEn, style: Theme.of(context).textTheme.bodyLarge, textAlign: TextAlign.center),
          if (exercise.rootLetters != null) ...[
            const SizedBox(height: 16),
            Text('Root: ${exercise.rootLetters}', style: Theme.of(context).textTheme.bodySmall),
          ],
          if (exercise.waznPattern != null)
            Text('Pattern: ${exercise.waznPattern}', style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 32),
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
            padding: const EdgeInsets.all(24),
            itemCount: exercise.ayat.length,
            separatorBuilder: (_, _) => const Divider(height: 32),
            itemBuilder: (context, index) {
              final ayah = exercise.ayat[index];
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    '${ayah.textDiacritized} ﴿${ayah.ayahNumber}﴾',
                    style: AppTypography.arabic(fontSize: 28),
                    textAlign: TextAlign.right,
                    textDirection: TextDirection.rtl,
                  ),
                  const SizedBox(height: 8),
                  Text(ayah.translationEn, style: Theme.of(context).textTheme.bodyMedium),
                ],
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
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

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          MixedArabicText(
            exercise.question,
            baseStyle: Theme.of(context).textTheme.titleLarge,
            arabicFontSize: 32,
          ),
          const SizedBox(height: 24),
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
            const SizedBox(height: 12),
          ],
          const Spacer(),
          if (answered)
            FilledButton(
              onPressed: onNext,
              style: FilledButton.styleFrom(
                backgroundColor: selectedOption == exercise.correctOptionIndex ? scheme.primary : scheme.error,
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
    final color = switch (state) {
      _QuizOptionState.neutral => null,
      _QuizOptionState.correct => scheme.primary,
      _QuizOptionState.incorrect => scheme.error,
    };

    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.all(16),
        side: color != null ? BorderSide(color: color, width: 2) : null,
      ),
      child: Text(label),
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
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '"$exerciseType" exercises aren\'t built in the app yet.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            FilledButton(onPressed: onSkip, child: const Text('Skip')),
          ],
        ),
      ),
    );
  }
}

class _CompletionView extends StatelessWidget {
  const _CompletionView({required this.correct, required this.total});

  final int correct;
  final int total;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle_rounded, size: 64, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 16),
            Text('Lesson complete', style: AppTypography.accent(fontSize: 28, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            if (total > 0) Text('$correct / $total correct'),
            Text('+${correct * 10} XP'),
            const SizedBox(height: 32),
            FilledButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Done')),
          ],
        ),
      ),
    );
  }
}
