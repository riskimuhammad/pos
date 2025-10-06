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
}

class LocalDataSourceImpl implements LocalDataSource {
  final DatabaseHelper _databaseHelper;

  LocalDataSourceImpl(this._databaseHelper);

  sqlite.Database get _database => _databaseHelper.database as sqlite.Database;

  // Tenant operations
  @override
  Future<Tenant> createTenant(Tenant tenant) async {
    final db = _database;
    await db.insert('tenants', tenant.toJson());
    return tenant;
  }

  @override
  Future<Tenant?> getTenant(String id) async {
    final db = _database;
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
    final db = _database;
    final result = await db.query(
      'tenants',
      where: 'deleted_at IS NULL',
      orderBy: 'created_at DESC',
    );
    return result.map((json) => Tenant.fromJson(json)).toList();
  }

  @override
  Future<Tenant> updateTenant(Tenant tenant) async {
    final db = _database;
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
    final db = _database;
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
    final db = _database;
    await db.insert('users', user.toJson());
    return user;
  }

  @override
  Future<User?> getUser(String id) async {
    final db = _database;
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
    final db = _database;
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
    final db = _database;
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
    final db = _database;
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
    final db = _database;
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
    final db = _database;
    await db.insert('categories', category.toJson());
    return category;
  }

  @override
  Future<Category?> getCategory(String id) async {
    final db = _database;
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
    final db = _database;
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
    final db = _database;
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
    final db = _database;
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
    final db = _database;
    await db.update(
      'categories',
      {'deleted_at': DateTime.now().millisecondsSinceEpoch},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Product operations
  @override
  Future<Product> createProduct(Product product) async {
    final db = _database;
    await db.insert('products', product.toJson());
    return product;
  }

  @override
  Future<Product?> getProduct(String id) async {
    final db = _database;
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
    final db = _database;
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
    final db = _database;
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
    final db = _database;
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
    final db = _database;
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
    final db = _database;
    final result = await db.rawQuery('''
      SELECT p.* FROM products p
      JOIN products_fts fts ON p.id = fts.product_id
      WHERE fts MATCH ? AND p.deleted_at IS NULL
      ORDER BY fts.rank
    ''', [query]);
    return result.map((json) => Product.fromJson(json)).toList();
  }

  @override
  Future<Product> updateProduct(Product product) async {
    final db = _database;
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
    final db = _database;
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
    final db = _database;
    await db.insert('locations', location.toJson());
    return location;
  }

  @override
  Future<Location?> getLocation(String id) async {
    final db = _database;
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
    final db = _database;
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
    final db = _database;
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
    final db = _database;
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
    final db = _database;
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
    final db = _database;
    await db.insert('inventory', inventory.toJson());
    return inventory;
  }

  @override
  Future<Inventory?> getInventory(String productId, String locationId) async {
    final db = _database;
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
    final db = _database;
    final result = await db.query(
      'inventory',
      where: 'product_id = ?',
      whereArgs: [productId],
    );
    return result.map((json) => Inventory.fromJson(json)).toList();
  }

  @override
  Future<List<Inventory>> getInventoriesByLocation(String locationId) async {
    final db = _database;
    final result = await db.query(
      'inventory',
      where: 'location_id = ?',
      whereArgs: [locationId],
    );
    return result.map((json) => Inventory.fromJson(json)).toList();
  }

  @override
  Future<List<Inventory>> getLowStockInventories(String tenantId) async {
    final db = _database;
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
    final db = _database;
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
    final db = _database;
    await db.delete(
      'inventory',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Transaction operations
  @override
  Future<Transaction> createTransaction(Transaction transaction) async {
    final db = _database;
    await db.insert('transactions', transaction.toJson());
    return transaction;
  }

  @override
  Future<Transaction?> getTransaction(String id) async {
    final db = _database;
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
    final db = _database;
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
    final db = _database;
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
    final db = _database;
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
    final db = _database;
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
    final db = _database;
    await db.delete(
      'transactions',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Transaction Item operations
  @override
  Future<TransactionItem> createTransactionItem(TransactionItem item) async {
    final db = _database;
    await db.insert('transaction_items', item.toJson());
    return item;
  }

  @override
  Future<List<TransactionItem>> getTransactionItems(String transactionId) async {
    final db = _database;
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
    final db = _database;
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
    final db = _database;
    await db.delete(
      'transaction_items',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Stock Movement operations
  @override
  Future<StockMovement> createStockMovement(StockMovement movement) async {
    final db = _database;
    await db.insert('stock_movements', movement.toJson());
    return movement;
  }

  @override
  Future<List<StockMovement>> getStockMovementsByProduct(String productId) async {
    final db = _database;
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
    final db = _database;
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
    final db = _database;
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
    final db = _database;
    await db.insert('sync_queue', queue.toJson());
    return queue;
  }

  @override
  Future<List<SyncQueue>> getPendingSyncQueues() async {
    final db = _database;
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
    final db = _database;
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
    final db = _database;
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
    final db = _database;
    await db.delete(
      'sync_queue',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  @override
  Future<void> clearCompletedSyncQueues() async {
    final db = _database;
    await db.delete(
      'sync_queue',
      where: 'status = ?',
      whereArgs: [SyncStatus.success.name],
    );
  }
}
