import 'package:flutter/foundation.dart' show TargetPlatform, defaultTargetPlatform;
import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/screen_header.dart';

enum _Platform { ios, android }

class _Step {
  const _Step({required this.icon, required this.text});
  final IconData icon;
  final String text;
}

const _iosSteps = [
  _Step(icon: Icons.explore_outlined, text: 'Open this page in Safari.'),
  _Step(icon: Icons.ios_share_rounded, text: 'Tap the Share icon in the toolbar.'),
  _Step(icon: Icons.add_box_outlined, text: 'Scroll down and tap "Add to Home Screen".'),
  _Step(icon: Icons.check_circle_outline_rounded, text: 'Tap "Add" in the top-right corner.'),
];

const _androidSteps = [
  _Step(icon: Icons.explore_outlined, text: 'Open this page in Chrome.'),
  _Step(icon: Icons.more_vert_rounded, text: 'Tap the menu icon (⋮) in the top-right corner.'),
  _Step(icon: Icons.add_to_home_screen_rounded, text: 'Tap "Add to Home screen" or "Install app".'),
  _Step(icon: Icons.check_circle_outline_rounded, text: 'Tap "Add" or "Install" to confirm.'),
];

/// A guide for installing Tadabbur without an App/Play Store listing — the
/// app is distributed as a website that the user adds to their home screen
/// (a PWA install), not a native-store download. No provider/network
/// dependency here, just static instructions, so this is a plain
/// StatefulWidget rather than a ConsumerWidget.
class InstallGuideScreen extends StatefulWidget {
  const InstallGuideScreen({super.key});

  @override
  State<InstallGuideScreen> createState() => _InstallGuideScreenState();
}

class _InstallGuideScreenState extends State<InstallGuideScreen> {
  // Defaults to whichever platform the visitor is actually browsing from
  // (Flutter web derives this from the browser's user agent), so the
  // right steps show without the visitor having to pick — but they can
  // still switch to check the other platform's steps.
  late _Platform _selected =
      defaultTargetPlatform == TargetPlatform.iOS ? _Platform.ios : _Platform.android;

  @override
  Widget build(BuildContext context) {
    final steps = _selected == _Platform.ios ? _iosSteps : _androidSteps;

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.screenInset,
            AppSpacing.md,
            AppSpacing.screenInset,
            AppSpacing.navOverlayInset,
          ),
          children: [
            const ScreenHeader(
              eyebrow: 'No app store needed',
              title: 'Put Tadabbur on your home screen',
              titleSize: 28,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'It runs full-screen and offline, and your progress stays exactly where it was.',
              style: AppTypography.label(fontSize: 14.5, fontWeight: FontWeight.w400, color: AppColors.textSecondary),
            ),
            const SizedBox(height: AppSpacing.xl),
            Row(
              children: [
                Expanded(
                  child: _PlatformPill(
                    icon: Icons.phone_iphone_rounded,
                    label: 'iPhone',
                    selected: _selected == _Platform.ios,
                    onTap: () => setState(() => _selected = _Platform.ios),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: _PlatformPill(
                    icon: Icons.phone_android_rounded,
                    label: 'Android',
                    selected: _selected == _Platform.android,
                    onTap: () => setState(() => _selected = _Platform.android),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xl),
            for (var i = 0; i < steps.length; i++)
              _StepRow(number: i + 1, step: steps[i], isLast: i == steps.length - 1),
          ],
        ),
      ),
    );
  }
}

class _PlatformPill extends StatelessWidget {
  const _PlatformPill({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final foreground = selected ? AppColors.onPrimary : AppColors.textPrimary;

    return Material(
      color: selected ? AppColors.brandPrimary : Colors.transparent,
      shape: StadiumBorder(
        side: BorderSide(color: selected ? AppColors.brandPrimary : AppColors.borderStrong, width: 1.5),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 13),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 18, color: foreground),
              const SizedBox(width: 7),
              Text(label, style: AppTypography.label(fontSize: 13.5, fontWeight: FontWeight.w600, color: foreground)),
            ],
          ),
        ),
      ),
    );
  }
}

class _StepRow extends StatelessWidget {
  const _StepRow({required this.number, required this.step, required this.isLast});

  final int number;
  final _Step step;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 22),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 38,
              child: Column(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.brandAccent.withValues(alpha: 0.4)),
                    ),
                    child: Text(
                      '$number',
                      style: AppTypography.numeric(fontSize: 14, color: AppColors.brandAccent),
                    ),
                  ),
                  if (!isLast)
                    Expanded(
                      child: Container(width: 1.5, margin: const EdgeInsets.only(top: 4), color: AppColors.borderSubtle),
                    ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.lg),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(step.icon, size: 18, color: AppColors.textSecondary),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(step.text, style: AppTypography.display(fontSize: 16)),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
