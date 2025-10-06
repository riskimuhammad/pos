# API Data Contracts - Mobile Integration

## Overview

This document defines the JSON data contracts for all AI Assistant API endpoints that the mobile app expects to receive from the backend server. These contracts ensure consistent data exchange between the mobile app and the API.

## Base Configuration

### API Base URL
```
https://api.pos-umkm.com/v1
```

### Authentication
All API requests require Bearer token authentication:
```
Authorization: Bearer <access_token>
```

### Response Format
All API responses follow this standard format:
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

## 1. Sales Prediction API

### Endpoint
```
GET /api/ai/sales-prediction/{productId}?days={daysAhead}
```

### Request Parameters
- `productId` (path): Product ID string
- `days` (query): Number of days to predict ahead (default: 7)

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
- `product_id`: Unique product identifier
- `predicted_quantity`: Predicted sales quantity for the period
- `confidence`: Confidence score (0.0 to 1.0)
- `trend`: Sales trend ("increasing", "decreasing", "stable")
- `recommendations`: Array of actionable recommendations
- `daily_average`: Average daily sales quantity
- `trend_percentage`: Percentage change in trend

---

## 2. Top Products API

### Endpoint
```
GET /api/ai/top-products?limit={limit}&days={daysBack}
```

### Request Parameters
- `limit` (query): Maximum number of products to return (default: 10)
- `days` (query): Number of days to look back (default: 30)

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
- `product_id`: Unique product identifier
- `product_name`: Display name of the product
- `category_name`: Category the product belongs to
- `total_quantity`: Total quantity sold in the period
- `total_revenue`: Total revenue generated
- `avg_price`: Average selling price
- `transaction_count`: Number of transactions

---

## 3. Top Categories API

### Endpoint
```
GET /api/ai/top-categories?limit={limit}&days={daysBack}
```

### Request Parameters
- `limit` (query): Maximum number of categories to return (default: 5)
- `days` (query): Number of days to look back (default: 30)

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
- `category_id`: Unique category identifier
- `category_name`: Display name of the category
- `total_quantity`: Total quantity sold in the period
- `total_revenue`: Total revenue generated
- `product_count`: Number of products in this category

---

## 4. Price Recommendation API

### Endpoint
```
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
- `product_id`: Unique product identifier
- `current_price`: Current selling price
- `recommended_price`: AI-recommended price
- `current_margin`: Current profit margin
- `target_margin`: Target profit margin
- `price_change`: Absolute price change amount
- `price_change_percent`: Percentage price change
- `strategies`: Array of pricing strategies considered
- `best_strategy`: The recommended strategy
- `impact`: Predicted impact of price change

---

## 5. Product Recommendations API

### Endpoint
```
GET /api/ai/product-recommendations?limit={limit}
```

### Request Parameters
- `limit` (query): Maximum number of recommendations (default: 10)

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
- `category_id`: Category identifier (nullable)
- `category_name`: Display name of the category
- `avg_margin`: Average profit margin for the category
- `total_sales`: Total sales quantity
- `suggestions`: Array of product suggestions
- `reasoning`: Explanation for the recommendation

---

## 6. Price Review Items API

### Endpoint
```
GET /api/ai/price-review-items
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
    "last_sale_date": "2024-01-14T15:30:00Z",
    "issues": [
      "Low margin compared to similar products",
      "No sales in the last 3 days"
    ]
  }
]
```

### Field Descriptions
- `product_id`: Unique product identifier
- `product_name`: Display name of the product
- `current_price`: Current selling price
- `cost_price`: Cost price of the product
- `margin_percent`: Current profit margin percentage
- `total_sales`: Total sales in recent period
- `last_sale_date`: ISO 8601 timestamp of last sale
- `issues`: Array of identified pricing issues

---

## 7. Daily Insight API

### Endpoint
```
GET /api/ai/daily-insight
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
      "min_stock": 10
    }
  ],
  "weekly_trend": "increasing",
  "recommendations": [
    {
      "type": "inventory",
      "title": "Restock Es Teh Manis",
      "description": "Current stock is below minimum threshold",
      "priority": "high"
    }
  ]
}
```

### Field Descriptions
- `date`: Date of the insight (ISO 8601)
- `today_sales`: Today's sales summary
- `top_products`: Best-selling products today
- `low_stock_items`: Products with low stock
- `weekly_trend`: Weekly sales trend ("increasing", "decreasing", "stable")
- `recommendations`: Actionable recommendations

---

## 8. Business Performance API

### Endpoint
```
GET /api/ai/business-performance?days={daysBack}
```

### Request Parameters
- `days` (query): Number of days to analyze (default: 30)

### Response Data Contract
```json
{
  "revenue_trend": [
    {
      "date": "2024-01-01T00:00:00Z",
      "revenue": 1000000.0,
      "transaction_count": 20
    },
    {
      "date": "2024-01-02T00:00:00Z",
      "revenue": 1200000.0,
      "transaction_count": 24
    }
  ],
  "category_performance": [
    {
      "category_id": "cat_001",
      "category_name": "Makanan Utama",
      "revenue": 7500000.0,
      "quantity_sold": 500,
      "product_count": 25
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
- `revenue_trend`: Daily revenue and transaction data
- `category_performance`: Performance by category
- `margin_analysis`: Overall margin statistics

---

## 9. Business Forecast API

### Endpoint
```
GET /api/ai/business-forecast?days={daysAhead}
```

### Request Parameters
- `days` (query): Number of days to forecast (default: 30)

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
- `predicted_revenue`: Total predicted revenue for the period
- `confidence`: Confidence score (0.0 to 1.0)
- `trend`: Trend factor (positive = growth, negative = decline)
- `avg_daily_revenue`: Average daily revenue prediction
- `recommendations`: Strategic recommendations

---

## 10. Business Recommendations API

### Endpoint
```
GET /api/ai/business-recommendations
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
  }
]
```

### Field Descriptions
- `type`: Recommendation type ("pricing", "inventory", "product", "category", "marketing")
- `priority`: Priority level ("low", "medium", "high")
- `title`: Short title for the recommendation
- `description`: Detailed description of the issue
- `action`: Specific action to take
- `impact`: Expected impact of the action

---

## Data Types and Validation

### Common Data Types
- **String**: UTF-8 encoded text
- **Number**: Decimal numbers (prices, percentages, quantities)
- **Integer**: Whole numbers (counts, IDs)
- **Boolean**: true/false values
- **Date/Time**: ISO 8601 format (e.g., "2024-01-15T10:30:00Z")
- **Array**: JSON arrays of objects
- **Object**: Nested JSON objects

### Validation Rules
- All required fields must be present
- Numeric values must be valid numbers (not NaN or Infinity)
- Dates must be valid ISO 8601 format
- Enums must match predefined values exactly
- Arrays should not be null (use empty array instead)

### Error Codes
- `VALIDATION_ERROR`: Invalid request data
- `PRODUCT_NOT_FOUND`: Product ID doesn't exist
- `INSUFFICIENT_DATA`: Not enough data for analysis
- `SERVER_ERROR`: Internal server error
- `UNAUTHORIZED`: Invalid or missing authentication
- `RATE_LIMITED`: Too many requests

---

## Testing and Examples

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

## Implementation Notes

### Mobile App Integration
1. The mobile app uses these exact field names for JSON parsing
2. All enum values are case-sensitive and must match exactly
3. Date fields are parsed using ISO 8601 format
4. Nullable fields are handled gracefully with null checks
5. Arrays are always initialized (never null)

### Backend Requirements
1. All endpoints must return data in the exact format specified
2. Error responses must follow the standard error format
3. Authentication is required for all endpoints
4. Rate limiting should be implemented
5. CORS headers must be configured for mobile app access

### Versioning
- Current API version: v1
- Future versions will maintain backward compatibility
- Breaking changes will be communicated in advance
- Deprecated endpoints will have a sunset period

---

## Support and Contact

For questions about these API contracts:
- Technical Support: tech@pos-umkm.com
- API Documentation: https://docs.pos-umkm.com
- Status Page: https://status.pos-umkm.com

Last Updated: January 15, 2024
Version: 1.0.0
