import 'package:flutter/foundation.dart' show TargetPlatform, defaultTargetPlatform;
import 'package:flutter/material.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/app_card.dart';

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
      appBar: AppBar(
        title: Row(
          children: [
            Icon(Icons.install_mobile_rounded, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 10),
            const Text('Install'),
          ],
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          Text(
            'Add Tadabbur to your home screen for quick, full-screen access — '
            'no App Store or Play Store download needed.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: AppSpacing.lg),
          SegmentedButton<_Platform>(
            segments: const [
              ButtonSegment(value: _Platform.ios, label: Text('iPhone'), icon: Icon(Icons.phone_iphone_rounded)),
              ButtonSegment(
                value: _Platform.android,
                label: Text('Android'),
                icon: Icon(Icons.phone_android_rounded),
              ),
            ],
            selected: {_selected},
            onSelectionChanged: (selection) => setState(() => _selected = selection.first),
          ),
          const SizedBox(height: AppSpacing.lg),
          for (var i = 0; i < steps.length; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: _StepCard(number: i + 1, step: steps[i]),
            ),
        ],
      ),
    );
  }
}

class _StepCard extends StatelessWidget {
  const _StepCard({required this.number, required this.step});

  final int number;
  final _Step step;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return AppCard(
      child: Row(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: colorScheme.primaryContainer,
            child: Text(
              '$number',
              style: TextStyle(color: colorScheme.onPrimaryContainer, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Icon(step.icon, color: colorScheme.secondary),
          const SizedBox(width: AppSpacing.md),
          Expanded(child: Text(step.text, style: Theme.of(context).textTheme.bodyLarge)),
        ],
      ),
    );
  }
}
