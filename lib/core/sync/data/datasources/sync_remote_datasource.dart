import 'package:dio/dio.dart';
import 'package:get_storage/get_storage.dart';
import '../../domain/entities/sync_queue.dart';
import '../../../constants/app_constants.dart';

abstract class SyncRemoteDataSource {
  Future<Map<String, dynamic>> syncProducts(List<Map<String, dynamic>> products, String lastSyncTimestamp);
  Future<Map<String, dynamic>> syncTransactions(List<Map<String, dynamic>> transactions, String lastSyncTimestamp);
  Future<Map<String, dynamic>> syncCategories(List<Map<String, dynamic>> categories, String lastSyncTimestamp);
  Future<Map<String, dynamic>> getUpdates(String lastSyncTimestamp);
  Future<Map<String, dynamic>> uploadSyncQueue(List<SyncQueue> syncItems);
}

class SyncRemoteDataSourceImpl implements SyncRemoteDataSource {
  final Dio dio;
  final GetStorage storage;

  SyncRemoteDataSourceImpl({
    required this.dio,
    required this.storage,
  });

  String get _deviceId => storage.read('device_id') ?? 'unknown_device';

  @override
  Future<Map<String, dynamic>> syncProducts(List<Map<String, dynamic>> products, String lastSyncTimestamp) async {
    if (!AppConstants.kEnableRemoteApi) {
      throw Exception('Remote API is disabled');
    }

    try {
      final response = await dio.post(
        '${AppConstants.baseUrl}/${AppConstants.apiVersion}/sync/products',
        data: {
          'products': products,
          'last_sync_timestamp': lastSyncTimestamp,
          'device_id': _deviceId,
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
      throw Exception('Failed to sync products: ${e.message}');
    }
  }

  @override
  Future<Map<String, dynamic>> syncTransactions(List<Map<String, dynamic>> transactions, String lastSyncTimestamp) async {
    if (!AppConstants.kEnableRemoteApi) {
      throw Exception('Remote API is disabled');
    }

    try {
      final response = await dio.post(
        '${AppConstants.baseUrl}/${AppConstants.apiVersion}/sync/transactions',
        data: {
          'transactions': transactions,
          'last_sync_timestamp': lastSyncTimestamp,
          'device_id': _deviceId,
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
      throw Exception('Failed to sync transactions: ${e.message}');
    }
  }

  @override
  Future<Map<String, dynamic>> syncCategories(List<Map<String, dynamic>> categories, String lastSyncTimestamp) async {
    if (!AppConstants.kEnableRemoteApi) {
      throw Exception('Remote API is disabled');
    }

    try {
      final response = await dio.post(
        '${AppConstants.baseUrl}/${AppConstants.apiVersion}/sync/categories',
        data: {
          'categories': categories,
          'last_sync_timestamp': lastSyncTimestamp,
          'device_id': _deviceId,
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
      throw Exception('Failed to sync categories: ${e.message}');
    }
  }

  @override
  Future<Map<String, dynamic>> getUpdates(String lastSyncTimestamp) async {
    if (!AppConstants.kEnableRemoteApi) {
      throw Exception('Remote API is disabled');
    }

    try {
      final response = await dio.get(
        '${AppConstants.baseUrl}/${AppConstants.apiVersion}/sync/updates',
        queryParameters: {
          'last_sync_timestamp': lastSyncTimestamp,
          'device_id': _deviceId,
        },
        options: Options(
          headers: {
            'Authorization': 'Bearer ${_getAuthToken()}',
          },
        ),
      );

      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw Exception('Failed to get updates: ${e.message}');
    }
  }

  @override
  Future<Map<String, dynamic>> uploadSyncQueue(List<SyncQueue> syncItems) async {
    if (!AppConstants.kEnableRemoteApi) {
      throw Exception('Remote API is disabled');
    }

    try {
      final response = await dio.post(
        '${AppConstants.baseUrl}/${AppConstants.apiVersion}/sync/queue/upload',
        data: {
          'sync_items': syncItems.map((item) => item.toJson()).toList(),
          'device_id': _deviceId,
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
      throw Exception('Failed to upload sync queue: ${e.message}');
    }
  }

  // Helper method to get device ID
  Future<String> _getDeviceId() async {
    String? deviceId = storage.read('device_id');
    if (deviceId == null) {
      deviceId = 'device_${DateTime.now().millisecondsSinceEpoch}';
      await storage.write('device_id', deviceId);
    }
    return deviceId;
  }

  // Helper method to get auth token
  String _getAuthToken() {
    return storage.read(AppConstants.tokenKey) ?? '';
  }
}

