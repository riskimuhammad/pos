import 'package:pos/shared/models/entities/user.dart';

abstract class AuthRepository {
  Future<User> login(String username, String password);
  Future<void> logout();
  Future<bool> checkSession();
  Future<bool> hasValidSession();
}
