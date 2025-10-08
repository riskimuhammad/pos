import 'dart:convert';
import 'package:sqflite_sqlcipher/sqflite.dart' as sqlite;
import 'package:pos/core/storage/database_helper.dart';
import 'package:pos/shared/models/entities/entities.dart';

abstract class LocalDataSource {
  // Tenant operations
  Future<Tenant> createTenant(Tenant tenant);
  Future<Tenant?> getTenant(String id);
  Future<List<Tenant>> getAllTenants();
  Future<Tenant> updateTenant(Tenant tenant);
  Future<void> deleteTenant(String id);

  // User operations
  Future<User> createUser(User user);
  Future<User?> getUser(String id);
  Future<User?> getUserByUsername(String username);
  Future<List<User>> getUsersByTenant(String tenantId);
  Future<User> updateUser(User user);
  Future<void> deleteUser(String id);

  // Category operations
  Future<Category> createCategory(Category category);
  Future<Category?> getCategory(String id);
  Future<List<Category>> getCategoriesByTenant(String tenantId);
  Future<List<Category>> getCategoriesByParent(String? parentId);
  Future<Category> updateCategory(Category category);
  Future<void> deleteCategory(String id);

  // Unit operations
  Future<Unit> createUnit(Unit unit);
  Future<Unit?> getUnit(String id);
  Future<List<Unit>> getUnits();
  Future<List<Unit>> getUnitsByTenant(String tenantId);
  Future<List<Unit>> searchUnits(String query);
  Future<bool> unitNameExists(String name, {String? excludeId});
  Future<Unit> updateUnit(Unit unit);
  Future<void> deleteUnit(String id);

  // Product operations
  Future<Product> createProduct(Product product);
  Future<Product?> getProduct(String id);
  Future<Product?> getProductBySku(String sku);
  Future<Product?> getProductByBarcode(String barcode);
  Future<List<Product>> getProductsByTenant(String tenantId);
  Future<List<Product>> getProductsByCategory(String categoryId);
  Future<List<Product>> searchProducts(String query);
  Future<Product> updateProduct(Product product);
  Future<void> deleteProduct(String id);

  // Location operations
  Future<Location> createLocation(Location location);
  Future<Location?> getLocation(String id);
  Future<List<Location>> getLocationsByTenant(String tenantId);
  Future<Location?> getPrimaryLocation(String tenantId);
  Future<Location> updateLocation(Location location);
  Future<void> deleteLocation(String id);

  // Inventory operations
  Future<Inventory> createInventory(Inventory inventory);
  Future<Inventory?> getInventory(String productId, String locationId);
  Future<List<Inventory>> getInventoriesByProduct(String productId);
  Future<List<Inventory>> getInventoriesByLocation(String locationId);
  Future<List<Inventory>> getLowStockInventories(String tenantId);
  Future<Inventory> updateInventory(Inventory inventory);
  Future<void> deleteInventory(String id);
  
  // Stock calculation operations
  Future<int> getCurrentStock(String productId);
  Future<List<Product>> getLowStockProducts(String tenantId);
  Future<void> createInitialInventory(Product product);

  // Transaction operations
  Future<Transaction> createTransaction(Transaction transaction);
  Future<Transaction?> getTransaction(String id);
  Future<List<Transaction>> getTransactionsByTenant(String tenantId);
  Future<List<Transaction>> getTransactionsByUser(String userId);
  Future<List<Transaction>> getTransactionsByDateRange(DateTime start, DateTime end);
  Future<Transaction> updateTransaction(Transaction transaction);
  Future<void> deleteTransaction(String id);

  // Transaction Item operations
  Future<TransactionItem> createTransactionItem(TransactionItem item);
  Future<List<TransactionItem>> getTransactionItems(String transactionId);
  Future<TransactionItem> updateTransactionItem(TransactionItem item);
  Future<void> deleteTransactionItem(String id);

  // Stock Movement operations
  Future<StockMovement> createStockMovement(StockMovement movement);
  Future<List<StockMovement>> getStockMovementsByProduct(String productId);
  Future<List<StockMovement>> getStockMovementsByLocation(String locationId);
  Future<List<StockMovement>> getStockMovementsByDateRange(DateTime start, DateTime end);

  // Sync Queue operations
  Future<SyncQueue> createSyncQueue(SyncQueue queue);
  Future<List<SyncQueue>> getPendingSyncQueues();
  Future<List<SyncQueue>> getFailedSyncQueues();
  Future<SyncQueue> updateSyncQueue(SyncQueue queue);
  Future<void> deleteSyncQueue(String id);
  Future<void> clearCompletedSyncQueues();
  Future<void> addToPendingSyncQueue(String operationType, String entityType, Map<String, dynamic>? entityData, {String? entityId});
}

class LocalDataSourceImpl implements LocalDataSource {
  final DatabaseHelper _databaseHelper;

  LocalDataSourceImpl(this._databaseHelper);

  Future<sqlite.Database> get _database => _databaseHelper.database;

  // Tenant operations
  @override
  Future<Tenant> createTenant(Tenant tenant) async {
    final db = await _database;
    await db.insert('tenants', tenant.toJson());
    return tenant;
  }

  @override
  Future<Tenant?> getTenant(String id) async {
    final db = await _database;
    final result = await db.query(
      'tenants',
      where: 'id = ? AND deleted_at IS NULL',
      whereArgs: [id],
    );
    if (result.isEmpty) return null;
    return Tenant.fromJson(result.first);
  }

  @override
  Future<List<Tenant>> getAllTenants() async {
    final db = await _database;
    final result = await db.query(
      'tenants',
      where: 'deleted_at IS NULL',
      orderBy: 'created_at DESC',
    );
    return result.map((json) => Tenant.fromJson(json)).toList();
  }

  @override
  Future<Tenant> updateTenant(Tenant tenant) async {
    final db = await _database;
    await db.update(
      'tenants',
      tenant.toJson(),
      where: 'id = ?',
      whereArgs: [tenant.id],
    );
    return tenant;
  }

  @override
  Future<void> deleteTenant(String id) async {
    final db = await _database;
    await db.update(
      'tenants',
      {'deleted_at': DateTime.now().millisecondsSinceEpoch},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // User operations
  @override
  Future<User> createUser(User user) async {
    final db = await _database;
    await db.insert('users', user.toJson());
    return user;
  }

  @override
  Future<User?> getUser(String id) async {
    final db = await _database;
    final result = await db.query(
      'users',
      where: 'id = ? AND deleted_at IS NULL',
      whereArgs: [id],
    );
    if (result.isEmpty) return null;
    return User.fromJson(result.first);
  }

  @override
  Future<User?> getUserByUsername(String username) async {
    final db = await _database;
    final result = await db.query(
      'users',
      where: 'username = ? AND deleted_at IS NULL',
      whereArgs: [username],
    );
    if (result.isEmpty) return null;
    return User.fromJson(result.first);
  }

  @override
  Future<List<User>> getUsersByTenant(String tenantId) async {
    final db = await _database;
    final result = await db.query(
      'users',
      where: 'tenant_id = ? AND deleted_at IS NULL',
      whereArgs: [tenantId],
      orderBy: 'created_at DESC',
    );
    return result.map((json) => User.fromJson(json)).toList();
  }

  @override
  Future<User> updateUser(User user) async {
    final db = await _database;
    await db.update(
      'users',
      user.toJson(),
      where: 'id = ?',
      whereArgs: [user.id],
    );
    return user;
  }

  @override
  Future<void> deleteUser(String id) async {
    final db = await _database;
    await db.update(
      'users',
      {'deleted_at': DateTime.now().millisecondsSinceEpoch},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Category operations
  @override
  Future<Category> createCategory(Category category) async {
    final db = await _database;
    await db.insert('categories', category.toJson());
    return category;
  }

  @override
  Future<Category?> getCategory(String id) async {
    final db = await _database;
    final result = await db.query(
      'categories',
      where: 'id = ? AND deleted_at IS NULL',
      whereArgs: [id],
    );
    if (result.isEmpty) return null;
    return Category.fromJson(result.first);
  }

  @override
  Future<List<Category>> getCategoriesByTenant(String tenantId) async {
    final db = await _database;
    final result = await db.query(
      'categories',
      where: 'tenant_id = ? AND deleted_at IS NULL',
      whereArgs: [tenantId],
      orderBy: 'sort_order ASC, name ASC',
    );
    return result.map((json) => Category.fromJson(json)).toList();
  }

  @override
  Future<List<Category>> getCategoriesByParent(String? parentId) async {
    final db = await _database;
    final result = await db.query(
      'categories',
      where: 'parent_id = ? AND deleted_at IS NULL',
      whereArgs: [parentId],
      orderBy: 'sort_order ASC, name ASC',
    );
    return result.map((json) => Category.fromJson(json)).toList();
  }

  @override
  Future<Category> updateCategory(Category category) async {
    final db = await _database;
    await db.update(
      'categories',
      category.toJson(),
      where: 'id = ?',
      whereArgs: [category.id],
    );
    return category;
  }

  @override
  Future<void> deleteCategory(String id) async {
    final db = await _database;
    await db.update(
      'categories',
      {'deleted_at': DateTime.now().millisecondsSinceEpoch},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Unit operations
  @override
  Future<Unit> createUnit(Unit unit) async {
    final db = await _database;
    await db.insert('units', unit.toJson());
    return unit;
  }

  @override
  Future<Unit?> getUnit(String id) async {
    final db = await _database;
    final result = await db.query(
      'units',
      where: 'id = ? AND deleted_at IS NULL',
      whereArgs: [id],
    );
    if (result.isEmpty) return null;
    return Unit.fromJson(result.first);
  }

  @override
  Future<List<Unit>> getUnits() async {
    final db = await _database;
    final result = await db.query(
      'units',
      where: 'deleted_at IS NULL AND is_active = 1',
      orderBy: 'name ASC',
    );
    return result.map((json) => Unit.fromJson(json)).toList();
  }

  @override
  Future<List<Unit>> getUnitsByTenant(String tenantId) async {
    final db = await _database;
    final result = await db.query(
      'units',
      where: 'tenant_id = ? AND deleted_at IS NULL AND is_active = 1',
      whereArgs: [tenantId],
      orderBy: 'name ASC',
    );
    return result.map((json) => Unit.fromJson(json)).toList();
  }

  @override
  Future<List<Unit>> searchUnits(String query) async {
    final db = await _database;
    final result = await db.query(
      'units',
      where: 'name LIKE ? AND deleted_at IS NULL AND is_active = 1',
      whereArgs: ['%$query%'],
      orderBy: 'name ASC',
    );
    return result.map((json) => Unit.fromJson(json)).toList();
  }

  @override
  Future<bool> unitNameExists(String name, {String? excludeId}) async {
    final db = await _database;
    String whereClause = 'name = ? AND deleted_at IS NULL';
    List<dynamic> whereArgs = [name];
    
    if (excludeId != null) {
      whereClause += ' AND id != ?';
      whereArgs.add(excludeId);
    }

    final result = await db.query(
      'units',
      where: whereClause,
      whereArgs: whereArgs,
    );

    return result.isNotEmpty;
  }

  @override
  Future<Unit> updateUnit(Unit unit) async {
    final db = await _database;
    await db.update(
      'units',
      unit.toJson(),
      where: 'id = ?',
      whereArgs: [unit.id],
    );
    return unit;
  }

  @override
  Future<void> deleteUnit(String id) async {
    final db = await _database;
    await db.update(
      'units',
      {'deleted_at': DateTime.now().millisecondsSinceEpoch},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Product operations
  @override
  Future<Product> createProduct(Product product) async {
    final db = await _database;
    await db.insert('products', product.toJson());
    return product;
  }

  @override
  Future<Product?> getProduct(String id) async {
    final db = await _database;
    final result = await db.query(
      'products',
      where: 'id = ? AND deleted_at IS NULL',
      whereArgs: [id],
    );
    if (result.isEmpty) return null;
    return Product.fromJson(result.first);
  }

  @override
  Future<Product?> getProductBySku(String sku) async {
    final db = await _database;
    final result = await db.query(
      'products',
      where: 'sku = ? AND deleted_at IS NULL',
      whereArgs: [sku],
    );
    if (result.isEmpty) return null;
    return Product.fromJson(result.first);
  }

  @override
  Future<Product?> getProductByBarcode(String barcode) async {
    final db = await _database;
    final result = await db.query(
      'products',
      where: 'barcode = ? AND deleted_at IS NULL',
      whereArgs: [barcode],
    );
    if (result.isEmpty) return null;
    return Product.fromJson(result.first);
  }

  @override
  Future<List<Product>> getProductsByTenant(String tenantId) async {
    final db = await _database;
    final result = await db.query(
      'products',
      where: 'tenant_id = ? AND deleted_at IS NULL',
      whereArgs: [tenantId],
      orderBy: 'name ASC',
    );
    return result.map((json) => Product.fromJson(json)).toList();
  }

  @override
  Future<List<Product>> getProductsByCategory(String categoryId) async {
    final db = await _database;
    final result = await db.query(
      'products',
      where: 'category_id = ? AND deleted_at IS NULL',
      whereArgs: [categoryId],
      orderBy: 'name ASC',
    );
    return result.map((json) => Product.fromJson(json)).toList();
  }

  @override
  Future<List<Product>> searchProducts(String query) async {
    final db = await _database;
    
    // Use regular LIKE search for now (FTS has issues)
    // TODO: Fix FTS table and query syntax later
    final result = await db.rawQuery('''
      SELECT * FROM products 
      WHERE (name LIKE ? OR sku LIKE ? OR description LIKE ?) 
      AND deleted_at IS NULL
      ORDER BY 
        CASE 
          WHEN name LIKE ? THEN 1
          WHEN sku LIKE ? THEN 2
          WHEN description LIKE ? THEN 3
          ELSE 4
        END,
        name
    ''', [
      '%$query%', '%$query%', '%$query%',  // WHERE conditions
      '%$query%', '%$query%', '%$query%'   // ORDER BY conditions
    ]);
    return result.map((json) => Product.fromJson(json)).toList();
  }

  @override
  Future<Product> updateProduct(Product product) async {
    final db = await _database;
    await db.update(
      'products',
      product.toJson(),
      where: 'id = ?',
      whereArgs: [product.id],
    );
    return product;
  }

  @override
  Future<void> deleteProduct(String id) async {
    final db = await _database;
    await db.update(
      'products',
      {'deleted_at': DateTime.now().millisecondsSinceEpoch},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Location operations
  @override
  Future<Location> createLocation(Location location) async {
    final db = await _database;
    await db.insert('locations', location.toJson());
    return location;
  }

  @override
  Future<Location?> getLocation(String id) async {
    final db = await _database;
    final result = await db.query(
      'locations',
      where: 'id = ? AND deleted_at IS NULL',
      whereArgs: [id],
    );
    if (result.isEmpty) return null;
    return Location.fromJson(result.first);
  }

  @override
  Future<List<Location>> getLocationsByTenant(String tenantId) async {
    final db = await _database;
    final result = await db.query(
      'locations',
      where: 'tenant_id = ? AND deleted_at IS NULL',
      whereArgs: [tenantId],
      orderBy: 'is_primary DESC, name ASC',
    );
    return result.map((json) => Location.fromJson(json)).toList();
  }

  @override
  Future<Location?> getPrimaryLocation(String tenantId) async {
    final db = await _database;
    final result = await db.query(
      'locations',
      where: 'tenant_id = ? AND is_primary = 1 AND deleted_at IS NULL',
      whereArgs: [tenantId],
    );
    if (result.isEmpty) return null;
    return Location.fromJson(result.first);
  }

  @override
  Future<Location> updateLocation(Location location) async {
    final db = await _database;
    await db.update(
      'locations',
      location.toJson(),
      where: 'id = ?',
      whereArgs: [location.id],
    );
    return location;
  }

  @override
  Future<void> deleteLocation(String id) async {
    final db = await _database;
    await db.update(
      'locations',
      {'deleted_at': DateTime.now().millisecondsSinceEpoch},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Inventory operations
  @override
  Future<Inventory> createInventory(Inventory inventory) async {
    final db = await _database;
    await db.insert('inventory', inventory.toJson());
    return inventory;
  }

  @override
  Future<Inventory?> getInventory(String productId, String locationId) async {
    final db = await _database;
    final result = await db.query(
      'inventory',
      where: 'product_id = ? AND location_id = ?',
      whereArgs: [productId, locationId],
    );
    if (result.isEmpty) return null;
    return Inventory.fromJson(result.first);
  }

  @override
  Future<List<Inventory>> getInventoriesByProduct(String productId) async {
    final db = await _database;
    final result = await db.query(
      'inventory',
      where: 'product_id = ?',
      whereArgs: [productId],
    );
    return result.map((json) => Inventory.fromJson(json)).toList();
  }

  @override
  Future<List<Inventory>> getInventoriesByLocation(String locationId) async {
    final db = await _database;
    final result = await db.query(
      'inventory',
      where: 'location_id = ?',
      whereArgs: [locationId],
    );
    return result.map((json) => Inventory.fromJson(json)).toList();
  }

  @override
  Future<List<Inventory>> getLowStockInventories(String tenantId) async {
    final db = await _database;
    final result = await db.rawQuery('''
      SELECT i.* FROM inventory i
      JOIN products p ON i.product_id = p.id
      WHERE p.tenant_id = ? AND i.quantity <= p.min_stock
      ORDER BY i.quantity ASC
    ''', [tenantId]);
    return result.map((json) => Inventory.fromJson(json)).toList();
  }

  @override
  Future<Inventory> updateInventory(Inventory inventory) async {
    final db = await _database;
    await db.update(
      'inventory',
      inventory.toJson(),
      where: 'id = ?',
      whereArgs: [inventory.id],
    );
    return inventory;
  }

  @override
  Future<void> deleteInventory(String id) async {
    final db = await _database;
    await db.delete(
      'inventory',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Stock calculation operations
  @override
  Future<int> getCurrentStock(String productId) async {
    final db = await _database;
    
    // Get initial stock from inventory table
    final inventoryResult = await db.rawQuery('''
      SELECT SUM(quantity) as total_inventory
      FROM inventory 
      WHERE product_id = ?
    ''', [productId]);
    
    final initialStock = (inventoryResult.first['total_inventory'] as int?) ?? 0;
    
    // Get stock movements (purchases + sales + adjustments)
    final movementsResult = await db.rawQuery('''
      SELECT 
        SUM(CASE WHEN type = 'purchase' THEN quantity ELSE 0 END) as total_purchases,
        SUM(CASE WHEN type = 'sale' THEN quantity ELSE 0 END) as total_sales,
        SUM(CASE WHEN type = 'adjustment' THEN quantity ELSE 0 END) as total_adjustments
      FROM stock_movements 
      WHERE product_id = ?
    ''', [productId]);
    
    final totalPurchases = (movementsResult.first['total_purchases'] as int?) ?? 0;
    final totalSales = (movementsResult.first['total_sales'] as int?) ?? 0;
    final totalAdjustments = (movementsResult.first['total_adjustments'] as int?) ?? 0;
    
    // Calculate current stock: initial + purchases - sales + adjustments
    final currentStock = initialStock + totalPurchases - totalSales + totalAdjustments;
    
    print('📊 Stock calculation for $productId:');
    print('  Initial: $initialStock');
    print('  Purchases: +$totalPurchases');
    print('  Sales: -$totalSales');
    print('  Adjustments: +$totalAdjustments');
    print('  Current: $currentStock');
    
    return currentStock;
  }

  @override
  Future<List<Product>> getLowStockProducts(String tenantId) async {
    // Get all products for tenant
    final products = await getProductsByTenant(tenantId);
    final lowStockProducts = <Product>[];
    
    for (final product in products) {
      try {
        final reorderPoint = product.attributes['reorder_point'] as int? ?? product.minStock;
        final currentStock = await getCurrentStock(product.id);
        
        // Check if this is a new product (created within last 7 days)
        final isNewProduct = DateTime.now().difference(product.createdAt).inDays < 7;
        
        // Only consider as low stock if:
        // 1. Not a new product (older than 7 days), OR
        // 2. New product but has stock movements (purchases/sales)
        final hasMovements = await _hasStockMovements(product.id);
        if (!isNewProduct || hasMovements) {
          if (currentStock <= reorderPoint) {
            lowStockProducts.add(product);
            print('📊 Low stock: ${product.name} (current: $currentStock, reorder: $reorderPoint)');
          }
        } else {
          print('📊 New product (${product.name}) - not considered low stock yet');
        }
      } catch (e) {
        print('❌ Error checking low stock for product ${product.id}: $e');
      }
    }
    
    return lowStockProducts;
  }
  
  /// Check if product has any stock movements
  Future<bool> _hasStockMovements(String productId) async {
    final db = await _database;
    final result = await db.rawQuery('''
      SELECT COUNT(*) as movement_count
      FROM stock_movements 
      WHERE product_id = ?
    ''', [productId]);
    
    final movementCount = (result.first['movement_count'] as int?) ?? 0;
    return movementCount > 0;
  }

  @override
  Future<void> createInitialInventory(Product product) async {
    try {
      // Get primary location for the tenant
      final primaryLocation = await getPrimaryLocation(product.tenantId);
      if (primaryLocation == null) {
        print('❌ No primary location found for tenant: ${product.tenantId}');
        return;
      }

      // Create initial inventory record with stock = 0
      final inventory = Inventory(
        id: 'inv_${DateTime.now().millisecondsSinceEpoch}',
        tenantId: product.tenantId,
        productId: product.id,
        locationId: primaryLocation.id,
        quantity: 0, // Initial stock = 0
        reserved: 0,
        updatedAt: DateTime.now(),
        syncStatus: 'pending',
        lastSyncedAt: null,
      );

      await createInventory(inventory);
      print('✅ Initial inventory created for product: ${product.name} (stock: 0)');
    } catch (e) {
      print('❌ Error creating initial inventory for product ${product.id}: $e');
      rethrow;
    }
  }

  // Transaction operations
  @override
  Future<Transaction> createTransaction(Transaction transaction) async {
    final db = await _database;
    await db.insert('transactions', transaction.toJson());
    return transaction;
  }

  @override
  Future<Transaction?> getTransaction(String id) async {
    final db = await _database;
    final result = await db.query(
      'transactions',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (result.isEmpty) return null;
    return Transaction.fromJson(result.first);
  }

  @override
  Future<List<Transaction>> getTransactionsByTenant(String tenantId) async {
    final db = await _database;
    final result = await db.query(
      'transactions',
      where: 'tenant_id = ?',
      whereArgs: [tenantId],
      orderBy: 'created_at DESC',
    );
    return result.map((json) => Transaction.fromJson(json)).toList();
  }

  @override
  Future<List<Transaction>> getTransactionsByUser(String userId) async {
    final db = await _database;
    final result = await db.query(
      'transactions',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'created_at DESC',
    );
    return result.map((json) => Transaction.fromJson(json)).toList();
  }

  @override
  Future<List<Transaction>> getTransactionsByDateRange(DateTime start, DateTime end) async {
    final db = await _database;
    final result = await db.query(
      'transactions',
      where: 'created_at BETWEEN ? AND ?',
      whereArgs: [start.millisecondsSinceEpoch, end.millisecondsSinceEpoch],
      orderBy: 'created_at DESC',
    );
    return result.map((json) => Transaction.fromJson(json)).toList();
  }

  @override
  Future<Transaction> updateTransaction(Transaction transaction) async {
    final db = await _database;
    await db.update(
      'transactions',
      transaction.toJson(),
      where: 'id = ?',
      whereArgs: [transaction.id],
    );
    return transaction;
  }

  @override
  Future<void> deleteTransaction(String id) async {
    final db = await _database;
    await db.delete(
      'transactions',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Transaction Item operations
  @override
  Future<TransactionItem> createTransactionItem(TransactionItem item) async {
    final db = await _database;
    await db.insert('transaction_items', item.toJson());
    return item;
  }

  @override
  Future<List<TransactionItem>> getTransactionItems(String transactionId) async {
    final db = await _database;
    final result = await db.query(
      'transaction_items',
      where: 'transaction_id = ?',
      whereArgs: [transactionId],
      orderBy: 'created_at ASC',
    );
    return result.map((json) => TransactionItem.fromJson(json)).toList();
  }

  @override
  Future<TransactionItem> updateTransactionItem(TransactionItem item) async {
    final db = await _database;
    await db.update(
      'transaction_items',
      item.toJson(),
      where: 'id = ?',
      whereArgs: [item.id],
    );
    return item;
  }

  @override
  Future<void> deleteTransactionItem(String id) async {
    final db = await _database;
    await db.delete(
      'transaction_items',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Stock Movement operations
  @override
  Future<StockMovement> createStockMovement(StockMovement movement) async {
    final db = await _database;
    await db.insert('stock_movements', movement.toJson());
    return movement;
  }

  @override
  Future<List<StockMovement>> getStockMovementsByProduct(String productId) async {
    final db = await _database;
    final result = await db.query(
      'stock_movements',
      where: 'product_id = ?',
      whereArgs: [productId],
      orderBy: 'created_at DESC',
    );
    return result.map((json) => StockMovement.fromJson(json)).toList();
  }

  @override
  Future<List<StockMovement>> getStockMovementsByLocation(String locationId) async {
    final db = await _database;
    final result = await db.query(
      'stock_movements',
      where: 'location_id = ?',
      whereArgs: [locationId],
      orderBy: 'created_at DESC',
    );
    return result.map((json) => StockMovement.fromJson(json)).toList();
  }

  @override
  Future<List<StockMovement>> getStockMovementsByDateRange(DateTime start, DateTime end) async {
    final db = await _database;
    final result = await db.query(
      'stock_movements',
      where: 'created_at BETWEEN ? AND ?',
      whereArgs: [start.millisecondsSinceEpoch, end.millisecondsSinceEpoch],
      orderBy: 'created_at DESC',
    );
    return result.map((json) => StockMovement.fromJson(json)).toList();
  }

  // Sync Queue operations
  @override
  Future<SyncQueue> createSyncQueue(SyncQueue queue) async {
    final db = await _database;
    await db.insert('sync_queue', queue.toJson());
    return queue;
  }

  @override
  Future<List<SyncQueue>> getPendingSyncQueues() async {
    final db = await _database;
    final result = await db.query(
      'sync_queue',
      where: 'status = ?',
      whereArgs: [SyncStatus.pending.name],
      orderBy: 'priority ASC, created_at ASC',
    );
    return result.map((json) => SyncQueue.fromJson(json)).toList();
  }

  @override
  Future<List<SyncQueue>> getFailedSyncQueues() async {
    final db = await _database;
    final result = await db.query(
      'sync_queue',
      where: 'status = ? AND retry_count < max_retries',
      whereArgs: [SyncStatus.failed.name],
      orderBy: 'priority ASC, created_at ASC',
    );
    return result.map((json) => SyncQueue.fromJson(json)).toList();
  }

  @override
  Future<SyncQueue> updateSyncQueue(SyncQueue queue) async {
    final db = await _database;
    await db.update(
      'sync_queue',
      queue.toJson(),
      where: 'id = ?',
      whereArgs: [queue.id],
    );
    return queue;
  }

  @override
  Future<void> deleteSyncQueue(String id) async {
    final db = await _database;
    await db.delete(
      'sync_queue',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  @override
  Future<void> clearCompletedSyncQueues() async {
    final db = await _database;
    await db.delete(
      'sync_queue',
      where: 'status = ?',
      whereArgs: [SyncStatus.success.name],
    );
  }

  @override
  Future<void> addToPendingSyncQueue(String operationType, String entityType, Map<String, dynamic>? entityData, {String? entityId}) async {
    final db = await _database;
    await db.insert('pending_sync_queue', {
      'operation_type': operationType,
      'entity_type': entityType,
      'entity_data': entityData != null ? jsonEncode(entityData) : null,
      'entity_id': entityId,
      'created_at': DateTime.now().millisecondsSinceEpoch,
      'retry_count': 0,
    });
  }
}
