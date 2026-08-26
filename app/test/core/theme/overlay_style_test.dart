import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tadabbur/core/theme/app_colors.dart';
import 'package:tadabbur/core/theme/app_theme.dart';

/// The status bar is the one piece of the app the app does not draw, so
/// nothing else here can catch it being wrong: on [AppColors.bgBase] the
/// platform default renders *dark* status-bar content, leaving the clock,
/// battery and signal near-invisible on a near-black ground.
///
/// These assert the values rather than merely that a style exists, because
/// the two brightness fields mean opposite things per platform and are easy
/// to "fix" into being wrong on one of them.
void main() {
  group('AppTheme.overlayStyle', () {
    test('asks iOS for light status-bar content', () {
      // iOS reads statusBarBrightness as the brightness of what is BEHIND
      // the bar, so a dark ground is what makes iOS draw light content.
      expect(AppTheme.overlayStyle.statusBarBrightness, Brightness.dark);
    });

    test('asks Android for light status-bar icons', () {
      // Android reads this one as the wanted brightness of the icons
      // themselves — the opposite convention to iOS above.
      expect(AppTheme.overlayStyle.statusBarIconBrightness, Brightness.light);
    });

    test('keeps the status bar transparent over the app ground', () {
      expect(AppTheme.overlayStyle.statusBarColor, Colors.transparent);
    });

    test("matches Android's navigation bar to the app ground", () {
      expect(AppTheme.overlayStyle.systemNavigationBarColor, AppColors.bgBase);
      expect(
        AppTheme.overlayStyle.systemNavigationBarIconBrightness,
        Brightness.light,
      );
    });
  });

  testWidgets('an AppBar cannot revert the style', (tester) async {
    // No screen renders an AppBar today, but one appearing later must not
    // quietly restore the platform default over the dark ground.
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark(),
        home: Scaffold(appBar: AppBar(title: const Text('x'))),
      ),
    );

    final appBar = tester.widget<AppBar>(find.byType(AppBar));
    final resolved = appBar.systemOverlayStyle ??
        Theme.of(tester.element(find.byType(AppBar))).appBarTheme.systemOverlayStyle;

    expect(resolved?.statusBarBrightness, Brightness.dark);
    expect(resolved?.statusBarIconBrightness, Brightness.light);
  });
}
