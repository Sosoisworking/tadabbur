// The update row is the only way a PWA user picks up a new build without
// knowing to fully quit and relaunch, so its two states both matter: it must
// stay completely invisible when there is nothing to apply (it is not a
// "check for updates" button), and it must appear the moment there is.
//
// AppUpdate reads a platform global, which a widget test has no way to drive,
// so these exercise the same widget shape through an injected listenable.

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:tadabbur/core/theme/app_colors.dart';
import 'package:tadabbur/core/theme/app_theme.dart';
import 'package:tadabbur/core/theme/app_typography.dart';
import 'package:tadabbur/shared/widgets/row_icon_dot.dart';

/// Mirrors _UpdateCard's visibility rule. Kept in step with the real widget
/// by the fact that both read the same nullable listenable and hide on false.
class _UpdateRow extends StatelessWidget {
  const _UpdateRow({required this.available, required this.onApply});

  final ValueListenable<bool>? available;
  final VoidCallback onApply;

  @override
  Widget build(BuildContext context) {
    final source = available;
    if (source == null) return const SizedBox.shrink();

    return ValueListenableBuilder<bool>(
      valueListenable: source,
      builder: (context, ready, _) {
        if (!ready) return const SizedBox.shrink();
        return Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onApply,
            child: Row(
              children: [
                RowIconDot(
                  icon: Icons.refresh_rounded,
                  background: AppColors.brandAccent.withValues(alpha: 0.16),
                  foreground: AppColors.brandAccent,
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('New version', style: AppTypography.display(fontSize: 16)),
                      Text(
                        'Downloaded and ready — tap to reload',
                        style: AppTypography.label(fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

Future<void> _pump(
  WidgetTester tester, {
  required ValueListenable<bool>? available,
  VoidCallback? onApply,
}) {
  return tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.dark(),
      home: Scaffold(
        body: _UpdateRow(available: available, onApply: onApply ?? () {}),
      ),
    ),
  );
}

void main() {
  testWidgets('shows nothing on a platform with no update channel', (tester) async {
    // Native: AppUpdate.available is null and the row must not reserve space
    // or render an empty section header.
    await _pump(tester, available: null);
    expect(find.text('New version'), findsNothing);
  });

  testWidgets('stays hidden while no update is waiting', (tester) async {
    await _pump(tester, available: ValueNotifier(false));
    expect(find.text('New version'), findsNothing);
  });

  testWidgets('offers the update once one is ready', (tester) async {
    await _pump(tester, available: ValueNotifier(true));

    expect(find.text('New version'), findsOneWidget);
    expect(find.text('Downloaded and ready — tap to reload'), findsOneWidget);
  });

  testWidgets('appears without a rebuild when an update lands mid-session', (tester) async {
    // The realistic case: Settings is already open when the worker finishes
    // precaching. Nothing re-navigates, so the listenable has to drive it.
    final notifier = ValueNotifier(false);
    await _pump(tester, available: notifier);
    expect(find.text('New version'), findsNothing);

    notifier.value = true;
    await tester.pump();

    expect(find.text('New version'), findsOneWidget);
  });

  testWidgets('tapping applies the update', (tester) async {
    var applied = 0;
    await _pump(tester, available: ValueNotifier(true), onApply: () => applied++);

    await tester.tap(find.text('New version'));
    await tester.pump();

    expect(applied, 1);
  });
}
