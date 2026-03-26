import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'auth_models.dart';
import 'auth_storage.dart';

final authStorageProvider = Provider<AuthStorage>((ref) {
  return SharedPreferencesAuthStorage(ref);
});

final authSessionProvider =
    AsyncNotifierProvider<AuthSessionController, AuthSession?>(
      AuthSessionController.new,
    );

class AuthSessionController extends AsyncNotifier<AuthSession?> {
  @override
  Future<AuthSession?> build() async {
    final storage = ref.read(authStorageProvider);
    return storage.loadSession();
  }

  Future<void> setSession(AuthSession session) async {
    state = AsyncData(session);
    final storage = ref.read(authStorageProvider);
    await storage.saveSession(session);
  }

  Future<void> clearSession() async {
    final storage = ref.read(authStorageProvider);
    await storage.clearSession();
    state = const AsyncData(null);
  }
}
