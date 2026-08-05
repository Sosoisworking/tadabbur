import 'package:flutter/material.dart';

/// Placeholder — streaks (Hijri + Gregorian), XP, achievements, and
/// mastery-challenge history land in implementation-plan.md milestone M6.
class ProgressScreen extends StatelessWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Progress')),
      body: const Center(child: Text('Streaks, XP, achievements — coming in M6')),
    );
  }
}
