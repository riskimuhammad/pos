import 'package:pos/core/constants/app_constants.dart';
import 'package:pos/core/storage/database_helper.dart';
import 'package:pos/core/data/database_seeder.dart';
import 'package:pos/shared/models/entities/entities.dart';
import 'package:pos/core/api/product_api_service.dart';
import 'package:pos/core/network/network_info.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:convert';

class ProductSyncService {
  final DatabaseHelper _databaseHelper;
  final DatabaseSeeder _databaseSeeder;
  final ProductApiService? _productApiService;
  final NetworkInfo _networkInfo;

  ProductSyncService({
    required DatabaseHelper databaseHelper,
    required DatabaseSeeder databaseSeeder,
    required NetworkInfo networkInfo,
    ProductApiService? productApiService,
  }) : _databaseHelper = databaseHelper,
       _databaseSeeder = databaseSeeder,
       _networkInfo = networkInfo,
       _productApiService = productApiService;

  /// Sync products from server or use local data
  Future<List<Product>> syncProducts() async {
    try {
      // Check network connectivity
      final isConnected = await _networkInfo.isConnected;
      
      if (AppConstants.kEnableRemoteApi && _productApiService != null && isConnected) {
        // Sync from server when online
        print('🌐 Network available, syncing from server...');
        return await _syncFromServer();
      } else {
        // Use local data when offline or API disabled
        if (!isConnected) {
          print('📱 No network connection, using local data...');
        } else {
          print('🔧 API disabled, using local data...');
        }
        return await _useLocalData();
      }
    } catch (e) {
      print('❌ Product sync failed: $e');
      // Fallback to local data
      return await _useLocalData();
    }
  }

  /// Sync products from server
  Future<List<Product>> _syncFromServer() async {
    try {
      print('🌐 Syncing products from server...');
      
      // Real API call to get products
      final response = await _productApiService!.getProducts(
        tenantId: 'default-tenant-id', // TODO: Get from user session
        limit: 1000, // Get all products
      );
      
      final products = response['products'] as List<Product>;
      
      // Save to local database
      await _saveProductsToLocal(products);
      
      print('✅ Products synced from server: ${products.length} items');
      return products;
    } catch (e) {
      print('❌ Server sync failed: $e');
      rethrow;
    }
  }

  /// Use local data (fallback when offline or API disabled)
  Future<List<Product>> _useLocalData() async {
    try {
      print('📦 Using local product data...');
      
      // Load from local database
      final products = await _loadProductsFromLocal();
      
      if (products.isEmpty) {
        print('📦 No local data found, seeding initial data...');
        // Only seed if no data exists
        await _databaseSeeder.seedDatabase();
        return await _loadProductsFromLocal();
      }
      
      print('✅ Local products loaded: ${products.length} items');
      return products;
    } catch (e) {
      print('❌ Local data loading failed: $e');
      rethrow;
    }
  }

  /// Save products to local database
  Future<void> _saveProductsToLocal(List<Product> products) async {
    final db = await _databaseHelper.database;
    
    for (final product in products) {
      await db.insert(
        'products',
        product.toJson(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
  }

  /// Load products from local database
  Future<List<Product>> _loadProductsFromLocal() async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'products',
      where: 'is_active = ?',
      whereArgs: [1],
      orderBy: 'name ASC',
    );

    return List.generate(maps.length, (i) {
      return Product.fromJson(maps[i]);
    });
  }

  /// Sync single product to server
  Future<void> syncProductToServer(Product product) async {
    if (!AppConstants.kEnableRemoteApi || _productApiService == null) {
      print('⚠️ API sync disabled, skipping server sync');
      return;
    }

    // Check network connectivity
    final isConnected = await _networkInfo.isConnected;
    if (!isConnected) {
      print('📱 No network connection, product will be synced when online: ${product.name}');
      await _addToPendingSyncQueue('CREATE', product);
      return;
    }

    try {
      await _productApiService.createProduct(product);
      print('✅ Product synced to server: ${product.name}');
    } catch (e) {
      print('❌ Failed to sync product to server: $e');
      await _addToPendingSyncQueue('CREATE', product);
      rethrow;
    }
  }

  /// Update product on server
  Future<void> updateProductOnServer(Product product) async {
    if (!AppConstants.kEnableRemoteApi || _productApiService == null) {
      print('⚠️ API sync disabled, skipping server update');
      return;
    }

    // Check network connectivity
    final isConnected = await _networkInfo.isConnected;
    if (!isConnected) {
      print('📱 No network connection, product update will be synced when online: ${product.name}');
      await _addToPendingSyncQueue('UPDATE', product);
      return;
    }

    try {
      await _productApiService.updateProduct(product);
      print('✅ Product updated on server: ${product.name}');
    } catch (e) {
      print('❌ Failed to update product on server: $e');
      await _addToPendingSyncQueue('UPDATE', product);
      rethrow;
    }
  }

  /// Delete product from server
  Future<void> deleteProductFromServer(String productId) async {
    if (!AppConstants.kEnableRemoteApi || _productApiService == null) {
      print('⚠️ API sync disabled, skipping server deletion');
      return;
    }

    // Check network connectivity
    final isConnected = await _networkInfo.isConnected;
    if (!isConnected) {
      print('📱 No network connection, product deletion will be synced when online: $productId');
      await _addToPendingSyncQueue('DELETE', null, productId: productId);
      return;
    }

    try {
      await _productApiService.deleteProduct(productId);
      print('✅ Product deleted from server: $productId');
    } catch (e) {
      print('❌ Failed to delete product from server: $e');
      await _addToPendingSyncQueue('DELETE', null, productId: productId);
      rethrow;
    }
  }

  /// Force refresh from server
  Future<List<Product>> forceRefreshFromServer() async {
    if (!AppConstants.kEnableRemoteApi || _productApiService == null) {
      print('⚠️ API sync disabled, using local data');
      return await _useLocalData();
    }

    try {
      print('🔄 Force refreshing products from server...');
      
      // Clear local data
      await _clearLocalProducts();
      
      // Sync from server
      return await _syncFromServer();
    } catch (e) {
      print('❌ Force refresh failed: $e');
      // Fallback to local data
      return await _useLocalData();
    }
  }

  /// Clear local products
  Future<void> _clearLocalProducts() async {
    final db = await _databaseHelper.database;
    await db.delete('products');
    await db.delete('stock_movements');
    await db.delete('categories');
  }

  /// Get sync status
  String getSyncStatus() {
    if (AppConstants.kEnableRemoteApi) {
      return 'Server Sync Enabled';
    } else {
      return 'Local Data Mode';
    }
  }

  /// Check if server sync is available
  bool isServerSyncAvailable() {
    return AppConstants.kEnableRemoteApi && _productApiService != null;
  }

  /// Listen to network changes and auto-sync when online
  void startNetworkListener() {
    _networkInfo.onConnectivityChanged.listen((isConnected) {
      if (isConnected && AppConstants.kEnableRemoteApi && _productApiService != null) {
        print('🌐 Network restored, auto-syncing...');
        // TODO: Implement auto-sync of pending changes
        _autoSyncPendingChanges();
      } else if (!isConnected) {
        print('📱 Network lost, switching to offline mode');
      }
    });
  }

  /// Auto-sync pending changes when network is restored
  Future<void> _autoSyncPendingChanges() async {
    try {
      print('🔄 Auto-syncing pending changes...');
      
      final db = await _databaseHelper.database;
      final pendingOperations = await db.query(
        'pending_sync_queue',
        orderBy: 'created_at ASC',
      );
      
      for (final operation in pendingOperations) {
        try {
          final operationType = operation['operation_type'] as String;
          final productData = operation['product_data'] as String?;
          final productId = operation['product_id'] as String?;
          
          switch (operationType) {
            case 'CREATE':
              if (productData != null) {
                final product = Product.fromJson(jsonDecode(productData));
                await _productApiService!.createProduct(product);
                print('✅ Auto-synced CREATE: ${product.name}');
              }
              break;
            case 'UPDATE':
              if (productData != null) {
                final product = Product.fromJson(jsonDecode(productData));
                await _productApiService!.updateProduct(product);
                print('✅ Auto-synced UPDATE: ${product.name}');
              }
              break;
            case 'DELETE':
              if (productId != null) {
                await _productApiService!.deleteProduct(productId);
                print('✅ Auto-synced DELETE: $productId');
              }
              break;
          }
          
          // Remove from queue after successful sync
          await db.delete(
            'pending_sync_queue',
            where: 'id = ?',
            whereArgs: [operation['id']],
          );
        } catch (e) {
          print('❌ Failed to auto-sync operation ${operation['id']}: $e');
          // Keep in queue for retry
        }
      }
      
      print('✅ Auto-sync completed');
    } catch (e) {
      print('❌ Auto-sync failed: $e');
    }
  }

  /// Add operation to pending sync queue
  Future<void> _addToPendingSyncQueue(String operationType, Product? product, {String? productId}) async {
    try {
      final db = await _databaseHelper.database;
      
      await db.insert('pending_sync_queue', {
        'operation_type': operationType,
        'product_data': product != null ? jsonEncode(product.toJson()) : null,
        'product_id': productId ?? product?.id,
        'created_at': DateTime.now().millisecondsSinceEpoch,
        'retry_count': 0,
      });
      
      print('📝 Added to pending sync queue: $operationType ${product?.name ?? productId}');
    } catch (e) {
      print('❌ Failed to add to pending sync queue: $e');
    }
  }

  /// Get pending sync queue status
  Future<Map<String, int>> getPendingSyncStatus() async {
    try {
      final db = await _databaseHelper.database;
      final pendingOperations = await db.query('pending_sync_queue');
      
      final status = <String, int>{
        'CREATE': 0,
        'UPDATE': 0,
        'DELETE': 0,
        'TOTAL': pendingOperations.length,
      };
      
      for (final operation in pendingOperations) {
        final type = operation['operation_type'] as String;
        status[type] = (status[type] ?? 0) + 1;
      }
      
      return status;
    } catch (e) {
      print('❌ Failed to get pending sync status: $e');
      return {'TOTAL': 0};
    }
  }

  /// Clear pending sync queue
  Future<void> clearPendingSyncQueue() async {
    try {
      final db = await _databaseHelper.database;
      await db.delete('pending_sync_queue');
      print('🗑️ Pending sync queue cleared');
    } catch (e) {
      print('❌ Failed to clear pending sync queue: $e');
    }
  }
}
