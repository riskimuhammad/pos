import 'package:get_storage/get_storage.dart';
import 'package:pos/core/constants/app_constants.dart';
import '../models/user_session.dart';

abstract class AuthLocalDataSource {
  Future<UserSession?> getCurrentSession();
  Future<void> saveSession(UserSession session);
  Future<void> clearSession();
  Future<bool> hasValidSession();
  Future<String?> getToken();
  Future<void> saveToken(String token);
  Future<void> clearToken();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final GetStorage _storage;

  AuthLocalDataSourceImpl(this._storage);

  @override
  Future<UserSession?> getCurrentSession() async {
    try {
      final sessionData = _storage.read('user_session');
      if (sessionData == null) return null;
      return UserSession.fromJson(Map<String, dynamic>.from(sessionData));
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> saveSession(UserSession session) async {
    await _storage.write('user_session', session.toJson());
    await _storage.write(AppConstants.tokenKey, session.token);
  }

  @override
  Future<void> clearSession() async {
    await _storage.remove('user_session');
    await _storage.remove(AppConstants.tokenKey);
    await _storage.remove(AppConstants.userKey);
    await _storage.remove(AppConstants.tenantKey);
  }

  @override
  Future<bool> hasValidSession() async {
    final session = await getCurrentSession();
    return session?.isValid ?? false;
  }

  @override
  Future<String?> getToken() async {
    return _storage.read(AppConstants.tokenKey);
  }

  @override
  Future<void> saveToken(String token) async {
    await _storage.write(AppConstants.tokenKey, token);
  }

  @override
  Future<void> clearToken() async {
    await _storage.remove(AppConstants.tokenKey);
  }
}
