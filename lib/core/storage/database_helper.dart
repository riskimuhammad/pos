import 'package:sqflite_sqlcipher/sqflite.dart';
import 'package:path/path.dart';
import '../constants/app_constants.dart';
import '../errors/exceptions.dart' as app_exceptions;

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    try {
      final dbPath = await getDatabasesPath();
      final path = join(dbPath, AppConstants.databaseName);
      
      return await openDatabase(
        path,
        version: AppConstants.databaseVersion,
        password: AppConstants.databasePassword,
        onCreate: _onCreate,
        onUpgrade: _onUpgrade,
        onOpen: _onOpen,
      );
    } catch (e) {
      throw app_exceptions.DatabaseException(message: 'Failed to initialize database: $e');
    }
  }

  Future<void> _onCreate(Database db, int version) async {
    try {
      // Create all tables
      await _createTables(db);
      await _createIndexes(db);
      await _createTriggers(db);
      await _insertDefaultData(db);
    } catch (e) {
      throw app_exceptions.DatabaseException(message: 'Failed to create database: $e');
    }
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    try {
      // Handle database migrations
      if (oldVersion < newVersion) {
        // Add migration logic here
        await _migrateDatabase(db, oldVersion, newVersion);
      }
    } catch (e) {
      throw app_exceptions.DatabaseException(message: 'Failed to upgrade database: $e');
    }
  }

  Future<void> _onOpen(Database db) async {
    try {
      // Enable foreign keys
      await db.execute('PRAGMA foreign_keys = ON');
      // Set journal mode
      await db.execute('PRAGMA journal_mode = WAL');
      // Set synchronous mode
      await db.execute('PRAGMA synchronous = NORMAL');
    } catch (e) {
      throw app_exceptions.DatabaseException(message: 'Failed to configure database: $e');
    }
  }

  Future<void> _createTables(Database db) async {
    // Tenants table
    await db.execute('''
      CREATE TABLE tenants (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        owner_name TEXT,
        email TEXT,
        phone TEXT,
        address TEXT,
        settings TEXT,
        subscription_tier TEXT DEFAULT 'free',
        subscription_expiry INTEGER,
        is_active INTEGER DEFAULT 1,
        logo_url TEXT,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL,
        deleted_at INTEGER,
        sync_status TEXT DEFAULT 'synced',
        last_synced_at INTEGER
      )
    ''');

    // Users table
    await db.execute('''
      CREATE TABLE users (
        id TEXT PRIMARY KEY,
        tenant_id TEXT NOT NULL,
        username TEXT NOT NULL,
        email TEXT,
        password_hash TEXT NOT NULL,
        full_name TEXT,
        role TEXT NOT NULL,
        permissions TEXT,
        is_active INTEGER DEFAULT 1,
        last_login_at INTEGER,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL,
        deleted_at INTEGER,
        sync_status TEXT DEFAULT 'synced',
        last_synced_at INTEGER,
        FOREIGN KEY (tenant_id) REFERENCES tenants(id)
      )
    ''');

    // Categories table
    await db.execute('''
      CREATE TABLE categories (
        id TEXT PRIMARY KEY,
        tenant_id TEXT NOT NULL,
        name TEXT NOT NULL,
        parent_id TEXT,
        icon TEXT,
        color TEXT,
        sort_order INTEGER DEFAULT 0,
        is_active INTEGER DEFAULT 1,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL,
        deleted_at INTEGER,
        sync_status TEXT DEFAULT 'synced',
        last_synced_at INTEGER,
        FOREIGN KEY (tenant_id) REFERENCES tenants(id),
        FOREIGN KEY (parent_id) REFERENCES categories(id)
      )
    ''');

    // Products table
    await db.execute('''
      CREATE TABLE products (
        id TEXT PRIMARY KEY,
        tenant_id TEXT NOT NULL,
        sku TEXT NOT NULL,
        name TEXT NOT NULL,
        category_id TEXT,
        description TEXT,
        unit TEXT DEFAULT 'pcs',
        price_buy REAL DEFAULT 0,
        price_sell REAL NOT NULL,
        weight REAL,
        has_barcode INTEGER DEFAULT 0,
        barcode TEXT,
        is_expirable INTEGER DEFAULT 0,
        is_active INTEGER DEFAULT 1,
        min_stock INTEGER DEFAULT 0,
        photos TEXT,
        attributes TEXT,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL,
        deleted_at INTEGER,
        sync_status TEXT DEFAULT 'synced',
        last_synced_at INTEGER,
        FOREIGN KEY (tenant_id) REFERENCES tenants(id),
        FOREIGN KEY (category_id) REFERENCES categories(id)
      )
    ''');

    // Locations table
    await db.execute('''
      CREATE TABLE locations (
        id TEXT PRIMARY KEY,
        tenant_id TEXT NOT NULL,
        name TEXT NOT NULL,
        type TEXT DEFAULT 'store',
        address TEXT,
        is_primary INTEGER DEFAULT 0,
        is_active INTEGER DEFAULT 1,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL,
        deleted_at INTEGER,
        sync_status TEXT DEFAULT 'synced',
        last_synced_at INTEGER,
        FOREIGN KEY (tenant_id) REFERENCES tenants(id)
      )
    ''');

    // Inventory table
    await db.execute('''
      CREATE TABLE inventory (
        id TEXT PRIMARY KEY,
        tenant_id TEXT NOT NULL,
        product_id TEXT NOT NULL,
        location_id TEXT NOT NULL,
        quantity INTEGER DEFAULT 0,
        reserved INTEGER DEFAULT 0,
        updated_at INTEGER NOT NULL,
        sync_status TEXT DEFAULT 'synced',
        last_synced_at INTEGER,
        FOREIGN KEY (tenant_id) REFERENCES tenants(id),
        FOREIGN KEY (product_id) REFERENCES products(id),
        FOREIGN KEY (location_id) REFERENCES locations(id)
      )
    ''');

    // Transactions table
    await db.execute('''
      CREATE TABLE transactions (
        id TEXT PRIMARY KEY,
        tenant_id TEXT NOT NULL,
        location_id TEXT NOT NULL,
        user_id TEXT NOT NULL,
        receipt_number TEXT,
        subtotal REAL NOT NULL,
        discount REAL DEFAULT 0,
        tax REAL DEFAULT 0,
        total REAL NOT NULL,
        payment_method TEXT,
        payment_details TEXT,
        amount_paid REAL,
        change_amount REAL,
        status TEXT DEFAULT 'completed',
        notes TEXT,
        customer_name TEXT,
        customer_phone TEXT,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL,
        voided_at INTEGER,
        voided_by TEXT,
        void_reason TEXT,
        sync_status TEXT DEFAULT 'synced',
        last_synced_at INTEGER,
        FOREIGN KEY (tenant_id) REFERENCES tenants(id),
        FOREIGN KEY (location_id) REFERENCES locations(id),
        FOREIGN KEY (user_id) REFERENCES users(id)
      )
    ''');

    // Transaction items table
    await db.execute('''
      CREATE TABLE transaction_items (
        id TEXT PRIMARY KEY,
        transaction_id TEXT NOT NULL,
        product_id TEXT NOT NULL,
        product_name TEXT NOT NULL,
        sku TEXT,
        quantity INTEGER NOT NULL,
        unit_price REAL NOT NULL,
        discount REAL DEFAULT 0,
        subtotal REAL NOT NULL,
        notes TEXT,
        created_at INTEGER NOT NULL,
        FOREIGN KEY (transaction_id) REFERENCES transactions(id) ON DELETE CASCADE,
        FOREIGN KEY (product_id) REFERENCES products(id)
      )
    ''');

    // Stock movements table
    await db.execute('''
      CREATE TABLE stock_movements (
        id TEXT PRIMARY KEY,
        tenant_id TEXT NOT NULL,
        product_id TEXT NOT NULL,
        location_id TEXT NOT NULL,
        type TEXT NOT NULL,
        quantity INTEGER NOT NULL,
        reference_type TEXT,
        reference_id TEXT,
        notes TEXT,
        user_id TEXT,
        created_at INTEGER NOT NULL,
        sync_status TEXT DEFAULT 'synced',
        last_synced_at INTEGER,
        FOREIGN KEY (tenant_id) REFERENCES tenants(id),
        FOREIGN KEY (product_id) REFERENCES products(id),
        FOREIGN KEY (location_id) REFERENCES locations(id),
        FOREIGN KEY (user_id) REFERENCES users(id)
      )
    ''');

    // Sync queue table
    await db.execute('''
      CREATE TABLE sync_queue (
        id TEXT PRIMARY KEY,
        entity_type TEXT NOT NULL,
        entity_id TEXT NOT NULL,
        operation TEXT NOT NULL,
        payload TEXT NOT NULL,
        priority INTEGER DEFAULT 5,
        retry_count INTEGER DEFAULT 0,
        max_retries INTEGER DEFAULT 3,
        status TEXT DEFAULT 'pending',
        error_message TEXT,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL,
        next_retry_at INTEGER
      )
    ''');

    // App settings table
    await db.execute('''
      CREATE TABLE app_settings (
        key TEXT PRIMARY KEY,
        value TEXT,
        updated_at INTEGER NOT NULL
      )
    ''');
  }

  Future<void> _createIndexes(Database db) async {
    // Create indexes for better performance
    await db.execute('CREATE INDEX idx_users_tenant ON users(tenant_id)');
    await db.execute('CREATE INDEX idx_users_username ON users(tenant_id, username)');
    await db.execute('CREATE INDEX idx_products_tenant ON products(tenant_id)');
    await db.execute('CREATE INDEX idx_products_sku ON products(tenant_id, sku)');
    await db.execute('CREATE INDEX idx_products_barcode ON products(barcode)');
    await db.execute('CREATE INDEX idx_inventory_product_location ON inventory(product_id, location_id)');
    await db.execute('CREATE INDEX idx_transactions_tenant ON transactions(tenant_id)');
    await db.execute('CREATE INDEX idx_transactions_created ON transactions(created_at DESC)');
    await db.execute('CREATE INDEX idx_sync_queue_status ON sync_queue(status, priority, created_at)');
  }

  Future<void> _createTriggers(Database db) async {
    // Create triggers for auto-updating timestamps
    await db.execute('''
      CREATE TRIGGER update_tenants_timestamp 
      AFTER UPDATE ON tenants
      FOR EACH ROW
      BEGIN
        UPDATE tenants SET updated_at = strftime('%s','now') WHERE id = NEW.id;
      END
    ''');

    await db.execute('''
      CREATE TRIGGER update_users_timestamp 
      AFTER UPDATE ON users
      FOR EACH ROW
      BEGIN
        UPDATE users SET updated_at = strftime('%s','now') WHERE id = NEW.id;
      END
    ''');

    await db.execute('''
      CREATE TRIGGER update_categories_timestamp 
      AFTER UPDATE ON categories
      FOR EACH ROW
      BEGIN
        UPDATE categories SET updated_at = strftime('%s','now') WHERE id = NEW.id;
      END
    ''');

    await db.execute('''
      CREATE TRIGGER update_products_timestamp 
      AFTER UPDATE ON products
      FOR EACH ROW
      BEGIN
        UPDATE products SET updated_at = strftime('%s','now') WHERE id = NEW.id;
      END
    ''');

    await db.execute('''
      CREATE TRIGGER update_locations_timestamp 
      AFTER UPDATE ON locations
      FOR EACH ROW
      BEGIN
        UPDATE locations SET updated_at = strftime('%s','now') WHERE id = NEW.id;
      END
    ''');

    await db.execute('''
      CREATE TRIGGER update_transactions_timestamp 
      AFTER UPDATE ON transactions
      FOR EACH ROW
      BEGIN
        UPDATE transactions SET updated_at = strftime('%s','now') WHERE id = NEW.id;
      END
    ''');

    // FTS5 triggers for products
    await db.execute('''
      CREATE TRIGGER products_fts_insert AFTER INSERT ON products BEGIN
        INSERT INTO products_fts(product_id, name, sku) VALUES (NEW.id, NEW.name, NEW.sku);
      END
    ''');

    await db.execute('''
      CREATE TRIGGER products_fts_delete AFTER DELETE ON products BEGIN
        DELETE FROM products_fts WHERE product_id = OLD.id;
      END
    ''');

    await db.execute('''
      CREATE TRIGGER products_fts_update AFTER UPDATE ON products BEGIN
        DELETE FROM products_fts WHERE product_id = OLD.id;
        INSERT INTO products_fts(product_id, name, sku) VALUES (NEW.id, NEW.name, NEW.sku);
      END
    ''');
  }

  Future<void> _insertDefaultData(Database db) async {
    // Insert default app settings
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    
    await db.insert('app_settings', {
      'key': 'current_tenant_id',
      'value': '',
      'updated_at': now,
    });
    
    await db.insert('app_settings', {
      'key': 'current_user_id',
      'value': '',
      'updated_at': now,
    });
    
    await db.insert('app_settings', {
      'key': 'last_sync_at',
      'value': '0',
      'updated_at': now,
    });
  }

  Future<void> _migrateDatabase(Database db, int oldVersion, int newVersion) async {
    // Add migration logic here when needed
    // Example:
    // if (oldVersion < 2) {
    //   await db.execute('ALTER TABLE products ADD COLUMN new_field TEXT');
    // }
  }

  Future<void> close() async {
    final db = _database;
    if (db != null) {
      await db.close();
      _database = null;
    }
  }

  Future<void> deleteDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, AppConstants.databaseName);
    await databaseFactory.deleteDatabase(path);
    _database = null;
  }
}
