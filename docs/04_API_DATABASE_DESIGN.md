# API Database Design (PostgreSQL)

## Overview
Database backend menggunakan PostgreSQL untuk mendukung multi-tenant, analytics, dan scalability. Design menggunakan prinsip:
- **Multi-tenant dengan Row-Level Security (RLS)**
- **Event Sourcing untuk audit trail**
- **CQRS pattern untuk read/write separation**
- **Time-series optimization untuk analytics**

---

## Schema Design

### 1. Table: tenants

```sql
CREATE TABLE tenants (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name VARCHAR(255) NOT NULL,
  slug VARCHAR(100) UNIQUE NOT NULL,
  owner_name VARCHAR(255),
  email VARCHAR(255) UNIQUE,
  phone VARCHAR(50),
  address TEXT,
  settings JSONB DEFAULT '{}',
  subscription_tier VARCHAR(50) DEFAULT 'free',
  subscription_started_at TIMESTAMPTZ,
  subscription_expires_at TIMESTAMPTZ,
  is_active BOOLEAN DEFAULT TRUE,
  logo_url TEXT,
  metadata JSONB DEFAULT '{}',
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  deleted_at TIMESTAMPTZ
);

CREATE INDEX idx_tenants_slug ON tenants(slug);
CREATE INDEX idx_tenants_email ON tenants(email);
CREATE INDEX idx_tenants_active ON tenants(is_active) WHERE is_active = TRUE;
CREATE INDEX idx_tenants_subscription ON tenants(subscription_tier, subscription_expires_at);

-- Trigger untuk auto-update updated_at
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_tenants_updated_at BEFORE UPDATE ON tenants
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
```

---

### 2. Table: users

```sql
CREATE TABLE users (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id UUID NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
  username VARCHAR(100) NOT NULL,
  email VARCHAR(255),
  password_hash VARCHAR(255) NOT NULL,
  full_name VARCHAR(255),
  role VARCHAR(50) NOT NULL, -- owner, manager, cashier, admin
  permissions JSONB DEFAULT '[]',
  is_active BOOLEAN DEFAULT TRUE,
  last_login_at TIMESTAMPTZ,
  last_login_ip INET,
  failed_login_attempts INTEGER DEFAULT 0,
  locked_until TIMESTAMPTZ,
  metadata JSONB DEFAULT '{}',
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  deleted_at TIMESTAMPTZ,
  UNIQUE(tenant_id, username)
);

CREATE INDEX idx_users_tenant ON users(tenant_id);
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_role ON users(role);
CREATE INDEX idx_users_active ON users(is_active, tenant_id);

CREATE TRIGGER update_users_updated_at BEFORE UPDATE ON users
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Row Level Security
ALTER TABLE users ENABLE ROW LEVEL SECURITY;

CREATE POLICY tenant_isolation_users ON users
  USING (tenant_id = current_setting('app.current_tenant_id')::UUID);
```

---

### 3. Table: categories

```sql
CREATE TABLE categories (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id UUID NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
  name VARCHAR(255) NOT NULL,
  parent_id UUID REFERENCES categories(id),
  icon VARCHAR(100),
  color VARCHAR(20),
  sort_order INTEGER DEFAULT 0,
  is_active BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  deleted_at TIMESTAMPTZ
);

CREATE INDEX idx_categories_tenant ON categories(tenant_id);
CREATE INDEX idx_categories_parent ON categories(parent_id);
CREATE INDEX idx_categories_active ON categories(is_active, tenant_id);

CREATE TRIGGER update_categories_updated_at BEFORE UPDATE ON categories
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

ALTER TABLE categories ENABLE ROW LEVEL SECURITY;
CREATE POLICY tenant_isolation_categories ON categories
  USING (tenant_id = current_setting('app.current_tenant_id')::UUID);
```

---

### 4. Table: products

```sql
CREATE TABLE products (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id UUID NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
  sku VARCHAR(100) NOT NULL,
  name VARCHAR(255) NOT NULL,
  category_id UUID REFERENCES categories(id),
  description TEXT,
  unit VARCHAR(50) DEFAULT 'pcs',
  price_buy DECIMAL(15,2) DEFAULT 0,
  price_sell DECIMAL(15,2) NOT NULL,
  weight DECIMAL(10,2),
  has_barcode BOOLEAN DEFAULT FALSE,
  barcode VARCHAR(100),
  is_expirable BOOLEAN DEFAULT FALSE,
  is_active BOOLEAN DEFAULT TRUE,
  min_stock INTEGER DEFAULT 0,
  photos JSONB DEFAULT '[]',
  attributes JSONB DEFAULT '{}',
  search_vector tsvector, -- untuk full-text search
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  deleted_at TIMESTAMPTZ,
  UNIQUE(tenant_id, sku)
);

CREATE INDEX idx_products_tenant ON products(tenant_id);
CREATE INDEX idx_products_category ON products(category_id);
CREATE INDEX idx_products_sku ON products(sku);
CREATE INDEX idx_products_barcode ON products(barcode) WHERE barcode IS NOT NULL;
CREATE INDEX idx_products_active ON products(is_active, tenant_id);
CREATE INDEX idx_products_search ON products USING GIN(search_vector);

-- Trigger untuk update search vector
CREATE OR REPLACE FUNCTION products_search_vector_update() RETURNS TRIGGER AS $$
BEGIN
  NEW.search_vector := 
    setweight(to_tsvector('indonesian', COALESCE(NEW.name, '')), 'A') ||
    setweight(to_tsvector('indonesian', COALESCE(NEW.sku, '')), 'B') ||
    setweight(to_tsvector('indonesian', COALESCE(NEW.description, '')), 'C');
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER products_search_vector_trigger BEFORE INSERT OR UPDATE ON products
  FOR EACH ROW EXECUTE FUNCTION products_search_vector_update();

CREATE TRIGGER update_products_updated_at BEFORE UPDATE ON products
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

ALTER TABLE products ENABLE ROW LEVEL SECURITY;
CREATE POLICY tenant_isolation_products ON products
  USING (tenant_id = current_setting('app.current_tenant_id')::UUID);
```

---

### 5. Table: locations

```sql
CREATE TABLE locations (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id UUID NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
  name VARCHAR(255) NOT NULL,
  type VARCHAR(50) DEFAULT 'store',
  address TEXT,
  coordinates POINT, -- PostGIS point untuk geolocation
  is_primary BOOLEAN DEFAULT FALSE,
  is_active BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  deleted_at TIMESTAMPTZ
);

CREATE INDEX idx_locations_tenant ON locations(tenant_id);
CREATE INDEX idx_locations_type ON locations(type);
CREATE INDEX idx_locations_primary ON locations(is_primary, tenant_id);

CREATE TRIGGER update_locations_updated_at BEFORE UPDATE ON locations
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

ALTER TABLE locations ENABLE ROW LEVEL SECURITY;
CREATE POLICY tenant_isolation_locations ON locations
  USING (tenant_id = current_setting('app.current_tenant_id')::UUID);
```

---

### 6. Table: inventory

```sql
CREATE TABLE inventory (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id UUID NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
  product_id UUID NOT NULL REFERENCES products(id),
  location_id UUID NOT NULL REFERENCES locations(id),
  quantity INTEGER DEFAULT 0,
  reserved INTEGER DEFAULT 0,
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(product_id, location_id)
);

CREATE INDEX idx_inventory_tenant ON inventory(tenant_id);
CREATE INDEX idx_inventory_product ON inventory(product_id);
CREATE INDEX idx_inventory_location ON inventory(location_id);
CREATE INDEX idx_inventory_low_stock ON inventory(tenant_id, product_id) 
  WHERE quantity <= (SELECT min_stock FROM products WHERE id = product_id);

CREATE TRIGGER update_inventory_updated_at BEFORE UPDATE ON inventory
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

ALTER TABLE inventory ENABLE ROW LEVEL SECURITY;
CREATE POLICY tenant_isolation_inventory ON inventory
  USING (tenant_id = current_setting('app.current_tenant_id')::UUID);
```

---

### 7. Table: stock_movements

```sql
CREATE TABLE stock_movements (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id UUID NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
  product_id UUID NOT NULL REFERENCES products(id),
  location_id UUID NOT NULL REFERENCES locations(id),
  type VARCHAR(50) NOT NULL,
  quantity INTEGER NOT NULL,
  reference_type VARCHAR(50),
  reference_id UUID,
  notes TEXT,
  user_id UUID REFERENCES users(id),
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_stock_movements_tenant ON stock_movements(tenant_id);
CREATE INDEX idx_stock_movements_product ON stock_movements(product_id);
CREATE INDEX idx_stock_movements_location ON stock_movements(location_id);
CREATE INDEX idx_stock_movements_reference ON stock_movements(reference_type, reference_id);
CREATE INDEX idx_stock_movements_created ON stock_movements(created_at DESC);
CREATE INDEX idx_stock_movements_type ON stock_movements(type);

-- Partition by month untuk optimasi
-- CREATE TABLE stock_movements_2025_01 PARTITION OF stock_movements
--   FOR VALUES FROM ('2025-01-01') TO ('2025-02-01');

ALTER TABLE stock_movements ENABLE ROW LEVEL SECURITY;
CREATE POLICY tenant_isolation_stock_movements ON stock_movements
  USING (tenant_id = current_setting('app.current_tenant_id')::UUID);
```

---

### 8. Table: transactions

```sql
CREATE TABLE transactions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id UUID NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
  location_id UUID NOT NULL REFERENCES locations(id),
  user_id UUID NOT NULL REFERENCES users(id),
  receipt_number VARCHAR(100),
  subtotal DECIMAL(15,2) NOT NULL,
  discount DECIMAL(15,2) DEFAULT 0,
  tax DECIMAL(15,2) DEFAULT 0,
  total DECIMAL(15,2) NOT NULL,
  payment_method VARCHAR(50),
  payment_details JSONB DEFAULT '{}',
  amount_paid DECIMAL(15,2),
  change_amount DECIMAL(15,2),
  status VARCHAR(50) DEFAULT 'completed',
  notes TEXT,
  customer_name VARCHAR(255),
  customer_phone VARCHAR(50),
  metadata JSONB DEFAULT '{}',
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  voided_at TIMESTAMPTZ,
  voided_by UUID REFERENCES users(id),
  void_reason TEXT,
  UNIQUE(tenant_id, receipt_number)
);

CREATE INDEX idx_transactions_tenant ON transactions(tenant_id);
CREATE INDEX idx_transactions_location ON transactions(location_id);
CREATE INDEX idx_transactions_user ON transactions(user_id);
CREATE INDEX idx_transactions_status ON transactions(status);
CREATE INDEX idx_transactions_created ON transactions(created_at DESC);
CREATE INDEX idx_transactions_receipt ON transactions(receipt_number);
CREATE INDEX idx_transactions_customer ON transactions(customer_phone) WHERE customer_phone IS NOT NULL;

CREATE TRIGGER update_transactions_updated_at BEFORE UPDATE ON transactions
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

ALTER TABLE transactions ENABLE ROW LEVEL SECURITY;
CREATE POLICY tenant_isolation_transactions ON transactions
  USING (tenant_id = current_setting('app.current_tenant_id')::UUID);

-- Partition by month
-- CREATE TABLE transactions_2025_01 PARTITION OF transactions
--   FOR VALUES FROM ('2025-01-01') TO ('2025-02-01');
```

---

### 9. Table: transaction_items

```sql
CREATE TABLE transaction_items (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  transaction_id UUID NOT NULL REFERENCES transactions(id) ON DELETE CASCADE,
  product_id UUID NOT NULL REFERENCES products(id),
  product_snapshot JSONB NOT NULL, -- snapshot produk saat transaksi
  quantity INTEGER NOT NULL,
  unit_price DECIMAL(15,2) NOT NULL,
  discount DECIMAL(15,2) DEFAULT 0,
  subtotal DECIMAL(15,2) NOT NULL,
  notes TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_transaction_items_transaction ON transaction_items(transaction_id);
CREATE INDEX idx_transaction_items_product ON transaction_items(product_id);
CREATE INDEX idx_transaction_items_created ON transaction_items(created_at DESC);
```

---

### 10. Table: product_detection_events

```sql
CREATE TABLE product_detection_events (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id UUID NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES users(id),
  image_url TEXT NOT NULL,
  predictions JSONB NOT NULL,
  selected_product_id UUID REFERENCES products(id),
  is_correct BOOLEAN,
  confidence_score DECIMAL(5,4),
  feedback_notes TEXT,
  inference_time_ms INTEGER,
  model_version VARCHAR(50),
  device_info JSONB,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_detection_events_tenant ON product_detection_events(tenant_id);
CREATE INDEX idx_detection_events_product ON product_detection_events(selected_product_id);
CREATE INDEX idx_detection_events_created ON product_detection_events(created_at DESC);
CREATE INDEX idx_detection_events_model ON product_detection_events(model_version);
CREATE INDEX idx_detection_events_feedback ON product_detection_events(is_correct) WHERE is_correct IS NOT NULL;

ALTER TABLE product_detection_events ENABLE ROW LEVEL SECURITY;
CREATE POLICY tenant_isolation_detection_events ON product_detection_events
  USING (tenant_id = current_setting('app.current_tenant_id')::UUID);
```

---

### 11. Table: stock_forecasts

```sql
CREATE TABLE stock_forecasts (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id UUID NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
  product_id UUID NOT NULL REFERENCES products(id),
  forecast_date DATE NOT NULL,
  predicted_demand DECIMAL(10,2) NOT NULL,
  confidence_interval JSONB, -- {lower: x, upper: y}
  model_version VARCHAR(50),
  features JSONB,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(product_id, forecast_date, model_version)
);

CREATE INDEX idx_forecasts_tenant ON stock_forecasts(tenant_id);
CREATE INDEX idx_forecasts_product ON stock_forecasts(product_id);
CREATE INDEX idx_forecasts_date ON stock_forecasts(forecast_date);

ALTER TABLE stock_forecasts ENABLE ROW LEVEL SECURITY;
CREATE POLICY tenant_isolation_forecasts ON stock_forecasts
  USING (tenant_id = current_setting('app.current_tenant_id')::UUID);
```

---

### 12. Table: anomaly_alerts

```sql
CREATE TABLE anomaly_alerts (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id UUID NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
  alert_type VARCHAR(50) NOT NULL, -- fraud_detection, stock_mismatch, pricing_anomaly
  severity VARCHAR(20) NOT NULL, -- low, medium, high, critical
  entity_type VARCHAR(50),
  entity_id UUID,
  description TEXT NOT NULL,
  metadata JSONB DEFAULT '{}',
  status VARCHAR(50) DEFAULT 'open', -- open, investigating, resolved, false_positive
  assigned_to UUID REFERENCES users(id),
  resolved_at TIMESTAMPTZ,
  resolved_by UUID REFERENCES users(id),
  resolution_notes TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_alerts_tenant ON anomaly_alerts(tenant_id);
CREATE INDEX idx_alerts_type ON anomaly_alerts(alert_type);
CREATE INDEX idx_alerts_status ON anomaly_alerts(status);
CREATE INDEX idx_alerts_severity ON anomaly_alerts(severity);
CREATE INDEX idx_alerts_created ON anomaly_alerts(created_at DESC);

CREATE TRIGGER update_alerts_updated_at BEFORE UPDATE ON anomaly_alerts
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

ALTER TABLE anomaly_alerts ENABLE ROW LEVEL SECURITY;
CREATE POLICY tenant_isolation_alerts ON anomaly_alerts
  USING (tenant_id = current_setting('app.current_tenant_id')::UUID);
```

---

### 13. Table: event_stream (Event Sourcing)

```sql
CREATE TABLE event_stream (
  id BIGSERIAL PRIMARY KEY,
  event_id UUID UNIQUE DEFAULT gen_random_uuid(),
  tenant_id UUID NOT NULL REFERENCES tenants(id),
  event_type VARCHAR(100) NOT NULL,
  aggregate_type VARCHAR(50) NOT NULL,
  aggregate_id UUID NOT NULL,
  event_version INTEGER NOT NULL,
  payload JSONB NOT NULL,
  metadata JSONB DEFAULT '{}',
  user_id UUID,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_event_stream_tenant ON event_stream(tenant_id);
CREATE INDEX idx_event_stream_type ON event_stream(event_type);
CREATE INDEX idx_event_stream_aggregate ON event_stream(aggregate_type, aggregate_id);
CREATE INDEX idx_event_stream_created ON event_stream(created_at DESC);

-- Publish to Kafka via trigger (optional)
-- CREATE OR REPLACE FUNCTION notify_event_stream() RETURNS TRIGGER AS $$
-- BEGIN
--   PERFORM pg_notify('event_stream', row_to_json(NEW)::text);
--   RETURN NEW;
-- END;
-- $$ LANGUAGE plpgsql;

-- CREATE TRIGGER event_stream_notify AFTER INSERT ON event_stream
--   FOR EACH ROW EXECUTE FUNCTION notify_event_stream();
```

---

### 14. Table: audit_logs

```sql
CREATE TABLE audit_logs (
  id BIGSERIAL PRIMARY KEY,
  tenant_id UUID NOT NULL REFERENCES tenants(id),
  user_id UUID REFERENCES users(id),
  action VARCHAR(50) NOT NULL,
  entity_type VARCHAR(50),
  entity_id UUID,
  old_values JSONB,
  new_values JSONB,
  ip_address INET,
  user_agent TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_audit_logs_tenant ON audit_logs(tenant_id);
CREATE INDEX idx_audit_logs_user ON audit_logs(user_id);
CREATE INDEX idx_audit_logs_entity ON audit_logs(entity_type, entity_id);
CREATE INDEX idx_audit_logs_created ON audit_logs(created_at DESC);

-- Partition by month
-- CREATE TABLE audit_logs_2025_01 PARTITION OF audit_logs
--   FOR VALUES FROM ('2025-01-01') TO ('2025-02-01');
```

---

### 15. Table: ml_training_datasets

```sql
CREATE TABLE ml_training_datasets (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  dataset_type VARCHAR(50) NOT NULL, -- product_detection, forecasting, anomaly
  version VARCHAR(50) NOT NULL,
  source VARCHAR(100),
  record_count INTEGER,
  file_path TEXT,
  metadata JSONB DEFAULT '{}',
  created_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(dataset_type, version)
);

CREATE INDEX idx_training_datasets_type ON ml_training_datasets(dataset_type);
```

---

### 16. Table: ml_models

```sql
CREATE TABLE ml_models (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name VARCHAR(255) NOT NULL,
  model_type VARCHAR(50) NOT NULL,
  version VARCHAR(50) NOT NULL,
  framework VARCHAR(50), -- tensorflow, pytorch, onnx
  file_path TEXT NOT NULL,
  file_size BIGINT,
  accuracy DECIMAL(5,4),
  metrics JSONB DEFAULT '{}',
  is_active BOOLEAN DEFAULT FALSE,
  training_completed_at TIMESTAMPTZ,
  deployed_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(model_type, version)
);

CREATE INDEX idx_ml_models_type ON ml_models(model_type);
CREATE INDEX idx_ml_models_active ON ml_models(is_active);

CREATE TRIGGER update_ml_models_updated_at BEFORE UPDATE ON ml_models
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
```

---

### 17. Table: subscriptions

```sql
CREATE TABLE subscriptions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id UUID NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
  plan VARCHAR(50) NOT NULL, -- free, basic, premium, enterprise
  status VARCHAR(50) NOT NULL, -- active, cancelled, expired, trial
  billing_cycle VARCHAR(20), -- monthly, yearly
  price DECIMAL(15,2),
  currency VARCHAR(10) DEFAULT 'IDR',
  started_at TIMESTAMPTZ NOT NULL,
  expires_at TIMESTAMPTZ,
  cancelled_at TIMESTAMPTZ,
  metadata JSONB DEFAULT '{}',
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_subscriptions_tenant ON subscriptions(tenant_id);
CREATE INDEX idx_subscriptions_status ON subscriptions(status);
CREATE INDEX idx_subscriptions_expires ON subscriptions(expires_at);

CREATE TRIGGER update_subscriptions_updated_at BEFORE UPDATE ON subscriptions
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
```

---

### 18. Table: payment_transactions

```sql
CREATE TABLE payment_transactions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id UUID NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
  transaction_id UUID REFERENCES transactions(id),
  subscription_id UUID REFERENCES subscriptions(id),
  payment_type VARCHAR(50) NOT NULL, -- sale, subscription, refund
  payment_gateway VARCHAR(50), -- qris, gopay, ovo, bank_transfer
  gateway_transaction_id VARCHAR(255),
  amount DECIMAL(15,2) NOT NULL,
  currency VARCHAR(10) DEFAULT 'IDR',
  status VARCHAR(50) NOT NULL, -- pending, success, failed, refunded
  payment_details JSONB DEFAULT '{}',
  paid_at TIMESTAMPTZ,
  refunded_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_payment_transactions_tenant ON payment_transactions(tenant_id);
CREATE INDEX idx_payment_transactions_transaction ON payment_transactions(transaction_id);
CREATE INDEX idx_payment_transactions_subscription ON payment_transactions(subscription_id);
CREATE INDEX idx_payment_transactions_gateway ON payment_transactions(gateway_transaction_id);
CREATE INDEX idx_payment_transactions_status ON payment_transactions(status);
CREATE INDEX idx_payment_transactions_created ON payment_transactions(created_at DESC);

CREATE TRIGGER update_payment_transactions_updated_at BEFORE UPDATE ON payment_transactions
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
```

---

## Materialized Views (untuk Performance)

### MV: daily_sales_summary

```sql
CREATE MATERIALIZED VIEW daily_sales_summary AS
SELECT 
  tenant_id,
  location_id,
  DATE(created_at) as sale_date,
  COUNT(*) as transaction_count,
  SUM(total) as total_sales,
  SUM(discount) as total_discount,
  SUM(tax) as total_tax,
  AVG(total) as avg_transaction_value,
  COUNT(DISTINCT customer_phone) as unique_customers
FROM transactions
WHERE status = 'completed' AND deleted_at IS NULL
GROUP BY tenant_id, location_id, DATE(created_at);

CREATE UNIQUE INDEX idx_daily_sales_summary ON daily_sales_summary(tenant_id, location_id, sale_date);

-- Refresh strategy: nightly or on-demand
-- REFRESH MATERIALIZED VIEW CONCURRENTLY daily_sales_summary;
```

### MV: product_sales_summary

```sql
CREATE MATERIALIZED VIEW product_sales_summary AS
SELECT 
  p.tenant_id,
  p.id as product_id,
  p.name as product_name,
  p.category_id,
  DATE_TRUNC('month', t.created_at) as month,
  COUNT(ti.id) as times_sold,
  SUM(ti.quantity) as total_quantity,
  SUM(ti.subtotal) as total_revenue,
  AVG(ti.unit_price) as avg_price
FROM transaction_items ti
JOIN transactions t ON ti.transaction_id = t.id
JOIN products p ON ti.product_id = p.id
WHERE t.status = 'completed'
GROUP BY p.tenant_id, p.id, p.name, p.category_id, DATE_TRUNC('month', t.created_at);

CREATE UNIQUE INDEX idx_product_sales_summary ON product_sales_summary(tenant_id, product_id, month);
```

---

## Functions & Stored Procedures

### Function: get_inventory_value

```sql
CREATE OR REPLACE FUNCTION get_inventory_value(p_tenant_id UUID, p_location_id UUID DEFAULT NULL)
RETURNS DECIMAL(15,2) AS $$
DECLARE
  total_value DECIMAL(15,2);
BEGIN
  SELECT SUM(i.quantity * p.price_buy) INTO total_value
  FROM inventory i
  JOIN products p ON i.product_id = p.id
  WHERE i.tenant_id = p_tenant_id
    AND (p_location_id IS NULL OR i.location_id = p_location_id)
    AND p.deleted_at IS NULL;
  
  RETURN COALESCE(total_value, 0);
END;
$$ LANGUAGE plpgsql;
```

### Function: calculate_profit

```sql
CREATE OR REPLACE FUNCTION calculate_profit(
  p_tenant_id UUID,
  p_start_date TIMESTAMPTZ,
  p_end_date TIMESTAMPTZ
)
RETURNS TABLE(
  total_revenue DECIMAL(15,2),
  total_cost DECIMAL(15,2),
  gross_profit DECIMAL(15,2),
  profit_margin DECIMAL(5,2)
) AS $$
BEGIN
  RETURN QUERY
  SELECT 
    SUM(ti.subtotal) as total_revenue,
    SUM(ti.quantity * p.price_buy) as total_cost,
    SUM(ti.subtotal - (ti.quantity * p.price_buy)) as gross_profit,
    (SUM(ti.subtotal - (ti.quantity * p.price_buy)) / NULLIF(SUM(ti.subtotal), 0) * 100) as profit_margin
  FROM transaction_items ti
  JOIN transactions t ON ti.transaction_id = t.id
  JOIN products p ON ti.product_id = p.id
  WHERE t.tenant_id = p_tenant_id
    AND t.created_at BETWEEN p_start_date AND p_end_date
    AND t.status = 'completed';
END;
$$ LANGUAGE plpgsql;
```

### Function: get_low_stock_products

```sql
CREATE OR REPLACE FUNCTION get_low_stock_products(p_tenant_id UUID)
RETURNS TABLE(
  product_id UUID,
  product_name VARCHAR,
  current_stock INTEGER,
  min_stock INTEGER,
  reorder_qty INTEGER
) AS $$
BEGIN
  RETURN QUERY
  SELECT 
    p.id,
    p.name,
    COALESCE(i.quantity, 0) as current_stock,
    p.min_stock,
    GREATEST(p.min_stock * 2 - COALESCE(i.quantity, 0), 0) as reorder_qty
  FROM products p
  LEFT JOIN inventory i ON p.id = i.product_id
  WHERE p.tenant_id = p_tenant_id
    AND p.is_active = TRUE
    AND p.deleted_at IS NULL
    AND COALESCE(i.quantity, 0) <= p.min_stock
  ORDER BY (p.min_stock - COALESCE(i.quantity, 0)) DESC;
END;
$$ LANGUAGE plpgsql;
```

---

## Database Partitioning Strategy

### Partition transactions by month

```sql
-- Parent table sudah dibuat di atas

-- Create partitions
CREATE TABLE transactions_2025_01 PARTITION OF transactions
  FOR VALUES FROM ('2025-01-01') TO ('2025-02-01');

CREATE TABLE transactions_2025_02 PARTITION OF transactions
  FOR VALUES FROM ('2025-02-01') TO ('2025-03-01');

-- Auto-create partitions via pg_partman extension
```

### Partition audit_logs by month

```sql
CREATE TABLE audit_logs_2025_01 PARTITION OF audit_logs
  FOR VALUES FROM ('2025-01-01') TO ('2025-02-01');
```

---

## Indexing Strategy

1. **B-tree indexes**: Default untuk FK, search columns
2. **GIN indexes**: Untuk JSONB, full-text search
3. **BRIN indexes**: Untuk time-series data (created_at)
4. **Partial indexes**: Untuk filtered queries (WHERE is_active = TRUE)

---

## Backup & Recovery Strategy

1. **Continuous Archiving (WAL)**: Enable untuk point-in-time recovery
2. **Daily Backups**: Full backup setiap hari
3. **Retention**: 30 hari untuk production
4. **Replication**: Master-slave replication untuk read scalability

---

## Performance Optimization

### Connection Pooling
```
max_connections = 200
shared_buffers = 2GB
effective_cache_size = 6GB
work_mem = 16MB
```

### Query Optimization
- Use EXPLAIN ANALYZE untuk analyze queries
- Create indexes untuk slow queries
- Use materialized views untuk heavy aggregations

### Monitoring
- pg_stat_statements untuk query monitoring
- pgBadger untuk log analysis
- Prometheus + Grafana untuk metrics

---

## Security Best Practices

1. **Row-Level Security (RLS)**: Enforce tenant isolation
2. **SSL/TLS**: Encrypted connections
3. **Password Policies**: Strong passwords dengan bcrypt
4. **Audit Logging**: Log semua sensitive operations
5. **Backup Encryption**: Encrypt backups at rest
6. **Least Privilege**: Grant minimal permissions per role

---

## Migration Strategy

### Using Flyway or Liquibase

```sql
-- V1__initial_schema.sql
-- V2__add_product_detection.sql
-- V3__add_partitioning.sql
```

### Version Control
- Track schema changes in git
- Test migrations in staging
- Rollback strategy for failed migrations

---

## Example Queries

### Get sales report

```sql
SELECT 
  DATE(t.created_at) as date,
  COUNT(*) as transaction_count,
  SUM(t.total) as total_sales,
  AVG(t.total) as avg_transaction,
  SUM(t.discount) as total_discount
FROM transactions t
WHERE t.tenant_id = 'xxx'
  AND t.status = 'completed'
  AND t.created_at >= NOW() - INTERVAL '30 days'
GROUP BY DATE(t.created_at)
ORDER BY date DESC;
```

### Top selling products

```sql
SELECT 
  p.id,
  p.name,
  c.name as category_name,
  COUNT(ti.id) as times_sold,
  SUM(ti.quantity) as total_quantity,
  SUM(ti.subtotal) as total_revenue
FROM transaction_items ti
JOIN transactions t ON ti.transaction_id = t.id
JOIN products p ON ti.product_id = p.id
LEFT JOIN categories c ON p.category_id = c.id
WHERE t.tenant_id = 'xxx'
  AND t.status = 'completed'
  AND t.created_at >= NOW() - INTERVAL '30 days'
GROUP BY p.id, p.name, c.name
ORDER BY total_revenue DESC
LIMIT 10;
```

### Inventory valuation

```sql
SELECT 
  p.id,
  p.name,
  i.quantity,
  p.price_buy,
  i.quantity * p.price_buy as value
FROM inventory i
JOIN products p ON i.product_id = p.id
WHERE p.tenant_id = 'xxx'
  AND p.deleted_at IS NULL
ORDER BY value DESC;
```


