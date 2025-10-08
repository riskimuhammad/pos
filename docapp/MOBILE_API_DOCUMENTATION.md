# Mobile API Documentation - POS UMKM

## Overview

Dokumentasi lengkap API yang digunakan oleh aplikasi mobile POS UMKM untuk integrasi dengan backend server. Dokumentasi ini mencakup semua endpoint, parameter, request/response format, dan contoh implementasi.

## Base Configuration

### API Base URL
```
https://api.pos-umkm.com/v1
```

### Authentication
Semua API requests memerlukan Bearer token authentication:
```http
Authorization: Bearer <access_token>
Content-Type: application/json
```

### Response Format
Semua API responses mengikuti format standar:
```json
{
  "success": true,
  "data": { ... },
  "message": "Success",
  "timestamp": "2024-01-15T10:30:00Z"
}
```

### Error Response Format
```json
{
  "success": false,
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Invalid product ID",
    "details": { ... }
  },
  "timestamp": "2024-01-15T10:30:00Z"
}
```

---

## 1. Product Management API

### 1.1 Create Product

#### Endpoint
```http
POST /api/products
```

#### Request Body
```json
{
  "tenant_id": "tenant_123",
  "sku": "IMG001",
  "name": "Indomie Goreng Rendang",
  "category_id": "cat_1",
  "description": "Mie instan goreng dengan bumbu rendang yang autentik",
  "unit": "bungkus",
  "price_buy": 2500.0,
  "price_sell": 3500.0,
  "weight": 0.0,
  "has_barcode": true,
  "barcode": "1234567890123",
  "is_expirable": false,
  "is_active": true,
  "min_stock": 10,
  "brand": "Indomie",
  "variant": "Goreng Rendang",
  "pack_size": "75g",
  "uom": "bungkus",
  "reorder_point": 5,
  "reorder_qty": 50,
  "photos": [
    "https://images.unsplash.com/photo-1569718212165-3a8278d5f624"
  ],
  "attributes": {
    "flavor": "rendang",
    "spice_level": "medium",
    "cooking_time": "3 minutes"
  }
}
```

#### Request Parameters
| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `tenant_id` | string | Yes | ID tenant pemilik produk |
| `sku` | string | Yes | Stock Keeping Unit (kode unik produk) |
| `name` | string | Yes | Nama produk |
| `category_id` | string | Yes | ID kategori produk |
| `description` | string | No | Deskripsi produk |
| `unit` | string | No | Satuan produk (default: "pcs") |
| `price_buy` | float | Yes | Harga beli produk |
| `price_sell` | float | Yes | Harga jual produk |
| `weight` | float | No | Berat produk dalam gram |
| `has_barcode` | boolean | No | Apakah produk memiliki barcode |
| `barcode` | string | No | Kode barcode produk |
| `is_expirable` | boolean | No | Apakah produk bisa expired |
| `is_active` | boolean | No | Status aktif produk |
| `min_stock` | integer | No | Stok minimum |
| `brand` | string | No | Merek produk |
| `variant` | string | No | Varian produk |
| `pack_size` | string | No | Ukuran kemasan |
| `uom` | string | No | Unit of Measure |
| `reorder_point` | integer | No | Titik reorder stok |
| `reorder_qty` | integer | No | Jumlah reorder |
| `photos` | array | No | Array URL foto produk |
| `attributes` | object | No | Atribut tambahan produk |

#### Request Example
```http
POST /api/products
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
Content-Type: application/json

{
  "tenant_id": "tenant_123",
  "sku": "IMG001",
  "name": "Indomie Goreng Rendang",
  "category_id": "cat_1",
  "description": "Mie instan goreng dengan bumbu rendang yang autentik",
  "unit": "bungkus",
  "price_buy": 2500.0,
  "price_sell": 3500.0,
  "has_barcode": true,
  "barcode": "1234567890123",
  "is_active": true,
  "min_stock": 10,
  "brand": "Indomie",
  "variant": "Goreng Rendang",
  "pack_size": "75g",
  "uom": "bungkus",
  "reorder_point": 5,
  "reorder_qty": 50
}
```

#### Response Data Contract
```json
{
  "id": "prod_001",
  "tenant_id": "tenant_123",
  "sku": "IMG001",
  "name": "Indomie Goreng Rendang",
  "category_id": "cat_1",
  "description": "Mie instan goreng dengan bumbu rendang yang autentik",
  "unit": "bungkus",
  "price_buy": 2500.0,
  "price_sell": 3500.0,
  "weight": 0.0,
  "has_barcode": true,
  "barcode": "1234567890123",
  "is_expirable": false,
  "is_active": true,
  "min_stock": 10,
  "brand": "Indomie",
  "variant": "Goreng Rendang",
  "pack_size": "75g",
  "uom": "bungkus",
  "reorder_point": 5,
  "reorder_qty": 50,
  "photos": [
    "https://images.unsplash.com/photo-1569718212165-3a8278d5f624"
  ],
  "attributes": {
    "flavor": "rendang",
    "spice_level": "medium",
    "cooking_time": "3 minutes"
  },
  "created_at": "2024-01-15T10:30:00Z",
  "updated_at": "2024-01-15T10:30:00Z",
  "deleted_at": null,
  "sync_status": "synced",
  "last_synced_at": "2024-01-15T10:30:00Z"
}
```

### 1.2 Update Product

#### Endpoint
```http
PUT /api/products/{productId}
```

#### Request Body
```json
{
  "sku": "IMG001",
  "name": "Indomie Goreng Rendang Updated",
  "category_id": "cat_1",
  "description": "Mie instan goreng dengan bumbu rendang yang autentik - Updated",
  "unit": "bungkus",
  "price_buy": 2600.0,
  "price_sell": 3600.0,
  "weight": 0.0,
  "has_barcode": true,
  "barcode": "1234567890123",
  "is_expirable": false,
  "is_active": true,
  "min_stock": 15,
  "brand": "Indomie",
  "variant": "Goreng Rendang",
  "pack_size": "75g",
  "uom": "bungkus",
  "reorder_point": 8,
  "reorder_qty": 60,
  "photos": [
    "https://images.unsplash.com/photo-1569718212165-3a8278d5f624"
  ],
  "attributes": {
    "flavor": "rendang",
    "spice_level": "medium",
    "cooking_time": "3 minutes"
  }
}
```

#### Request Parameters
| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `productId` | string | Yes | ID produk yang akan diupdate (path parameter) |
| `sku` | string | No | Stock Keeping Unit (kode unik produk) |
| `name` | string | No | Nama produk |
| `category_id` | string | No | ID kategori produk |
| `description` | string | No | Deskripsi produk |
| `unit` | string | No | Satuan produk |
| `price_buy` | float | No | Harga beli produk |
| `price_sell` | float | No | Harga jual produk |
| `weight` | float | No | Berat produk dalam gram |
| `has_barcode` | boolean | No | Apakah produk memiliki barcode |
| `barcode` | string | No | Kode barcode produk |
| `is_expirable` | boolean | No | Apakah produk bisa expired |
| `is_active` | boolean | No | Status aktif produk |
| `min_stock` | integer | No | Stok minimum |
| `brand` | string | No | Merek produk |
| `variant` | string | No | Varian produk |
| `pack_size` | string | No | Ukuran kemasan |
| `uom` | string | No | Unit of Measure |
| `reorder_point` | integer | No | Titik reorder stok |
| `reorder_qty` | integer | No | Jumlah reorder |
| `photos` | array | No | Array URL foto produk |
| `attributes` | object | No | Atribut tambahan produk |

#### Request Example
```http
PUT /api/products/prod_001
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
Content-Type: application/json

{
  "name": "Indomie Goreng Rendang Updated",
  "price_buy": 2600.0,
  "price_sell": 3600.0,
  "min_stock": 15,
  "reorder_point": 8,
  "reorder_qty": 60
}
```

#### Response Data Contract
```json
{
  "id": "prod_001",
  "tenant_id": "tenant_123",
  "sku": "IMG001",
  "name": "Indomie Goreng Rendang Updated",
  "category_id": "cat_1",
  "description": "Mie instan goreng dengan bumbu rendang yang autentik - Updated",
  "unit": "bungkus",
  "price_buy": 2600.0,
  "price_sell": 3600.0,
  "weight": 0.0,
  "has_barcode": true,
  "barcode": "1234567890123",
  "is_expirable": false,
  "is_active": true,
  "min_stock": 15,
  "brand": "Indomie",
  "variant": "Goreng Rendang",
  "pack_size": "75g",
  "uom": "bungkus",
  "reorder_point": 8,
  "reorder_qty": 60,
  "photos": [
    "https://images.unsplash.com/photo-1569718212165-3a8278d5f624"
  ],
  "attributes": {
    "flavor": "rendang",
    "spice_level": "medium",
    "cooking_time": "3 minutes"
  },
  "created_at": "2024-01-15T10:30:00Z",
  "updated_at": "2024-01-15T11:45:00Z",
  "deleted_at": null,
  "sync_status": "synced",
  "last_synced_at": "2024-01-15T11:45:00Z"
}
```

### 1.3 Get Products

#### Endpoint
```http
GET /api/products?tenant_id={tenantId}&category_id={categoryId}&search={query}&page={page}&limit={limit}
```

#### Request Parameters
| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `tenant_id` | string | Yes | ID tenant |
| `category_id` | string | No | Filter by category ID |
| `search` | string | No | Search query for name/SKU |
| `page` | integer | No | Page number (default: 1) |
| `limit` | integer | No | Items per page (default: 20) |

#### Request Example
```http
GET /api/products?tenant_id=tenant_123&search=indomie&page=1&limit=20
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

#### Response Data Contract
```json
{
  "products": [
    {
      "id": "prod_001",
      "tenant_id": "tenant_123",
      "sku": "IMG001",
      "name": "Indomie Goreng Rendang",
      "category_id": "cat_1",
      "description": "Mie instan goreng dengan bumbu rendang yang autentik",
      "unit": "bungkus",
      "price_buy": 2500.0,
      "price_sell": 3500.0,
      "weight": 0.0,
      "has_barcode": true,
      "barcode": "1234567890123",
      "is_expirable": false,
      "is_active": true,
      "min_stock": 10,
      "brand": "Indomie",
      "variant": "Goreng Rendang",
      "pack_size": "75g",
      "uom": "bungkus",
      "reorder_point": 5,
      "reorder_qty": 50,
      "photos": [
        "https://images.unsplash.com/photo-1569718212165-3a8278d5f624"
      ],
      "attributes": {
        "flavor": "rendang",
        "spice_level": "medium",
        "cooking_time": "3 minutes"
      },
      "created_at": "2024-01-15T10:30:00Z",
      "updated_at": "2024-01-15T10:30:00Z",
      "deleted_at": null,
      "sync_status": "synced",
      "last_synced_at": "2024-01-15T10:30:00Z"
    }
  ],
  "pagination": {
    "current_page": 1,
    "total_pages": 5,
    "total_items": 100,
    "items_per_page": 20,
    "has_next": true,
    "has_prev": false
  }
}
```

### 1.4 Get Product by ID

#### Endpoint
```http
GET /api/products/{productId}
```

#### Request Example
```http
GET /api/products/prod_001
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

#### Response Data Contract
```json
{
  "id": "prod_001",
  "tenant_id": "tenant_123",
  "sku": "IMG001",
  "name": "Indomie Goreng Rendang",
  "category_id": "cat_1",
  "description": "Mie instan goreng dengan bumbu rendang yang autentik",
  "unit": "bungkus",
  "price_buy": 2500.0,
  "price_sell": 3500.0,
  "weight": 0.0,
  "has_barcode": true,
  "barcode": "1234567890123",
  "is_expirable": false,
  "is_active": true,
  "min_stock": 10,
  "brand": "Indomie",
  "variant": "Goreng Rendang",
  "pack_size": "75g",
  "uom": "bungkus",
  "reorder_point": 5,
  "reorder_qty": 50,
  "photos": [
    "https://images.unsplash.com/photo-1569718212165-3a8278d5f624"
  ],
  "attributes": {
    "flavor": "rendang",
    "spice_level": "medium",
    "cooking_time": "3 minutes"
  },
  "created_at": "2024-01-15T10:30:00Z",
  "updated_at": "2024-01-15T10:30:00Z",
  "deleted_at": null,
  "sync_status": "synced",
  "last_synced_at": "2024-01-15T10:30:00Z"
}
```

### 1.5 Delete Product

#### Endpoint
```http
DELETE /api/products/{productId}
```

#### Request Example
```http
DELETE /api/products/prod_001
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

#### Response Data Contract
```json
{
  "success": true,
  "message": "Product deleted successfully",
  "data": {
    "id": "prod_001",
    "deleted_at": "2024-01-15T12:00:00Z"
  },
  "timestamp": "2024-01-15T12:00:00Z"
}
```

---

## 2. Sales Prediction API

### Endpoint
```http
GET /api/ai/sales-prediction/{productId}?days={daysAhead}
```

### Request Parameters
| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `productId` | string | Yes | ID produk yang akan diprediksi (path parameter) |
| `days` | integer | No | Jumlah hari ke depan untuk prediksi (default: 7) |

### Request Example
```http
GET /api/ai/sales-prediction/prod_123?days=7
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

### Response Data Contract
```json
{
  "product_id": "prod_123",
  "predicted_quantity": 45,
  "confidence": 0.85,
  "trend": "increasing",
  "recommendations": [
    "Consider increasing stock for weekend sales",
    "Monitor competitor pricing"
  ],
  "daily_average": 6.4,
  "trend_percentage": 15
}
```

### Field Descriptions
| Field | Type | Description |
|-------|------|-------------|
| `product_id` | string | Unique product identifier |
| `predicted_quantity` | integer | Predicted sales quantity for the period |
| `confidence` | float | Confidence score (0.0 to 1.0) |
| `trend` | string | Sales trend ("increasing", "decreasing", "stable") |
| `recommendations` | array | Array of actionable recommendations |
| `daily_average` | float | Average daily sales quantity |
| `trend_percentage` | integer | Percentage change in trend |

---

## 2. Top Products API

### Endpoint
```http
GET /api/ai/top-products?limit={limit}&days={daysBack}
```

### Request Parameters
| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `limit` | integer | No | Maximum number of products to return (default: 10) |
| `days` | integer | No | Number of days to look back (default: 30) |

### Request Example
```http
GET /api/ai/top-products?limit=10&days=30
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

### Response Data Contract
```json
[
  {
    "product_id": "prod_123",
    "product_name": "Nasi Goreng Spesial",
    "category_name": "Makanan Utama",
    "total_quantity": 150,
    "total_revenue": 2250000.0,
    "avg_price": 15000.0,
    "transaction_count": 45
  },
  {
    "product_id": "prod_456",
    "product_name": "Es Teh Manis",
    "category_name": "Minuman",
    "total_quantity": 200,
    "total_revenue": 800000.0,
    "avg_price": 4000.0,
    "transaction_count": 50
  }
]
```

### Field Descriptions
| Field | Type | Description |
|-------|------|-------------|
| `product_id` | string | Unique product identifier |
| `product_name` | string | Display name of the product |
| `category_name` | string | Category the product belongs to |
| `total_quantity` | integer | Total quantity sold in the period |
| `total_revenue` | float | Total revenue generated |
| `avg_price` | float | Average selling price |
| `transaction_count` | integer | Number of transactions |

---

## 3. Top Categories API

### Endpoint
```http
GET /api/ai/top-categories?limit={limit}&days={daysBack}
```

### Request Parameters
| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `limit` | integer | No | Maximum number of categories to return (default: 5) |
| `days` | integer | No | Number of days to look back (default: 30) |

### Request Example
```http
GET /api/ai/top-categories?limit=5&days=30
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

### Response Data Contract
```json
[
  {
    "category_id": "cat_001",
    "category_name": "Makanan Utama",
    "total_quantity": 500,
    "total_revenue": 7500000.0,
    "product_count": 25
  },
  {
    "category_id": "cat_002",
    "category_name": "Minuman",
    "total_quantity": 300,
    "total_revenue": 1200000.0,
    "product_count": 15
  }
]
```

### Field Descriptions
| Field | Type | Description |
|-------|------|-------------|
| `category_id` | string | Unique category identifier |
| `category_name` | string | Display name of the category |
| `total_quantity` | integer | Total quantity sold in the period |
| `total_revenue` | float | Total revenue generated |
| `product_count` | integer | Number of products in this category |

---

## 4. Price Recommendation API

### Endpoint
```http
POST /api/ai/price-recommendation
```

### Request Body
```json
{
  "product_id": "prod_123",
  "competitor_price": 18000.0,
  "target_margin": 0.3
}
```

### Request Parameters
| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `product_id` | string | Yes | ID produk yang akan direkomendasikan harganya |
| `competitor_price` | float | No | Harga kompetitor untuk analisis |
| `target_margin` | float | No | Target margin yang diinginkan (0.0 to 1.0) |

### Request Example
```http
POST /api/ai/price-recommendation
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
Content-Type: application/json

{
  "product_id": "prod_123",
  "competitor_price": 18000.0,
  "target_margin": 0.3
}
```

### Response Data Contract
```json
{
  "product_id": "prod_123",
  "current_price": 15000.0,
  "recommended_price": 17500.0,
  "current_margin": 0.25,
  "target_margin": 0.3,
  "price_change": 2500.0,
  "price_change_percent": 16.67,
  "strategies": [
    {
      "type": "marginBased",
      "price": 17500.0,
      "confidence": 0.9,
      "reasoning": "Based on target margin of 30%"
    },
    {
      "type": "competitorBased",
      "price": 17000.0,
      "confidence": 0.8,
      "reasoning": "5% below competitor price"
    }
  ],
  "best_strategy": {
    "type": "marginBased",
    "price": 17500.0,
    "confidence": 0.9,
    "reasoning": "Based on target margin of 30%"
  },
  "impact": {
    "sales_impact": -0.1,
    "revenue_impact": 0.15,
    "margin_impact": 0.05
  }
}
```

### Field Descriptions
| Field | Type | Description |
|-------|------|-------------|
| `product_id` | string | Unique product identifier |
| `current_price` | float | Current selling price |
| `recommended_price` | float | AI-recommended price |
| `current_margin` | float | Current profit margin |
| `target_margin` | float | Target profit margin |
| `price_change` | float | Absolute price change amount |
| `price_change_percent` | float | Percentage price change |
| `strategies` | array | Array of pricing strategies considered |
| `best_strategy` | object | The recommended strategy |
| `impact` | object | Predicted impact of price change |

---

## 5. Price Review Items API

### Endpoint
```http
GET /api/ai/price-review-items
```

### Request Example
```http
GET /api/ai/price-review-items
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

### Response Data Contract
```json
[
  {
    "product_id": "prod_123",
    "product_name": "Nasi Goreng Spesial",
    "current_price": 15000.0,
    "cost_price": 10000.0,
    "margin_percent": 33.33,
    "total_sales": 45,
    "last_sale_date": "2024-01-14T10:30:00Z",
    "issues": [
      "Low margin compared to category average",
      "Price hasn't been updated in 30 days"
    ],
    "regional_avg_price": 16500.0,
    "suggested_price": 17500.0,
    "price_delta": 2500.0,
    "predicted_margin_impact": 0.05
  }
]
```

### Field Descriptions
| Field | Type | Description |
|-------|------|-------------|
| `product_id` | string | Unique product identifier |
| `product_name` | string | Display name of the product |
| `current_price` | float | Current selling price |
| `cost_price` | float | Cost price of the product |
| `margin_percent` | float | Current margin percentage |
| `total_sales` | integer | Total sales in the period |
| `last_sale_date` | string | ISO 8601 date of last sale |
| `issues` | array | Array of pricing issues identified |
| `regional_avg_price` | float | Regional average price |
| `suggested_price` | float | AI-suggested new price |
| `price_delta` | float | Price change amount |
| `predicted_margin_impact` | float | Predicted margin improvement |

---

## 6. Product Recommendations API

### Endpoint
```http
GET /api/ai/product-recommendations?limit={limit}
```

### Request Parameters
| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `limit` | integer | No | Maximum number of recommendations (default: 10) |

### Request Example
```http
GET /api/ai/product-recommendations?limit=10
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

### Response Data Contract
```json
[
  {
    "category_id": "cat_001",
    "category_name": "Makanan Utama",
    "avg_margin": 0.35,
    "total_sales": 500,
    "suggestions": [
      "Add more variety to breakfast items",
      "Consider seasonal menu items"
    ],
    "reasoning": "High margin category with good sales volume"
  }
]
```

### Field Descriptions
| Field | Type | Description |
|-------|------|-------------|
| `category_id` | string | Category identifier (nullable) |
| `category_name` | string | Display name of the category |
| `avg_margin` | float | Average margin for this category |
| `total_sales` | integer | Total sales in this category |
| `suggestions` | array | Array of product suggestions |
| `reasoning` | string | Explanation for the recommendation |

---

## 7. Daily Insight API

### Endpoint
```http
GET /api/ai/daily-insight
```

### Request Example
```http
GET /api/ai/daily-insight
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

### Response Data Contract
```json
{
  "date": "2024-01-15T00:00:00Z",
  "today_sales": {
    "transaction_count": 25,
    "total_revenue": 1250000.0,
    "avg_transaction_value": 50000.0
  },
  "top_products": [
    {
      "product_id": "prod_123",
      "product_name": "Nasi Goreng Spesial",
      "quantity_sold": 15,
      "revenue": 225000.0
    }
  ],
  "low_stock_items": [
    {
      "product_id": "prod_456",
      "product_name": "Es Teh Manis",
      "current_stock": 5,
      "min_stock": 10,
      "deficit": 5,
      "days_coverage": 2,
      "suggested_restock_qty": 50
    }
  ],
  "weekly_trend": "increasing",
  "recommendations": [
    {
      "type": "inventory",
      "priority": "high",
      "title": "Restock Low Stock Items",
      "description": "5 items need immediate restocking",
      "action": "Order 50 units of Es Teh Manis",
      "impact": "Prevent lost sales"
    }
  ]
}
```

### Field Descriptions
| Field | Type | Description |
|-------|------|-------------|
| `date` | string | ISO 8601 date |
| `today_sales` | object | Today's sales summary |
| `top_products` | array | Top selling products today |
| `low_stock_items` | array | Products with low stock |
| `weekly_trend` | string | Weekly trend ("increasing", "decreasing", "stable") |
| `recommendations` | array | Action recommendations |

---

## 8. Business Performance API

### Endpoint
```http
GET /api/ai/business-performance?days={daysBack}
```

### Request Parameters
| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `days` | integer | No | Number of days to look back (default: 30) |

### Request Example
```http
GET /api/ai/business-performance?days=30
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

### Response Data Contract
```json
{
  "period": {
    "start_date": "2023-12-16T00:00:00Z",
    "end_date": "2024-01-15T00:00:00Z",
    "days": 30
  },
  "revenue_trend": {
    "total_revenue": 45000000.0,
    "avg_daily_revenue": 1500000.0,
    "growth_rate": 0.12,
    "trend": "increasing"
  },
  "transaction_metrics": {
    "total_transactions": 900,
    "avg_daily_transactions": 30,
    "avg_transaction_value": 50000.0
  },
  "category_performance": [
    {
      "category_id": "cat_001",
      "category_name": "Makanan Utama",
      "revenue": 22500000.0,
      "transaction_count": 450,
      "avg_margin": 0.35
    }
  ],
  "margin_analysis": {
    "avg_margin": 0.32,
    "min_margin": 0.15,
    "max_margin": 0.45
  }
}
```

### Field Descriptions
| Field | Type | Description |
|-------|------|-------------|
| `period` | object | Analysis period information |
| `revenue_trend` | object | Revenue trend analysis |
| `transaction_metrics` | object | Transaction statistics |
| `category_performance` | array | Performance by category |
| `margin_analysis` | object | Overall margin statistics |

---

## 9. Business Forecast API

### Endpoint
```http
GET /api/ai/business-forecast?days={daysAhead}
```

### Request Parameters
| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `days` | integer | No | Number of days to forecast (default: 30) |

### Request Example
```http
GET /api/ai/business-forecast?days=30
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

### Response Data Contract
```json
{
  "predicted_revenue": 45000000.0,
  "confidence": 0.78,
  "trend": 0.12,
  "avg_daily_revenue": 1500000.0,
  "recommendations": [
    "Consider expanding popular menu items",
    "Monitor seasonal trends for better forecasting"
  ]
}
```

### Field Descriptions
| Field | Type | Description |
|-------|------|-------------|
| `predicted_revenue` | float | Total predicted revenue for the period |
| `confidence` | float | Confidence score (0.0 to 1.0) |
| `trend` | float | Trend factor (positive = growth, negative = decline) |
| `avg_daily_revenue` | float | Average daily revenue prediction |
| `recommendations` | array | Strategic recommendations |

---

## 10. Business Recommendations API

### Endpoint
```http
GET /api/ai/business-recommendations?top_n={topN}&restock_policy={policy}&percent={percent}
```

### Request Parameters
| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `top_n` | integer | No | Number of top items to consider (default: 3) |
| `restock_policy` | string | No | Restock policy ("percent_of_sales", "fixed_amount") |
| `percent` | float | No | Percentage of sales for restock calculation (default: 0.2) |

### Request Example
```http
GET /api/ai/business-recommendations?top_n=3&restock_policy=percent_of_sales&percent=0.2
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

### Response Data Contract
```json
[
  {
    "type": "pricing",
    "priority": "high",
    "title": "Optimize Menu Pricing",
    "description": "Several items have low margins affecting profitability",
    "action": "Review and adjust pricing for 5 low-margin items",
    "impact": "Expected 15% increase in profit margin"
  },
  {
    "type": "inventory",
    "priority": "medium",
    "title": "Stock Management",
    "description": "Some popular items frequently run out of stock",
    "action": "Increase stock levels for top 3 selling items",
    "impact": "Reduce lost sales by 20%"
  },
  {
    "type": "restock",
    "priority": "high",
    "title": "Restock Top 3 Items",
    "description": "Best-selling items need restocking",
    "action": "Order 50 units of Nasi Goreng Spesial",
    "impact": "Maintain sales momentum",
    "items": [
      {
        "product_id": "prod_123",
        "product_name": "Nasi Goreng Spesial",
        "current_stock": 15,
        "suggested_qty": 50,
        "reason": "High demand, low stock"
      }
    ]
  }
]
```

### Field Descriptions
| Field | Type | Description |
|-------|------|-------------|
| `type` | string | Recommendation type ("pricing", "inventory", "product", "category", "marketing", "restock") |
| `priority` | string | Priority level ("low", "medium", "high") |
| `title` | string | Short title for the recommendation |
| `description` | string | Detailed description of the issue |
| `action` | string | Specific action to take |
| `impact` | string | Expected impact of the action |
| `items` | array | Specific items for restock recommendations (optional) |

---

## Error Handling

### Common Error Codes
| Code | Description | HTTP Status |
|------|-------------|-------------|
| `VALIDATION_ERROR` | Invalid request data | 400 |
| `PRODUCT_NOT_FOUND` | Product ID doesn't exist | 404 |
| `INSUFFICIENT_DATA` | Not enough data for analysis | 422 |
| `SERVER_ERROR` | Internal server error | 500 |
| `UNAUTHORIZED` | Invalid or missing authentication | 401 |
| `RATE_LIMITED` | Too many requests | 429 |

### Error Response Example
```json
{
  "success": false,
  "error": {
    "code": "PRODUCT_NOT_FOUND",
    "message": "Product with ID 'prod_999' not found",
    "details": {
      "product_id": "prod_999",
      "available_products": ["prod_123", "prod_456", "prod_789"]
    }
  },
  "timestamp": "2024-01-15T10:30:00Z"
}
```

---

## Rate Limiting

### Limits
- **Standard requests**: 100 requests per minute per user
- **AI analysis requests**: 20 requests per minute per user
- **Bulk operations**: 10 requests per minute per user

### Rate Limit Headers
```http
X-RateLimit-Limit: 100
X-RateLimit-Remaining: 95
X-RateLimit-Reset: 1642248600
```

---

## Authentication

### Token Format
```http
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiaWF0IjoxNTE2MjM5MDIyfQ.SflKxwRJSMeKKF2QT4fwpMeJf36POk6yJV_adQssw5c
```

### Token Refresh
```http
POST /api/auth/refresh
Content-Type: application/json

{
  "refresh_token": "your_refresh_token_here"
}
```

---

## Mobile Implementation Notes

### 1. Request Headers
```dart
final headers = {
  'Authorization': 'Bearer $token',
  'Content-Type': 'application/json',
  'Accept': 'application/json',
};
```

### 2. Error Handling
```dart
try {
  final response = await dio.get('/api/ai/sales-prediction/$productId');
  return SalesPrediction.fromJson(response.data);
} on DioException catch (e) {
  if (e.response?.statusCode == 401) {
    // Handle unauthorized - redirect to login
    throw UnauthorizedException();
  } else if (e.response?.statusCode == 429) {
    // Handle rate limiting
    throw RateLimitException();
  } else {
    // Handle other errors
    throw ApiException(e.message);
  }
}
```

### 3. Retry Logic
```dart
Future<T> retryRequest<T>(Future<T> Function() request) async {
  int attempts = 0;
  const maxAttempts = 3;
  
  while (attempts < maxAttempts) {
    try {
      return await request();
    } catch (e) {
      attempts++;
      if (attempts >= maxAttempts) rethrow;
      await Future.delayed(Duration(seconds: attempts * 2));
    }
  }
  throw Exception('Max retry attempts reached');
}
```

### 4. Caching Strategy
```dart
// Cache AI insights for 5 minutes
final cacheKey = 'ai_insight_${DateTime.now().millisecondsSinceEpoch ~/ 300000}';
final cachedData = await cache.get(cacheKey);
if (cachedData != null) {
  return WarungInsight.fromJson(cachedData);
}
```

---

## Testing

### Sample cURL Requests

#### Get Sales Prediction
```bash
curl -X GET "https://api.pos-umkm.com/v1/api/ai/sales-prediction/prod_123?days=7" \
  -H "Authorization: Bearer your_token_here" \
  -H "Content-Type: application/json"
```

#### Get Price Recommendation
```bash
curl -X POST "https://api.pos-umkm.com/v1/api/ai/price-recommendation" \
  -H "Authorization: Bearer your_token_here" \
  -H "Content-Type: application/json" \
  -d '{
    "product_id": "prod_123",
    "competitor_price": 18000.0,
    "target_margin": 0.3
  }'
```

#### Get Daily Insight
```bash
curl -X GET "https://api.pos-umkm.com/v1/api/ai/daily-insight" \
  -H "Authorization: Bearer your_token_here" \
  -H "Content-Type: application/json"
```

---

## Changelog

### Version 1.1.0 (2024-01-15)
- Added Product Management API endpoints
- POST /api/products - Create product
- PUT /api/products/{id} - Update product
- GET /api/products - Get products with pagination
- GET /api/products/{id} - Get product by ID
- DELETE /api/products/{id} - Delete product
- Complete product data contracts with all fields
- Support for barcode, photos, attributes, and inventory management

### Version 1.0.0 (2024-01-15)
- Initial API release
- All 10 AI endpoints implemented
- Complete data contracts defined
- Error handling and rate limiting implemented

---

## Support

Untuk pertanyaan atau bantuan teknis, silakan hubungi:
- **Email**: api-support@pos-umkm.com
- **Documentation**: https://docs.pos-umkm.com
- **Status Page**: https://status.pos-umkm.com
