import 'package:pos/core/storage/database_helper.dart';
import 'package:pos/shared/models/entities/entities.dart';
import 'package:sqflite/sqflite.dart'; // Import for ConflictAlgorithm

class DatabaseSeeder {
  final DatabaseHelper _databaseHelper;

  DatabaseSeeder(this._databaseHelper);

  /// Initialize database with minimal required data (no dummy data)
  Future<void> seedDatabase() async {
    try {
      print('🌱 Initializing database with minimal required data...');
      
      
      // Seed tenant and location first (required for foreign keys)
      await _seedTenantAndLocation();
      
      // Seed system user (required for stock movements)
      await _seedSystemUser();
      
      print('✅ Database initialization completed successfully!');
      print('📝 Note: Only essential data seeded (tenant, location, user).');
      print('📝 Users must add their own categories and units before creating products.');
    } catch (e) {
      print('❌ Database initialization failed: $e');
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
        name: 'Default Tenant',
        address: 'Default Address',
        phone: '0000000000',
        email: 'default@tenant.com',
        isActive: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        deletedAt: null,
        syncStatus: 'synced',
        lastSyncedAt: DateTime.now(),
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
        name: 'Main Store',
        type: 'store',
        address: 'Main Store Address',
        isPrimary: true, // Set as primary location
        isActive: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        deletedAt: null,
        syncStatus: 'synced',
        lastSyncedAt: DateTime.now(),
      );
      
      await db.insert('locations', location.toJson(), conflictAlgorithm: ConflictAlgorithm.replace);
      print('📍 Seeded default location');
    } else {
      // Update existing location to be primary if it's not already
      final existingLocationData = existingLocation.first;
      if ((existingLocationData['is_primary'] as int? ?? 0) == 0) {
        await db.update(
          'locations',
          {'is_primary': 1, 'name': 'Main Store', 'type': 'store'},
          where: 'id = ?',
          whereArgs: ['default-location-id'],
        );
        print('📍 Updated existing location to be primary');
      }
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
        email: 'system@pos.com',
        passwordHash: 'system_hash',
        fullName: 'System User',
        role: 'system',
        permissions: ['all'],
        isActive: true,
        lastLoginAt: null,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        deletedAt: null,
        syncStatus: 'synced',
        lastSyncedAt: DateTime.now(),
      );
      
      await db.insert('users', user.toJson(), conflictAlgorithm: ConflictAlgorithm.replace);
      print('👤 Seeded system user');
    }
  }



  /// Clear all seeded data (for testing)
  Future<void> clearSeededData() async {
    try {
      final db = await _databaseHelper.database;
      
      // Clear in reverse order of dependencies
      await db.delete('stock_movements');
      await db.delete('products');
      await db.delete('categories');
      await db.delete('units');
      await db.delete('users');
      await db.delete('locations');
      await db.delete('tenants');
      
      print('🧹 Cleared all seeded data');
    } catch (e) {
      print('❌ Failed to clear seeded data: $e');
      rethrow;
    }
  }

  /// Fix products without inventory records
  Future<void> fixProductsWithoutInventory() async {
    final db = await _databaseHelper.database;
    
    // Get all products that don't have inventory records
    final productsWithoutInventory = await db.rawQuery('''
      SELECT p.* FROM products p
      LEFT JOIN inventory i ON p.id = i.product_id
      WHERE i.product_id IS NULL AND p.deleted_at IS NULL
    ''');
    
    if (productsWithoutInventory.isNotEmpty) {
      print('🔧 Found ${productsWithoutInventory.length} products without inventory records');
      
      // Get primary location
      final primaryLocation = await db.query(
        'locations',
        where: 'tenant_id = ? AND is_primary = 1 AND deleted_at IS NULL',
        whereArgs: ['default-tenant-id'],
      );
      
      if (primaryLocation.isNotEmpty) {
        final locationId = primaryLocation.first['id'] as String;
        
        for (final productData in productsWithoutInventory) {
          final productId = productData['id'] as String;
          final productName = productData['name'] as String;
          
          // Create inventory record
          final inventory = {
            'id': 'inv_${DateTime.now().millisecondsSinceEpoch}_${productId}',
            'tenant_id': 'default-tenant-id',
            'product_id': productId,
            'location_id': locationId,
            'quantity': 0,
            'reserved': 0,
            'updated_at': DateTime.now().millisecondsSinceEpoch,
            'sync_status': 'pending',
            'last_synced_at': null,
          };
          
          await db.insert('inventory', inventory);
          print('✅ Created inventory for product: $productName');
        }
      } else {
        print('❌ No primary location found, cannot create inventory records');
      }
    } else {
      print('✅ All products already have inventory records');
    }
  }

}