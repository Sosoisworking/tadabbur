/// The three independent axes from docs/feature-specs.md §1, declared in
/// the dependency order that document's routing table assumes: you can't
/// assess recitation fluency without script literacy, and vocabulary
/// scores only mean something once both hold. [PlacementResult.axes] walks
/// these in declaration order to decide where the user starts, so
/// reordering this enum changes behaviour, not just display.
enum PlacementAxis {
  scriptLiteracy('Script literacy'),
  recitationFluency('Recitation fluency'),
  vocabGrammar('Vocabulary & grammar');

  const PlacementAxis(this.label);

  final String label;
}

/// What one axis says about where the user is starting. Deliberately not
/// pass/fail and deliberately missing a "Weak" case — the placement result
/// is a routing explanation, not a report card, and docs/PRD.md's whole
/// argument for three axes is that a low score on one of them is a
/// starting point rather than a verdict on the learner.
enum PlacementVerdict {
  strong('Strong'),
  startingHere('Starting here'),
  comesLater('Comes later');

  const PlacementVerdict(this.label);

  final String label;
}

/// Mirrors docs/database-schema.md `placement_results`, with the
/// recommended unit resolved rather than left as a bare id — the row only
/// stores `recommended_unit_id`, but every consumer of this model has to
/// name the unit, so resolving it once here beats each screen re-fetching
/// it. Plain immutable class with no codegen, same reasoning as
/// CurriculumUnit.
///
/// Scores are the 0-100 axis scores the placement Edge Function returns
/// (`POST /functions/v1/placement/score`, docs/api-design.md §2).
class PlacementResult {
  const PlacementResult({
    required this.scriptLiteracyScore,
    required this.recitationFluencyScore,
    required this.vocabGrammarScore,
    required this.recommendedUnit,
  });

  final double scriptLiteracyScore;
  final double recitationFluencyScore;
  final double vocabGrammarScore;
  final RecommendedUnit recommendedUnit;

  /// Cutoff for printing "Strong" next to an axis. This is a *display*
  /// threshold and nothing else: the actual routing decision is made
  /// server-side so it stays tunable without an app release
  /// (docs/feature-specs.md §1), and it reaches the client already made,
  /// as [recommendedUnit]. Never re-derive routing from these scores here
  /// — that would put a second, silently-diverging copy of the routing
  /// table on the client, which is exactly what the spec forbids.
  static const double strongScoreThreshold = 70;

  /// The per-axis rows a result screen renders, in [PlacementAxis]
  /// declaration order. Anything at or above [strongScoreThreshold] is
  /// something the user already has; the *first* axis below it is where
  /// they start, and any axis after that is downstream of a gap they
  /// haven't closed yet, so it reads "comes later" rather than a second
  /// "starting here". Without that walk, a learner with no script
  /// literacy at all (the Aisha persona in docs/PRD.md) would see three
  /// simultaneous starting points.
  List<({PlacementAxis axis, PlacementVerdict verdict})> get axes {
    final scores = [scriptLiteracyScore, recitationFluencyScore, vocabGrammarScore];
    final outcomes = <({PlacementAxis axis, PlacementVerdict verdict})>[];
    var entryPointFound = false;

    for (var i = 0; i < PlacementAxis.values.length; i++) {
      final PlacementVerdict verdict;
      if (scores[i] >= strongScoreThreshold) {
        verdict = PlacementVerdict.strong;
      } else if (entryPointFound) {
        verdict = PlacementVerdict.comesLater;
      } else {
        verdict = PlacementVerdict.startingHere;
        entryPointFound = true;
      }
      outcomes.add((axis: PlacementAxis.values[i], verdict: verdict));
    }

    return outcomes;
  }

  /// The axis the curriculum picks up from. Falls back to the last axis
  /// when every score cleared the threshold: the curriculum still has to
  /// begin somewhere, and "furthest along" is the right somewhere — a
  /// firstWhere with no orElse would throw on the one profile the app
  /// should be happiest to see.
  PlacementAxis get entryPoint {
    return axes
        .firstWhere(
          (outcome) => outcome.verdict == PlacementVerdict.startingHere,
          orElse: () => (axis: PlacementAxis.values.last, verdict: PlacementVerdict.startingHere),
        )
        .axis;
  }

  /// Parses the row as PostgREST returns it with the recommended unit
  /// embedded (`select=*,units!recommended_unit_id(...)`) — see
  /// [RecommendedUnit.fromJson] for that nested shape. `numeric` columns
  /// arrive as [num], not always [double], hence the explicit conversion.
  factory PlacementResult.fromJson(Map<String, dynamic> json) {
    return PlacementResult(
      scriptLiteracyScore: (json['script_literacy_score'] as num).toDouble(),
      recitationFluencyScore: (json['recitation_fluency_score'] as num).toDouble(),
      vocabGrammarScore: (json['vocab_grammar_score'] as num).toDouble(),
      recommendedUnit: RecommendedUnit.fromJson(json['units'] as Map<String, dynamic>),
    );
  }
}

/// The unit `recommended_unit_id` points at, carrying only what a
/// recommendation needs to say about it: what it's called, how much is in
/// it, and what it opens with. Kept separate from CurriculumUnit rather
/// than reusing it: that model is built around progress against a unit the
/// user has already touched (status, completed counts, minutes left), and
/// a freshly recommended unit has no `user_unit_progress` row to derive
/// any of that from — while it does need a first-lesson title, which
/// CurriculumUnit has no reason to carry.
class RecommendedUnit {
  const RecommendedUnit({
    required this.id,
    required this.title,
    required this.lessonCount,
    required this.firstLessonTitle,
  });

  final int id;
  final String title;
  final int lessonCount;
  final String firstLessonTitle;

  /// `lessons` arrives as the embedded child rows, ordered by
  /// `sequence_order` server-side — the count and the first title both
  /// come from that one embed rather than two extra round trips.
  factory RecommendedUnit.fromJson(Map<String, dynamic> json) {
    final lessons = (json['lessons'] as List<dynamic>? ?? const []).cast<Map<String, dynamic>>();

    return RecommendedUnit(
      id: json['id'] as int,
      title: json['title'] as String,
      lessonCount: lessons.length,
      firstLessonTitle: lessons.isEmpty ? '' : lessons.first['title'] as String,
    );
  }
}
