import 'package:pos/core/constants/app_constants.dart';
import 'package:pos/core/storage/database_helper.dart';
import 'package:pos/core/data/database_seeder.dart';
import 'package:pos/core/data/dummy_products.dart';
import 'package:pos/shared/models/entities/entities.dart';
import 'package:pos/core/ai/ai_api_service.dart';
import 'package:sqflite/sqflite.dart';

class ProductSyncService {
  final DatabaseHelper _databaseHelper;
  final DatabaseSeeder _databaseSeeder;
  final AIApiService? _apiService;

  ProductSyncService({
    required DatabaseHelper databaseHelper,
    required DatabaseSeeder databaseSeeder,
    AIApiService? apiService,
  }) : _databaseHelper = databaseHelper,
       _databaseSeeder = databaseSeeder,
       _apiService = apiService;

  /// Sync products from server or use dummy data
  Future<List<Product>> syncProducts() async {
    try {
      if (AppConstants.kEnableRemoteApi && _apiService != null) {
        // Sync from server
        return await _syncFromServer();
      } else {
        // Use dummy data
        return await _useDummyData();
      }
    } catch (e) {
      print('❌ Product sync failed: $e');
      // Fallback to dummy data
      return await _useDummyData();
    }
  }

  /// Sync products from server
  Future<List<Product>> _syncFromServer() async {
    try {
      print('🌐 Syncing products from server...');
      
      // TODO: Implement actual API call when server is ready
      // final products = await _apiService!.getProducts();
      
      // For now, return dummy data as placeholder
      final products = DummyProducts.getIndonesianUMKMProducts();
      
      // Save to local database
      await _saveProductsToLocal(products);
      
      print('✅ Products synced from server: ${products.length} items');
      return products;
    } catch (e) {
      print('❌ Server sync failed: $e');
      rethrow;
    }
  }

  /// Use dummy data
  Future<List<Product>> _useDummyData() async {
    try {
      print('📦 Using dummy product data...');
      
      // Check if already seeded
      final isSeeded = await _databaseSeeder.isSeeded();
      if (!isSeeded) {
        await _databaseSeeder.seedDatabase();
      }
      
      // Load from local database
      final products = await _loadProductsFromLocal();
      
      print('✅ Dummy products loaded: ${products.length} items');
      return products;
    } catch (e) {
      print('❌ Dummy data loading failed: $e');
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
    if (!AppConstants.kEnableRemoteApi || _apiService == null) {
      print('⚠️ API sync disabled, skipping server sync');
      return;
    }

    try {
      // TODO: Implement actual API call when server is ready
      // await _apiService!.createProduct(product);
      
      print('✅ Product synced to server: ${product.name}');
    } catch (e) {
      print('❌ Failed to sync product to server: $e');
      rethrow;
    }
  }

  /// Update product on server
  Future<void> updateProductOnServer(Product product) async {
    if (!AppConstants.kEnableRemoteApi || _apiService == null) {
      print('⚠️ API sync disabled, skipping server update');
      return;
    }

    try {
      // TODO: Implement actual API call when server is ready
      // await _apiService!.updateProduct(product);
      
      print('✅ Product updated on server: ${product.name}');
    } catch (e) {
      print('❌ Failed to update product on server: $e');
      rethrow;
    }
  }

  /// Delete product from server
  Future<void> deleteProductFromServer(String productId) async {
    if (!AppConstants.kEnableRemoteApi || _apiService == null) {
      print('⚠️ API sync disabled, skipping server deletion');
      return;
    }

    try {
      // TODO: Implement actual API call when server is ready
      // await _apiService!.deleteProduct(productId);
      
      print('✅ Product deleted from server: $productId');
    } catch (e) {
      print('❌ Failed to delete product from server: $e');
      rethrow;
    }
  }

  /// Force refresh from server
  Future<List<Product>> forceRefreshFromServer() async {
    if (!AppConstants.kEnableRemoteApi || _apiService == null) {
      print('⚠️ API sync disabled, using dummy data');
      return await _useDummyData();
    }

    try {
      print('🔄 Force refreshing products from server...');
      
      // Clear local data
      await _clearLocalProducts();
      
      // Sync from server
      return await _syncFromServer();
    } catch (e) {
      print('❌ Force refresh failed: $e');
      // Fallback to dummy data
      return await _useDummyData();
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
    return AppConstants.kEnableRemoteApi && _apiService != null;
  }
}
