import 'package:pos/core/storage/database_helper.dart';
import 'package:pos/core/data/dummy_products.dart';
import 'package:pos/shared/models/entities/entities.dart';
import 'package:sqflite/sqflite.dart'; // Import for ConflictAlgorithm

class DatabaseSeeder {
  final DatabaseHelper _databaseHelper;

  DatabaseSeeder(this._databaseHelper);

  /// Seed database with dummy data
  Future<void> seedDatabase() async {
    try {
      print('🌱 Starting database seeding...');
      
      // Seed tenant and location first (required for foreign keys)
      await _seedTenantAndLocation();
      
      // Seed system user (required for stock movements)
      await _seedSystemUser();
      
      // Seed categories
      await _seedCategories();
      
      // Seed products
      await _seedProducts();
      
      // Seed stock movements
      await _seedStockMovements();
      
      print('✅ Database seeding completed successfully!');
    } catch (e) {
      print('❌ Database seeding failed: $e');
      
      // If FTS table error, try to reset database and retry
      if (e.toString().contains('products_fts')) {
        print('🔄 FTS table error detected, resetting database...');
        try {
          await _databaseHelper.resetDatabase();
          print('🌱 Retrying database seeding after reset...');
          
          // Retry seeding
          await _seedTenantAndLocation();
          await _seedSystemUser();
          await _seedCategories();
          await _seedProducts();
          await _seedStockMovements();
          
          print('✅ Database seeding completed successfully after reset!');
          return;
        } catch (retryError) {
          print('❌ Database seeding failed even after reset: $retryError');
          rethrow;
        }
      }
      
      rethrow;
    }
  }

  /// Seed tenant and location (required for foreign keys)
  Future<void> _seedTenantAndLocation() async {
    final db = await _databaseHelper.database;
    
    // Check if tenant already exists
    final existingTenant = await db.query(
      'tenants',
      where: 'id = ?',
      whereArgs: ['default-tenant-id'],
    );
    
    if (existingTenant.isEmpty) {
      // Create default tenant
      final tenant = Tenant(
        id: 'default-tenant-id',
        name: 'Warung UMKM Demo',
        ownerName: 'Demo Owner',
        email: 'demo@warung.com',
        phone: '+6281234567890',
        address: 'Jl. Demo No. 123, Jakarta',
        subscriptionTier: 'free',
        isActive: true,
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
        updatedAt: DateTime.now().subtract(const Duration(days: 1)),
        syncStatus: 'synced',
        lastSyncedAt: DateTime.now().subtract(const Duration(days: 1)),
      );
      
      await db.insert('tenants', tenant.toJson(), conflictAlgorithm: ConflictAlgorithm.replace);
      print('🏢 Seeded default tenant');
    }
    
    // Check if location already exists
    final existingLocation = await db.query(
      'locations',
      where: 'id = ?',
      whereArgs: ['default-location-id'],
    );
    
    if (existingLocation.isEmpty) {
      // Create default location
      final location = Location(
        id: 'default-location-id',
        tenantId: 'default-tenant-id',
        name: 'Toko Utama',
        type: 'store',
        address: 'Jl. Demo No. 123, Jakarta',
        isPrimary: true,
        isActive: true,
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
        updatedAt: DateTime.now().subtract(const Duration(days: 1)),
        syncStatus: 'synced',
        lastSyncedAt: DateTime.now().subtract(const Duration(days: 1)),
      );
      
      await db.insert('locations', location.toJson(), conflictAlgorithm: ConflictAlgorithm.replace);
      print('📍 Seeded default location');
    }
  }

  /// Seed system user (required for stock movements)
  Future<void> _seedSystemUser() async {
    final db = await _databaseHelper.database;
    
    // Check if system user already exists
    final existingUser = await db.query(
      'users',
      where: 'id = ?',
      whereArgs: ['system'],
    );
    
    if (existingUser.isEmpty) {
      // Create system user
      final user = User(
        id: 'system',
        tenantId: 'default-tenant-id',
        username: 'system',
        email: 'system@warung.com',
        passwordHash: 'system_hash', // This is just for seeding, not real auth
        fullName: 'System User',
        role: 'admin',
        isActive: true,
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
        updatedAt: DateTime.now().subtract(const Duration(days: 1)),
        syncStatus: 'synced',
        lastSyncedAt: DateTime.now().subtract(const Duration(days: 1)),
      );
      
      await db.insert('users', user.toJson(), conflictAlgorithm: ConflictAlgorithm.replace);
      print('👤 Seeded system user');
    }
  }

  /// Seed categories
  Future<void> _seedCategories() async {
    final categories = DummyProducts.getCategories();
    final db = await _databaseHelper.database;
    
    for (int i = 0; i < categories.length; i++) {
      final category = Category(
        id: 'cat_${i + 1}',
        tenantId: 'default-tenant-id',
        name: categories[i],
        isActive: true,
        createdAt: DateTime.now().subtract(Duration(days: 30 - i)),
        updatedAt: DateTime.now().subtract(Duration(days: 5 - i)),
      );
      
      await db.insert('categories', category.toJson(), conflictAlgorithm: ConflictAlgorithm.replace);
    }
    
    print('📁 Seeded ${categories.length} categories');
  }

  /// Seed products
  Future<void> _seedProducts() async {
    final products = DummyProducts.getIndonesianUMKMProducts();
    final db = await _databaseHelper.database;
    
    for (final product in products) {
      await db.insert('products', product.toJson(), conflictAlgorithm: ConflictAlgorithm.replace);
    }
    
    print('📦 Seeded ${products.length} products');
  }

  /// Seed stock movements for initial stock
  Future<void> _seedStockMovements() async {
    final products = DummyProducts.getIndonesianUMKMProducts();
    final db = await _databaseHelper.database;
    
    for (final product in products) {
      final stockMovement = StockMovement(
        id: 'sm_${product.id}',
        tenantId: 'default-tenant-id',
        productId: product.id,
        locationId: 'default-location-id',
        type: StockMovementType.purchase,
        quantity: product.minStock,
        costPrice: product.priceBuy, // Use product's buy price as cost price
        referenceType: 'initial_stock',
        referenceId: 'initial_${product.id}',
        notes: 'Initial stock seeding',
        userId: 'system',
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
        syncStatus: 'synced',
        lastSyncedAt: DateTime.now().subtract(const Duration(days: 30)),
      );
      
      await db.insert('stock_movements', stockMovement.toJson(), conflictAlgorithm: ConflictAlgorithm.replace);
    }
    
    print('📊 Seeded ${products.length} stock movements');
  }

  /// Clear all seeded data
  Future<void> clearSeededData() async {
    try {
      final db = await _databaseHelper.database;
      
      // Delete in reverse order to respect foreign key constraints
      await db.delete('stock_movements');
      await db.delete('products');
      await db.delete('categories');
      await db.delete('locations');
      await db.delete('tenants');
      
      print('🗑️ Cleared all seeded data');
    } catch (e) {
      print('❌ Failed to clear seeded data: $e');
      rethrow;
    }
  }

  /// Check if database is already seeded
  Future<bool> isSeeded() async {
    try {
      final db = await _databaseHelper.database;
      final result = await db.rawQuery('SELECT COUNT(*) as count FROM products');
      final count = result.first['count'] as int;
      return count > 0;
    } catch (e) {
      return false;
    }
  }
}
