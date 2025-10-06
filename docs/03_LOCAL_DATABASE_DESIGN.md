# Local Database Design (SQLite)

## Overview
Database lokal menggunakan SQLite untuk mendukung offline-first architecture. Data disimpan di device dan disinkronisasi ke server saat online.

## Design Principles
1. **Offline-First**: Semua operasi CRUD dapat dilakukan tanpa koneksi
2. **Sync Status**: Setiap tabel memiliki kolom untuk tracking sync status
3. **Soft Delete**: Menggunakan soft delete (is_deleted flag) untuk kemudahan sync
4. **Audit Trail**: Timestamp created_at, updated_at, deleted_at
5. **Tenant Isolation**: Semua data ter-scope ke tenant_id

---

## Schema Definition (SQLite)

### 1. Table: tenants
Menyimpan informasi tenant/toko

```sql
CREATE TABLE tenants (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  owner_name TEXT,
  email TEXT,
  phone TEXT,
  address TEXT,
  settings TEXT, -- JSON string untuk settings
  subscription_tier TEXT DEFAULT 'free', -- free, basic, premium
  subscription_expiry INTEGER, -- Unix timestamp
  is_active INTEGER DEFAULT 1,
  logo_url TEXT,
  created_at INTEGER NOT NULL,
  updated_at INTEGER NOT NULL,
  deleted_at INTEGER,
  sync_status TEXT DEFAULT 'synced', -- synced, pending, failed
  last_synced_at INTEGER
);

CREATE INDEX idx_tenants_sync ON tenants(sync_status);
```

---

### 2. Table: users
Menyimpan data user

```sql
CREATE TABLE users (
  id TEXT PRIMARY KEY,
  tenant_id TEXT NOT NULL,
  username TEXT NOT NULL,
  email TEXT,
  password_hash TEXT NOT NULL,
  full_name TEXT,
  role TEXT NOT NULL, -- owner, manager, cashier
  permissions TEXT, -- JSON array of permissions
  is_active INTEGER DEFAULT 1,
  last_login_at INTEGER,
  created_at INTEGER NOT NULL,
  updated_at INTEGER NOT NULL,
  deleted_at INTEGER,
  sync_status TEXT DEFAULT 'synced',
  last_synced_at INTEGER,
  FOREIGN KEY (tenant_id) REFERENCES tenants(id)
);

CREATE UNIQUE INDEX idx_users_username ON users(tenant_id, username) WHERE deleted_at IS NULL;
CREATE INDEX idx_users_tenant ON users(tenant_id);
CREATE INDEX idx_users_sync ON users(sync_status);
```

---

### 3. Table: categories
Kategori produk dengan support hierarchical

```sql
CREATE TABLE categories (
  id TEXT PRIMARY KEY,
  tenant_id TEXT NOT NULL,
  name TEXT NOT NULL,
  parent_id TEXT, -- untuk sub-kategori
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
);

CREATE INDEX idx_categories_tenant ON categories(tenant_id);
CREATE INDEX idx_categories_parent ON categories(parent_id);
CREATE INDEX idx_categories_sync ON categories(sync_status);
```

---

### 4. Table: products
Master produk

```sql
CREATE TABLE products (
  id TEXT PRIMARY KEY,
  tenant_id TEXT NOT NULL,
  sku TEXT NOT NULL,
  name TEXT NOT NULL,
  category_id TEXT,
  description TEXT,
  unit TEXT DEFAULT 'pcs', -- pcs, kg, liter, box, dll
  price_buy REAL DEFAULT 0,
  price_sell REAL NOT NULL,
  weight REAL, -- dalam gram
  has_barcode INTEGER DEFAULT 0,
  barcode TEXT,
  is_expirable INTEGER DEFAULT 0,
  is_active INTEGER DEFAULT 1,
  min_stock INTEGER DEFAULT 0, -- minimum stock untuk alert
  photos TEXT, -- JSON array of photo URLs
  attributes TEXT, -- JSON untuk attributes tambahan
  created_at INTEGER NOT NULL,
  updated_at INTEGER NOT NULL,
  deleted_at INTEGER,
  sync_status TEXT DEFAULT 'synced',
  last_synced_at INTEGER,
  FOREIGN KEY (tenant_id) REFERENCES tenants(id),
  FOREIGN KEY (category_id) REFERENCES categories(id)
);

CREATE UNIQUE INDEX idx_products_sku ON products(tenant_id, sku) WHERE deleted_at IS NULL;
CREATE INDEX idx_products_tenant ON products(tenant_id);
CREATE INDEX idx_products_category ON products(category_id);
CREATE INDEX idx_products_barcode ON products(barcode) WHERE barcode IS NOT NULL;
CREATE INDEX idx_products_name ON products(name);
CREATE INDEX idx_products_sync ON products(sync_status);

-- Full-text search untuk nama produk
CREATE VIRTUAL TABLE products_fts USING fts5(
  product_id UNINDEXED,
  name,
  sku,
  tokenize='porter'
);
```

---

### 5. Table: locations
Lokasi penyimpanan (toko, gudang)

```sql
CREATE TABLE locations (
  id TEXT PRIMARY KEY,
  tenant_id TEXT NOT NULL,
  name TEXT NOT NULL,
  type TEXT DEFAULT 'store', -- store, warehouse
  address TEXT,
  is_primary INTEGER DEFAULT 0,
  is_active INTEGER DEFAULT 1,
  created_at INTEGER NOT NULL,
  updated_at INTEGER NOT NULL,
  deleted_at INTEGER,
  sync_status TEXT DEFAULT 'synced',
  last_synced_at INTEGER,
  FOREIGN KEY (tenant_id) REFERENCES tenants(id)
);

CREATE INDEX idx_locations_tenant ON locations(tenant_id);
CREATE INDEX idx_locations_sync ON locations(sync_status);
```

---

### 6. Table: inventory
Stock per produk per lokasi

```sql
CREATE TABLE inventory (
  id TEXT PRIMARY KEY,
  tenant_id TEXT NOT NULL,
  product_id TEXT NOT NULL,
  location_id TEXT NOT NULL,
  quantity INTEGER DEFAULT 0,
  reserved INTEGER DEFAULT 0, -- qty yang direserve untuk order
  updated_at INTEGER NOT NULL,
  sync_status TEXT DEFAULT 'synced',
  last_synced_at INTEGER,
  FOREIGN KEY (tenant_id) REFERENCES tenants(id),
  FOREIGN KEY (product_id) REFERENCES products(id),
  FOREIGN KEY (location_id) REFERENCES locations(id)
);

CREATE UNIQUE INDEX idx_inventory_product_location ON inventory(product_id, location_id);
CREATE INDEX idx_inventory_tenant ON inventory(tenant_id);
CREATE INDEX idx_inventory_product ON inventory(product_id);
CREATE INDEX idx_inventory_location ON inventory(location_id);
CREATE INDEX idx_inventory_sync ON inventory(sync_status);
```

---

### 7. Table: stock_movements
History pergerakan stok

```sql
CREATE TABLE stock_movements (
  id TEXT PRIMARY KEY,
  tenant_id TEXT NOT NULL,
  product_id TEXT NOT NULL,
  location_id TEXT NOT NULL,
  type TEXT NOT NULL, -- SALE, PURCHASE, RETURN, ADJUSTMENT, TRANSFER, DAMAGE, EXPIRED
  quantity INTEGER NOT NULL, -- positif untuk in, negatif untuk out
  reference_type TEXT, -- transaction, purchase_order, adjustment
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
);

CREATE INDEX idx_stock_movements_tenant ON stock_movements(tenant_id);
CREATE INDEX idx_stock_movements_product ON stock_movements(product_id);
CREATE INDEX idx_stock_movements_location ON stock_movements(location_id);
CREATE INDEX idx_stock_movements_reference ON stock_movements(reference_type, reference_id);
CREATE INDEX idx_stock_movements_created ON stock_movements(created_at DESC);
CREATE INDEX idx_stock_movements_sync ON stock_movements(sync_status);
```

---

### 8. Table: transactions
Transaksi penjualan

```sql
CREATE TABLE transactions (
  id TEXT PRIMARY KEY,
  tenant_id TEXT NOT NULL,
  location_id TEXT NOT NULL,
  user_id TEXT NOT NULL, -- kasir
  receipt_number TEXT,
  subtotal REAL NOT NULL,
  discount REAL DEFAULT 0,
  tax REAL DEFAULT 0,
  total REAL NOT NULL,
  payment_method TEXT, -- cash, qris, e-wallet, transfer, split
  payment_details TEXT, -- JSON untuk detail payment (split payment, dll)
  amount_paid REAL,
  change_amount REAL,
  status TEXT DEFAULT 'completed', -- draft, completed, voided, refunded, partial_refunded
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
);

CREATE UNIQUE INDEX idx_transactions_receipt ON transactions(tenant_id, receipt_number) WHERE receipt_number IS NOT NULL;
CREATE INDEX idx_transactions_tenant ON transactions(tenant_id);
CREATE INDEX idx_transactions_user ON transactions(user_id);
CREATE INDEX idx_transactions_status ON transactions(status);
CREATE INDEX idx_transactions_created ON transactions(created_at DESC);
CREATE INDEX idx_transactions_sync ON transactions(sync_status);
```

---

### 9. Table: transaction_items
Item dalam transaksi

```sql
CREATE TABLE transaction_items (
  id TEXT PRIMARY KEY,
  transaction_id TEXT NOT NULL,
  product_id TEXT NOT NULL,
  product_name TEXT NOT NULL, -- snapshot nama produk saat transaksi
  sku TEXT,
  quantity INTEGER NOT NULL,
  unit_price REAL NOT NULL,
  discount REAL DEFAULT 0,
  subtotal REAL NOT NULL,
  notes TEXT,
  created_at INTEGER NOT NULL,
  FOREIGN KEY (transaction_id) REFERENCES transactions(id) ON DELETE CASCADE,
  FOREIGN KEY (product_id) REFERENCES products(id)
);

CREATE INDEX idx_transaction_items_transaction ON transaction_items(transaction_id);
CREATE INDEX idx_transaction_items_product ON transaction_items(product_id);
```

---

### 10. Table: parked_transactions
Transaksi yang di-hold/park sementara

```sql
CREATE TABLE parked_transactions (
  id TEXT PRIMARY KEY,
  tenant_id TEXT NOT NULL,
  user_id TEXT NOT NULL,
  data TEXT NOT NULL, -- JSON snapshot transaction + items
  created_at INTEGER NOT NULL,
  FOREIGN KEY (tenant_id) REFERENCES tenants(id),
  FOREIGN KEY (user_id) REFERENCES users(id)
);

CREATE INDEX idx_parked_transactions_tenant ON parked_transactions(tenant_id);
CREATE INDEX idx_parked_transactions_user ON parked_transactions(user_id);
```

---

### 11. Table: product_detection_events
Event deteksi produk via AI

```sql
CREATE TABLE product_detection_events (
  id TEXT PRIMARY KEY,
  tenant_id TEXT NOT NULL,
  user_id TEXT NOT NULL,
  image_path TEXT NOT NULL, -- local file path
  image_url TEXT, -- URL after sync to cloud
  predictions TEXT NOT NULL, -- JSON array of {product_id, confidence}
  selected_product_id TEXT,
  is_correct INTEGER, -- 1 jika prediksi benar, 0 jika salah/dikoreksi
  feedback_notes TEXT,
  inference_time_ms INTEGER,
  model_version TEXT,
  created_at INTEGER NOT NULL,
  sync_status TEXT DEFAULT 'synced',
  last_synced_at INTEGER,
  FOREIGN KEY (tenant_id) REFERENCES tenants(id),
  FOREIGN KEY (user_id) REFERENCES users(id),
  FOREIGN KEY (selected_product_id) REFERENCES products(id)
);

CREATE INDEX idx_detection_events_tenant ON product_detection_events(tenant_id);
CREATE INDEX idx_detection_events_created ON product_detection_events(created_at DESC);
CREATE INDEX idx_detection_events_sync ON product_detection_events(sync_status);
```

---

### 12. Table: sync_queue
Queue untuk sinkronisasi

```sql
CREATE TABLE sync_queue (
  id TEXT PRIMARY KEY,
  entity_type TEXT NOT NULL, -- transaction, product, inventory, dll
  entity_id TEXT NOT NULL,
  operation TEXT NOT NULL, -- insert, update, delete
  payload TEXT NOT NULL, -- JSON data
  priority INTEGER DEFAULT 5, -- 1=highest, 10=lowest
  retry_count INTEGER DEFAULT 0,
  max_retries INTEGER DEFAULT 3,
  status TEXT DEFAULT 'pending', -- pending, processing, success, failed
  error_message TEXT,
  created_at INTEGER NOT NULL,
  updated_at INTEGER NOT NULL,
  next_retry_at INTEGER
);

CREATE INDEX idx_sync_queue_status ON sync_queue(status, priority, created_at);
CREATE INDEX idx_sync_queue_entity ON sync_queue(entity_type, entity_id);
```

---

### 13. Table: event_logs
Audit trail dan event logging

```sql
CREATE TABLE event_logs (
  id TEXT PRIMARY KEY,
  tenant_id TEXT NOT NULL,
  event_type TEXT NOT NULL,
  entity_type TEXT,
  entity_id TEXT,
  user_id TEXT,
  action TEXT, -- create, update, delete, login, logout, dll
  payload TEXT, -- JSON data
  ip_address TEXT,
  device_info TEXT,
  created_at INTEGER NOT NULL,
  sync_status TEXT DEFAULT 'synced',
  last_synced_at INTEGER,
  FOREIGN KEY (tenant_id) REFERENCES tenants(id),
  FOREIGN KEY (user_id) REFERENCES users(id)
);

CREATE INDEX idx_event_logs_tenant ON event_logs(tenant_id);
CREATE INDEX idx_event_logs_type ON event_logs(event_type);
CREATE INDEX idx_event_logs_user ON event_logs(user_id);
CREATE INDEX idx_event_logs_created ON event_logs(created_at DESC);
CREATE INDEX idx_event_logs_sync ON event_logs(sync_status);
```

---

### 14. Table: app_settings
Pengaturan aplikasi lokal

```sql
CREATE TABLE app_settings (
  key TEXT PRIMARY KEY,
  value TEXT,
  updated_at INTEGER NOT NULL
);

-- Default settings
INSERT INTO app_settings (key, value, updated_at) VALUES
  ('current_tenant_id', '', strftime('%s','now')),
  ('current_user_id', '', strftime('%s','now')),
  ('current_location_id', '', strftime('%s','now')),
  ('auth_token', '', strftime('%s','now')),
  ('last_sync_at', '0', strftime('%s','now')),
  ('receipt_printer_address', '', strftime('%s','now')),
  ('scanner_enabled', '1', strftime('%s','now')),
  ('offline_mode', '0', strftime('%s','now'));
```

---

### 15. Table: ml_models
Metadata model ML yang terinstall

```sql
CREATE TABLE ml_models (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  version TEXT NOT NULL,
  type TEXT NOT NULL, -- product_detection, forecasting, anomaly
  file_path TEXT NOT NULL,
  file_size INTEGER,
  accuracy REAL,
  is_active INTEGER DEFAULT 1,
  downloaded_at INTEGER,
  updated_at INTEGER NOT NULL
);

CREATE INDEX idx_ml_models_type ON ml_models(type);
CREATE INDEX idx_ml_models_active ON ml_models(is_active);
```

---

## Database Views

### View: product_inventory_view
Gabungan produk dengan inventory

```sql
CREATE VIEW product_inventory_view AS
SELECT 
  p.id,
  p.tenant_id,
  p.sku,
  p.name,
  p.category_id,
  c.name as category_name,
  p.unit,
  p.price_buy,
  p.price_sell,
  p.price_sell - p.price_buy as profit_margin,
  p.barcode,
  p.photos,
  p.is_active,
  p.min_stock,
  COALESCE(i.quantity, 0) as stock_quantity,
  COALESCE(i.reserved, 0) as reserved_quantity,
  COALESCE(i.quantity, 0) - COALESCE(i.reserved, 0) as available_quantity,
  CASE 
    WHEN COALESCE(i.quantity, 0) <= p.min_stock THEN 1 
    ELSE 0 
  END as is_low_stock,
  p.updated_at
FROM products p
LEFT JOIN categories c ON p.category_id = c.id
LEFT JOIN inventory i ON p.id = i.product_id
WHERE p.deleted_at IS NULL;
```

### View: transaction_summary_view
Summary transaksi dengan detail

```sql
CREATE VIEW transaction_summary_view AS
SELECT 
  t.id,
  t.tenant_id,
  t.receipt_number,
  t.created_at,
  u.full_name as cashier_name,
  l.name as location_name,
  COUNT(ti.id) as item_count,
  SUM(ti.quantity) as total_quantity,
  t.subtotal,
  t.discount,
  t.tax,
  t.total,
  t.payment_method,
  t.status
FROM transactions t
INNER JOIN users u ON t.user_id = u.id
INNER JOIN locations l ON t.location_id = l.id
LEFT JOIN transaction_items ti ON t.id = ti.transaction_id
GROUP BY t.id;
```

---

## Database Triggers

### Trigger: auto_update_inventory
Update inventory saat transaksi

```sql
-- Trigger ini di-handle di application layer untuk kontrol lebih baik
-- Tapi bisa juga diimplementasi sebagai trigger
```

### Trigger: update_timestamp
Auto-update updated_at

```sql
-- Trigger untuk auto-update updated_at pada setiap tabel
-- Contoh untuk products:
CREATE TRIGGER update_products_timestamp 
AFTER UPDATE ON products
FOR EACH ROW
BEGIN
  UPDATE products SET updated_at = strftime('%s','now') WHERE id = NEW.id;
END;
```

---

## Indexes Summary

Indexes dibuat untuk:
1. Foreign keys (untuk JOIN performance)
2. Kolom yang sering di-query (tenant_id, status, created_at)
3. Kolom untuk search (name, sku, barcode)
4. Sync status untuk background sync process

---

## Database Size Estimation

### Asumsi (untuk 1 toko, 1 tahun):
- Products: 1,000 items × 2KB = 2MB
- Transactions: 100 tx/day × 365 days × 1KB = 36MB
- Transaction Items: 100 tx × 5 items × 365 days × 0.5KB = 90MB
- Stock Movements: 200/day × 365 × 0.5KB = 36MB
- Event Logs: 500/day × 365 × 0.5KB = 90MB

**Total Estimated: ~250MB/year/toko**

---

## Database Maintenance

### Periodic Tasks:
1. **Vacuum**: Jalankan VACUUM setiap bulan untuk reclaim space
2. **Archive**: Archive transaksi >1 tahun ke table terpisah
3. **Cleanup**: Hapus event_logs >3 bulan
4. **Reindex**: REINDEX untuk optimize query performance

### Migration Strategy:
- Gunakan migration tool (sqflite_migration atau custom)
- Versioning schema di app_settings table
- Always backup before migration

---

## Security Considerations

1. **Encryption**: Gunakan sqflite_sqlcipher untuk encrypt database
2. **Backup**: Auto backup daily ke secure location
3. **Sensitive Data**: Hash password, encrypt payment tokens
4. **Access Control**: Validate user permission di application layer

---

## Usage Example (Dart/Flutter)

```dart
// Initialize database
final database = await openDatabase(
  path,
  version: 1,
  onCreate: (db, version) async {
    // Execute all CREATE TABLE statements
  },
  onUpgrade: (db, oldVersion, newVersion) async {
    // Handle schema migrations
  },
);

// Query with FTS
final results = await database.rawQuery('''
  SELECT p.* 
  FROM products p
  INNER JOIN products_fts fts ON p.id = fts.product_id
  WHERE products_fts MATCH ?
''', ['kemasan*']);

// Transaction with inventory update
await database.transaction((txn) async {
  // Insert transaction
  await txn.insert('transactions', transactionData);
  
  // Insert items
  for (var item in items) {
    await txn.insert('transaction_items', item);
    
    // Update inventory
    await txn.rawUpdate('''
      UPDATE inventory 
      SET quantity = quantity - ?, updated_at = ?
      WHERE product_id = ? AND location_id = ?
    ''', [item['quantity'], now, item['product_id'], locationId]);
  }
  
  // Add to sync queue
  await txn.insert('sync_queue', syncJob);
});
```


