import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:babycare_mobile/src/auth/api_auth_repository.dart';
import 'package:babycare_mobile/src/auth/auth_models.dart';

void main() {
  test('parses a successful registration response', () async {
    final repository = ApiAuthRepository(
      client: MockClient((request) async {
        expect(request.url.path, '/api/v1/auth/register');
        expect(request.headers['Content-Type'], 'application/json');

        return http.Response(
          jsonEncode(<String, dynamic>{
            'accessToken': 'access-token',
            'refreshToken': 'refresh-token',
            'tokenType': 'Bearer',
            'expiresIn': 3600,
            'user': <String, dynamic>{
              'id': '550e8400-e29b-41d4-a716-446655440000',
              'email': 'user@example.com',
            },
          }),
          200,
        );
      }),
      baseUrl: Uri.parse('http://localhost:5099'),
    );

    final session = await repository.register(
      email: 'User@Example.com ',
      password: 'ValidPass1',
    );

    expect(session.accessToken, 'access-token');
    expect(session.refreshToken, 'refresh-token');
    expect(session.user.email, 'user@example.com');
  });

  test('maps duplicate email errors', () async {
    final repository = ApiAuthRepository(
      client: MockClient((_) async {
        return http.Response(
          jsonEncode(<String, dynamic>{
            'code': 'email_already_in_use',
            'message': 'Email address is already registered.',
          }),
          409,
        );
      }),
      baseUrl: Uri.parse('http://localhost:5099'),
    );

    await expectLater(
      repository.register(email: 'user@example.com', password: 'ValidPass1'),
      throwsA(
        isA<RegisterFailure>()
            .having((error) => error.code, 'code', 'email_already_in_use')
            .having((error) => error.message, 'message', 'Email address is already registered.'),
      ),
    );
  });

  test('maps password policy errors', () async {
    final repository = ApiAuthRepository(
      client: MockClient((_) async {
        return http.Response(
          jsonEncode(<String, dynamic>{
            'code': 'password_policy_failed',
            'message': 'Password does not meet the required rules.',
            'fieldErrors': <Map<String, dynamic>>[
              <String, dynamic>{
                'field': 'password',
                'code': 'password_uppercase',
                'message': 'Password must include at least one uppercase letter.',
              },
            ],
          }),
          422,
        );
      }),
      baseUrl: Uri.parse('http://localhost:5099'),
    );

    await expectLater(
      repository.register(email: 'user@example.com', password: 'validpass1'),
      throwsA(
        isA<RegisterFailure>()
            .having((error) => error.code, 'code', 'password_policy_failed')
            .having((error) => error.fieldErrors, 'fieldErrors', isNotEmpty),
      ),
    );
  });
}
