import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_typography.dart';
import '../../data/srs_repository.dart';
import '../../domain/srs_item.dart';

/// Full-screen modal takeover, same pattern as the lesson player
/// (docs/design-system.md) — a focused review session, not something
/// bolted into the due-queue screen. Flip-card interaction: reveal, then
/// self-rate difficulty, which maps directly to the SM-2 quality_rating
/// the srs-review Edge Function grades on (docs/feature-specs.md §3).
class ReviewSessionScreen extends ConsumerStatefulWidget {
  const ReviewSessionScreen({super.key});

  @override
  ConsumerState<ReviewSessionScreen> createState() => _ReviewSessionScreenState();
}

class _ReviewSessionScreenState extends ConsumerState<ReviewSessionScreen> {
  List<DueSrsItem>? _items;
  int _index = 0;
  bool _revealed = false;
  bool _completed = false;
  String? _lastResultLabel;

  @override
  void initState() {
    super.initState();
    // Fetched fresh at session start rather than reusing the Review tab's
    // cached provider value — the queue may have changed since that
    // screen was last shown, and a stale list here would let a review
    // session include an item that's no longer due (or miss one that
    // just became due).
    ref.read(srsRepositoryProvider).fetchDueItems().then((items) {
      if (mounted) setState(() => _items = items);
    });
  }

  Future<void> _rate(int qualityRating) async {
    final item = _items![_index];
    final result = await ref.read(srsRepositoryProvider).submitReview(
          srsItemId: item.srsItemId,
          qualityRating: qualityRating,
        );

    if (!mounted) return;

    final days = result.intervalDays;
    setState(() => _lastResultLabel = 'Next review in $days ${days == 1 ? 'day' : 'days'}');

    await Future<void>.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;

    if (_index + 1 >= _items!.length) {
      ref.invalidate(dueSrsItemsProvider);
      setState(() => _completed = true);
    } else {
      setState(() {
        _index++;
        _revealed = false;
        _lastResultLabel = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Review')),
      body: SafeArea(child: _buildBody()),
    );
  }

  Widget _buildBody() {
    if (_items == null) return const Center(child: CircularProgressIndicator());
    if (_completed) return const _ReviewCompleteView();
    if (_items!.isEmpty) return const Center(child: Text('Nothing due right now.'));

    final item = _items![_index];

    return Column(
      children: [
        LinearProgressIndicator(value: (_index + 1) / _items!.length),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(item.arabicText, style: AppTypography.arabic(fontSize: 72), textAlign: TextAlign.center),
                const SizedBox(height: 24),
                if (_revealed) ...[
                  Text(item.label, style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 8),
                  Text(item.detail, textAlign: TextAlign.center),
                  const SizedBox(height: 32),
                  if (_lastResultLabel != null)
                    Text(_lastResultLabel!, style: Theme.of(context).textTheme.bodySmall)
                  else
                    _RatingButtons(onRate: _rate),
                ] else
                  FilledButton(
                    onPressed: () => setState(() => _revealed = true),
                    child: const Text('Show Answer'),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _RatingButtons extends StatelessWidget {
  const _RatingButtons({required this.onRate});

  final ValueChanged<int> onRate;

  @override
  Widget build(BuildContext context) {
    // Standard SM-2 self-rating buckets mapped onto the 0-5 quality
    // scale the Edge Function grades on (docs/feature-specs.md §3) — a
    // rating below 3 resets the item's interval, 3 and above extends it
    // by varying amounts depending on ease factor.
    const ratings = [
      (label: 'Again', value: 1),
      (label: 'Hard', value: 3),
      (label: 'Good', value: 4),
      (label: 'Easy', value: 5),
    ];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      alignment: WrapAlignment.center,
      children: [
        for (final rating in ratings)
          OutlinedButton(
            onPressed: () => onRate(rating.value),
            child: Text(rating.label),
          ),
      ],
    );
  }
}

class _ReviewCompleteView extends StatelessWidget {
  const _ReviewCompleteView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle_rounded, size: 64, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 16),
            Text('Review complete', style: AppTypography.accent(fontSize: 28, fontWeight: FontWeight.w600)),
            const SizedBox(height: 32),
            FilledButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Done')),
          ],
        ),
      ),
    );
  }
}
