import 'package:dio/dio.dart';
import 'package:pos/core/constants/app_constants.dart';
import 'package:pos/shared/models/entities/entities.dart';

class UnitApiService {
  final Dio _dio;
  final String _baseUrl;

  UnitApiService({required Dio dio}) 
      : _dio = dio,
        _baseUrl = '${AppConstants.baseUrl}/${AppConstants.apiVersion}';

  /// Get all units
  Future<List<Unit>> getUnits({
    required String tenantId,
    String? search,
    bool? isActive,
    int page = 1,
    int limit = 100,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'tenant_id': tenantId,
        'page': page,
        'limit': limit,
      };
      
      if (search != null && search.isNotEmpty) queryParams['search'] = search;
      if (isActive != null) queryParams['is_active'] = isActive;

      final response = await _dio.get(
        '$_baseUrl/api/units',
        queryParameters: queryParams,
      );
      
      final data = response.data as Map<String, dynamic>;
      final unitsList = data['units'] as List<dynamic>;
      
      return unitsList
          .map((e) => Unit.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  /// Get unit by ID
  Future<Unit> getUnitById(String unitId) async {
    try {
      final response = await _dio.get(
        '$_baseUrl/api/units/$unitId',
      );
      
      return Unit.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  /// Create a new unit
  Future<Unit> createUnit(Unit unit) async {
    try {
      final response = await _dio.post(
        '$_baseUrl/api/units',
        data: unit.toJson(),
      );
      
      return Unit.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  /// Update an existing unit
  Future<Unit> updateUnit(Unit unit) async {
    try {
      final response = await _dio.put(
        '$_baseUrl/api/units/${unit.id}',
        data: unit.toJson(),
      );
      
      return Unit.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  /// Delete unit
  Future<void> deleteUnit(String unitId) async {
    try {
      await _dio.delete(
        '$_baseUrl/api/units/$unitId',
      );
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  /// Search units by name
  Future<List<Unit>> searchUnits({
    required String tenantId,
    required String query,
    int limit = 20,
  }) async {
    try {
      final response = await _dio.get(
        '$_baseUrl/api/units/search',
        queryParameters: {
          'tenant_id': tenantId,
          'q': query,
          'limit': limit,
        },
      );
      
      final data = response.data as Map<String, dynamic>;
      final unitsList = data['units'] as List<dynamic>;
      
      return unitsList
          .map((e) => Unit.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  /// Check if unit name exists
  Future<bool> unitNameExists({
    required String tenantId,
    required String name,
    String? excludeId,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'tenant_id': tenantId,
        'name': name,
      };
      
      if (excludeId != null) queryParams['exclude_id'] = excludeId;

      final response = await _dio.get(
        '$_baseUrl/api/units/exists',
        queryParameters: queryParams,
      );
      
      final data = response.data as Map<String, dynamic>;
      return data['exists'] as bool;
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return false;
      throw _handleDioException(e);
    }
  }

  /// Handle Dio exceptions and convert to meaningful errors
  Exception _handleDioException(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return Exception('Connection timeout. Please check your internet connection.');
      
      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode;
        final message = e.response?.data?['error']?['message'] ?? 'Server error';
        
        switch (statusCode) {
          case 400:
            return Exception('Bad request: $message');
          case 401:
            return Exception('Unauthorized. Please login again.');
          case 403:
            return Exception('Forbidden. You don\'t have permission to perform this action.');
          case 404:
            return Exception('Unit not found.');
          case 409:
            return Exception('Conflict: $message');
          case 422:
            return Exception('Validation error: $message');
          case 429:
            return Exception('Too many requests. Please try again later.');
          case 500:
            return Exception('Internal server error. Please try again later.');
          default:
            return Exception('Server error ($statusCode): $message');
        }
      
      case DioExceptionType.cancel:
        return Exception('Request was cancelled.');
      
      case DioExceptionType.connectionError:
        return Exception('Connection error. Please check your internet connection.');
      
      case DioExceptionType.badCertificate:
        return Exception('SSL certificate error. Please check your connection.');
      
      case DioExceptionType.unknown:
      default:
        return Exception('Unknown error occurred: ${e.message}');
    }
  }
}
