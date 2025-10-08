# Inventory API - Example Data & Requests

## Sample Data for Testing

### 1. Create Inventory Request
```json
POST /api/v1/inventory
Content-Type: application/json
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...

{
  "id": "inv_1759923672482",
  "tenant_id": "default-tenant-id",
  "product_id": "prod_1759923672481",
  "location_id": "loc_1759923672480",
  "quantity": 0,
  "reserved": 0,
  "updated_at": 1759923672482,
  "sync_status": "pending",
  "last_synced_at": null
}
```

### 2. Update Inventory Request
```json
PUT /api/v1/inventory/inv_1759923672482
Content-Type: application/json
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...

{
  "quantity": 50,
  "reserved": 5,
  "updated_at": 1759923672482
}
```

### 3. Bulk Sync Request
```json
POST /api/v1/inventory/sync
Content-Type: application/json
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...

{
  "device_id": "device_1759923672482",
  "last_sync_timestamp": "2024-01-15T10:30:00Z",
  "inventories": [
    {
      "id": "inv_1759923672482",
      "tenant_id": "default-tenant-id",
      "product_id": "prod_1759923672481",
      "location_id": "loc_1759923672480",
      "quantity": 50,
      "reserved": 5,
      "updated_at": 1759923672482,
      "sync_status": "pending",
      "last_synced_at": null
    },
    {
      "id": "inv_1759923672483",
      "tenant_id": "default-tenant-id",
      "product_id": "prod_1759923672484",
      "location_id": "loc_1759923672480",
      "quantity": 25,
      "reserved": 0,
      "updated_at": 1759923672483,
      "sync_status": "pending",
      "last_synced_at": null
    }
  ]
}
```

## Expected Server Responses

### 1. Create Inventory Success Response
```json
HTTP/1.1 201 Created
Content-Type: application/json

{
  "success": true,
  "message": "Inventory created successfully",
  "data": {
    "id": "inv_1759923672482",
    "tenant_id": "default-tenant-id",
    "product_id": "prod_1759923672481",
    "location_id": "loc_1759923672480",
    "quantity": 0,
    "reserved": 0,
    "updated_at": 1759923672482,
    "sync_status": "synced",
    "last_synced_at": 1759923672482,
    "created_at": 1759923672482
  }
}
```

### 2. Update Inventory Success Response
```json
HTTP/1.1 200 OK
Content-Type: application/json

{
  "success": true,
  "message": "Inventory updated successfully",
  "data": {
    "id": "inv_1759923672482",
    "tenant_id": "default-tenant-id",
    "product_id": "prod_1759923672481",
    "location_id": "loc_1759923672480",
    "quantity": 50,
    "reserved": 5,
    "updated_at": 1759923672482,
    "sync_status": "synced",
    "last_synced_at": 1759923672482
  }
}
```

### 3. Bulk Sync Success Response
```json
HTTP/1.1 200 OK
Content-Type: application/json

{
  "success": true,
  "message": "Inventory sync completed",
  "data": {
    "synced_count": 2,
    "failed_count": 0,
    "failed_items": [],
    "server_timestamp": "2024-01-15T10:35:00Z"
  }
}
```

### 4. Bulk Sync Partial Success Response
```json
HTTP/1.1 207 Multi-Status
Content-Type: application/json

{
  "success": true,
  "message": "Inventory sync completed with errors",
  "data": {
    "synced_count": 1,
    "failed_count": 1,
    "failed_items": [
      {
        "id": "inv_1759923672483",
        "error": "Product not found"
      }
    ],
    "server_timestamp": "2024-01-15T10:35:00Z"
  }
}
```

### 5. Error Response Examples
```json
HTTP/1.1 400 Bad Request
Content-Type: application/json

{
  "success": false,
  "message": "Validation failed",
  "errors": {
    "product_id": ["Product not found"],
    "location_id": ["Location not found"],
    "quantity": ["Quantity must be non-negative"]
  }
}
```

```json
HTTP/1.1 409 Conflict
Content-Type: application/json

{
  "success": false,
  "message": "Inventory already exists",
  "error_code": "INVENTORY_EXISTS"
}
```

## Real-World Data Examples

### Product Creation Flow
When a user creates a new product "Minuman" with minStock=10, reorderPoint=30:

1. **Product Created:**
```json
{
  "id": "prod_1759923672481",
  "name": "Minuman",
  "min_stock": 10,
  "reorder_point": 30,
  "tenant_id": "default-tenant-id"
}
```

2. **Initial Inventory Created:**
```json
{
  "id": "inv_1759923672482",
  "tenant_id": "default-tenant-id",
  "product_id": "prod_1759923672481",
  "location_id": "loc_1759923672480",
  "quantity": 0,
  "reserved": 0,
  "updated_at": 1759923672482,
  "sync_status": "pending"
}
```

3. **Sent to Server:**
```json
POST /api/v1/inventory
{
  "id": "inv_1759923672482",
  "tenant_id": "default-tenant-id",
  "product_id": "prod_1759923672481",
  "location_id": "loc_1759923672480",
  "quantity": 0,
  "reserved": 0,
  "updated_at": 1759923672482,
  "sync_status": "pending"
}
```

### Stock Movement Examples

#### Purchase (Stock In)
```json
PUT /api/v1/inventory/inv_1759923672482
{
  "quantity": 100,
  "reserved": 0,
  "updated_at": 1759923672483
}
```

#### Sale (Stock Out)
```json
PUT /api/v1/inventory/inv_1759923672482
{
  "quantity": 95,
  "reserved": 0,
  "updated_at": 1759923672484
}
```

#### Adjustment
```json
PUT /api/v1/inventory/inv_1759923672482
{
  "quantity": 90,
  "reserved": 0,
  "updated_at": 1759923672485
}
```

## Database Schema for Backend

### Inventory Table
```sql
CREATE TABLE inventory (
  id VARCHAR(255) PRIMARY KEY,
  tenant_id VARCHAR(255) NOT NULL,
  product_id VARCHAR(255) NOT NULL,
  location_id VARCHAR(255) NOT NULL,
  quantity INT NOT NULL DEFAULT 0,
  reserved INT NOT NULL DEFAULT 0,
  updated_at BIGINT NOT NULL,
  sync_status VARCHAR(50) DEFAULT 'synced',
  last_synced_at BIGINT,
  created_at BIGINT NOT NULL,
  FOREIGN KEY (tenant_id) REFERENCES tenants(id),
  FOREIGN KEY (product_id) REFERENCES products(id),
  FOREIGN KEY (location_id) REFERENCES locations(id),
  UNIQUE KEY unique_product_location (product_id, location_id)
);
```

### Indexes
```sql
CREATE INDEX idx_inventory_tenant ON inventory(tenant_id);
CREATE INDEX idx_inventory_product ON inventory(product_id);
CREATE INDEX idx_inventory_location ON inventory(location_id);
CREATE INDEX idx_inventory_sync_status ON inventory(sync_status);
```

## Mobile App Integration Notes

1. **ID Generation**: Mobile app uses timestamp-based IDs (`inv_1759923672482`)
2. **Timestamp Format**: Unix milliseconds since epoch
3. **Sync Status**: 
   - `pending` - Not yet synced to server
   - `synced` - Successfully synced to server
   - `failed` - Sync failed, will retry
4. **Offline Handling**: Operations are queued when offline
5. **Retry Logic**: Failed operations are retried with exponential backoff
6. **Bulk Operations**: Multiple inventory operations are batched for efficiency

## Testing Checklist

- [ ] Create inventory with valid data
- [ ] Create inventory with invalid product_id
- [ ] Create inventory with invalid location_id
- [ ] Update inventory quantity
- [ ] Update inventory reserved amount
- [ ] Delete inventory
- [ ] Bulk sync with multiple inventories
- [ ] Bulk sync with partial failures
- [ ] Get inventory by product
- [ ] Get inventory by location
- [ ] Get low stock products
- [ ] Authentication with valid token
- [ ] Authentication with invalid token
- [ ] Rate limiting for bulk operations
- [ ] Tenant isolation
- [ ] Concurrent updates handling
