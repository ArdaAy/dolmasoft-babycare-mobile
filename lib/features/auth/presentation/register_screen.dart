import 'package:babycare_mobile/features/auth/domain/auth_error.dart';
import 'package:babycare_mobile/features/auth/presentation/register_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final authFailure = authState.authFailure;
    final isSubmitting = authState.isLoading;
    final emailError = _fieldMessage(authFailure, 'email');
    final passwordErrors = _fieldMessages(authFailure, 'password');

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 460),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Create your BabyCare account',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Register with your email and password. A successful registration signs you in immediately.',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 24),
                        if (_bannerMessage(authFailure) case final banner?)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: _ErrorBanner(message: banner),
                          ),
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          autofillHints: const [AutofillHints.email],
                          decoration: InputDecoration(
                            labelText: 'Email',
                            hintText: 'user@example.com',
                            errorText: emailError,
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _passwordController,
                          obscureText: true,
                          autofillHints: const [AutofillHints.newPassword],
                          decoration: InputDecoration(
                            labelText: 'Password',
                            hintText: 'ValidPass1',
                            errorText: passwordErrors.isEmpty
                                ? null
                                : passwordErrors.join('\n'),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '8 to 72 characters, with at least 1 uppercase letter, 1 lowercase letter, and 1 digit.',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton(
                            onPressed: isSubmitting ? null : _submit,
                            child: isSubmitting
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Text('Create account'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    await ref
        .read(authControllerProvider.notifier)
        .register(
          email: _emailController.text,
          password: _passwordController.text,
        );
  }

  String? _bannerMessage(AuthFailure? failure) {
    if (failure == null) {
      return null;
    }

    if (failure.isDuplicateEmail ||
        failure.isPasswordPolicyFailure ||
        failure.isValidationFailure) {
      return failure.message;
    }

    return 'Registration failed. Please try again.';
  }

  String? _fieldMessage(AuthFailure? failure, String field) {
    final messages = _fieldMessages(failure, field);
    if (messages.isEmpty) {
      return null;
    }
    return messages.join('\n');
  }

  List<String> _fieldMessages(AuthFailure? failure, String field) {
    if (failure == null) {
      return const [];
    }

    return failure.fieldErrors
        .where((error) => error.field == field)
        .map((error) => error.message)
        .toList(growable: false);
  }
}

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFE8E5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(message, style: Theme.of(context).textTheme.bodyMedium),
    );
  }
}
