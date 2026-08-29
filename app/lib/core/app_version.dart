/// Which build this is, so "am I on the latest?" has an answer.
///
/// The marketing version comes from pubspec and changes when the product
/// does. [buildLabel] is what actually distinguishes one deploy from the
/// next: the CI run number, injected at build time by the Pages workflow
/// (`--dart-define=APP_BUILD=…`), so it increases by one per deploy and can
/// be compared against the Actions tab.
///
/// A local build has no run number and reports `dev` rather than a
/// misleading zero — a number that looked real but never changed is worse
/// than an obvious placeholder, which is the failure this exists to end.
abstract final class AppVersion {
  /// Keep in step with `version:` in pubspec.yaml.
  static const String name = '1.0.0';

  static const String _build = String.fromEnvironment('APP_BUILD');

  /// `42` for a deployed build, `dev` for one built locally.
  static String get buildLabel => _build.isEmpty ? 'dev' : _build;

  /// "1.0.0 · build 42" — the whole thing, for display.
  static String get full => '$name · build $buildLabel';
}
