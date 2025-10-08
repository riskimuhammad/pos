import 'package:dio/dio.dart';
import 'package:pos/shared/models/entities/entities.dart';
import 'package:pos/core/constants/app_constants.dart';

abstract class InventoryApiService {
  Future<Map<String, dynamic>> createInventory(Inventory inventory);
  Future<Map<String, dynamic>> updateInventory(Inventory inventory);
  Future<Map<String, dynamic>> deleteInventory(String inventoryId);
  Future<Map<String, dynamic>> getInventoryByProduct(String productId);
  Future<Map<String, dynamic>> getInventoryByLocation(String locationId);
  Future<Map<String, dynamic>> syncInventories(List<Inventory> inventories, String lastSyncTimestamp);
  Future<Map<String, dynamic>> getLowStockProducts(String tenantId);
}

class InventoryApiServiceImpl implements InventoryApiService {
  final Dio _dio;

  InventoryApiServiceImpl(this._dio);

  @override
  Future<Map<String, dynamic>> createInventory(Inventory inventory) async {
    try {
      final response = await _dio.post(
        '${AppConstants.baseUrl}/${AppConstants.apiVersion}/inventory',
        data: inventory.toJson(),
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer ${_getAuthToken()}',
          },
        ),
      );

      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw Exception('Failed to create inventory: ${e.message}');
    }
  }

  @override
  Future<Map<String, dynamic>> updateInventory(Inventory inventory) async {
    try {
      final response = await _dio.put(
        '${AppConstants.baseUrl}/${AppConstants.apiVersion}/inventory/${inventory.id}',
        data: {
          'quantity': inventory.quantity,
          'reserved': inventory.reserved,
          'updated_at': inventory.updatedAt.millisecondsSinceEpoch,
        },
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer ${_getAuthToken()}',
          },
        ),
      );

      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw Exception('Failed to update inventory: ${e.message}');
    }
  }

  @override
  Future<Map<String, dynamic>> deleteInventory(String inventoryId) async {
    try {
      final response = await _dio.delete(
        '${AppConstants.baseUrl}/${AppConstants.apiVersion}/inventory/$inventoryId',
        options: Options(
          headers: {
            'Authorization': 'Bearer ${_getAuthToken()}',
          },
        ),
      );

      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw Exception('Failed to delete inventory: ${e.message}');
    }
  }

  @override
  Future<Map<String, dynamic>> getInventoryByProduct(String productId) async {
    try {
      final response = await _dio.get(
        '${AppConstants.baseUrl}/${AppConstants.apiVersion}/inventory/product/$productId',
        options: Options(
          headers: {
            'Authorization': 'Bearer ${_getAuthToken()}',
          },
        ),
      );

      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw Exception('Failed to get inventory by product: ${e.message}');
    }
  }

  @override
  Future<Map<String, dynamic>> getInventoryByLocation(String locationId) async {
    try {
      final response = await _dio.get(
        '${AppConstants.baseUrl}/${AppConstants.apiVersion}/inventory/location/$locationId',
        options: Options(
          headers: {
            'Authorization': 'Bearer ${_getAuthToken()}',
          },
        ),
      );

      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw Exception('Failed to get inventory by location: ${e.message}');
    }
  }

  @override
  Future<Map<String, dynamic>> syncInventories(List<Inventory> inventories, String lastSyncTimestamp) async {
    try {
      final response = await _dio.post(
        '${AppConstants.baseUrl}/${AppConstants.apiVersion}/inventory/sync',
        data: {
          'device_id': _getDeviceId(),
          'last_sync_timestamp': lastSyncTimestamp,
          'inventories': inventories.map((inventory) => inventory.toJson()).toList(),
        },
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer ${_getAuthToken()}',
          },
        ),
      );

      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw Exception('Failed to sync inventories: ${e.message}');
    }
  }

  @override
  Future<Map<String, dynamic>> getLowStockProducts(String tenantId) async {
    try {
      final response = await _dio.get(
        '${AppConstants.baseUrl}/${AppConstants.apiVersion}/inventory/low-stock',
        queryParameters: {
          'tenant_id': tenantId,
        },
        options: Options(
          headers: {
            'Authorization': 'Bearer ${_getAuthToken()}',
          },
        ),
      );

      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw Exception('Failed to get low stock products: ${e.message}');
    }
  }

  // Helper method to get device ID
  String _getDeviceId() {
    // This should be implemented based on your device ID storage mechanism
    // For now, return a placeholder
    return 'device_${DateTime.now().millisecondsSinceEpoch}';
  }

  // Helper method to get auth token
  String _getAuthToken() {
    // This should be implemented based on your token storage mechanism
    // For now, return a placeholder
    return '';
  }
}
