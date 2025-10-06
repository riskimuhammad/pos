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
      // Enable foreign keys (use rawQuery for PRAGMA with SQLCipher)
      await db.rawQuery('PRAGMA foreign_keys = ON');
      // SQLCipher: prefer DELETE journal mode for compatibility
      await db.rawQuery('PRAGMA journal_mode = DELETE');
      // Set synchronous mode
      await db.rawQuery('PRAGMA synchronous = NORMAL');
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
        brand TEXT,
        variant TEXT,
        pack_size TEXT,
        uom TEXT DEFAULT 'pcs',
        category_id TEXT,
        description TEXT,
        price_buy REAL DEFAULT 0,
        price_sell REAL NOT NULL,
        weight REAL,
        has_barcode INTEGER DEFAULT 0,
        barcode TEXT,
        is_expirable INTEGER DEFAULT 0,
        is_active INTEGER DEFAULT 1,
        min_stock INTEGER DEFAULT 0,
        reorder_point INTEGER DEFAULT 0,
        reorder_qty INTEGER DEFAULT 0,
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
        cost_price REAL DEFAULT 0,
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

    // AI scans table removed

    // AI training samples table (user-labeled images)
    await db.execute('''
      CREATE TABLE ai_training_samples (
        id TEXT PRIMARY KEY,
        image_path TEXT NOT NULL,
        label TEXT NOT NULL,
        created_at INTEGER NOT NULL,
        synced_at INTEGER,
        sync_status TEXT DEFAULT 'pending'
      )
    ''');

    // AI learning samples table (for local learning from user feedback)
    await db.execute('''
      CREATE TABLE ai_learning_samples (
        id TEXT PRIMARY KEY,
        image_path TEXT NOT NULL,
        product_id TEXT NOT NULL,
        features TEXT,
        confidence REAL,
        timestamp INTEGER NOT NULL,
        sync_status TEXT DEFAULT 'pending',
        error_message TEXT,
        FOREIGN KEY (product_id) REFERENCES products (id)
      )
    ''');

    // Regional price table
    await db.execute('''
      CREATE TABLE regional_price (
        id TEXT PRIMARY KEY,
        tenant_id TEXT NOT NULL,
        product_id TEXT NOT NULL,
        region_code TEXT NOT NULL,
        avg_price REAL NOT NULL,
        min_price REAL,
        max_price REAL,
        sample_count INTEGER DEFAULT 0,
        updated_at INTEGER NOT NULL,
        sync_status TEXT DEFAULT 'synced',
        last_synced_at INTEGER,
        FOREIGN KEY (tenant_id) REFERENCES tenants(id),
        FOREIGN KEY (product_id) REFERENCES products(id)
      )
    ''');

    // Sync queue table (updated schema)
    await db.execute('''
      CREATE TABLE sync_queue (
        id TEXT PRIMARY KEY,
        table_name TEXT NOT NULL,
        operation TEXT NOT NULL,
        data TEXT NOT NULL,
        timestamp INTEGER NOT NULL,
        is_synced INTEGER DEFAULT 0,
        retry_count INTEGER DEFAULT 0,
        error_message TEXT
      )
    ''');

    // Sync status table
    await db.execute('''
      CREATE TABLE sync_status (
        id TEXT PRIMARY KEY,
        last_sync_timestamp INTEGER NOT NULL,
        sync_version TEXT NOT NULL,
        is_online INTEGER DEFAULT 0,
        pending_items_count INTEGER DEFAULT 0
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
    await db.execute('CREATE INDEX idx_sync_queue_status ON sync_queue(is_synced, timestamp)');
    await db.execute('CREATE INDEX idx_sync_queue_table ON sync_queue(table_name, is_synced)');
    // index for ai_scans removed
    await db.execute('CREATE INDEX idx_ai_training_samples_status ON ai_training_samples(sync_status, created_at)');
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
    // Migration from version 1 to 2: Add AI training samples table
    if (oldVersion < 2) {
      // Check if ai_training_samples table exists, if not create it
      final result = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='table' AND name='ai_training_samples'"
      );
      
      if (result.isEmpty) {
        await db.execute('''
          CREATE TABLE ai_training_samples (
            id TEXT PRIMARY KEY,
            image_path TEXT NOT NULL,
            label TEXT NOT NULL,
            created_at INTEGER NOT NULL,
            synced_at INTEGER,
            sync_status TEXT DEFAULT 'pending'
          )
        ''');
        
        // Create index for the new table
        await db.execute('CREATE INDEX idx_ai_training_samples_status ON ai_training_samples(sync_status, created_at)');
      }
    }
    // Migration to version 3: Ensure ai_learning_samples exists
    if (oldVersion < 3) {
      final result = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='table' AND name='ai_learning_samples'"
      );
      if (result.isEmpty) {
        await db.execute('''
          CREATE TABLE ai_learning_samples (
            id TEXT PRIMARY KEY,
            image_path TEXT NOT NULL,
            product_id TEXT NOT NULL,
            features TEXT,
            confidence REAL,
            timestamp INTEGER NOT NULL,
            sync_status TEXT DEFAULT 'pending',
            error_message TEXT,
            FOREIGN KEY (product_id) REFERENCES products (id)
          )
        ''');
      }
    }
    // Migration to version 4: add product details, stock_movements.cost_price, regional_price
    if (oldVersion < 4) {
      // Products new columns
      final cols = await db.rawQuery("PRAGMA table_info(products)");
      final colNames = cols.map((e) => e['name'] as String).toSet();
      if (!colNames.contains('brand')) {
        await db.execute("ALTER TABLE products ADD COLUMN brand TEXT");
      }
      if (!colNames.contains('variant')) {
        await db.execute("ALTER TABLE products ADD COLUMN variant TEXT");
      }
      if (!colNames.contains('pack_size')) {
        await db.execute("ALTER TABLE products ADD COLUMN pack_size TEXT");
      }
      if (!colNames.contains('uom')) {
        await db.execute("ALTER TABLE products ADD COLUMN uom TEXT DEFAULT 'pcs'");
      }
      if (!colNames.contains('reorder_point')) {
        await db.execute("ALTER TABLE products ADD COLUMN reorder_point INTEGER DEFAULT 0");
      }
      if (!colNames.contains('reorder_qty')) {
        await db.execute("ALTER TABLE products ADD COLUMN reorder_qty INTEGER DEFAULT 0");
      }

      // Stock movements new column
      final smCols = await db.rawQuery("PRAGMA table_info(stock_movements)");
      final smColNames = smCols.map((e) => e['name'] as String).toSet();
      if (!smColNames.contains('cost_price')) {
        await db.execute("ALTER TABLE stock_movements ADD COLUMN cost_price REAL DEFAULT 0");
      }

      // Regional price table create if missing
      final rp = await db.rawQuery("SELECT name FROM sqlite_master WHERE type='table' AND name='regional_price'");
      if (rp.isEmpty) {
        await db.execute('''
          CREATE TABLE regional_price (
            id TEXT PRIMARY KEY,
            tenant_id TEXT NOT NULL,
            product_id TEXT NOT NULL,
            region_code TEXT NOT NULL,
            avg_price REAL NOT NULL,
            min_price REAL,
            max_price REAL,
            sample_count INTEGER DEFAULT 0,
            updated_at INTEGER NOT NULL,
            sync_status TEXT DEFAULT 'synced',
            last_synced_at INTEGER,
            FOREIGN KEY (tenant_id) REFERENCES tenants(id),
            FOREIGN KEY (product_id) REFERENCES products(id)
          )
        ''');
      }
    }
    // Drop legacy ai_scans table if exists
    final scans = await db.rawQuery("SELECT name FROM sqlite_master WHERE type='table' AND name='ai_scans'");
    if (scans.isNotEmpty) {
      await db.execute('DROP TABLE IF EXISTS ai_scans');
    }
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
