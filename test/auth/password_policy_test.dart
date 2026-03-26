import 'package:flutter_test/flutter_test.dart';

import 'package:babycare_mobile/src/auth/password_policy.dart';

void main() {
  const policy = PasswordPolicy();

  test('accepts a valid password', () {
    final result = policy.validate('ValidPass1');

    expect(result.isValid, isTrue);
    expect(result.errors, isEmpty);
  });

  test('rejects passwords that do not meet length and character rules', () {
    final result = policy.validate('short');

    expect(result.isValid, isFalse);
    expect(
      result.errors.map((item) => item.code),
      containsAll(<String>['password_length', 'password_uppercase', 'password_digit']),
    );
  });
}
