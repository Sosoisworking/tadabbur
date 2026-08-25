import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_theme.dart';
import '../theme/app_typography.dart';

/// Shown when the app cannot finish starting up — a stalled or failed
/// Supabase init, or missing/invalid configuration.
///
/// Exists because the alternative is worse than an error: without it a
/// failed `main()` never reaches `runApp`, and the user is left looking at
/// a black window that is indistinguishable from a crash, a slow network,
/// or a broken install. Anything that can stop startup has to be able to
/// say so.
class StartupFailureApp extends StatefulWidget {
  const StartupFailureApp({super.key, required this.error, required this.onRetry});

  final Object error;

  /// Re-runs startup. Returns true once the app has started successfully,
  /// at which point this screen is replaced.
  final Future<bool> Function() onRetry;

  @override
  State<StartupFailureApp> createState() => _StartupFailureAppState();
}

class _StartupFailureAppState extends State<StartupFailureApp> {
  bool _retrying = false;

  Future<void> _retry() async {
    setState(() => _retrying = true);
    final recovered = await widget.onRetry();
    // On success the whole app is replaced, so there's nothing to update.
    if (mounted && !recovered) setState(() => _retrying = false);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tadabbur',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark(),
      home: Scaffold(
        body: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 88,
                  height: 88,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.error.withValues(alpha: 0.5),
                      width: 1.5,
                    ),
                  ),
                  child: const Icon(Icons.cloud_off_rounded, size: 36, color: AppColors.error),
                ),
                const SizedBox(height: AppSpacing.xl),
                Text(
                  "Couldn't start Tadabbur",
                  style: AppTypography.display(fontSize: 26),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.sm),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 320),
                  child: Text(
                    'Check your connection and try again. If this keeps '
                    'happening, signing in again usually clears it.',
                    style: AppTypography.label(fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: AppSpacing.xxl),
                if (_retrying)
                  const CircularProgressIndicator()
                else
                  FilledButton(onPressed: _retry, child: const Text('Try again')),
                const SizedBox(height: AppSpacing.xl),
                // The raw error stays available but visually subordinate:
                // useful in a bug report, not the headline.
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 320),
                  child: Text(
                    '${widget.error}',
                    style: AppTypography.label(fontSize: 11, color: AppColors.textMuted),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
