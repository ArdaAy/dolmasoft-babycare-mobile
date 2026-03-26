import 'dart:convert';

class AuthUser {
  const AuthUser({required this.id, required this.email});

  factory AuthUser.fromJson(Map<String, dynamic> json) {
    return AuthUser(
      id: json['id'] as String? ?? '',
      email: json['email'] as String? ?? '',
    );
  }

  final String id;
  final String email;

  Map<String, dynamic> toJson() => <String, dynamic>{'id': id, 'email': email};
}

class AuthSession {
  const AuthSession({
    required this.accessToken,
    required this.refreshToken,
    required this.tokenType,
    required this.expiresIn,
    required this.user,
  });

  factory AuthSession.fromJson(Map<String, dynamic> json) {
    return AuthSession(
      accessToken: json['accessToken'] as String? ?? '',
      refreshToken: json['refreshToken'] as String? ?? '',
      tokenType: json['tokenType'] as String? ?? 'Bearer',
      expiresIn: json['expiresIn'] as int? ?? 0,
      user: AuthUser.fromJson(
        (json['user'] as Map?)?.cast<String, dynamic>() ??
            const <String, dynamic>{},
      ),
    );
  }

  final String accessToken;
  final String refreshToken;
  final String tokenType;
  final int expiresIn;
  final AuthUser user;

  Map<String, dynamic> toJson() => <String, dynamic>{
    'accessToken': accessToken,
    'refreshToken': refreshToken,
    'tokenType': tokenType,
    'expiresIn': expiresIn,
    'user': user.toJson(),
  };

  String toEncodedJson() => jsonEncode(toJson());

  factory AuthSession.fromEncodedJson(String encodedJson) {
    return AuthSession.fromJson(
      jsonDecode(encodedJson) as Map<String, dynamic>,
    );
  }
}

class RegisterFieldError {
  const RegisterFieldError({
    required this.field,
    required this.code,
    required this.message,
  });

  factory RegisterFieldError.fromJson(Map<String, dynamic> json) {
    return RegisterFieldError(
      field: json['field'] as String? ?? '',
      code: json['code'] as String? ?? '',
      message: json['message'] as String? ?? '',
    );
  }

  final String field;
  final String code;
  final String message;

  Map<String, dynamic> toJson() => <String, dynamic>{
    'field': field,
    'code': code,
    'message': message,
  };
}

class RegisterFailure implements Exception {
  const RegisterFailure({
    required this.code,
    required this.message,
    this.fieldErrors = const <RegisterFieldError>[],
  });

  factory RegisterFailure.fromJsonResponse(
    Map<String, dynamic> json, {
    String fallbackCode = 'internal_error',
  }) {
    final fieldErrors =
        (json['fieldErrors'] as List?)
            ?.whereType<Map>()
            .map(
              (item) =>
                  RegisterFieldError.fromJson(item.cast<String, dynamic>()),
            )
            .toList(growable: false) ??
        const <RegisterFieldError>[];
    return RegisterFailure(
      code: json['code'] as String? ?? fallbackCode,
      message: json['message'] as String? ?? 'Unexpected error.',
      fieldErrors: fieldErrors,
    );
  }

  final String code;
  final String message;
  final List<RegisterFieldError> fieldErrors;

  Map<String, dynamic> toJson() => <String, dynamic>{
    'code': code,
    'message': message,
    if (fieldErrors.isNotEmpty)
      'fieldErrors': fieldErrors
          .map((item) => item.toJson())
          .toList(growable: false),
  };

  @override
  String toString() => 'RegisterFailure(${jsonEncode(toJson())})';
}
