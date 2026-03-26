import 'dart:convert';

import 'package:babycare_mobile/features/auth/domain/auth_session.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _authSessionKey = 'auth_session';

final sessionStoreProvider = Provider<SessionStore>((ref) {
  return SharedPreferencesSessionStore();
});

abstract class SessionStore {
  Future<AuthSession?> read();

  Future<void> write(AuthSession session);
}

class SharedPreferencesSessionStore implements SessionStore {
  @override
  Future<AuthSession?> read() async {
    final preferences = await SharedPreferences.getInstance();
    final rawValue = preferences.getString(_authSessionKey);
    if (rawValue == null || rawValue.isEmpty) {
      return null;
    }

    final decoded = jsonDecode(rawValue) as Map<String, dynamic>;
    return AuthSession.fromJson(decoded);
  }

  @override
  Future<void> write(AuthSession session) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(_authSessionKey, jsonEncode(session.toJson()));
  }
}

class InMemorySessionStore implements SessionStore {
  AuthSession? _session;

  @override
  Future<AuthSession?> read() async => _session;

  @override
  Future<void> write(AuthSession session) async {
    _session = session;
  }
}
