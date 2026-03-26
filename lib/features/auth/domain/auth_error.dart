class AuthFieldError {
  const AuthFieldError({
    required this.field,
    required this.code,
    required this.message,
  });

  final String field;
  final String code;
  final String message;
}

class AuthFailure implements Exception {
  const AuthFailure({
    required this.statusCode,
    required this.code,
    required this.message,
    this.fieldErrors = const [],
  });

  final int statusCode;
  final String code;
  final String message;
  final List<AuthFieldError> fieldErrors;

  bool get isDuplicateEmail =>
      statusCode == 409 && code == 'email_already_in_use';

  bool get isPasswordPolicyFailure =>
      statusCode == 422 && code == 'password_policy_failed';

  bool get isValidationFailure =>
      statusCode == 400 && code == 'validation_error';
}
