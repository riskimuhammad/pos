import 'package:dio/dio.dart';
import 'package:pos/core/constants/app_constants.dart';
import 'package:pos/core/errors/exceptions.dart';
import '../models/auth_request.dart';
import '../models/auth_response.dart';

abstract class AuthRemoteDataSource {
  Future<AuthResponse> login(AuthRequest request);
  Future<AuthResponse> refreshToken(String refreshToken);
  Future<void> logout(String token);
  Future<void> changePassword(String oldPassword, String newPassword);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final Dio _dio;

  AuthRemoteDataSourceImpl(this._dio);

  @override
  Future<AuthResponse> login(AuthRequest request) async {
    try {
      final response = await _dio.post(
        '${AppConstants.baseUrl}${AppConstants.apiVersion}/auth/login',
        data: request.toJson(),
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200) {
        return AuthResponse.fromJson(response.data['data']);
      } else {
        throw ServerException(
          message: response.data['message'] ?? 'Login failed',
        );
      }
    } on DioException catch (e) {
      if (e.response != null) {
        throw ServerException(
          message: e.response?.data['message'] ?? 'Network error',
        );
      } else {
        throw NetworkException(message: 'No internet connection');
      }
    } catch (e) {
      throw ServerException(message: 'Unexpected error: $e');
    }
  }

  @override
  Future<AuthResponse> refreshToken(String refreshToken) async {
    try {
      final response = await _dio.post(
        '${AppConstants.baseUrl}${AppConstants.apiVersion}/auth/refresh',
        data: {'refresh_token': refreshToken},
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200) {
        return AuthResponse.fromJson(response.data['data']);
      } else {
        throw ServerException(
          message: response.data['message'] ?? 'Token refresh failed',
        );
      }
    } on DioException catch (e) {
      if (e.response != null) {
        throw ServerException(
          message: e.response?.data['message'] ?? 'Network error',
        );
      } else {
        throw NetworkException(message: 'No internet connection');
      }
    } catch (e) {
      throw ServerException(message: 'Unexpected error: $e');
    }
  }

  @override
  Future<void> logout(String token) async {
    try {
      await _dio.post(
        '${AppConstants.baseUrl}${AppConstants.apiVersion}/auth/logout',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );
    } on DioException catch (e) {
      // Logout should not fail even if network is down
      // Just log the error but don't throw
      print('Logout network error: ${e.message}');
    } catch (e) {
      // Same here - don't fail logout
      print('Logout error: $e');
    }
  }

  @override
  Future<void> changePassword(String oldPassword, String newPassword) async {
    try {
      final response = await _dio.post(
        '${AppConstants.baseUrl}${AppConstants.apiVersion}/auth/change-password',
        data: {
          'old_password': oldPassword,
          'new_password': newPassword,
        },
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ),
      );

      if (response.statusCode != 200) {
        throw ServerException(
          message: response.data['message'] ?? 'Password change failed',
        );
      }
    } on DioException catch (e) {
      if (e.response != null) {
        throw ServerException(
          message: e.response?.data['message'] ?? 'Network error',
        );
      } else {
        throw NetworkException(message: 'No internet connection');
      }
    } catch (e) {
      throw ServerException(message: 'Unexpected error: $e');
    }
  }
}
