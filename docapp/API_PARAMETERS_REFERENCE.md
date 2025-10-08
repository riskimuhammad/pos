# API Parameters Reference - POS UMKM

## Overview

Referensi lengkap semua parameter yang digunakan dalam API POS UMKM, termasuk tipe data, validasi, dan contoh penggunaan.

---

## Common Parameters

### Pagination Parameters
| Parameter | Type | Required | Default | Description | Example |
|-----------|------|----------|---------|-------------|---------|
| `limit` | integer | No | 10 | Maximum number of items to return | `?limit=20` |
| `offset` | integer | No | 0 | Number of items to skip | `?offset=40` |
| `page` | integer | No | 1 | Page number (alternative to offset) | `?page=3` |

### Date Range Parameters
| Parameter | Type | Required | Default | Description | Example |
|-----------|------|----------|---------|-------------|---------|
| `days` | integer | No | 30 | Number of days to look back/ahead | `?days=7` |
| `start_date` | string | No | - | Start date (ISO 8601) | `?start_date=2024-01-01` |
| `end_date` | string | No | - | End date (ISO 8601) | `?end_date=2024-01-31` |

### Filter Parameters
| Parameter | Type | Required | Default | Description | Example |
|-----------|------|----------|---------|-------------|---------|
| `category_id` | string | No | - | Filter by category ID | `?category_id=cat_001` |
| `status` | string | No | - | Filter by status | `?status=active` |
| `sort_by` | string | No | - | Sort field | `?sort_by=revenue` |
| `sort_order` | string | No | `desc` | Sort order (asc/desc) | `?sort_order=asc` |

---

## Sales Prediction API Parameters

### GET /api/ai/sales-prediction/{productId}

#### Path Parameters
| Parameter | Type | Required | Validation | Description |
|-----------|------|----------|------------|-------------|
| `productId` | string | Yes | UUID format | Product identifier |

#### Query Parameters
| Parameter | Type | Required | Default | Validation | Description |
|-----------|------|----------|---------|------------|-------------|
| `days` | integer | No | 7 | 1-365 | Days ahead to predict |

#### Example Request
```http
GET /api/ai/sales-prediction/550e8400-e29b-41d4-a716-446655440000?days=14
```

#### Response Parameters
| Field | Type | Description | Example |
|-------|------|-------------|---------|
| `product_id` | string | Product identifier | `"550e8400-e29b-41d4-a716-446655440000"` |
| `predicted_quantity` | integer | Predicted sales quantity | `45` |
| `confidence` | float | Confidence score (0.0-1.0) | `0.85` |
| `trend` | string | Trend direction | `"increasing"` |
| `recommendations` | array | Action recommendations | `["Increase stock", "Monitor pricing"]` |
| `daily_average` | float | Average daily sales | `6.4` |
| `trend_percentage` | integer | Trend percentage | `15` |

---

## Top Products API Parameters

### GET /api/ai/top-products

#### Query Parameters
| Parameter | Type | Required | Default | Validation | Description |
|-----------|------|----------|---------|------------|-------------|
| `limit` | integer | No | 10 | 1-100 | Maximum products to return |
| `days` | integer | No | 30 | 1-365 | Days to look back |
| `category_id` | string | No | - | UUID format | Filter by category |
| `sort_by` | string | No | `quantity` | `quantity`, `revenue`, `margin` | Sort criteria |

#### Example Request
```http
GET /api/ai/top-products?limit=20&days=7&category_id=cat_001&sort_by=revenue
```

#### Response Parameters
| Field | Type | Description | Example |
|-------|------|-------------|---------|
| `product_id` | string | Product identifier | `"550e8400-e29b-41d4-a716-446655440000"` |
| `product_name` | string | Product display name | `"Nasi Goreng Spesial"` |
| `category_name` | string | Category name | `"Makanan Utama"` |
| `total_quantity` | integer | Total quantity sold | `150` |
| `total_revenue` | float | Total revenue | `2250000.0` |
| `avg_price` | float | Average selling price | `15000.0` |
| `transaction_count` | integer | Number of transactions | `45` |

---

## Top Categories API Parameters

### GET /api/ai/top-categories

#### Query Parameters
| Parameter | Type | Required | Default | Validation | Description |
|-----------|------|----------|---------|------------|-------------|
| `limit` | integer | No | 5 | 1-50 | Maximum categories to return |
| `days` | integer | No | 30 | 1-365 | Days to look back |
| `sort_by` | string | No | `revenue` | `revenue`, `quantity`, `margin` | Sort criteria |

#### Example Request
```http
GET /api/ai/top-categories?limit=10&days=14&sort_by=quantity
```

#### Response Parameters
| Field | Type | Description | Example |
|-------|------|-------------|---------|
| `category_id` | string | Category identifier | `"cat_001"` |
| `category_name` | string | Category display name | `"Makanan Utama"` |
| `total_quantity` | integer | Total quantity sold | `500` |
| `total_revenue` | float | Total revenue | `7500000.0` |
| `product_count` | integer | Number of products | `25` |

---

## Price Recommendation API Parameters

### POST /api/ai/price-recommendation

#### Request Body Parameters
| Parameter | Type | Required | Validation | Description |
|-----------|------|----------|------------|-------------|
| `product_id` | string | Yes | UUID format | Product identifier |
| `competitor_price` | float | No | > 0 | Competitor price for analysis |
| `target_margin` | float | No | 0.0-1.0 | Target profit margin |
| `strategy` | string | No | `auto` | Pricing strategy preference |

#### Example Request
```json
{
  "product_id": "550e8400-e29b-41d4-a716-446655440000",
  "competitor_price": 18000.0,
  "target_margin": 0.3,
  "strategy": "margin_based"
}
```

#### Response Parameters
| Field | Type | Description | Example |
|-------|------|-------------|---------|
| `product_id` | string | Product identifier | `"550e8400-e29b-41d4-a716-446655440000"` |
| `current_price` | float | Current selling price | `15000.0` |
| `recommended_price` | float | AI-recommended price | `17500.0` |
| `current_margin` | float | Current profit margin | `0.25` |
| `target_margin` | float | Target profit margin | `0.3` |
| `price_change` | float | Absolute price change | `2500.0` |
| `price_change_percent` | float | Percentage change | `16.67` |
| `strategies` | array | All considered strategies | See below |
| `best_strategy` | object | Recommended strategy | See below |
| `impact` | object | Predicted impact | See below |

#### Strategy Object Parameters
| Field | Type | Description | Example |
|-------|------|-------------|---------|
| `type` | string | Strategy type | `"marginBased"` |
| `price` | float | Suggested price | `17500.0` |
| `confidence` | float | Confidence score | `0.9` |
| `reasoning` | string | Explanation | `"Based on target margin of 30%"` |

#### Impact Object Parameters
| Field | Type | Description | Example |
|-------|------|-------------|---------|
| `sales_impact` | float | Predicted sales change | `-0.1` |
| `revenue_impact` | float | Predicted revenue change | `0.15` |
| `margin_impact` | float | Predicted margin change | `0.05` |

---

## Price Review Items API Parameters

### GET /api/ai/price-review-items

#### Query Parameters
| Parameter | Type | Required | Default | Validation | Description |
|-----------|------|----------|---------|------------|-------------|
| `limit` | integer | No | 50 | 1-100 | Maximum items to return |
| `min_margin` | float | No | 0.0 | 0.0-1.0 | Minimum margin threshold |
| `max_margin` | float | No | 1.0 | 0.0-1.0 | Maximum margin threshold |
| `days_since_update` | integer | No | - | 1-365 | Days since last price update |

#### Example Request
```http
GET /api/ai/price-review-items?limit=20&min_margin=0.1&max_margin=0.3&days_since_update=30
```

#### Response Parameters
| Field | Type | Description | Example |
|-------|------|-------------|---------|
| `product_id` | string | Product identifier | `"550e8400-e29b-41d4-a716-446655440000"` |
| `product_name` | string | Product display name | `"Nasi Goreng Spesial"` |
| `current_price` | float | Current selling price | `15000.0` |
| `cost_price` | float | Cost price | `10000.0` |
| `margin_percent` | float | Current margin percentage | `33.33` |
| `total_sales` | integer | Total sales in period | `45` |
| `last_sale_date` | string | ISO 8601 date | `"2024-01-14T10:30:00Z"` |
| `issues` | array | Identified issues | `["Low margin", "Old price"]` |
| `regional_avg_price` | float | Regional average | `16500.0` |
| `suggested_price` | float | AI-suggested price | `17500.0` |
| `price_delta` | float | Price change amount | `2500.0` |
| `predicted_margin_impact` | float | Predicted improvement | `0.05` |

---

## Product Recommendations API Parameters

### GET /api/ai/product-recommendations

#### Query Parameters
| Parameter | Type | Required | Default | Validation | Description |
|-----------|------|----------|---------|------------|-------------|
| `limit` | integer | No | 10 | 1-50 | Maximum recommendations |
| `category_id` | string | No | - | UUID format | Filter by category |
| `min_margin` | float | No | 0.2 | 0.0-1.0 | Minimum margin requirement |
| `min_sales` | integer | No | 10 | 1-1000 | Minimum sales requirement |

#### Example Request
```http
GET /api/ai/product-recommendations?limit=15&category_id=cat_001&min_margin=0.3&min_sales=50
```

#### Response Parameters
| Field | Type | Description | Example |
|-------|------|-------------|---------|
| `category_id` | string | Category identifier | `"cat_001"` |
| `category_name` | string | Category display name | `"Makanan Utama"` |
| `avg_margin` | float | Average margin | `0.35` |
| `total_sales` | integer | Total sales | `500` |
| `suggestions` | array | Product suggestions | `["Add breakfast items", "Seasonal menu"]` |
| `reasoning` | string | Recommendation reasoning | `"High margin category"` |

---

## Daily Insight API Parameters

### GET /api/ai/daily-insight

#### Query Parameters
| Parameter | Type | Required | Default | Validation | Description |
|-----------|------|----------|---------|------------|-------------|
| `date` | string | No | Today | ISO 8601 date | Specific date for insight |
| `include_forecast` | boolean | No | false | true/false | Include forecast data |

#### Example Request
```http
GET /api/ai/daily-insight?date=2024-01-15&include_forecast=true
```

#### Response Parameters
| Field | Type | Description | Example |
|-------|------|-------------|---------|
| `date` | string | ISO 8601 date | `"2024-01-15T00:00:00Z"` |
| `today_sales` | object | Today's sales data | See below |
| `top_products` | array | Top products today | See below |
| `low_stock_items` | array | Low stock items | See below |
| `weekly_trend` | string | Weekly trend | `"increasing"` |
| `recommendations` | array | Action recommendations | See below |

#### Today Sales Object Parameters
| Field | Type | Description | Example |
|-------|------|-------------|---------|
| `transaction_count` | integer | Number of transactions | `25` |
| `total_revenue` | float | Total revenue | `1250000.0` |
| `avg_transaction_value` | float | Average transaction value | `50000.0` |

#### Top Product Object Parameters
| Field | Type | Description | Example |
|-------|------|-------------|---------|
| `product_id` | string | Product identifier | `"550e8400-e29b-41d4-a716-446655440000"` |
| `product_name` | string | Product name | `"Nasi Goreng Spesial"` |
| `quantity_sold` | integer | Quantity sold | `15` |
| `revenue` | float | Revenue generated | `225000.0` |

#### Low Stock Item Object Parameters
| Field | Type | Description | Example |
|-------|------|-------------|---------|
| `product_id` | string | Product identifier | `"550e8400-e29b-41d4-a716-446655440000"` |
| `product_name` | string | Product name | `"Es Teh Manis"` |
| `current_stock` | integer | Current stock level | `5` |
| `min_stock` | integer | Minimum stock level | `10` |
| `deficit` | integer | Stock deficit | `5` |
| `days_coverage` | integer | Days of coverage | `2` |
| `suggested_restock_qty` | integer | Suggested restock quantity | `50` |

---

## Business Performance API Parameters

### GET /api/ai/business-performance

#### Query Parameters
| Parameter | Type | Required | Default | Validation | Description |
|-----------|------|----------|---------|------------|-------------|
| `days` | integer | No | 30 | 1-365 | Days to analyze |
| `start_date` | string | No | - | ISO 8601 date | Start date (overrides days) |
| `end_date` | string | No | - | ISO 8601 date | End date (overrides days) |
| `include_categories` | boolean | No | true | true/false | Include category breakdown |
| `include_margins` | boolean | No | true | true/false | Include margin analysis |

#### Example Request
```http
GET /api/ai/business-performance?days=14&include_categories=true&include_margins=true
```

#### Response Parameters
| Field | Type | Description | Example |
|-------|------|-------------|---------|
| `period` | object | Analysis period | See below |
| `revenue_trend` | object | Revenue analysis | See below |
| `transaction_metrics` | object | Transaction stats | See below |
| `category_performance` | array | Category breakdown | See below |
| `margin_analysis` | object | Margin statistics | See below |

#### Period Object Parameters
| Field | Type | Description | Example |
|-------|------|-------------|---------|
| `start_date` | string | ISO 8601 start date | `"2023-12-16T00:00:00Z"` |
| `end_date` | string | ISO 8601 end date | `"2024-01-15T00:00:00Z"` |
| `days` | integer | Number of days | `30` |

#### Revenue Trend Object Parameters
| Field | Type | Description | Example |
|-------|------|-------------|---------|
| `total_revenue` | float | Total revenue | `45000000.0` |
| `avg_daily_revenue` | float | Average daily revenue | `1500000.0` |
| `growth_rate` | float | Growth rate | `0.12` |
| `trend` | string | Trend direction | `"increasing"` |

---

## Business Forecast API Parameters

### GET /api/ai/business-forecast

#### Query Parameters
| Parameter | Type | Required | Default | Validation | Description |
|-----------|------|----------|---------|------------|-------------|
| `days` | integer | No | 30 | 1-365 | Days to forecast |
| `confidence_level` | float | No | 0.8 | 0.5-0.99 | Confidence level |
| `include_scenarios` | boolean | No | false | true/false | Include best/worst case |

#### Example Request
```http
GET /api/ai/business-forecast?days=14&confidence_level=0.9&include_scenarios=true
```

#### Response Parameters
| Field | Type | Description | Example |
|-------|------|-------------|---------|
| `predicted_revenue` | float | Predicted total revenue | `45000000.0` |
| `confidence` | float | Confidence score | `0.78` |
| `trend` | float | Trend factor | `0.12` |
| `avg_daily_revenue` | float | Average daily prediction | `1500000.0` |
| `recommendations` | array | Strategic recommendations | `["Expand menu", "Monitor trends"]` |

---

## Business Recommendations API Parameters

### GET /api/ai/business-recommendations

#### Query Parameters
| Parameter | Type | Required | Default | Validation | Description |
|-----------|------|----------|---------|------------|-------------|
| `top_n` | integer | No | 3 | 1-10 | Number of top items to consider |
| `restock_policy` | string | No | `percent_of_sales` | `percent_of_sales`, `fixed_amount` | Restock calculation method |
| `percent` | float | No | 0.2 | 0.1-1.0 | Percentage for restock calculation |
| `priority_filter` | string | No | - | `low`, `medium`, `high` | Filter by priority |
| `type_filter` | string | No | - | `pricing`, `inventory`, `product` | Filter by type |

#### Example Request
```http
GET /api/ai/business-recommendations?top_n=5&restock_policy=percent_of_sales&percent=0.3&priority_filter=high
```

#### Response Parameters
| Field | Type | Description | Example |
|-------|------|-------------|---------|
| `type` | string | Recommendation type | `"pricing"` |
| `priority` | string | Priority level | `"high"` |
| `title` | string | Recommendation title | `"Optimize Menu Pricing"` |
| `description` | string | Detailed description | `"Several items have low margins"` |
| `action` | string | Specific action | `"Review and adjust pricing"` |
| `impact` | string | Expected impact | `"15% increase in profit margin"` |
| `items` | array | Specific items (for restock) | See below |

#### Restock Item Object Parameters
| Field | Type | Description | Example |
|-------|------|-------------|---------|
| `product_id` | string | Product identifier | `"550e8400-e29b-41d4-a716-446655440000"` |
| `product_name` | string | Product name | `"Nasi Goreng Spesial"` |
| `current_stock` | integer | Current stock level | `15` |
| `suggested_qty` | integer | Suggested restock quantity | `50` |
| `reason` | string | Restock reason | `"High demand, low stock"` |

---

## Data Validation Rules

### String Parameters
- **UUID Format**: Must match pattern `^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$`
- **Date Format**: Must be ISO 8601 format `YYYY-MM-DDTHH:mm:ssZ`
- **Enum Values**: Must match predefined values exactly (case-sensitive)

### Numeric Parameters
- **Integer**: Must be whole numbers within specified ranges
- **Float**: Must be decimal numbers within specified ranges
- **Percentage**: Must be between 0.0 and 1.0 (0% to 100%)
- **Currency**: Must be positive numbers with up to 2 decimal places

### Array Parameters
- **Limit**: Maximum number of items in array
- **Unique**: Array items must be unique (where applicable)
- **Format**: Each item must match specified object structure

---

## Error Response Parameters

### Error Object Structure
| Field | Type | Description | Example |
|-------|------|-------------|---------|
| `code` | string | Error code | `"VALIDATION_ERROR"` |
| `message` | string | Human-readable message | `"Invalid product ID"` |
| `details` | object | Additional error details | `{"field": "product_id", "value": "invalid"}` |
| `timestamp` | string | Error timestamp | `"2024-01-15T10:30:00Z"` |

### Validation Error Details
| Field | Type | Description | Example |
|-------|------|-------------|---------|
| `field` | string | Field name with error | `"product_id"` |
| `value` | string | Invalid value provided | `"invalid-id"` |
| `expected` | string | Expected format/type | `"UUID format"` |
| `constraints` | object | Validation constraints | `{"min": 1, "max": 365}` |

---

## Rate Limiting Parameters

### Rate Limit Headers
| Header | Type | Description | Example |
|--------|------|-------------|---------|
| `X-RateLimit-Limit` | integer | Requests allowed per window | `100` |
| `X-RateLimit-Remaining` | integer | Requests remaining in window | `95` |
| `X-RateLimit-Reset` | integer | Unix timestamp of reset | `1642248600` |
| `X-RateLimit-Window` | integer | Window size in seconds | `60` |

### Rate Limit Response
```json
{
  "success": false,
  "error": {
    "code": "RATE_LIMITED",
    "message": "Too many requests. Please try again later.",
    "details": {
      "limit": 100,
      "remaining": 0,
      "reset_time": "2024-01-15T10:31:00Z"
    }
  },
  "timestamp": "2024-01-15T10:30:00Z"
}
```

---

## Authentication Parameters

### Token Request
| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `username` | string | Yes | User login name |
| `password` | string | Yes | User password |
| `grant_type` | string | Yes | Must be "password" |

### Token Response
| Field | Type | Description | Example |
|-------|------|-------------|---------|
| `access_token` | string | JWT access token | `"eyJhbGciOiJIUzI1NiIs..."` |
| `refresh_token` | string | Refresh token | `"eyJhbGciOiJIUzI1NiIs..."` |
| `token_type` | string | Token type | `"Bearer"` |
| `expires_in` | integer | Token expiry in seconds | `3600` |

### Refresh Token Request
| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `refresh_token` | string | Yes | Valid refresh token |
| `grant_type` | string | Yes | Must be "refresh_token" |

---

## Mobile Implementation Examples

### Dart/Flutter Parameter Usage
```dart
// Sales prediction with parameters
final response = await dio.get(
  '/api/ai/sales-prediction/$productId',
  queryParameters: {
    'days': 14,
  },
);

// Price recommendation with body parameters
final response = await dio.post(
  '/api/ai/price-recommendation',
  data: {
    'product_id': productId,
    'competitor_price': 18000.0,
    'target_margin': 0.3,
  },
);

// Top products with multiple parameters
final response = await dio.get(
  '/api/ai/top-products',
  queryParameters: {
    'limit': 20,
    'days': 7,
    'category_id': categoryId,
    'sort_by': 'revenue',
  },
);
```

### Parameter Validation
```dart
class ApiParameterValidator {
  static bool isValidUUID(String value) {
    return RegExp(r'^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$')
        .hasMatch(value);
  }
  
  static bool isValidDate(String value) {
    try {
      DateTime.parse(value);
      return true;
    } catch (e) {
      return false;
    }
  }
  
  static bool isValidPercentage(double value) {
    return value >= 0.0 && value <= 1.0;
  }
}
```

---

## Testing Parameters

### Test Data Examples
```json
{
  "valid_product_id": "550e8400-e29b-41d4-a716-446655440000",
  "valid_category_id": "cat_001",
  "valid_date": "2024-01-15T10:30:00Z",
  "valid_percentage": 0.3,
  "valid_price": 15000.0,
  "invalid_product_id": "invalid-id",
  "invalid_date": "2024-13-45",
  "invalid_percentage": 1.5
}
```

### Parameter Test Cases
| Test Case | Parameter | Value | Expected Result |
|-----------|-----------|-------|-----------------|
| Valid UUID | product_id | `550e8400-e29b-41d4-a716-446655440000` | Success |
| Invalid UUID | product_id | `invalid-id` | 400 Bad Request |
| Valid days | days | `7` | Success |
| Invalid days | days | `400` | 400 Bad Request |
| Valid percentage | target_margin | `0.3` | Success |
| Invalid percentage | target_margin | `1.5` | 400 Bad Request |
| Valid date | start_date | `2024-01-01` | Success |
| Invalid date | start_date | `2024-13-45` | 400 Bad Request |

---

## Changelog

### Version 1.0.0 (2024-01-15)
- Initial parameter reference
- All API parameters documented
- Validation rules defined
- Test cases provided
