/// One exercise within a lesson. Sealed so the lesson player (see
/// presentation/screens/lesson_player_screen.dart) can exhaustively switch
/// over every known type at compile time — adding a new exercise type to
/// the app forces every switch site to be updated, rather than silently
/// falling through.
///
/// vocab_card, reading_passage, recall_quiz, letter_card,
/// diacritic_intro, grammar_explanation, letter_chain, knowledge_card,
/// and prayer_step are backed by real content right now
/// (docs/feature-specs.md's other exercise types — listening_drill,
/// pronunciation_recording, mastery_challenge — land in later
/// milestones per docs/implementation-plan.md). Anything else resolves
/// to [UnsupportedExercise], which the player skips visibly rather
/// than crashing on unrecognized content.
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
    this.testedVocabItemId,
    this.testedLetterId,
  });

  /// When set, answering this quiz (right or wrong) feeds directly into
  /// that item's SRS schedule via SrsRepository.gradeFromQuiz — a wrong
  /// answer resets its spacing, not just leaves it at whatever passive
  /// exposure set it to. Both nullable and mutually optional: not every
  /// quiz question necessarily tests one single trackable item.
  final int? testedVocabItemId;
  final int? testedLetterId;

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
    required this.initialForm,
    required this.medialForm,
    required this.finalForm,
    required this.isEmphatic,
    required this.nameArabic,
    required this.nameTransliteration,
    required this.pronunciationGuide,
    required this.articulationPoint,
  });

  /// Needed to enter this letter into the user's SRS review queue
  /// (docs/feature-specs.md §3) once they've seen it — not just for
  /// display.
  final int letterId;
  final String isolatedForm;

  /// Positional forms — non-connecting letters (ا د ذ ر ز و) have
  /// initialForm == isolatedForm and medialForm == finalForm; that's
  /// linguistically correct, not a data gap (see migration 0008).
  final String initialForm;
  final String medialForm;
  final String finalForm;

  /// One of the 7 "heavy"/emphatic letters (خ ص ض ط ظ غ ق) pronounced
  /// with a full mouth — per the Qaida book's own framing, this is
  /// worth surfacing right on the letter card, not buried in a later
  /// Tajweed-only lesson.
  final bool isEmphatic;

  final String nameArabic;
  final String nameTransliteration;
  final String pronunciationGuide;

  /// Makhraj — where in the mouth/throat this letter is articulated
  /// (docs/database-schema.md migration 0017). Shown as secondary,
  /// on-demand detail, not the first thing a beginner sees — this is
  /// advanced phonetic detail, not needed to start recognizing letters.
  final String articulationPoint;
}

/// One grid cell in a [DiacriticIntroExercise]: a letter's isolated form
/// plus its base consonant sound (e.g. "B" for ب), so the UI can show a
/// pronunciation label under the combined glyph, not just the Arabic on
/// its own (docs/database-schema.md migration 0013).
class DiacriticLetterForm {
  const DiacriticLetterForm({required this.isolatedForm, required this.baseConsonant});

  final String isolatedForm;
  final String baseConsonant;
}

/// Introduces one vowel mark (Fathah/Kasrah/Dhammah, ...) and shows it
/// applied across every letter for reading practice. Combined glyphs
/// (e.g. "بَ") are computed as `isolatedForm + markUnicode`, and reading
/// labels (e.g. "Ba") as `baseConsonant + readingSuffix` — neither is
/// precomputed and stored; the mark is a real Unicode combining
/// character and the reading is pure string concatenation, so there's
/// nothing here with an independent existence worth duplicating in the
/// database.
class DiacriticIntroExercise extends LessonExercise {
  const DiacriticIntroExercise({
    required super.id,
    required super.sequenceOrder,
    required this.nameEn,
    required this.markUnicode,
    required this.placement,
    required this.soundDescription,
    required this.explanationShort,
    required this.readingSuffix,
    this.doublesConsonant = false,
    required this.allLetterForms,
  });

  final String nameEn;
  final String markUnicode;
  final String placement;
  final String soundDescription;
  final String explanationShort;
  final String readingSuffix;

  /// True only for Shaddah: the base consonant is pronounced twice
  /// (Saakin, then again with a harakah), so the reading is
  /// `baseConsonant + baseConsonant + readingSuffix` (e.g. "Bba"), not
  /// just `baseConsonant + readingSuffix` — the first mark that doesn't
  /// fit the plain "append a suffix" pattern every other diacritic uses.
  final bool doublesConsonant;

  final List<DiacriticLetterForm> allLetterForms;
}

/// A single-concept explanation — for rules that apply to one specific
/// case (e.g. how the ل in "Allah" is pronounced, or waqf/stop signs at
/// the end of an ayah) rather than systematically across all 28 letters
/// the way every other exercise type in this app does. That's exactly
/// why this is its own type instead of forcing the content into
/// DiacriticIntroExercise's 28-letter-grid shape.
class GrammarExplanationExercise extends LessonExercise {
  const GrammarExplanationExercise({
    required super.id,
    required super.sequenceOrder,
    required this.titleEn,
    required this.explanationShort,
    required this.explanationFull,
    this.exampleAyahText,
    this.exampleAyahTranslation,
  });

  final String titleEn;
  final String explanationShort;
  final String explanationFull;

  /// Both null or both non-null — an example ayah is optional context,
  /// not every grammar point needs one.
  final String? exampleAyahText;
  final String? exampleAyahTranslation;
}

/// A short, unvocalized (no diacritics) chain of 2-3 real letters joined
/// together — the stepping stone between single letters (LetterCard)
/// and full vocalized text (ReadingPassage). Pure shape recognition:
/// no sound is attached, since without vowel marks these aren't
/// actually pronounceable.
class LetterChainExercise extends LessonExercise {
  const LetterChainExercise({
    required super.id,
    required super.sequenceOrder,
    required this.chainText,
  });

  /// Plain Arabic letters, e.g. "كتب". The per-letter breakdown shown
  /// underneath isn't stored separately — every Arabic consonant is a
  /// single Unicode code point regardless of position, so splitting
  /// this string into characters and rendering each alone (isolated
  /// form) or together (joined form) is the same underlying text; the
  /// font's shaping engine handles the rest.
  final String chainText;
}

/// A general "explain a concept" card — structurally identical to
/// [GrammarExplanationExercise] (title, short/full explanation) but
/// deliberately a separate type: grammar_explanation is scoped to
/// Quranic Arabic reading/language (nahw/sarf/tajweed/script), while
/// this backs practical worship content (e.g. "The Importance of
/// Wudu") that has nothing to do with the language track. No example
/// ayah slot — that concept doesn't apply to fiqh content the way it
/// does to a grammar point illustrated by a Quranic phrase.
class KnowledgeCardExercise extends LessonExercise {
  const KnowledgeCardExercise({
    required super.id,
    required super.sequenceOrder,
    required this.titleEn,
    required this.explanationShort,
    required this.explanationFull,
  });

  final String titleEn;
  final String explanationShort;
  final String explanationFull;
}

/// One step in a physical+verbal procedure (Wudu, Salah) — an
/// instruction, and optionally an Arabic phrase to say with it.
/// Everything but [instructionEn] is nullable: most Wudu steps are
/// pure action with nothing to say (e.g. washing the arms), and the
/// two recitation steps that do have a phrase don't have a
/// [repeatCount] (each is said once, not "x3").
class PrayerStepExercise extends LessonExercise {
  const PrayerStepExercise({
    required super.id,
    required super.sequenceOrder,
    required this.instructionEn,
    this.arabicText,
    this.transliteration,
    this.translationEn,
    this.repeatCount,
  });

  final String instructionEn;
  final String? arabicText;
  final String? transliteration;
  final String? translationEn;
  final int? repeatCount;
}

class UnsupportedExercise extends LessonExercise {
  const UnsupportedExercise({
    required super.id,
    required super.sequenceOrder,
    required this.exerciseType,
  });

  final String exerciseType;
}
