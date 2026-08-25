import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/pill.dart';
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
      body: Stack(
        children: [
          // The same soft radial the app uses to warm a corner of an
          // otherwise very dark ground.
          Positioned(
            top: -140,
            left: -100,
            child: Container(
              width: 360,
              height: 360,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [AppColors.brandAccent.withValues(alpha: 0.16), Colors.transparent],
                  stops: const [0, 0.7],
                ),
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.screenInset,
                AppSpacing.xxl,
                AppSpacing.screenInset,
                AppSpacing.xxl,
              ),
              child: ConstrainedBox(
                // Keeps the form from stretching into an unreadable line
                // length on a tablet or a desktop browser window.
                constraints: const BoxConstraints(maxWidth: 420),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const _Hero(),
                    const SizedBox(height: AppSpacing.xxl),
                    if (_checkEmailToConfirm)
                      _Notice(
                        icon: Icons.mark_email_unread_rounded,
                        text: 'Check your email to confirm your account, then log in below.',
                        color: AppColors.brandAccent,
                      )
                    else
                      ..._buildAuthForm(),
                    if (_error != null) ...[
                      const SizedBox(height: AppSpacing.lg),
                      _Notice(
                        icon: Icons.error_outline_rounded,
                        text: _error!,
                        color: AppColors.error,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildAuthForm() {
    return [
      _ModeToggle(
        mode: _mode,
        onChanged: (mode) => setState(() => _mode = mode),
      ),
      const SizedBox(height: AppSpacing.lg),
      TextField(
        controller: _emailController,
        keyboardType: TextInputType.emailAddress,
        autofillHints: const [AutofillHints.email],
        textInputAction: TextInputAction.next,
        decoration: const InputDecoration(labelText: 'Email'),
      ),
      const SizedBox(height: AppSpacing.md),
      TextField(
        controller: _passwordController,
        obscureText: true,
        autofillHints: const [AutofillHints.password],
        textInputAction: TextInputAction.done,
        onSubmitted: (_) => _submitting ? null : _submit(),
        decoration: const InputDecoration(labelText: 'Password'),
      ),
      const SizedBox(height: AppSpacing.xl),
      PillButton(
        label: _mode == _Mode.logIn ? 'Log in' : 'Create account',
        icon: Icons.east_rounded,
        expand: true,
        onPressed: _submitting ? null : _submit,
      ),
      const SizedBox(height: AppSpacing.xl),
      Row(
        children: [
          const Expanded(child: Divider()),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: Text('or', style: AppTypography.label(fontSize: 12)),
          ),
          const Expanded(child: Divider()),
        ],
      ),
      const SizedBox(height: AppSpacing.md),
      Center(
        child: TextButton(
          onPressed: _continuingAnonymously ? null : _continueAnonymously,
          child: Text(
            'Continue without an account',
            style: AppTypography.label(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.brandPrimary,
            ),
          ),
        ),
      ),
      // Progress for either action shares one slot below the buttons
      // rather than replacing a button's label — swapping a label for a
      // spinner collapses the button's width and makes the whole form
      // jump while you wait.
      SizedBox(
        height: 24,
        child: Center(
          child: (_submitting || _continuingAnonymously)
              ? const SizedBox(
                  height: 18,
                  width: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : null,
        ),
      ),
    ];
  }
}

class _Hero extends StatelessWidget {
  const _Hero();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'تَدَبُّر',
          textDirection: TextDirection.rtl,
          style: AppTypography.arabic(fontSize: 52, color: AppColors.brandPrimary),
        ),
        const SizedBox(height: AppSpacing.md),
        Text.rich(
          TextSpan(
            style: AppTypography.display(fontSize: 32),
            children: [
              const TextSpan(text: "Read a page you've never seen — and "),
              TextSpan(
                text: 'understand it.',
                style: AppTypography.emphasis(AppColors.brandAccent),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Text(
          'Ten minutes a day. Less time than a single prayer.',
          style: AppTypography.label(
            fontSize: 15,
            fontWeight: FontWeight.w400,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

/// The two-state pill toggle, replacing Material's [SegmentedButton] —
/// which clipped its own labels ("Log In" rendering as "Log") once the
/// user's text size went up, because its segment height is fixed.
class _ModeToggle extends StatelessWidget {
  const _ModeToggle({required this.mode, required this.onChanged});

  final _Mode mode;
  final ValueChanged<_Mode> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.bgSurface,
        borderRadius: BorderRadius.circular(AppRadius.pill),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Row(
        children: [
          Expanded(
            child: _ToggleHalf(
              label: 'Log in',
              selected: mode == _Mode.logIn,
              onTap: () => onChanged(_Mode.logIn),
            ),
          ),
          Expanded(
            child: _ToggleHalf(
              label: 'Sign up',
              selected: mode == _Mode.signUp,
              onTap: () => onChanged(_Mode.signUp),
            ),
          ),
        ],
      ),
    );
  }
}

class _ToggleHalf extends StatelessWidget {
  const _ToggleHalf({required this.label, required this.selected, required this.onTap});

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      selected: selected,
      button: true,
      child: Material(
        color: selected ? AppColors.brandPrimary : Colors.transparent,
        borderRadius: BorderRadius.circular(AppRadius.pill),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            // Vertical padding rather than a fixed height, so the pill
            // grows with the label instead of cropping it.
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: AppTypography.label(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: selected ? AppColors.onPrimary : AppColors.textSecondary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// A tinted, bordered message block — the confirm-your-email prompt and
/// auth errors, which previously rendered as bare unstyled text.
class _Notice extends StatelessWidget {
  const _Notice({required this.icon, required this.text, required this.color});

  final IconData icon;
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              text,
              style: AppTypography.label(
                fontSize: 13,
                fontWeight: FontWeight.w400,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
