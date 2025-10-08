import 'package:dio/dio.dart';
import 'package:pos/core/constants/app_constants.dart';
import 'package:pos/shared/models/entities/entities.dart';

class ProductApiService {
  final Dio _dio;
  final String _baseUrl;

  ProductApiService({required Dio dio}) 
      : _dio = dio,
        _baseUrl = '${AppConstants.baseUrl}/${AppConstants.apiVersion}';

  /// Create a new product
  Future<Product> createProduct(Product product) async {
    try {
      final response = await _dio.post(
        '$_baseUrl/api/products',
        data: product.toJson(),
      );
      
      return Product.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  /// Update an existing product
  Future<Product> updateProduct(Product product) async {
    try {
      final response = await _dio.put(
        '$_baseUrl/api/products/${product.id}',
        data: product.toJson(),
      );
      
      return Product.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  /// Get products with pagination and filters
  Future<Map<String, dynamic>> getProducts({
    required String tenantId,
    String? categoryId,
    String? search,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'tenant_id': tenantId,
        'page': page,
        'limit': limit,
      };
      
      if (categoryId != null) queryParams['category_id'] = categoryId;
      if (search != null && search.isNotEmpty) queryParams['search'] = search;

      final response = await _dio.get(
        '$_baseUrl/api/products',
        queryParameters: queryParams,
      );
      
      final data = response.data as Map<String, dynamic>;
      
      // Parse products list
      final productsList = data['products'] as List<dynamic>;
      final products = productsList
          .map((e) => Product.fromJson(e as Map<String, dynamic>))
          .toList();
      
      return {
        'products': products,
        'pagination': data['pagination'],
      };
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  /// Get product by ID
  Future<Product> getProductById(String productId) async {
    try {
      final response = await _dio.get(
        '$_baseUrl/api/products/$productId',
      );
      
      return Product.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  /// Delete product
  Future<void> deleteProduct(String productId) async {
    try {
      await _dio.delete(
        '$_baseUrl/api/products/$productId',
      );
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  /// Get product by SKU
  Future<Product?> getProductBySku(String sku) async {
    try {
      final response = await _dio.get(
        '$_baseUrl/api/products',
        queryParameters: {'sku': sku},
      );
      
      final data = response.data as Map<String, dynamic>;
      final products = data['products'] as List<dynamic>;
      
      if (products.isEmpty) return null;
      
      return Product.fromJson(products.first as Map<String, dynamic>);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return null;
      throw _handleDioException(e);
    }
  }

  /// Get product by barcode
  Future<Product?> getProductByBarcode(String barcode) async {
    try {
      final response = await _dio.get(
        '$_baseUrl/api/products',
        queryParameters: {'barcode': barcode},
      );
      
      final data = response.data as Map<String, dynamic>;
      final products = data['products'] as List<dynamic>;
      
      if (products.isEmpty) return null;
      
      return Product.fromJson(products.first as Map<String, dynamic>);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return null;
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
            return Exception('Product not found.');
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
