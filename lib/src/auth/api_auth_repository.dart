import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import '../core/api_config.dart';
import 'auth_models.dart';
import 'auth_repository.dart';

final httpClientProvider = Provider<http.Client>((ref) {
  final client = http.Client();
  ref.onDispose(client.close);
  return client;
});

final apiBaseUrlProvider = Provider<Uri>((ref) {
  final baseUrl = kDefaultApiBaseUrl.trim();
  return Uri.parse(baseUrl);
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return ApiAuthRepository(
    client: ref.watch(httpClientProvider),
    baseUrl: ref.watch(apiBaseUrlProvider),
  );
});

class ApiAuthRepository implements AuthRepository {
  ApiAuthRepository({required http.Client client, required Uri baseUrl})
    : _client = client,
      _baseUrl = baseUrl;

  final http.Client _client;
  final Uri _baseUrl;

  Uri get _registerUri => _baseUrl.resolve('/api/v1/auth/register');

  @override
  Future<AuthSession> register({
    required String email,
    required String password,
  }) async {
    final response = await _client.post(
      _registerUri,
      headers: const <String, String>{
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode(<String, String>{
        'email': email.trim().toLowerCase(),
        'password': password,
      }),
    );

    final decoded = _decodeResponse(response.body);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return AuthSession.fromJson(decoded);
    }

    if (response.statusCode == 409) {
      throw RegisterFailure.fromJsonResponse(
        decoded,
        fallbackCode: 'email_already_in_use',
      );
    }

    if (response.statusCode == 422) {
      throw RegisterFailure.fromJsonResponse(
        decoded,
        fallbackCode: 'password_policy_failed',
      );
    }

    if (response.statusCode == 400) {
      throw RegisterFailure.fromJsonResponse(
        decoded,
        fallbackCode: 'validation_error',
      );
    }

    throw RegisterFailure(
      code: 'internal_error',
      message: decoded['message'] as String? ?? 'Unexpected server error.',
      fieldErrors: const <RegisterFieldError>[],
    );
  }

  Map<String, dynamic> _decodeResponse(String body) {
    if (body.trim().isEmpty) {
      return <String, dynamic>{};
    }
    final decoded = jsonDecode(body);
    return decoded is Map<String, dynamic> ? decoded : <String, dynamic>{};
  }
}
