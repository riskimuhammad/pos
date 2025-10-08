import 'package:pos/core/network/network_info.dart';
import 'package:pos/core/repositories/base_repository.dart';
import 'package:pos/core/errors/failures.dart';
import 'package:pos/core/errors/exceptions.dart';
import 'package:pos/features/auth/domain/repositories/auth_repository.dart';
import '../datasources/auth_local_datasource.dart';
import '../datasources/auth_remote_datasource.dart';
import '../datasources/auth_mock_datasource.dart';
import '../models/auth_request.dart';
import '../models/auth_response.dart';
import '../models/user_session.dart';

abstract class AuthRepository {
  Future<UserSession> login(AuthRequest request);
  Future<UserSession> refreshToken(String refreshToken);
  Future<void> logout();
  Future<void> changePassword(String oldPassword, String newPassword);
  Future<UserSession?> getCurrentSession();
  Future<bool> hasValidSession();
  Future<void> clearSession();
}

class AuthRepositoryImpl extends BaseRepository implements AuthRepository {
  final AuthLocalDataSource localDataSource;
  final AuthRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;
  final bool useMockData; // Flag untuk development

  AuthRepositoryImpl({
    required this.localDataSource,
    required this.remoteDataSource,
    required this.networkInfo,
    this.useMockData = true, // Default true untuk development
  }) : super(networkInfo);

  @override
  Future<UserSession> login(AuthRequest request) async {
    try {
      AuthResponse authResponse;

      if (useMockData) {
        // Use mock data for development
        authResponse = await AuthMockDataSource.login(request);
      } else {
        // Use real API when available
        authResponse = await handleNetworkOperation(() async {
          return await remoteDataSource.login(request);
        });
      }

      // Create user session
      final session = UserSession(
        user: authResponse.user,
        tenant: authResponse.tenant,
        token: authResponse.token,
        refreshToken: authResponse.refreshToken,
        expiresAt: authResponse.expiresAt,
        loginAt: DateTime.now(),
      );

      // Save session locally
      await localDataSource.saveSession(session);

      return session;
    } on AuthenticationException catch (e) {
      throw AuthenticationFailure(message: e.message);
    } on ValidationException catch (e) {
      throw ValidationFailure(message: e.message);
    } on NetworkException catch (e) {
      throw NetworkFailure(message: e.message);
    } on ServerException catch (e) {
      throw ServerFailure(message: e.message);
    } catch (e) {
      throw UnexpectedFailure(message: e.toString());
    }
  }

  @override
  Future<UserSession> refreshToken(String refreshToken) async {
    try {
      AuthResponse authResponse;

      if (useMockData) {
        // Use mock data for development
        authResponse = await AuthMockDataSource.refreshToken(refreshToken);
      } else {
        // Use real API when available
        authResponse = await handleNetworkOperation(() async {
          return await remoteDataSource.refreshToken(refreshToken);
        });
      }

      // Create new user session
      final session = UserSession(
        user: authResponse.user,
        tenant: authResponse.tenant,
        token: authResponse.token,
        refreshToken: authResponse.refreshToken,
        expiresAt: authResponse.expiresAt,
        loginAt: DateTime.now(),
      );

      // Save updated session locally
      await localDataSource.saveSession(session);

      return session;
    } on AuthenticationException catch (e) {
      throw AuthenticationFailure(message: e.message);
    } on NetworkException catch (e) {
      throw NetworkFailure(message: e.message);
    } on ServerException catch (e) {
      throw ServerFailure(message: e.message);
    } catch (e) {
      throw UnexpectedFailure(message: e.toString());
    }
  }

  @override
  Future<void> logout() async {
    try {
      final session = await localDataSource.getCurrentSession();
      
      if (session != null) {
        if (useMockData) {
          // Use mock data for development
          await AuthMockDataSource.logout(session.token);
        } else {
          // Use real API when available
          if (await networkInfo.isConnected) {
            try {
              await remoteDataSource.logout(session.token);
            } catch (e) {
              // Don't fail logout if network call fails
              print('Logout API call failed: $e');
            }
          }
        }
      }

      // Always clear local session
      await localDataSource.clearSession();
    } catch (e) {
      // Don't fail logout, just clear local session
      await localDataSource.clearSession();
      throw UnexpectedFailure(message: 'Logout failed: $e');
    }
  }

  @override
  Future<void> changePassword(String oldPassword, String newPassword) async {
    try {
      if (useMockData) {
        // Use mock data for development
        await AuthMockDataSource.changePassword(oldPassword, newPassword);
      } else {
        // Use real API when available
        await handleNetworkOperation(() async {
          return await remoteDataSource.changePassword(oldPassword, newPassword);
        });
      }
    } on ValidationException catch (e) {
      throw ValidationFailure(message: e.message);
    } on NetworkException catch (e) {
      throw NetworkFailure(message: e.message);
    } on ServerException catch (e) {
      throw ServerFailure(message: e.message);
    } catch (e) {
      throw UnexpectedFailure(message: e.toString());
    }
  }

  @override
  Future<UserSession?> getCurrentSession() async {
    try {
      return await localDataSource.getCurrentSession();
    } catch (e) {
      throw CacheFailure(message: 'Failed to get current session: $e');
    }
  }

  @override
  Future<bool> hasValidSession() async {
    try {
      return await localDataSource.hasValidSession();
    } catch (e) {
      return false;
    }
  }

  @override
  Future<void> clearSession() async {
    try {
      await localDataSource.clearSession();
    } catch (e) {
      throw CacheFailure(message: 'Failed to clear session: $e');
    }
  }
}
