import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/theme/app_spacing.dart';
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

enum _Mode { logIn, signUp }

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  _Mode _mode = _Mode.logIn;
  bool _submitting = false;
  bool _continuingAnonymously = false;
  bool _checkEmailToConfirm = false;
  String? _error;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() {
      _error = null;
      _submitting = true;
    });

    final email = _emailController.text.trim();
    final password = _passwordController.text;

    try {
      if (_mode == _Mode.signUp) {
        final response = await ref.read(authRepositoryProvider).signUpWithPassword(
              email: email,
              password: password,
            );
        // No session yet means the project requires email confirmation
        // before this account is usable — a one-time step, unlike magic
        // link's every-sign-in redirect dependency.
        if (response.session == null) {
          setState(() {
            _checkEmailToConfirm = true;
            _submitting = false;
          });
          return;
        }
        // Session present: router's redirect (app_router.dart) takes over.
      } else {
        await ref.read(authRepositoryProvider).signInWithPassword(email: email, password: password);
      }
    } on AuthException catch (e) {
      setState(() {
        _error = e.message;
        _submitting = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Something went wrong: $e';
        _submitting = false;
      });
    }
  }

  Future<void> _continueAnonymously() async {
    setState(() {
      _error = null;
      _continuingAnonymously = true;
    });
    try {
      await ref.read(authRepositoryProvider).continueAnonymously();
      // No explicit navigation needed — the router's redirect (see
      // app_router.dart) reacts to the auth-state stream and takes over
      // once currentUser is non-null.
    } catch (e) {
      setState(() {
        _error = 'Could not continue: $e\n\nIf this is the first time, check '
            'that "Allow anonymous sign-ins" is enabled in your Supabase '
            'project under Authentication settings.';
        _continuingAnonymously = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Tadabbur', style: AppTypography.accent(fontSize: 32, fontWeight: FontWeight.w600)),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Full onboarding (placement test, first lesson) lands in M2 — '
                  'sign in below to exercise the auth flow.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: AppSpacing.xxl),
                if (_checkEmailToConfirm)
                  const Text(
                    'Check your email to confirm your account, then log in below.',
                    textAlign: TextAlign.center,
                  )
                else ...[
                  SegmentedButton<_Mode>(
                    segments: const [
                      ButtonSegment(value: _Mode.logIn, label: Text('Log In')),
                      ButtonSegment(value: _Mode.signUp, label: Text('Sign Up')),
                    ],
                    selected: {_mode},
                    onSelectionChanged: (selection) => setState(() => _mode = selection.first),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  TextField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(labelText: 'Email', border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  TextField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(labelText: 'Password', border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  FilledButton(
                    onPressed: _submitting ? null : _submit,
                    child: _submitting
                        ? const SizedBox(
                            height: AppSpacing.lg,
                            width: AppSpacing.lg,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(_mode == _Mode.logIn ? 'Log In' : 'Sign Up'),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  const Text('— or —'),
                  const SizedBox(height: AppSpacing.sm),
                  TextButton(
                    onPressed: _continuingAnonymously ? null : _continueAnonymously,
                    child: _continuingAnonymously
                        ? const SizedBox(
                            height: AppSpacing.lg,
                            width: AppSpacing.lg,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Continue without an account'),
                  ),
                ],
                if (_error != null) ...[
                  const SizedBox(height: AppSpacing.lg),
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
