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
      print('🔍 Debug - Session data from storage: $sessionData');
      if (sessionData == null) {
        print('❌ Debug - No session data found');
        return null;
      }
      final session = UserSession.fromJson(Map<String, dynamic>.from(sessionData));
      print('✅ Debug - Session loaded: ${session.user.username}, expires: ${session.expiresAt}, isValid: ${session.isValid}');
      return session;
    } catch (e) {
      print('❌ Debug - Error loading session: $e');
      return null;
    }
  }

  @override
  Future<void> saveSession(UserSession session) async {
    final sessionJson = session.toJson();
    print('💾 Debug - Saving session: ${session.user.username}, expires: ${session.expiresAt}');
    print('💾 Debug - Session JSON: $sessionJson');
    await _storage.write('user_session', sessionJson);
    await _storage.write(AppConstants.tokenKey, session.token);
    print('✅ Debug - Session saved successfully');
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
    final isValid = session?.isValid ?? false;
    print('🔍 Debug - Has valid session: $isValid');
    if (session != null) {
      print('🔍 Debug - Session details: expires=${session.expiresAt}, now=${DateTime.now()}, isExpired=${session.isExpired}');
    }
    return isValid;
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
