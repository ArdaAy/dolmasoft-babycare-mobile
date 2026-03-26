import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:babycare_mobile/src/app.dart';
import 'package:babycare_mobile/src/auth/api_auth_repository.dart';
import 'package:babycare_mobile/src/auth/auth_models.dart';
import 'package:babycare_mobile/src/auth/auth_repository.dart';
import 'package:babycare_mobile/src/auth/auth_session_controller.dart';
import 'package:babycare_mobile/src/auth/auth_storage.dart';

class FakeAuthStorage implements AuthStorage {
  FakeAuthStorage({AuthSession? session}) : _session = session;

  AuthSession? _session;

  @override
  Future<AuthSession?> loadSession() async => _session;

  @override
  Future<void> saveSession(AuthSession session) async {
    _session = session;
  }

  @override
  Future<void> clearSession() async {
    _session = null;
  }
}

class FakeAuthRepository implements AuthRepository {
  FakeAuthRepository({required this.session});

  final AuthSession session;

  @override
  Future<AuthSession> register({
    required String email,
    required String password,
  }) async {
    return AuthSession(
      accessToken: session.accessToken,
      refreshToken: session.refreshToken,
      tokenType: session.tokenType,
      expiresIn: session.expiresIn,
      user: AuthUser(id: session.user.id, email: email.trim().toLowerCase()),
    );
  }
}

void main() {
  testWidgets('registers a user and shows signed-in state', (tester) async {
    final storage = FakeAuthStorage();
    final repository = FakeAuthRepository(
      session: const AuthSession(
        accessToken: 'access-token',
        refreshToken: 'refresh-token',
        tokenType: 'Bearer',
        expiresIn: 3600,
        user: AuthUser(
          id: '550e8400-e29b-41d4-a716-446655440000',
          email: 'user@example.com',
        ),
      ),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: <Override>[
          authStorageProvider.overrideWithValue(storage),
          authRepositoryProvider.overrideWithValue(repository),
          apiBaseUrlProvider.overrideWithValue(Uri.parse('http://localhost:5099')),
        ],
        child: const BabyCareApp(),
      ),
    );

    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(const Key('email_field')), 'User@Example.com');
    await tester.enterText(find.byKey(const Key('password_field')), 'ValidPass1');
    await tester.tap(find.byKey(const Key('register_button')));
    await tester.pumpAndSettle();

    expect(find.text('You are signed in'), findsOneWidget);
    expect(find.text('user@example.com'), findsOneWidget);
  });
}
