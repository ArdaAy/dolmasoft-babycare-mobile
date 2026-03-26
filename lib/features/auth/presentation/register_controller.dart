import 'package:babycare_mobile/features/auth/data/auth_repository.dart';
import 'package:babycare_mobile/features/auth/data/session_store.dart';
import 'package:babycare_mobile/features/auth/domain/auth_error.dart';
import 'package:babycare_mobile/features/auth/domain/auth_session.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final authControllerProvider =
    AsyncNotifierProvider<AuthController, AuthSession?>(AuthController.new);

class AuthController extends AsyncNotifier<AuthSession?> {
  @override
  Future<AuthSession?> build() {
    return ref.read(sessionStoreProvider).read();
  }

  Future<void> register({
    required String email,
    required String password,
  }) async {
    state = const AsyncLoading<AuthSession?>().copyWithPrevious(state);
    state = await AsyncValue.guard(() async {
      final session = await ref
          .read(authRepositoryProvider)
          .register(email: email, password: password);
      await ref.read(sessionStoreProvider).write(session);
      return session;
    });
  }
}

extension AsyncAuthStateX on AsyncValue<AuthSession?> {
  AuthFailure? get authFailure {
    final error = this.error;
    return error is AuthFailure ? error : null;
  }
}
