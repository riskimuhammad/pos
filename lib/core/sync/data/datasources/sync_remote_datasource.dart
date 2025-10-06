import 'package:dio/dio.dart';
import 'package:get_storage/get_storage.dart';
import '../../domain/entities/sync_queue.dart';

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
    // TODO: Replace with real API endpoint when hosting is ready
    // For now, simulate API response
    await Future.delayed(Duration(seconds: 1)); // Simulate network delay
    
    return {
      'success': true,
      'message': 'Products synced successfully',
      'synced_count': products.length,
      'server_timestamp': DateTime.now().toIso8601String(),
      'conflicts': [],
    };
  }

  @override
  Future<Map<String, dynamic>> syncTransactions(List<Map<String, dynamic>> transactions, String lastSyncTimestamp) async {
    // TODO: Replace with real API endpoint when hosting is ready
    await Future.delayed(Duration(seconds: 1));
    
    return {
      'success': true,
      'message': 'Transactions synced successfully',
      'synced_count': transactions.length,
      'server_timestamp': DateTime.now().toIso8601String(),
      'conflicts': [],
    };
  }

  @override
  Future<Map<String, dynamic>> syncCategories(List<Map<String, dynamic>> categories, String lastSyncTimestamp) async {
    // TODO: Replace with real API endpoint when hosting is ready
    await Future.delayed(Duration(seconds: 1));
    
    return {
      'success': true,
      'message': 'Categories synced successfully',
      'synced_count': categories.length,
      'server_timestamp': DateTime.now().toIso8601String(),
      'conflicts': [],
    };
  }

  @override
  Future<Map<String, dynamic>> getUpdates(String lastSyncTimestamp) async {
    // TODO: Replace with real API endpoint when hosting is ready
    await Future.delayed(Duration(seconds: 1));
    
    return {
      'success': true,
      'updates': {
        'products': [],
        'categories': [],
        'transactions': [],
      },
      'server_timestamp': DateTime.now().toIso8601String(),
    };
  }

  @override
  Future<Map<String, dynamic>> uploadSyncQueue(List<SyncQueue> syncItems) async {
    // TODO: Replace with real API endpoint when hosting is ready
    await Future.delayed(Duration(seconds: 2));
    
    // Simulate some failures for testing
    final failedItems = <String>[];
    if (syncItems.length > 5) {
      failedItems.add(syncItems[0].id); // Simulate first item failure
    }
    
    return {
      'success': true,
      'message': 'Sync queue uploaded successfully',
      'synced_count': syncItems.length - failedItems.length,
      'failed_items': failedItems,
      'server_timestamp': DateTime.now().toIso8601String(),
    };
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
}

// Mock implementation for testing
class MockSyncRemoteDataSource implements SyncRemoteDataSource {
  @override
  Future<Map<String, dynamic>> syncProducts(List<Map<String, dynamic>> products, String lastSyncTimestamp) async {
    await Future.delayed(Duration(milliseconds: 500));
    return {
      'success': true,
      'message': 'Products synced successfully (MOCK)',
      'synced_count': products.length,
      'server_timestamp': DateTime.now().toIso8601String(),
    };
  }

  @override
  Future<Map<String, dynamic>> syncTransactions(List<Map<String, dynamic>> transactions, String lastSyncTimestamp) async {
    await Future.delayed(Duration(milliseconds: 500));
    return {
      'success': true,
      'message': 'Transactions synced successfully (MOCK)',
      'synced_count': transactions.length,
      'server_timestamp': DateTime.now().toIso8601String(),
    };
  }

  @override
  Future<Map<String, dynamic>> syncCategories(List<Map<String, dynamic>> categories, String lastSyncTimestamp) async {
    await Future.delayed(Duration(milliseconds: 500));
    return {
      'success': true,
      'message': 'Categories synced successfully (MOCK)',
      'synced_count': categories.length,
      'server_timestamp': DateTime.now().toIso8601String(),
    };
  }

  @override
  Future<Map<String, dynamic>> getUpdates(String lastSyncTimestamp) async {
    await Future.delayed(Duration(milliseconds: 500));
    return {
      'success': true,
      'updates': {
        'products': [],
        'categories': [],
        'transactions': [],
      },
      'server_timestamp': DateTime.now().toIso8601String(),
    };
  }

  @override
  Future<Map<String, dynamic>> uploadSyncQueue(List<SyncQueue> syncItems) async {
    await Future.delayed(Duration(milliseconds: 800));
    return {
      'success': true,
      'message': 'Sync queue uploaded successfully (MOCK)',
      'synced_count': syncItems.length,
      'failed_items': [],
      'server_timestamp': DateTime.now().toIso8601String(),
    };
  }
}
