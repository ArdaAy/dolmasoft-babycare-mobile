import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'api_auth_repository.dart';
import 'auth_models.dart';
import 'auth_session_controller.dart';
import 'password_policy.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _passwordPolicy = const PasswordPolicy();

  bool _isSubmitting = false;
  String? _emailError;
  String? _passwordError;
  String? _generalError;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sessionValue = ref.watch(authSessionProvider);
    final session = sessionValue.valueOrNull;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: <Color>[
              Color(0xFFF7F7F2),
              Color(0xFFE6F4F1),
              Color(0xFFD9EAF2),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 520),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  child: session == null
                      ? _buildRegisterCard(context)
                      : _SignedInView(session: session),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRegisterCard(BuildContext context) {
    return Card(
      key: const ValueKey('register-card'),
      elevation: 12,
      shadowColor: Colors.black12,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              const _HeroHeader(),
              const SizedBox(height: 32),
              TextFormField(
                key: const Key('email_field'),
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                autofillHints: const <String>[AutofillHints.email],
                decoration: InputDecoration(
                  labelText: 'Email',
                  prefixIcon: const Icon(Icons.mail_outline_rounded),
                  errorText: _emailError,
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                key: const Key('password_field'),
                controller: _passwordController,
                obscureText: true,
                autofillHints: const <String>[AutofillHints.newPassword],
                decoration: InputDecoration(
                  labelText: 'Password',
                  prefixIcon: const Icon(Icons.lock_outline_rounded),
                  errorText: _passwordError,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Use 8 to 72 characters with at least one uppercase letter, one lowercase letter, and one digit.',
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: Colors.black54),
              ),
              const SizedBox(height: 18),
              if (_generalError != null) ...<Widget>[
                _ErrorBanner(message: _generalError!),
                const SizedBox(height: 18),
              ],
              FilledButton(
                key: const Key('register_button'),
                onPressed: _isSubmitting ? null : _handleSubmit,
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: _isSubmitting
                      ? const SizedBox(
                          key: ValueKey('register_loading'),
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2.4),
                        )
                      : const Text(
                          key: ValueKey('register_label'),
                          'Create account',
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleSubmit() async {
    setState(() {
      _emailError = null;
      _passwordError = null;
      _generalError = null;
    });

    final email = _emailController.text.trim();
    final password = _passwordController.text;

    var hasError = false;
    if (email.isEmpty) {
      _emailError = 'Email is required.';
      hasError = true;
    }

    if (password.isEmpty) {
      _passwordError = 'Password is required.';
      hasError = true;
    } else {
      final passwordPolicyResult = _passwordPolicy.validate(password);
      if (!passwordPolicyResult.isValid) {
        _passwordError = passwordPolicyResult.errors
            .map((item) => item.message)
            .join('\n');
        hasError = true;
      }
    }

    if (hasError) {
      setState(() {});
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final repository = ref.read(authRepositoryProvider);
      final session = await repository.register(
        email: email,
        password: password,
      );
      await ref.read(authSessionProvider.notifier).setSession(session);
    } on RegisterFailure catch (error) {
      _applyFailure(error);
    } catch (_) {
      setState(() {
        _generalError = 'Something went wrong while creating the account.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  void _applyFailure(RegisterFailure failure) {
    final fieldErrors = <String, List<String>>{};
    for (final error in failure.fieldErrors) {
      fieldErrors.putIfAbsent(error.field, () => <String>[]).add(error.message);
    }

    setState(() {
      _generalError = failure.message;
      _emailError = _joinErrors(fieldErrors['email']);
      _passwordError = _joinErrors(fieldErrors['password']);
      if (_emailError == null &&
          _passwordError == null &&
          failure.code == 'email_already_in_use') {
        _generalError = failure.message;
      }
    });
  }

  String? _joinErrors(List<String>? messages) {
    if (messages == null || messages.isEmpty) {
      return null;
    }
    return messages.join('\n');
  }
}

class _HeroHeader extends StatelessWidget {
  const _HeroHeader();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          width: 68,
          height: 68,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: const LinearGradient(
              colors: <Color>[Color(0xFF1F7A8C), Color(0xFF0B3954)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: const Icon(
            Icons.child_care_rounded,
            color: Colors.white,
            size: 34,
          ),
        ),
        const SizedBox(height: 20),
        Text(
          'Create your BabyCare account',
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: const Color(0xFF0B3954),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Register with your email and password to start using the app immediately.',
          style: theme.textTheme.bodyLarge?.copyWith(color: Colors.black87),
        ),
      ],
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFE8E8),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF1B0B7)),
      ),
      child: Text(
        message,
        style: Theme.of(
          context,
        ).textTheme.bodyMedium?.copyWith(color: const Color(0xFF8A1F2D)),
      ),
    );
  }
}

class _SignedInView extends StatelessWidget {
  const _SignedInView({required this.session});

  final AuthSession session;

  @override
  Widget build(BuildContext context) {
    return Card(
      key: const ValueKey('signed-in-card'),
      elevation: 12,
      shadowColor: Colors.black12,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              width: 68,
              height: 68,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: const LinearGradient(
                  colors: <Color>[Color(0xFF7ABF8A), Color(0xFF1F7A8C)],
                ),
              ),
              child: const Icon(
                Icons.verified_rounded,
                color: Colors.white,
                size: 34,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'You are signed in',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: const Color(0xFF0B3954),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              session.user.email,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              'Access token and refresh token were saved locally for authenticated requests.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 18),
            _InfoRow(label: 'Token type', value: session.tokenType),
            _InfoRow(
              label: 'Expires in',
              value: '${session.expiresIn} seconds',
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.black54,
              ),
            ),
          ),
          Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: const Color(0xFF0B3954),
            ),
          ),
        ],
      ),
    );
  }
}
