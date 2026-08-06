/// One exercise within a lesson. Sealed so the lesson player (see
/// presentation/screens/lesson_player_screen.dart) can exhaustively switch
/// over every known type at compile time — adding a new exercise type to
/// the app forces every switch site to be updated, rather than silently
/// falling through.
///
/// vocab_card, reading_passage, recall_quiz, and letter_card are backed
/// by real content right now (docs/feature-specs.md's other exercise
/// types — grammar_explanation, listening_drill, pronunciation_recording,
/// mastery_challenge — land in later milestones per
/// docs/implementation-plan.md). Anything else resolves to
/// [UnsupportedExercise], which the player skips visibly rather than
/// crashing on unrecognized content.
sealed class LessonExercise {
  const LessonExercise({required this.id, required this.sequenceOrder});

  final int id;
  final int sequenceOrder;
}

class VocabCardExercise extends LessonExercise {
  const VocabCardExercise({
    required super.id,
    required super.sequenceOrder,
    required this.vocabItemId,
    required this.arabicText,
    required this.transliteration,
    required this.meaningEn,
    this.rootLetters,
    this.waznPattern,
  });

  /// Needed to enter this item into the user's SRS review queue
  /// (docs/feature-specs.md §3) once they've seen it — not just for
  /// display.
  final int vocabItemId;
  final String arabicText;
  final String transliteration;
  final String meaningEn;
  final String? rootLetters;
  final String? waznPattern;
}

class ReadingPassageAyah {
  const ReadingPassageAyah({
    required this.ayahNumber,
    required this.textDiacritized,
    required this.translationEn,
  });

  final int ayahNumber;
  final String textDiacritized;
  final String translationEn;
}

class ReadingPassageExercise extends LessonExercise {
  const ReadingPassageExercise({
    required super.id,
    required super.sequenceOrder,
    required this.ayat,
  });

  final List<ReadingPassageAyah> ayat;
}

class RecallQuizExercise extends LessonExercise {
  const RecallQuizExercise({
    required super.id,
    required super.sequenceOrder,
    required this.question,
    required this.options,
    required this.correctOptionIndex,
  });

  final String question;
  final List<String> options;
  final int correctOptionIndex;
}

/// The letter-recognition primer content (docs/feature-specs.md §1) —
/// deliberately its own type rather than reusing VocabCardExercise, since
/// letters aren't vocabulary (no root/pattern) and the placement test
/// treats script literacy as an axis distinct from vocabulary knowledge.
class LetterCardExercise extends LessonExercise {
  const LetterCardExercise({
    required super.id,
    required super.sequenceOrder,
    required this.letterId,
    required this.isolatedForm,
    required this.nameArabic,
    required this.nameTransliteration,
    required this.pronunciationGuide,
  });

  /// Needed to enter this letter into the user's SRS review queue
  /// (docs/feature-specs.md §3) once they've seen it — not just for
  /// display.
  final int letterId;
  final String isolatedForm;
  final String nameArabic;
  final String nameTransliteration;
  final String pronunciationGuide;
}

class UnsupportedExercise extends LessonExercise {
  const UnsupportedExercise({
    required super.id,
    required super.sequenceOrder,
    required this.exerciseType,
  });

  final String exerciseType;
}
