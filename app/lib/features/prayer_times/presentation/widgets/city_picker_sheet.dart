import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../domain/manual_city.dart';
import '../providers/prayer_times_providers.dart';

/// Opens the location picker as a bottom sheet — "Use My Location" plus a
/// searchable list of [manualCities]. Wraps the sheet's own
/// [ConsumerStatefulWidget] so callers (the AppBar action, the error
/// state's "Choose a City" button) don't need a [WidgetRef] themselves.
void showCityPickerSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (context) => const _CityPickerSheet(),
  );
}

class _CityPickerSheet extends ConsumerStatefulWidget {
  const _CityPickerSheet();

  @override
  ConsumerState<_CityPickerSheet> createState() => _CityPickerSheetState();
}

class _CityPickerSheetState extends ConsumerState<_CityPickerSheet> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final query = _query.trim().toLowerCase();
    final results = query.isEmpty
        ? manualCities
        : manualCities.where((city) => city.displayName.toLowerCase().contains(query)).toList();

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
              Text('Change Location', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: AppSpacing.md),
              TextField(
                controller: _searchController,
                onChanged: (value) => setState(() => _query = value),
                decoration: const InputDecoration(
                  hintText: 'Search for a city',
                  prefixIcon: Icon(Icons.search_rounded),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Expanded(
                child: ListView(
                  controller: scrollController,
                  children: [
                    ListTile(
                      leading: const Icon(Icons.my_location_rounded),
                      title: const Text('Use My Location'),
                      onTap: () async {
                        await ref.read(prayerLocationControllerProvider.notifier).useDeviceLocation();
                        if (context.mounted) Navigator.of(context).pop();
                      },
                    ),
                    const Divider(),
                    for (final city in results)
                      ListTile(
                        title: Text(city.name),
                        subtitle: Text(city.country),
                        onTap: () async {
                          await ref.read(prayerLocationControllerProvider.notifier).selectCity(city);
                          if (context.mounted) Navigator.of(context).pop();
                        },
                      ),
                    if (results.isEmpty)
                      Padding(
                        padding: const EdgeInsets.all(AppSpacing.xl),
                        child: Text(
                          'No cities match "$_query"',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
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
