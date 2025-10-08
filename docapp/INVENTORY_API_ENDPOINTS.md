# Inventory API Endpoints Documentation

## Overview
This document describes the API endpoints required for inventory synchronization between the POS mobile app and the backend server.

## Base URL
```
{baseUrl}/api/v1/inventory
```

## Authentication
All endpoints require Bearer token authentication:
```
Authorization: Bearer {token}
```

---

## 1. Create Inventory

### Endpoint
```
POST /api/v1/inventory
```

### Request Body
```json
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

### Response (Success - 201)
```json
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

### Response (Error - 400)
```json
{
  "success": false,
  "message": "Validation failed",
  "errors": {
    "product_id": ["Product not found"],
    "location_id": ["Location not found"]
  }
}
```

---

## 2. Update Inventory

### Endpoint
```
PUT /api/v1/inventory/{inventory_id}
```

### Request Body
```json
{
  "quantity": 50,
  "reserved": 5,
  "updated_at": 1759923672482
}
```

### Response (Success - 200)
```json
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

---

## 3. Delete Inventory

### Endpoint
```
DELETE /api/v1/inventory/{inventory_id}
```

### Response (Success - 200)
```json
{
  "success": true,
  "message": "Inventory deleted successfully"
}
```

---

## 4. Get Inventory by Product

### Endpoint
```
GET /api/v1/inventory/product/{product_id}
```

### Response (Success - 200)
```json
{
  "success": true,
  "data": [
    {
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
  ]
}
```

---

## 5. Get Inventory by Location

### Endpoint
```
GET /api/v1/inventory/location/{location_id}
```

### Response (Success - 200)
```json
{
  "success": true,
  "data": [
    {
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
  ]
}
```

---

## 6. Bulk Inventory Sync

### Endpoint
```
POST /api/v1/inventory/sync
```

### Request Body
```json
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
    }
  ]
}
```

### Response (Success - 200)
```json
{
  "success": true,
  "message": "Inventory sync completed",
  "data": {
    "synced_count": 1,
    "failed_count": 0,
    "failed_items": [],
    "server_timestamp": "2024-01-15T10:35:00Z"
  }
}
```

### Response (Partial Success - 207)
```json
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

---

## 7. Get Low Stock Products

### Endpoint
```
GET /api/v1/inventory/low-stock?tenant_id={tenant_id}
```

### Response (Success - 200)
```json
{
  "success": true,
  "data": [
    {
      "product_id": "prod_1759923672481",
      "product_name": "Minuman",
      "current_stock": 5,
      "min_stock": 10,
      "reorder_point": 30,
      "location_id": "loc_1759923672480",
      "location_name": "Main Store"
    }
  ]
}
```

---

## Data Models

### Inventory Model
```json
{
  "id": "string (required) - Unique inventory ID",
  "tenant_id": "string (required) - Tenant identifier",
  "product_id": "string (required) - Product identifier",
  "location_id": "string (required) - Location identifier",
  "quantity": "integer (required) - Current stock quantity",
  "reserved": "integer (optional, default: 0) - Reserved quantity",
  "updated_at": "integer (required) - Unix timestamp",
  "sync_status": "string (optional, default: 'synced') - 'pending' | 'synced' | 'failed'",
  "last_synced_at": "integer (optional) - Unix timestamp"
}
```

### Error Response Model
```json
{
  "success": false,
  "message": "string - Error description",
  "errors": {
    "field_name": ["array of error messages"]
  }
}
```

---

## HTTP Status Codes

- `200` - Success
- `201` - Created
- `207` - Multi-Status (partial success)
- `400` - Bad Request (validation error)
- `401` - Unauthorized
- `403` - Forbidden
- `404` - Not Found
- `409` - Conflict (duplicate ID)
- `500` - Internal Server Error

---

## Notes for Backend Implementation

1. **ID Generation**: Mobile app generates IDs using timestamp format (`inv_1759923672482`)
2. **Timestamp Format**: All timestamps are Unix milliseconds since epoch
3. **Tenant Isolation**: All operations must be scoped to tenant_id
4. **Foreign Key Validation**: Validate product_id and location_id exist
5. **Sync Status**: Track sync status for offline/online scenarios
6. **Bulk Operations**: Support bulk sync for better performance
7. **Error Handling**: Return detailed error messages for failed items
8. **Rate Limiting**: Consider rate limiting for bulk operations

---

## Mobile App Integration

The mobile app will:
1. Queue inventory operations when offline
2. Sync in bulk when online
3. Handle partial sync failures gracefully
4. Retry failed operations
5. Update local sync_status after successful server sync

---

## Testing Endpoints

### Test Data
```json
{
  "id": "inv_test_001",
  "tenant_id": "test-tenant",
  "product_id": "prod_test_001",
  "location_id": "loc_test_001",
  "quantity": 100,
  "reserved": 0,
  "updated_at": 1759923672482
}
```

### cURL Examples
```bash
# Create inventory
curl -X POST "https://api.example.com/api/v1/inventory" \
  -H "Authorization: Bearer {token}" \
  -H "Content-Type: application/json" \
  -d @inventory_create.json

# Get inventory by product
curl -X GET "https://api.example.com/api/v1/inventory/product/prod_test_001" \
  -H "Authorization: Bearer {token}"

# Bulk sync
curl -X POST "https://api.example.com/api/v1/inventory/sync" \
  -H "Authorization: Bearer {token}" \
  -H "Content-Type: application/json" \
  -d @inventory_sync.json
```
