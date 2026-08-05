import 'package:flutter/material.dart';

/// Placeholder — scoped AI tutor chat lands in implementation-plan.md
/// milestone M4, backed by the cost-capped proxy in
/// docs/api-design.md §2 (POST /functions/v1/tutor/message). Every
/// conversation must be context-anchored (vocab_item | grammar_point |
/// ayah) per feature-specs.md §7 — no open-ended chat entry point.
class TutorScreen extends StatelessWidget {
  const TutorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tutor')),
      body: const Center(child: Text('Scoped AI tutor — coming in M4')),
    );
  }
}
