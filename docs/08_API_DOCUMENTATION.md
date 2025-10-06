# 📡 API Documentation - POS UMKM

## Table of Contents
1. [Authentication](#authentication)
2. [Tenant Management](#tenant-management)
3. [User Management](#user-management)
4. [Category Management](#category-management)
5. [Product Management](#product-management)
6. [Location Management](#location-management)
7. [Inventory Management](#inventory-management)
8. [Transaction Management](#transaction-management)
9. [Stock Movement](#stock-movement)
10. [Sync Endpoints](#sync-endpoints)
11. [Reporting](#reporting)
12. [ML/AI Endpoints](#mlai-endpoints)
13. [Common Response Format](#common-response-format)
14. [Error Handling](#error-handling)

---

## Authentication

### POST /api/auth/login
Login user dan mendapatkan access token.

**Request Body:**
```json
{
  "username": "string",
  "password": "string",
  "device_info": {
    "device_id": "string",
    "device_name": "string",
    "os_version": "string",
    "app_version": "string"
  }
}
```

**Response:**
```json
{
  "success": true,
  "data": {
    "user": {
      "id": "string",
      "tenant_id": "string",
      "username": "string",
      "full_name": "string",
      "role": "string",
      "permissions": ["string"],
      "is_active": true
    },
    "tenant": {
      "id": "string",
      "name": "string",
      "subscription_tier": "string",
      "subscription_expiry": "timestamp"
    },
    "token": "string",
    "refresh_token": "string",
    "expires_at": "timestamp"
  }
}
```

### POST /api/auth/refresh
Refresh access token menggunakan refresh token.

**Request Body:**
```json
{
  "refresh_token": "string"
}
```

**Response:**
```json
{
  "success": true,
  "data": {
    "token": "string",
    "refresh_token": "string",
    "expires_at": "timestamp"
  }
}
```

### POST /api/auth/logout
Logout user dan invalidate token.

**Request Body:**
```json
{
  "device_id": "string"
}
```

**Response:**
```json
{
  "success": true,
  "message": "Logout successful"
}
```

---

## Tenant Management

### GET /api/tenants/{tenant_id}
Mendapatkan informasi tenant.

**Response:**
```json
{
  "success": true,
  "data": {
    "id": "string",
    "name": "string",
    "owner_name": "string",
    "email": "string",
    "phone": "string",
    "address": "string",
    "settings": {
      "currency": "string",
      "timezone": "string",
      "tax_rate": "number",
      "receipt_template": "string"
    },
    "subscription_tier": "string",
    "subscription_expiry": "timestamp",
    "is_active": true,
    "logo_url": "string"
  }
}
```

### PUT /api/tenants/{tenant_id}
Update informasi tenant.

**Request Body:**
```json
{
  "name": "string",
  "owner_name": "string",
  "email": "string",
  "phone": "string",
  "address": "string",
  "settings": {
    "currency": "string",
    "timezone": "string",
    "tax_rate": "number",
    "receipt_template": "string"
  }
}
```

---

## User Management

### GET /api/tenants/{tenant_id}/users
Mendapatkan daftar user dalam tenant.

**Query Parameters:**
- `page`: number (default: 1)
- `limit`: number (default: 20)
- `role`: string (filter by role)
- `is_active`: boolean

**Response:**
```json
{
  "success": true,
  "data": {
    "users": [
      {
        "id": "string",
        "username": "string",
        "email": "string",
        "full_name": "string",
        "role": "string",
        "permissions": ["string"],
        "is_active": true,
        "last_login_at": "timestamp",
        "created_at": "timestamp"
      }
    ],
    "pagination": {
      "page": 1,
      "limit": 20,
      "total": 100,
      "total_pages": 5
    }
  }
}
```

### POST /api/tenants/{tenant_id}/users
Membuat user baru.

**Request Body:**
```json
{
  "username": "string",
  "email": "string",
  "password": "string",
  "full_name": "string",
  "role": "string",
  "permissions": ["string"]
}
```

### GET /api/tenants/{tenant_id}/users/{user_id}
Mendapatkan detail user.

### PUT /api/tenants/{tenant_id}/users/{user_id}
Update informasi user.

### DELETE /api/tenants/{tenant_id}/users/{user_id}
Menghapus user (soft delete).

---

## Category Management

### GET /api/tenants/{tenant_id}/categories
Mendapatkan daftar kategori.

**Query Parameters:**
- `parent_id`: string (filter by parent category)
- `is_active`: boolean

**Response:**
```json
{
  "success": true,
  "data": [
    {
      "id": "string",
      "name": "string",
      "parent_id": "string",
      "icon": "string",
      "color": "string",
      "sort_order": 0,
      "is_active": true,
      "created_at": "timestamp",
      "updated_at": "timestamp"
    }
  ]
}
```

### POST /api/tenants/{tenant_id}/categories
Membuat kategori baru.

**Request Body:**
```json
{
  "name": "string",
  "parent_id": "string",
  "icon": "string",
  "color": "string",
  "sort_order": 0
}
```

### GET /api/tenants/{tenant_id}/categories/{category_id}
Mendapatkan detail kategori.

### PUT /api/tenants/{tenant_id}/categories/{category_id}
Update kategori.

### DELETE /api/tenants/{tenant_id}/categories/{category_id}
Menghapus kategori.

---

## Product Management

### GET /api/tenants/{tenant_id}/products
Mendapatkan daftar produk.

**Query Parameters:**
- `page`: number (default: 1)
- `limit`: number (default: 20)
- `search`: string (search by name/sku)
- `category_id`: string
- `is_active`: boolean
- `low_stock`: boolean
- `sort_by`: string (name, sku, price_sell, created_at)
- `sort_order`: string (asc, desc)

**Response:**
```json
{
  "success": true,
  "data": {
    "products": [
      {
        "id": "string",
        "sku": "string",
        "name": "string",
        "category_id": "string",
        "description": "string",
        "unit": "string",
        "price_buy": 10000,
        "price_sell": 15000,
        "weight": 500,
        "has_barcode": true,
        "barcode": "string",
        "is_expirable": true,
        "is_active": true,
        "min_stock": 10,
        "photos": ["string"],
        "attributes": {
          "brand": "string",
          "size": "string",
          "color": "string"
        },
        "created_at": "timestamp",
        "updated_at": "timestamp"
      }
    ],
    "pagination": {
      "page": 1,
      "limit": 20,
      "total": 100,
      "total_pages": 5
    }
  }
}
```

### POST /api/tenants/{tenant_id}/products
Membuat produk baru.

**Request Body:**
```json
{
  "sku": "string",
  "name": "string",
  "category_id": "string",
  "description": "string",
  "unit": "string",
  "price_buy": 10000,
  "price_sell": 15000,
  "weight": 500,
  "has_barcode": true,
  "barcode": "string",
  "is_expirable": true,
  "min_stock": 10,
  "photos": ["string"],
  "attributes": {
    "brand": "string",
    "size": "string",
    "color": "string"
  }
}
```

### GET /api/tenants/{tenant_id}/products/{product_id}
Mendapatkan detail produk.

### PUT /api/tenants/{tenant_id}/products/{product_id}
Update produk.

### DELETE /api/tenants/{tenant_id}/products/{product_id}
Menghapus produk.

### GET /api/tenants/{tenant_id}/products/search
Pencarian produk dengan full-text search.

**Query Parameters:**
- `q`: string (search query)
- `limit`: number (default: 20)

---

## Location Management

### GET /api/tenants/{tenant_id}/locations
Mendapatkan daftar lokasi.

**Response:**
```json
{
  "success": true,
  "data": [
    {
      "id": "string",
      "name": "string",
      "type": "string",
      "address": "string",
      "is_primary": true,
      "is_active": true,
      "created_at": "timestamp",
      "updated_at": "timestamp"
    }
  ]
}
```

### POST /api/tenants/{tenant_id}/locations
Membuat lokasi baru.

**Request Body:**
```json
{
  "name": "string",
  "type": "string",
  "address": "string",
  "is_primary": false
}
```

---

## Inventory Management

### GET /api/tenants/{tenant_id}/inventory
Mendapatkan data inventory.

**Query Parameters:**
- `location_id`: string
- `product_id`: string
- `low_stock`: boolean

**Response:**
```json
{
  "success": true,
  "data": [
    {
      "id": "string",
      "product_id": "string",
      "location_id": "string",
      "quantity": 100,
      "reserved": 5,
      "updated_at": "timestamp"
    }
  ]
}
```

### POST /api/tenants/{tenant_id}/inventory/adjustment
Melakukan penyesuaian stok.

**Request Body:**
```json
{
  "product_id": "string",
  "location_id": "string",
  "quantity": 10,
  "type": "string",
  "notes": "string",
  "user_id": "string"
}
```

### GET /api/tenants/{tenant_id}/inventory/low-stock
Mendapatkan produk dengan stok rendah.

**Response:**
```json
{
  "success": true,
  "data": [
    {
      "product_id": "string",
      "product_name": "string",
      "current_stock": 5,
      "min_stock": 10,
      "location_id": "string",
      "location_name": "string"
    }
  ]
}
```

---

## Transaction Management

### GET /api/tenants/{tenant_id}/transactions
Mendapatkan daftar transaksi.

**Query Parameters:**
- `page`: number (default: 1)
- `limit`: number (default: 20)
- `start_date`: timestamp
- `end_date`: timestamp
- `user_id`: string
- `status`: string
- `location_id`: string

**Response:**
```json
{
  "success": true,
  "data": {
    "transactions": [
      {
        "id": "string",
        "receipt_number": "string",
        "subtotal": 100000,
        "discount": 5000,
        "tax": 9500,
        "total": 104500,
        "payment_method": "string",
        "payment_details": {
          "cash_amount": 100000,
          "qris_amount": 4500,
          "e_wallet_amount": 0
        },
        "amount_paid": 104500,
        "change_amount": 0,
        "status": "string",
        "notes": "string",
        "customer_name": "string",
        "customer_phone": "string",
        "user_id": "string",
        "location_id": "string",
        "created_at": "timestamp",
        "items": [
          {
            "id": "string",
            "product_id": "string",
            "product_name": "string",
            "sku": "string",
            "quantity": 2,
            "unit_price": 50000,
            "discount": 0,
            "subtotal": 100000
          }
        ]
      }
    ],
    "pagination": {
      "page": 1,
      "limit": 20,
      "total": 100,
      "total_pages": 5
    }
  }
}
```

### POST /api/tenants/{tenant_id}/transactions
Membuat transaksi baru.

**Request Body:**
```json
{
  "location_id": "string",
  "subtotal": 100000,
  "discount": 5000,
  "tax": 9500,
  "total": 104500,
  "payment_method": "string",
  "payment_details": {
    "cash_amount": 100000,
    "qris_amount": 4500,
    "e_wallet_amount": 0
  },
  "amount_paid": 104500,
  "change_amount": 0,
  "notes": "string",
  "customer_name": "string",
  "customer_phone": "string",
  "items": [
    {
      "product_id": "string",
      "quantity": 2,
      "unit_price": 50000,
      "discount": 0,
      "subtotal": 100000
    }
  ]
}
```

### GET /api/tenants/{tenant_id}/transactions/{transaction_id}
Mendapatkan detail transaksi.

### POST /api/tenants/{tenant_id}/transactions/{transaction_id}/void
Membatalkan transaksi.

**Request Body:**
```json
{
  "reason": "string"
}
```

### POST /api/tenants/{tenant_id}/transactions/{transaction_id}/refund
Melakukan refund transaksi.

**Request Body:**
```json
{
  "items": [
    {
      "item_id": "string",
      "quantity": 1,
      "reason": "string"
    }
  ],
  "reason": "string"
}
```

---

## Stock Movement

### GET /api/tenants/{tenant_id}/stock-movements
Mendapatkan riwayat pergerakan stok.

**Query Parameters:**
- `product_id`: string
- `location_id`: string
- `type`: string
- `start_date`: timestamp
- `end_date`: timestamp
- `page`: number
- `limit`: number

**Response:**
```json
{
  "success": true,
  "data": {
    "movements": [
      {
        "id": "string",
        "product_id": "string",
        "location_id": "string",
        "type": "string",
        "quantity": 10,
        "reference_type": "string",
        "reference_id": "string",
        "notes": "string",
        "user_id": "string",
        "created_at": "timestamp"
      }
    ],
    "pagination": {
      "page": 1,
      "limit": 20,
      "total": 100,
      "total_pages": 5
    }
  }
}
```

---

## Sync Endpoints

### POST /api/tenants/{tenant_id}/sync/upload
Upload data dari mobile ke server.

**Request Body:**
```json
{
  "entity_type": "string",
  "operations": [
    {
      "id": "string",
      "operation": "string",
      "payload": {},
      "created_at": "timestamp"
    }
  ]
}
```

**Response:**
```json
{
  "success": true,
  "data": {
    "processed": 10,
    "failed": 0,
    "errors": []
  }
}
```

### GET /api/tenants/{tenant_id}/sync/download
Download data dari server ke mobile.

**Query Parameters:**
- `last_sync_at`: timestamp
- `entity_types`: string[] (products, categories, transactions, inventory)

**Response:**
```json
{
  "success": true,
  "data": {
    "entities": {
      "products": [],
      "categories": [],
      "transactions": [],
      "inventory": []
    },
    "sync_timestamp": "timestamp"
  }
}
```

### GET /api/tenants/{tenant_id}/sync/status
Mendapatkan status sync.

**Response:**
```json
{
  "success": true,
  "data": {
    "last_sync_at": "timestamp",
    "pending_uploads": 5,
    "pending_downloads": 2,
    "sync_in_progress": false
  }
}
```

---

## Reporting

### GET /api/tenants/{tenant_id}/reports/sales
Laporan penjualan.

**Query Parameters:**
- `start_date`: timestamp
- `end_date`: timestamp
- `location_id`: string
- `user_id`: string
- `group_by`: string (day, week, month)

**Response:**
```json
{
  "success": true,
  "data": {
    "summary": {
      "total_sales": 1000000,
      "total_transactions": 100,
      "average_transaction": 10000
    },
    "daily_data": [
      {
        "date": "2024-01-01",
        "sales": 50000,
        "transactions": 5
      }
    ],
    "payment_methods": [
      {
        "method": "cash",
        "amount": 600000,
        "percentage": 60
      },
      {
        "method": "qris",
        "amount": 400000,
        "percentage": 40
      }
    ]
  }
}
```

### GET /api/tenants/{tenant_id}/reports/products
Laporan produk.

**Query Parameters:**
- `start_date`: timestamp
- `end_date`: timestamp
- `top_n`: number (default: 10)

**Response:**
```json
{
  "success": true,
  "data": {
    "top_products": [
      {
        "product_id": "string",
        "product_name": "string",
        "quantity_sold": 100,
        "revenue": 500000
      }
    ],
    "low_stock": [
      {
        "product_id": "string",
        "product_name": "string",
        "current_stock": 5,
        "min_stock": 10
      }
    ]
  }
}
```

### GET /api/tenants/{tenant_id}/reports/inventory
Laporan inventory.

**Response:**
```json
{
  "success": true,
  "data": {
    "total_products": 100,
    "total_value": 5000000,
    "low_stock_count": 5,
    "out_of_stock_count": 2
  }
}
```

---

## ML/AI Endpoints

### POST /api/tenants/{tenant_id}/ml/product-detection
Deteksi produk dari gambar.

**Request Body:**
```json
{
  "image": "base64_string",
  "model_version": "string"
}
```

**Response:**
```json
{
  "success": true,
  "data": {
    "predictions": [
      {
        "product_id": "string",
        "confidence": 0.95,
        "product_name": "string"
      }
    ],
    "inference_time_ms": 150,
    "model_version": "string"
  }
}
```

### GET /api/tenants/{tenant_id}/ml/models/update
Cek update model ML.

**Response:**
```json
{
  "success": true,
  "data": {
    "model_url": "string",
    "version": "string",
    "size": 1024000,
    "checksum": "string",
    "update_available": true
  }
}
```

### POST /api/tenants/{tenant_id}/ml/feedback
Kirim feedback untuk model ML.

**Request Body:**
```json
{
  "detection_id": "string",
  "is_correct": true,
  "correct_product_id": "string",
  "feedback_notes": "string"
}
```

---

## Common Response Format

### Success Response
```json
{
  "success": true,
  "data": {},
  "message": "string",
  "timestamp": "2024-01-01T00:00:00Z"
}
```

### Error Response
```json
{
  "success": false,
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "string",
    "details": {}
  },
  "timestamp": "2024-01-01T00:00:00Z"
}
```

---

## Error Handling

### HTTP Status Codes
- `200` - Success
- `201` - Created
- `400` - Bad Request
- `401` - Unauthorized
- `403` - Forbidden
- `404` - Not Found
- `409` - Conflict
- `422` - Validation Error
- `500` - Internal Server Error

### Error Codes
- `VALIDATION_ERROR` - Input validation failed
- `AUTHENTICATION_ERROR` - Authentication failed
- `AUTHORIZATION_ERROR` - Insufficient permissions
- `NOT_FOUND` - Resource not found
- `DUPLICATE_ERROR` - Resource already exists
- `BUSINESS_LOGIC_ERROR` - Business rule violation
- `SYNC_ERROR` - Sync operation failed
- `ML_ERROR` - ML model error

### Authentication Headers
```
Authorization: Bearer {access_token}
Content-Type: application/json
X-Device-ID: {device_id}
X-App-Version: {app_version}
X-Platform: {platform}
```

### Pagination
```json
{
  "pagination": {
    "page": 1,
    "limit": 20,
    "total": 100,
    "total_pages": 5,
    "has_next": true,
    "has_prev": false
  }
}
```

### Date Format
All timestamps use ISO 8601 format: `2024-01-01T00:00:00Z`

### Rate Limiting
- `1000 requests per hour` per user
- `100 requests per minute` per IP
- `10 requests per second` for ML endpoints

---

## Webhook Endpoints

### POST /api/webhooks/transaction-created
Webhook untuk transaksi baru.

**Payload:**
```json
{
  "event": "transaction.created",
  "data": {
    "transaction_id": "string",
    "tenant_id": "string",
    "total": 100000,
    "created_at": "timestamp"
  }
}
```

### POST /api/webhooks/low-stock-alert
Webhook untuk alert stok rendah.

**Payload:**
```json
{
  "event": "inventory.low_stock",
  "data": {
    "product_id": "string",
    "tenant_id": "string",
    "current_stock": 5,
    "min_stock": 10
  }
}
```

---

## Testing

### Test Environment
- Base URL: `https://api-test.posumkm.com`
- Test credentials available in documentation

### Postman Collection
Download Postman collection: [POS UMKM API Collection](./postman/POS_UMKM_API.postman_collection.json)

### API Documentation
Interactive API documentation available at: `https://api.posumkm.com/docs`
