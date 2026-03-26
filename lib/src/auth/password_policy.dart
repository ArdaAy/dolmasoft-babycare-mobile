class PasswordPolicyResult {
  const PasswordPolicyResult({required this.isValid, required this.errors});

  final bool isValid;
  final List<PasswordPolicyError> errors;
}

class PasswordPolicyError {
  const PasswordPolicyError({required this.code, required this.message});

  final String code;
  final String message;
}

class PasswordPolicy {
  const PasswordPolicy();

  PasswordPolicyResult validate(String password) {
    final errors = <PasswordPolicyError>[];

    if (password.length < 8 || password.length > 72) {
      errors.add(
        const PasswordPolicyError(
          code: 'password_length',
          message: 'Password must be between 8 and 72 characters long.',
        ),
      );
    }

    if (!RegExp(r'[A-Z]').hasMatch(password)) {
      errors.add(
        const PasswordPolicyError(
          code: 'password_uppercase',
          message: 'Password must include at least one uppercase letter.',
        ),
      );
    }

    if (!RegExp(r'[a-z]').hasMatch(password)) {
      errors.add(
        const PasswordPolicyError(
          code: 'password_lowercase',
          message: 'Password must include at least one lowercase letter.',
        ),
      );
    }

    if (!RegExp(r'\d').hasMatch(password)) {
      errors.add(
        const PasswordPolicyError(
          code: 'password_digit',
          message: 'Password must include at least one digit.',
        ),
      );
    }

    return PasswordPolicyResult(isValid: errors.isEmpty, errors: errors);
  }
}
