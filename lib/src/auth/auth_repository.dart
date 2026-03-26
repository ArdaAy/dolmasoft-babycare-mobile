import 'auth_models.dart';

abstract class AuthRepository {
  Future<AuthSession> register({
    required String email,
    required String password,
  });
}
