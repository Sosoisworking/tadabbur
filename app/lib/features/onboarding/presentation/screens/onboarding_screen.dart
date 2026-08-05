import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_typography.dart';
import '../../../auth/data/auth_repository.dart';

/// Placeholder for the full onboarding flow in information-architecture.md
/// (motivation selection -> placement test -> first lesson -> signup ->
/// notification permission). The real flow deliberately runs the first
/// lesson BEFORE this sign-in step so a new user gets a win before being
/// asked to create an account — that sequencing is intentionally not
/// represented yet in this scaffold-stage screen, which only proves the
/// auth wiring works end to end.
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _emailController = TextEditingController();
  bool _linkSent = false;
  String? _error;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _sendLink() async {
    setState(() => _error = null);
    try {
      await ref.read(authRepositoryProvider).sendMagicLink(_emailController.text.trim());
      setState(() => _linkSent = true);
    } catch (e) {
      setState(() => _error = 'Could not send sign-in link: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Tadabbur', style: AppTypography.accent(fontSize: 32, fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                Text(
                  'Full onboarding (placement test, first lesson) lands in M2 — '
                  'sign in below to exercise the auth flow.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 32),
                if (_linkSent)
                  const Text('Check your email for a sign-in link.')
                else ...[
                  TextField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(labelText: 'Email', border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 16),
                  FilledButton(onPressed: _sendLink, child: const Text('Send sign-in link')),
                ],
                if (_error != null) ...[
                  const SizedBox(height: 16),
                  Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
