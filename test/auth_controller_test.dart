import 'package:babycare_mobile/core/network/api_client.dart';
import 'package:babycare_mobile/features/auth/data/auth_repository.dart';
import 'package:babycare_mobile/features/auth/data/session_store.dart';
import 'package:babycare_mobile/features/auth/domain/auth_error.dart';
import 'package:babycare_mobile/features/auth/domain/auth_session.dart';
import 'package:babycare_mobile/features/auth/presentation/register_controller.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  test('register persists the returned auth session', () async {
    const session = AuthSession(
      accessToken: 'access-token',
      refreshToken: 'refresh-token',
      tokenType: 'Bearer',
      expiresIn: 3600,
      userId: '550e8400-e29b-41d4-a716-446655440000',
      email: 'user@example.com',
    );
    final sessionStore = InMemorySessionStore();

    final container = ProviderContainer(
      overrides: [
        authRepositoryProvider.overrideWithValue(
          _FakeAuthRepository(result: session),
        ),
        sessionStoreProvider.overrideWithValue(sessionStore),
      ],
    );
    addTearDown(container.dispose);

    await container.read(authControllerProvider.future);
    await container
        .read(authControllerProvider.notifier)
        .register(email: 'User@Example.com', password: 'ValidPass1');

    expect(container.read(authControllerProvider).value, session);
    expect(await sessionStore.read(), session);
  });

  test('register exposes contract failures', () async {
    final failure = AuthFailure(
      statusCode: 409,
      code: 'email_already_in_use',
      message: 'Email address is already registered.',
    );

    final container = ProviderContainer(
      overrides: [
        authRepositoryProvider.overrideWithValue(
          _FakeAuthRepository(error: failure),
        ),
        sessionStoreProvider.overrideWithValue(InMemorySessionStore()),
      ],
    );
    addTearDown(container.dispose);

    await container.read(authControllerProvider.future);
    await container
        .read(authControllerProvider.notifier)
        .register(email: 'user@example.com', password: 'ValidPass1');

    final state = container.read(authControllerProvider);
    expect(state.hasError, isTrue);
    expect(state.error, failure);
  });
}

class _FakeAuthRepository extends AuthRepository {
  _FakeAuthRepository({this.result, this.error})
    : super(apiClient: ApiClient(baseUrl: 'http://localhost:5099'));

  final AuthSession? result;
  final AuthFailure? error;

  @override
  Future<AuthSession> register({
    required String email,
    required String password,
  }) async {
    if (error != null) {
      throw error!;
    }

    return result!;
  }
}
