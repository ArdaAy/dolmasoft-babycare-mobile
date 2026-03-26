class AuthSession {
  const AuthSession({
    required this.accessToken,
    required this.refreshToken,
    required this.tokenType,
    required this.expiresIn,
    required this.userId,
    required this.email,
  });

  final String accessToken;
  final String refreshToken;
  final String tokenType;
  final int expiresIn;
  final String userId;
  final String email;

  Map<String, Object?> toJson() {
    return {
      'accessToken': accessToken,
      'refreshToken': refreshToken,
      'tokenType': tokenType,
      'expiresIn': expiresIn,
      'userId': userId,
      'email': email,
    };
  }

  factory AuthSession.fromJson(Map<String, Object?> json) {
    return AuthSession(
      accessToken: json['accessToken'] as String,
      refreshToken: json['refreshToken'] as String,
      tokenType: json['tokenType'] as String,
      expiresIn: json['expiresIn'] as int,
      userId: json['userId'] as String,
      email: json['email'] as String,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is AuthSession &&
            runtimeType == other.runtimeType &&
            accessToken == other.accessToken &&
            refreshToken == other.refreshToken &&
            tokenType == other.tokenType &&
            expiresIn == other.expiresIn &&
            userId == other.userId &&
            email == other.email;
  }

  @override
  int get hashCode => Object.hash(
    accessToken,
    refreshToken,
    tokenType,
    expiresIn,
    userId,
    email,
  );
}
