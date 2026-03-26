import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'auth_models.dart';

abstract class AuthStorage {
  Future<AuthSession?> loadSession();
  Future<void> saveSession(AuthSession session);
  Future<void> clearSession();
}

final sharedPreferencesProvider = FutureProvider<SharedPreferences>((
  ref,
) async {
  return SharedPreferences.getInstance();
});

class SharedPreferencesAuthStorage implements AuthStorage {
  SharedPreferencesAuthStorage(this._ref);

  static const _sessionKey = 'babycare.auth.session.v1';

  final Ref _ref;

  Future<SharedPreferences> get _prefs =>
      _ref.read(sharedPreferencesProvider.future);

  @override
  Future<AuthSession?> loadSession() async {
    final prefs = await _prefs;
    final encoded = prefs.getString(_sessionKey);
    if (encoded == null || encoded.isEmpty) {
      return null;
    }

    return AuthSession.fromEncodedJson(encoded);
  }

  @override
  Future<void> saveSession(AuthSession session) async {
    final prefs = await _prefs;
    await prefs.setString(_sessionKey, jsonEncode(session.toJson()));
  }

  @override
  Future<void> clearSession() async {
    final prefs = await _prefs;
    await prefs.remove(_sessionKey);
  }
}
