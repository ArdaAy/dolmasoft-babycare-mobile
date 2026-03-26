import 'package:babycare_mobile/core/config/app_config.dart';
import 'package:babycare_mobile/core/network/api_client.dart';
import 'package:babycare_mobile/features/auth/domain/auth_error.dart';
import 'package:babycare_mobile/features/auth/domain/auth_session.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient(baseUrl: AppConfig.apiBaseUrl);
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(apiClient: ref.watch(apiClientProvider));
});

class AuthRepository {
  AuthRepository({required ApiClient apiClient}) : _apiClient = apiClient;

  final ApiClient _apiClient;

  Future<AuthSession> register({
    required String email,
    required String password,
  }) async {
    final response = await _apiClient.postJson(
      '/api/v1/auth/register',
      body: {'email': email, 'password': password},
    );

    final body = response.body ?? <String, dynamic>{};
    if (response.statusCode == 200) {
      final user = body['user'] as Map<String, dynamic>;
      return AuthSession(
        accessToken: body['accessToken'] as String,
        refreshToken: body['refreshToken'] as String,
        tokenType: body['tokenType'] as String,
        expiresIn: body['expiresIn'] as int,
        userId: user['id'] as String,
        email: user['email'] as String,
      );
    }

    throw AuthFailure(
      statusCode: response.statusCode,
      code: body['code'] as String? ?? 'internal_error',
      message: body['message'] as String? ?? 'Something went wrong.',
      fieldErrors: _parseFieldErrors(body['fieldErrors']),
    );
  }

  List<AuthFieldError> _parseFieldErrors(Object? value) {
    if (value is! List) {
      return const [];
    }

    return value
        .whereType<Map<String, dynamic>>()
        .map(
          (item) => AuthFieldError(
            field: item['field'] as String? ?? '',
            code: item['code'] as String? ?? 'validation_error',
            message: item['message'] as String? ?? 'Invalid value.',
          ),
        )
        .toList(growable: false);
  }
}
