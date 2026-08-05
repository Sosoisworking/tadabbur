import 'package:flutter/material.dart';

/// Placeholder — SRS due-queue UI lands in implementation-plan.md
/// milestone M3, backed by the SM-2 scheduling Edge Function in
/// docs/api-design.md §2 (POST /functions/v1/srs/review).
class ReviewScreen extends StatelessWidget {
  const ReviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Review')),
      body: const Center(child: Text('Spaced repetition review — coming in M3')),
    );
  }
}
