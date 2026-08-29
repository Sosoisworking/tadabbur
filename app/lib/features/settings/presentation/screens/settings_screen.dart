import 'package:adhan_dart/adhan_dart.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/app_version.dart';
import '../../../../core/platform/app_update.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/util/hijri_date.dart';
import '../../../../shared/widgets/disclosure.dart';
import '../../../../shared/widgets/pill.dart';
import '../../../../shared/widgets/row_icon_dot.dart';
import '../../../../shared/widgets/screen_header.dart';
import '../../../auth/data/auth_repository.dart';
import '../../../prayer_times/domain/prayer_calculation_settings.dart';
import '../../../prayer_times/presentation/providers/prayer_times_providers.dart';
import '../../../prayer_times/presentation/widgets/city_picker_sheet.dart';
import '../../domain/app_settings.dart';
import '../providers/settings_providers.dart';

/// The three things about this app that are genuinely a matter of local
/// practice rather than product opinion: where prayer times are computed
/// for, how they're computed, and which day the Hijri calendar is on.
///
/// Every control here writes through [AppSettingsController] to
/// shared_preferences and takes effect immediately — the Hijri section
/// shows today's date rendered through the live seam, so the correction
/// is visible while it's being made rather than something the user has to
/// go back to another tab to check.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  /// Owned by `app_router.dart`; named here so the route and its screen
  /// can't drift apart.
  static const routePath = '/settings';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(appSettingsProvider);

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.screenInset,
            AppSpacing.md,
            AppSpacing.screenInset,
            AppSpacing.xxxl,
          ),
          children: [
            ScreenHeader(
              eyebrow: 'Preferences',
              title: 'Settings',
              trailing: CircleIconButton(
                icon: Icons.close_rounded,
                size: AppSpacing.minTouchTarget,
                onPressed: () => context.pop(),
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),
            const _SectionLabel('Prayer times'),
            const SizedBox(height: AppSpacing.md),
            _Card(
              children: [
                const _LocationRow(),
                const _RowDivider(),
                _SettingRow(
                  icon: Icons.public_rounded,
                  label: 'Calculation method',
                  value: settings.calculationMethod.displayName,
                  onTap: () => _showCalculationMethodSheet(context),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            _MadhabCard(selected: settings.madhab),
            const SizedBox(height: AppSpacing.xxl),
            const _SectionLabel('Hijri date'),
            const SizedBox(height: AppSpacing.md),
            _HijriOffsetCard(offset: settings.hijriDayOffset),
            const SizedBox(height: AppSpacing.xxl),
            const _UpdateCard(),
            const _SectionLabel('Account'),
            const SizedBox(height: AppSpacing.md),
            const _AccountCard(),
          ],
        ),
      ),
    );
  }
}

/// The location control is the city picker that already exists on the
/// Prayer tab, not a second list of cities — one sheet, one persisted
/// choice, no chance of the two disagreeing about which city is selected.
class _LocationRow extends ConsumerWidget {
  const _LocationRow();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final saved = ref.watch(prayerLocationControllerProvider);

    // The stored *choice*, not the resolved position: reading the resolved
    // location here would fire a GPS permission prompt at a user who only
    // came to change the Hijri offset.
    final value = switch (saved) {
      AsyncData(:final value?) => value.displayName,
      AsyncData() => 'Use my location',
      _ => '…',
    };

    return _SettingRow(
      icon: Icons.place_rounded,
      label: 'Location',
      value: value,
      onTap: () => showCityPickerSheet(context),
    );
  }
}

class _MadhabCard extends ConsumerWidget {
  const _MadhabCard({required this.selected});

  final Madhab selected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return _Card(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Asr timing', style: AppTypography.display(fontSize: 17)),
              const SizedBox(height: 5),
              Text(
                'Hanafi puts Asr later — it waits for a shadow twice an '
                'object\'s height instead of once. Nothing else moves.',
                style: AppTypography.label(fontSize: 12.5, fontWeight: FontWeight.w400),
              ),
              const SizedBox(height: AppSpacing.lg),
              // Wraps instead of overflowing once the labels grow at a
              // large text scale.
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: [
                  for (final madhab in Madhab.values)
                    PillChip(
                      label: _madhabLabel(madhab),
                      selected: madhab == selected,
                      onTap: () => ref.read(appSettingsProvider.notifier).setMadhab(madhab),
                    ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  static String _madhabLabel(Madhab madhab) => switch (madhab) {
    Madhab.shafi => 'Shafi, Maliki, Hanbali',
    Madhab.hanafi => 'Hanafi',
  };
}

class _HijriOffsetCard extends ConsumerWidget {
  const _HijriOffsetCard({required this.offset});

  final int offset;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // The live seam, not this card's own [offset] field: rendering through
    // the same provider every other screen reads is what makes the preview
    // proof that the setting took, rather than a local echo of the tap.
    final preview = hijriToday(dayOffset: ref.watch(hijriDayOffsetProvider));
    final controller = ref.read(appSettingsProvider.notifier);

    return _Card(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Today reads as', style: AppTypography.label(fontSize: 12)),
              const SizedBox(height: 6),
              Text(preview, style: AppTypography.display(fontSize: 21)),
              const SizedBox(height: AppSpacing.lg),
              Row(
                children: [
                  CircleIconButton(
                    icon: Icons.remove_rounded,
                    size: AppSpacing.minTouchTarget,
                    onPressed: offset > AppSettings.minHijriDayOffset
                        ? () => controller.setHijriDayOffset(offset - 1)
                        : null,
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        _offsetLabel(offset),
                        textAlign: TextAlign.center,
                        style: AppTypography.label(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: offset == 0 ? AppColors.textSecondary : AppColors.brandAccent,
                        ),
                      ),
                    ),
                  ),
                  CircleIconButton(
                    icon: Icons.add_rounded,
                    size: AppSpacing.minTouchTarget,
                    onPressed: offset < AppSettings.maxHijriDayOffset
                        ? () => controller.setHijriDayOffset(offset + 1)
                        : null,
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Disclosure(
                label: 'Why would this be off?',
                child: Text(
                  'The app converts the date arithmetically, on a fixed '
                  '30-year cycle. The date announced where you live '
                  'follows the moon being sighted, which lands a day '
                  'either side of that conversion often enough to matter '
                  'in Ramadan. This shifts every Hijri date in the app to '
                  'match your local announcement.',
                  style: AppTypography.label(fontSize: 12.5, fontWeight: FontWeight.w400),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  static String _offsetLabel(int offset) => switch (offset) {
    0 => 'No correction',
    1 => '1 day later',
    -1 => '1 day earlier',
    final value when value > 0 => '$value days later',
    final value => '${-value} days earlier',
  };
}

/// Offers a downloaded-but-not-yet-applied build.
///
/// Renders nothing at all until there is genuinely something to apply — this
/// is not a "check for updates" button. The service worker deliberately waits
/// rather than swapping a new build in mid-session, and index.html applies it
/// at the next launch, so the only alternative to this row is expecting people
/// to know that fully quitting and relaunching is what picks up a new version.
///
/// Absent on native, where the store owns updates.
class _UpdateCard extends StatelessWidget {
  const _UpdateCard();

  @override
  Widget build(BuildContext context) {
    final available = AppUpdate.available;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const _SectionLabel('App'),
        const SizedBox(height: AppSpacing.md),
        _Card(
          children: [
            // Always shown. Knowing which build is running is the thing that
            // makes "the change didn't appear" answerable instead of guesswork
            // — it matches the run number in the Actions tab.
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                children: [
                  RowIconDot(
                    icon: Icons.info_outline_rounded,
                    background: AppColors.brandPrimary.withValues(alpha: 0.14),
                    foreground: AppColors.brandPrimary,
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Version', style: AppTypography.label(fontSize: 12)),
                        const SizedBox(height: 2),
                        Text(AppVersion.full, style: AppTypography.display(fontSize: 15)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            if (available != null) _UpdateRow(available: available),
          ],
        ),
        const SizedBox(height: AppSpacing.xxl),
      ],
    );
  }
}

/// The "new version — tap to reload" row, present only while a newer build is
/// genuinely precached and waiting. Not a check-for-updates button.
class _UpdateRow extends StatelessWidget {
  const _UpdateRow({required this.available});

  final ValueListenable<bool> available;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: available,
      builder: (context, ready, _) {
        if (!ready) return const SizedBox.shrink();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const _RowDivider(),
            Material(
                  color: Colors.transparent,
                  child: InkWell(
                    // Applying reloads the page onto the new build, so this
                    // is the one control here that discards what is on screen.
                    // It is only ever offered from Settings, never mid-lesson.
                    onTap: AppUpdate.apply,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      child: Row(
                        children: [
                          RowIconDot(
                            icon: Icons.refresh_rounded,
                            background: AppColors.brandAccent.withValues(alpha: 0.16),
                            foreground: AppColors.brandAccent,
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'New version',
                                  style: AppTypography.display(fontSize: 16),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Downloaded and ready — tap to reload',
                                  style: AppTypography.label(fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                          const Icon(
                            Icons.chevron_right_rounded,
                            size: 20,
                            color: AppColors.textMuted,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
          ],
        );
      },
    );
  }
}

/// Who you are signed in as, and the way out.
///
/// The two states are genuinely different actions wearing similar words. An
/// account holder signing out can sign back in and find everything where they
/// left it. An anonymous session is the only key to the progress stored under
/// its auth.uid() — there are no credentials to return with — so signing out
/// of one discards that progress for good. The copy, the icon and the
/// confirmation all diverge on that, rather than sharing one neutral wording
/// that would be a lie in the anonymous case.
class _AccountCard extends ConsumerWidget {
  const _AccountCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authRepositoryProvider);
    final isAnonymous = auth.isAnonymous;
    final email = auth.email;

    return _Card(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(
            children: [
              RowIconDot(
                icon: isAnonymous ? Icons.person_outline_rounded : Icons.person_rounded,
                background: AppColors.brandPrimary.withValues(alpha: 0.14),
                foreground: AppColors.brandPrimary,
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isAnonymous ? 'Signed in without an account' : 'Signed in',
                      style: AppTypography.label(fontSize: 12),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      email ?? 'Progress is saved on this device only',
                      style: AppTypography.display(fontSize: 15),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const _RowDivider(),
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => _confirmSignOut(context, ref, isAnonymous: isAnonymous),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                children: [
                  RowIconDot(
                    icon: Icons.logout_rounded,
                    background: AppColors.error.withValues(alpha: 0.14),
                    foreground: AppColors.error,
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Text(
                      'Log out',
                      style: AppTypography.display(fontSize: 16, color: AppColors.error),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Always confirms. Signing out is one tap from a settings list, and for an
/// anonymous session it is destructive and irreversible — so the anonymous
/// variant names what is lost rather than asking a generic "are you sure".
Future<void> _confirmSignOut(
  BuildContext context,
  WidgetRef ref, {
  required bool isAnonymous,
}) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(isAnonymous ? 'Log out and lose your progress?' : 'Log out?'),
      content: Text(
        isAnonymous
            ? 'This device is signed in without an account, so there is no way '
                'to sign back in. Your lessons, streak and review queue will be '
                'gone for good.'
            : 'You can sign back in any time and your progress will be waiting.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(true),
          style: TextButton.styleFrom(foregroundColor: AppColors.error),
          child: Text(isAnonymous ? 'Log out anyway' : 'Log out'),
        ),
      ],
    ),
  );

  if (confirmed != true) return;

  try {
    await ref.read(authRepositoryProvider).signOut();
    // No navigation here on purpose: the router redirects to onboarding off
    // the auth-state stream (see app_router.dart), so pushing a route as well
    // would race it.
  } catch (error) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Could not log out. Please try again.\n$error')),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(text.toUpperCase(), style: AppTypography.eyebrow(color: AppColors.textMuted));
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.bgSurface,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: children),
    );
  }
}

class _RowDivider extends StatelessWidget {
  const _RowDivider();

  @override
  Widget build(BuildContext context) {
    return const Divider(height: 1, thickness: 1, color: AppColors.borderSubtle, indent: 20, endIndent: 20);
  }
}

class _SettingRow extends StatelessWidget {
  const _SettingRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(
            children: [
              RowIconDot(
                icon: icon,
                background: AppColors.brandPrimary.withValues(alpha: 0.14),
                foreground: AppColors.brandPrimary,
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label, style: AppTypography.label(fontSize: 12)),
                    const SizedBox(height: 3),
                    // Wraps rather than ellipsizing: a calculation method
                    // truncated to "University of Islamic Sciences,…"
                    // stops naming the thing the user picked.
                    Text(value, style: AppTypography.display(fontSize: 16)),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              const Icon(Icons.chevron_right_rounded, size: 20, color: AppColors.textMuted),
            ],
          ),
        ),
      ),
    );
  }
}

/// Same bottom-sheet shape as the city picker, for the same reason: the
/// list is longer than a dialog can hold and the choice is a single tap.
void _showCalculationMethodSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (context) => const _CalculationMethodSheet(),
  );
}

class _CalculationMethodSheet extends ConsumerWidget {
  const _CalculationMethodSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(appSettingsProvider).calculationMethod;

    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: Column(
            children: [
              const SizedBox(height: AppSpacing.md),
              Text('Calculation method', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: AppSpacing.xs),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                child: Text(
                  'Methods differ in the sun angle they use for Fajr and '
                  'Isha. Pick whichever your local mosque follows.',
                  textAlign: TextAlign.center,
                  style: AppTypography.label(fontSize: 12, fontWeight: FontWeight.w400),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Expanded(
                child: ListView(
                  controller: scrollController,
                  children: [
                    for (final method in calculationMethodFactories.keys)
                      ListTile(
                        title: Text(method.displayName),
                        trailing: method == selected
                            ? const Icon(Icons.check_rounded, color: AppColors.brandPrimary)
                            : null,
                        onTap: () async {
                          await ref.read(appSettingsProvider.notifier).setCalculationMethod(method);
                          if (context.mounted) Navigator.of(context).pop();
                        },
                      ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
