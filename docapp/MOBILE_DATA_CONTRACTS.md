# Mobile Data Contracts - POS UMKM

## Overview

Dokumentasi lengkap data contracts yang akan diterima oleh aplikasi mobile POS UMKM dari backend API. Setiap contract mencakup struktur data, tipe field, validasi, dan contoh implementasi.

---

## Base Response Structure

### Standard Success Response
```json
{
  "success": true,
  "data": { ... },
  "message": "Success",
  "timestamp": "2024-01-15T10:30:00Z"
}
```

### Standard Error Response
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

## 1. Sales Prediction Data Contract

### Response Structure
```json
{
  "product_id": "string",
  "predicted_quantity": "integer",
  "confidence": "float",
  "trend": "string",
  "recommendations": ["string"],
  "daily_average": "float",
  "trend_percentage": "integer"
}
```

### Field Specifications
| Field | Type | Required | Validation | Description |
|-------|------|----------|------------|-------------|
| `product_id` | string | Yes | UUID format | Unique product identifier |
| `predicted_quantity` | integer | Yes | ≥ 0 | Predicted sales quantity |
| `confidence` | float | Yes | 0.0-1.0 | Confidence score |
| `trend` | string | Yes | Enum | "increasing", "decreasing", "stable" |
| `recommendations` | array | Yes | Non-empty | Actionable recommendations |
| `daily_average` | float | Yes | ≥ 0 | Average daily sales |
| `trend_percentage` | integer | Yes | -100 to 100 | Trend percentage change |

### Example Response
```json
{
  "product_id": "550e8400-e29b-41d4-a716-446655440000",
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

### Mobile Implementation
```dart
class SalesPrediction {
  final String productId;
  final int predictedQuantity;
  final double confidence;
  final String trend;
  final List<String> recommendations;
  final double dailyAverage;
  final int trendPercentage;

  SalesPrediction({
    required this.productId,
    required this.predictedQuantity,
    required this.confidence,
    required this.trend,
    required this.recommendations,
    required this.dailyAverage,
    required this.trendPercentage,
  });

  factory SalesPrediction.fromJson(Map<String, dynamic> json) {
    return SalesPrediction(
      productId: json['product_id'] as String,
      predictedQuantity: json['predicted_quantity'] as int,
      confidence: (json['confidence'] as num).toDouble(),
      trend: json['trend'] as String,
      recommendations: List<String>.from(json['recommendations']),
      dailyAverage: (json['daily_average'] as num).toDouble(),
      trendPercentage: json['trend_percentage'] as int,
    );
  }
}
```

---

## 2. Top Products Data Contract

### Response Structure
```json
[
  {
    "product_id": "string",
    "product_name": "string",
    "category_name": "string",
    "total_quantity": "integer",
    "total_revenue": "float",
    "avg_price": "float",
    "transaction_count": "integer"
  }
]
```

### Field Specifications
| Field | Type | Required | Validation | Description |
|-------|------|----------|------------|-------------|
| `product_id` | string | Yes | UUID format | Unique product identifier |
| `product_name` | string | Yes | Non-empty | Product display name |
| `category_name` | string | Yes | Non-empty | Category name |
| `total_quantity` | integer | Yes | ≥ 0 | Total quantity sold |
| `total_revenue` | float | Yes | ≥ 0 | Total revenue generated |
| `avg_price` | float | Yes | ≥ 0 | Average selling price |
| `transaction_count` | integer | Yes | ≥ 0 | Number of transactions |

### Example Response
```json
[
  {
    "product_id": "550e8400-e29b-41d4-a716-446655440000",
    "product_name": "Nasi Goreng Spesial",
    "category_name": "Makanan Utama",
    "total_quantity": 150,
    "total_revenue": 2250000.0,
    "avg_price": 15000.0,
    "transaction_count": 45
  },
  {
    "product_id": "550e8400-e29b-41d4-a716-446655440001",
    "product_name": "Es Teh Manis",
    "category_name": "Minuman",
    "total_quantity": 200,
    "total_revenue": 800000.0,
    "avg_price": 4000.0,
    "transaction_count": 50
  }
]
```

### Mobile Implementation
```dart
class TopProduct {
  final String productId;
  final String productName;
  final String categoryName;
  final int totalQuantity;
  final double totalRevenue;
  final double avgPrice;
  final int transactionCount;

  TopProduct({
    required this.productId,
    required this.productName,
    required this.categoryName,
    required this.totalQuantity,
    required this.totalRevenue,
    required this.avgPrice,
    required this.transactionCount,
  });

  factory TopProduct.fromJson(Map<String, dynamic> json) {
    return TopProduct(
      productId: json['product_id'] as String,
      productName: json['product_name'] as String,
      categoryName: json['category_name'] as String,
      totalQuantity: json['total_quantity'] as int,
      totalRevenue: (json['total_revenue'] as num).toDouble(),
      avgPrice: (json['avg_price'] as num).toDouble(),
      transactionCount: json['transaction_count'] as int,
    );
  }
}
```

---

## 3. Top Categories Data Contract

### Response Structure
```json
[
  {
    "category_id": "string",
    "category_name": "string",
    "total_quantity": "integer",
    "total_revenue": "float",
    "product_count": "integer"
  }
]
```

### Field Specifications
| Field | Type | Required | Validation | Description |
|-------|------|----------|------------|-------------|
| `category_id` | string | Yes | UUID format | Unique category identifier |
| `category_name` | string | Yes | Non-empty | Category display name |
| `total_quantity` | integer | Yes | ≥ 0 | Total quantity sold |
| `total_revenue` | float | Yes | ≥ 0 | Total revenue generated |
| `product_count` | integer | Yes | ≥ 0 | Number of products |

### Example Response
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

### Mobile Implementation
```dart
class TopCategory {
  final String categoryId;
  final String categoryName;
  final int totalQuantity;
  final double totalRevenue;
  final int productCount;

  TopCategory({
    required this.categoryId,
    required this.categoryName,
    required this.totalQuantity,
    required this.totalRevenue,
    required this.productCount,
  });

  factory TopCategory.fromJson(Map<String, dynamic> json) {
    return TopCategory(
      categoryId: json['category_id'] as String,
      categoryName: json['category_name'] as String,
      totalQuantity: json['total_quantity'] as int,
      totalRevenue: (json['total_revenue'] as num).toDouble(),
      productCount: json['product_count'] as int,
    );
  }
}
```

---

## 4. Price Recommendation Data Contract

### Response Structure
```json
{
  "product_id": "string",
  "current_price": "float",
  "recommended_price": "float",
  "current_margin": "float",
  "target_margin": "float",
  "price_change": "float",
  "price_change_percent": "float",
  "strategies": [
    {
      "type": "string",
      "price": "float",
      "confidence": "float",
      "reasoning": "string"
    }
  ],
  "best_strategy": {
    "type": "string",
    "price": "float",
    "confidence": "float",
    "reasoning": "string"
  },
  "impact": {
    "sales_impact": "float",
    "revenue_impact": "float",
    "margin_impact": "float"
  }
}
```

### Field Specifications
| Field | Type | Required | Validation | Description |
|-------|------|----------|------------|-------------|
| `product_id` | string | Yes | UUID format | Unique product identifier |
| `current_price` | float | Yes | ≥ 0 | Current selling price |
| `recommended_price` | float | Yes | ≥ 0 | AI-recommended price |
| `current_margin` | float | Yes | 0.0-1.0 | Current profit margin |
| `target_margin` | float | Yes | 0.0-1.0 | Target profit margin |
| `price_change` | float | Yes | Any | Absolute price change |
| `price_change_percent` | float | Yes | Any | Percentage price change |
| `strategies` | array | Yes | Non-empty | All considered strategies |
| `best_strategy` | object | Yes | - | Recommended strategy |
| `impact` | object | Yes | - | Predicted impact |

### Strategy Object Specifications
| Field | Type | Required | Validation | Description |
|-------|------|----------|------------|-------------|
| `type` | string | Yes | Enum | "marginBased", "competitive", "demandBased", "psychological" |
| `price` | float | Yes | ≥ 0 | Suggested price |
| `confidence` | float | Yes | 0.0-1.0 | Confidence score |
| `reasoning` | string | Yes | Non-empty | Explanation |

### Impact Object Specifications
| Field | Type | Required | Validation | Description |
|-------|------|----------|------------|-------------|
| `sales_impact` | float | Yes | -1.0 to 1.0 | Predicted sales change |
| `revenue_impact` | float | Yes | -1.0 to 1.0 | Predicted revenue change |
| `margin_impact` | float | Yes | -1.0 to 1.0 | Predicted margin change |

### Example Response
```json
{
  "product_id": "550e8400-e29b-41d4-a716-446655440000",
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
      "type": "competitive",
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

### Mobile Implementation
```dart
class PriceRecommendation {
  final String productId;
  final double currentPrice;
  final double recommendedPrice;
  final double currentMargin;
  final double targetMargin;
  final double priceChange;
  final double priceChangePercent;
  final List<PriceStrategy> strategies;
  final PriceStrategy bestStrategy;
  final PriceImpact impact;

  PriceRecommendation({
    required this.productId,
    required this.currentPrice,
    required this.recommendedPrice,
    required this.currentMargin,
    required this.targetMargin,
    required this.priceChange,
    required this.priceChangePercent,
    required this.strategies,
    required this.bestStrategy,
    required this.impact,
  });

  factory PriceRecommendation.fromJson(Map<String, dynamic> json) {
    return PriceRecommendation(
      productId: json['product_id'] as String,
      currentPrice: (json['current_price'] as num).toDouble(),
      recommendedPrice: (json['recommended_price'] as num).toDouble(),
      currentMargin: (json['current_margin'] as num).toDouble(),
      targetMargin: (json['target_margin'] as num).toDouble(),
      priceChange: (json['price_change'] as num).toDouble(),
      priceChangePercent: (json['price_change_percent'] as num).toDouble(),
      strategies: (json['strategies'] as List)
          .map((s) => PriceStrategy.fromJson(s))
          .toList(),
      bestStrategy: PriceStrategy.fromJson(json['best_strategy']),
      impact: PriceImpact.fromJson(json['impact']),
    );
  }
}

class PriceStrategy {
  final String type;
  final double price;
  final double confidence;
  final String reasoning;

  PriceStrategy({
    required this.type,
    required this.price,
    required this.confidence,
    required this.reasoning,
  });

  factory PriceStrategy.fromJson(Map<String, dynamic> json) {
    return PriceStrategy(
      type: json['type'] as String,
      price: (json['price'] as num).toDouble(),
      confidence: (json['confidence'] as num).toDouble(),
      reasoning: json['reasoning'] as String,
    );
  }
}

class PriceImpact {
  final double salesImpact;
  final double revenueImpact;
  final double marginImpact;

  PriceImpact({
    required this.salesImpact,
    required this.revenueImpact,
    required this.marginImpact,
  });

  factory PriceImpact.fromJson(Map<String, dynamic> json) {
    return PriceImpact(
      salesImpact: (json['sales_impact'] as num).toDouble(),
      revenueImpact: (json['revenue_impact'] as num).toDouble(),
      marginImpact: (json['margin_impact'] as num).toDouble(),
    );
  }
}
```

---

## 5. Price Review Items Data Contract

### Response Structure
```json
[
  {
    "product_id": "string",
    "product_name": "string",
    "current_price": "float",
    "cost_price": "float",
    "margin_percent": "float",
    "total_sales": "integer",
    "last_sale_date": "string",
    "issues": ["string"],
    "regional_avg_price": "float",
    "suggested_price": "float",
    "price_delta": "float",
    "predicted_margin_impact": "float"
  }
]
```

### Field Specifications
| Field | Type | Required | Validation | Description |
|-------|------|----------|------------|-------------|
| `product_id` | string | Yes | UUID format | Unique product identifier |
| `product_name` | string | Yes | Non-empty | Product display name |
| `current_price` | float | Yes | ≥ 0 | Current selling price |
| `cost_price` | float | Yes | ≥ 0 | Cost price |
| `margin_percent` | float | Yes | Any | Current margin percentage |
| `total_sales` | integer | Yes | ≥ 0 | Total sales in period |
| `last_sale_date` | string | Yes | ISO 8601 | Last sale date |
| `issues` | array | Yes | Non-empty | Identified pricing issues |
| `regional_avg_price` | float | Yes | ≥ 0 | Regional average price |
| `suggested_price` | float | Yes | ≥ 0 | AI-suggested price |
| `price_delta` | float | Yes | Any | Price change amount |
| `predicted_margin_impact` | float | Yes | Any | Predicted margin improvement |

### Example Response
```json
[
  {
    "product_id": "550e8400-e29b-41d4-a716-446655440000",
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

### Mobile Implementation
```dart
class PriceReviewItem {
  final String productId;
  final String productName;
  final double currentPrice;
  final double costPrice;
  final double marginPercent;
  final int totalSales;
  final DateTime lastSaleDate;
  final List<String> issues;
  final double regionalAvgPrice;
  final double suggestedPrice;
  final double priceDelta;
  final double predictedMarginImpact;

  PriceReviewItem({
    required this.productId,
    required this.productName,
    required this.currentPrice,
    required this.costPrice,
    required this.marginPercent,
    required this.totalSales,
    required this.lastSaleDate,
    required this.issues,
    required this.regionalAvgPrice,
    required this.suggestedPrice,
    required this.priceDelta,
    required this.predictedMarginImpact,
  });

  factory PriceReviewItem.fromJson(Map<String, dynamic> json) {
    return PriceReviewItem(
      productId: json['product_id'] as String,
      productName: json['product_name'] as String,
      currentPrice: (json['current_price'] as num).toDouble(),
      costPrice: (json['cost_price'] as num).toDouble(),
      marginPercent: (json['margin_percent'] as num).toDouble(),
      totalSales: json['total_sales'] as int,
      lastSaleDate: DateTime.parse(json['last_sale_date'] as String),
      issues: List<String>.from(json['issues']),
      regionalAvgPrice: (json['regional_avg_price'] as num).toDouble(),
      suggestedPrice: (json['suggested_price'] as num).toDouble(),
      priceDelta: (json['price_delta'] as num).toDouble(),
      predictedMarginImpact: (json['predicted_margin_impact'] as num).toDouble(),
    );
  }
}
```

---

## 6. Product Recommendations Data Contract

### Response Structure
```json
[
  {
    "category_id": "string",
    "category_name": "string",
    "avg_margin": "float",
    "total_sales": "integer",
    "suggestions": ["string"],
    "reasoning": "string"
  }
]
```

### Field Specifications
| Field | Type | Required | Validation | Description |
|-------|------|----------|------------|-------------|
| `category_id` | string | No | UUID format | Category identifier (nullable) |
| `category_name` | string | Yes | Non-empty | Category display name |
| `avg_margin` | float | Yes | 0.0-1.0 | Average margin for category |
| `total_sales` | integer | Yes | ≥ 0 | Total sales in category |
| `suggestions` | array | Yes | Non-empty | Product suggestions |
| `reasoning` | string | Yes | Non-empty | Recommendation reasoning |

### Example Response
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

### Mobile Implementation
```dart
class ProductRecommendation {
  final String? categoryId;
  final String categoryName;
  final double avgMargin;
  final int totalSales;
  final List<String> suggestions;
  final String reasoning;

  ProductRecommendation({
    this.categoryId,
    required this.categoryName,
    required this.avgMargin,
    required this.totalSales,
    required this.suggestions,
    required this.reasoning,
  });

  factory ProductRecommendation.fromJson(Map<String, dynamic> json) {
    return ProductRecommendation(
      categoryId: json['category_id'] as String?,
      categoryName: json['category_name'] as String,
      avgMargin: (json['avg_margin'] as num).toDouble(),
      totalSales: json['total_sales'] as int,
      suggestions: List<String>.from(json['suggestions']),
      reasoning: json['reasoning'] as String,
    );
  }
}
```

---

## 7. Daily Insight Data Contract

### Response Structure
```json
{
  "date": "string",
  "today_sales": {
    "transaction_count": "integer",
    "total_revenue": "float",
    "avg_transaction_value": "float"
  },
  "top_products": [
    {
      "product_id": "string",
      "product_name": "string",
      "quantity_sold": "integer",
      "revenue": "float"
    }
  ],
  "low_stock_items": [
    {
      "product_id": "string",
      "product_name": "string",
      "current_stock": "integer",
      "min_stock": "integer",
      "deficit": "integer",
      "days_coverage": "integer",
      "suggested_restock_qty": "integer"
    }
  ],
  "weekly_trend": "string",
  "recommendations": [
    {
      "type": "string",
      "priority": "string",
      "title": "string",
      "description": "string",
      "action": "string",
      "impact": "string"
    }
  ]
}
```

### Field Specifications
| Field | Type | Required | Validation | Description |
|-------|------|----------|------------|-------------|
| `date` | string | Yes | ISO 8601 | Date of insight |
| `today_sales` | object | Yes | - | Today's sales summary |
| `top_products` | array | Yes | Non-empty | Top selling products |
| `low_stock_items` | array | Yes | Non-empty | Low stock items |
| `weekly_trend` | string | Yes | Enum | "increasing", "decreasing", "stable" |
| `recommendations` | array | Yes | Non-empty | Action recommendations |

### Today Sales Object Specifications
| Field | Type | Required | Validation | Description |
|-------|------|----------|------------|-------------|
| `transaction_count` | integer | Yes | ≥ 0 | Number of transactions |
| `total_revenue` | float | Yes | ≥ 0 | Total revenue |
| `avg_transaction_value` | float | Yes | ≥ 0 | Average transaction value |

### Top Product Object Specifications
| Field | Type | Required | Validation | Description |
|-------|------|----------|------------|-------------|
| `product_id` | string | Yes | UUID format | Product identifier |
| `product_name` | string | Yes | Non-empty | Product name |
| `quantity_sold` | integer | Yes | ≥ 0 | Quantity sold |
| `revenue` | float | Yes | ≥ 0 | Revenue generated |

### Low Stock Item Object Specifications
| Field | Type | Required | Validation | Description |
|-------|------|----------|------------|-------------|
| `product_id` | string | Yes | UUID format | Product identifier |
| `product_name` | string | Yes | Non-empty | Product name |
| `current_stock` | integer | Yes | ≥ 0 | Current stock level |
| `min_stock` | integer | Yes | ≥ 0 | Minimum stock level |
| `deficit` | integer | Yes | Any | Stock deficit |
| `days_coverage` | integer | Yes | ≥ 0 | Days of coverage |
| `suggested_restock_qty` | integer | Yes | ≥ 0 | Suggested restock quantity |

### Recommendation Object Specifications
| Field | Type | Required | Validation | Description |
|-------|------|----------|------------|-------------|
| `type` | string | Yes | Enum | "inventory", "pricing", "product", "category" |
| `priority` | string | Yes | Enum | "low", "medium", "high" |
| `title` | string | Yes | Non-empty | Recommendation title |
| `description` | string | Yes | Non-empty | Detailed description |
| `action` | string | Yes | Non-empty | Specific action |
| `impact` | string | Yes | Non-empty | Expected impact |

### Example Response
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
      "product_id": "550e8400-e29b-41d4-a716-446655440000",
      "product_name": "Nasi Goreng Spesial",
      "quantity_sold": 15,
      "revenue": 225000.0
    }
  ],
  "low_stock_items": [
    {
      "product_id": "550e8400-e29b-41d4-a716-446655440001",
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

### Mobile Implementation
```dart
class WarungInsight {
  final DateTime date;
  final TodaySales todaySales;
  final List<TopProductToday> topProducts;
  final List<LowStockItem> lowStockItems;
  final String weeklyTrend;
  final List<ActionRecommendation> recommendations;

  WarungInsight({
    required this.date,
    required this.todaySales,
    required this.topProducts,
    required this.lowStockItems,
    required this.weeklyTrend,
    required this.recommendations,
  });

  factory WarungInsight.fromJson(Map<String, dynamic> json) {
    return WarungInsight(
      date: DateTime.parse(json['date'] as String),
      todaySales: TodaySales.fromJson(json['today_sales']),
      topProducts: (json['top_products'] as List)
          .map((p) => TopProductToday.fromJson(p))
          .toList(),
      lowStockItems: (json['low_stock_items'] as List)
          .map((s) => LowStockItem.fromJson(s))
          .toList(),
      weeklyTrend: json['weekly_trend'] as String,
      recommendations: (json['recommendations'] as List)
          .map((r) => ActionRecommendation.fromJson(r))
          .toList(),
    );
  }
}

class TodaySales {
  final int transactionCount;
  final double totalRevenue;
  final double avgTransactionValue;

  TodaySales({
    required this.transactionCount,
    required this.totalRevenue,
    required this.avgTransactionValue,
  });

  factory TodaySales.fromJson(Map<String, dynamic> json) {
    return TodaySales(
      transactionCount: json['transaction_count'] as int,
      totalRevenue: (json['total_revenue'] as num).toDouble(),
      avgTransactionValue: (json['avg_transaction_value'] as num).toDouble(),
    );
  }
}

class TopProductToday {
  final String productId;
  final String productName;
  final int quantitySold;
  final double revenue;

  TopProductToday({
    required this.productId,
    required this.productName,
    required this.quantitySold,
    required this.revenue,
  });

  factory TopProductToday.fromJson(Map<String, dynamic> json) {
    return TopProductToday(
      productId: json['product_id'] as String,
      productName: json['product_name'] as String,
      quantitySold: json['quantity_sold'] as int,
      revenue: (json['revenue'] as num).toDouble(),
    );
  }
}

class LowStockItem {
  final String productId;
  final String productName;
  final int currentStock;
  final int minStock;
  final int deficit;
  final int daysCoverage;
  final int suggestedRestockQty;

  LowStockItem({
    required this.productId,
    required this.productName,
    required this.currentStock,
    required this.minStock,
    required this.deficit,
    required this.daysCoverage,
    required this.suggestedRestockQty,
  });

  factory LowStockItem.fromJson(Map<String, dynamic> json) {
    return LowStockItem(
      productId: json['product_id'] as String,
      productName: json['product_name'] as String,
      currentStock: json['current_stock'] as int,
      minStock: json['min_stock'] as int,
      deficit: json['deficit'] as int,
      daysCoverage: json['days_coverage'] as int,
      suggestedRestockQty: json['suggested_restock_qty'] as int,
    );
  }
}

class ActionRecommendation {
  final String type;
  final String priority;
  final String title;
  final String description;
  final String action;
  final String impact;

  ActionRecommendation({
    required this.type,
    required this.priority,
    required this.title,
    required this.description,
    required this.action,
    required this.impact,
  });

  factory ActionRecommendation.fromJson(Map<String, dynamic> json) {
    return ActionRecommendation(
      type: json['type'] as String,
      priority: json['priority'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      action: json['action'] as String,
      impact: json['impact'] as String,
    );
  }
}
```

---

## 8. Business Performance Data Contract

### Response Structure
```json
{
  "period": {
    "start_date": "string",
    "end_date": "string",
    "days": "integer"
  },
  "revenue_trend": {
    "total_revenue": "float",
    "avg_daily_revenue": "float",
    "growth_rate": "float",
    "trend": "string"
  },
  "transaction_metrics": {
    "total_transactions": "integer",
    "avg_daily_transactions": "integer",
    "avg_transaction_value": "float"
  },
  "category_performance": [
    {
      "category_id": "string",
      "category_name": "string",
      "revenue": "float",
      "transaction_count": "integer",
      "avg_margin": "float"
    }
  ],
  "margin_analysis": {
    "avg_margin": "float",
    "min_margin": "float",
    "max_margin": "float"
  }
}
```

### Field Specifications
| Field | Type | Required | Validation | Description |
|-------|------|----------|------------|-------------|
| `period` | object | Yes | - | Analysis period information |
| `revenue_trend` | object | Yes | - | Revenue trend analysis |
| `transaction_metrics` | object | Yes | - | Transaction statistics |
| `category_performance` | array | Yes | Non-empty | Performance by category |
| `margin_analysis` | object | Yes | - | Overall margin statistics |

### Period Object Specifications
| Field | Type | Required | Validation | Description |
|-------|------|----------|------------|-------------|
| `start_date` | string | Yes | ISO 8601 | Start date |
| `end_date` | string | Yes | ISO 8601 | End date |
| `days` | integer | Yes | ≥ 1 | Number of days |

### Revenue Trend Object Specifications
| Field | Type | Required | Validation | Description |
|-------|------|----------|------------|-------------|
| `total_revenue` | float | Yes | ≥ 0 | Total revenue |
| `avg_daily_revenue` | float | Yes | ≥ 0 | Average daily revenue |
| `growth_rate` | float | Yes | Any | Growth rate |
| `trend` | string | Yes | Enum | "increasing", "decreasing", "stable" |

### Transaction Metrics Object Specifications
| Field | Type | Required | Validation | Description |
|-------|------|----------|------------|-------------|
| `total_transactions` | integer | Yes | ≥ 0 | Total transactions |
| `avg_daily_transactions` | integer | Yes | ≥ 0 | Average daily transactions |
| `avg_transaction_value` | float | Yes | ≥ 0 | Average transaction value |

### Category Performance Object Specifications
| Field | Type | Required | Validation | Description |
|-------|------|----------|------------|-------------|
| `category_id` | string | Yes | UUID format | Category identifier |
| `category_name` | string | Yes | Non-empty | Category name |
| `revenue` | float | Yes | ≥ 0 | Category revenue |
| `transaction_count` | integer | Yes | ≥ 0 | Transaction count |
| `avg_margin` | float | Yes | 0.0-1.0 | Average margin |

### Margin Analysis Object Specifications
| Field | Type | Required | Validation | Description |
|-------|------|----------|------------|-------------|
| `avg_margin` | float | Yes | 0.0-1.0 | Average margin |
| `min_margin` | float | Yes | 0.0-1.0 | Minimum margin |
| `max_margin` | float | Yes | 0.0-1.0 | Maximum margin |

### Example Response
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

### Mobile Implementation
```dart
class BusinessPerformance {
  final AnalysisPeriod period;
  final RevenueTrend revenueTrend;
  final TransactionMetrics transactionMetrics;
  final List<CategoryPerformance> categoryPerformance;
  final MarginAnalysis marginAnalysis;

  BusinessPerformance({
    required this.period,
    required this.revenueTrend,
    required this.transactionMetrics,
    required this.categoryPerformance,
    required this.marginAnalysis,
  });

  factory BusinessPerformance.fromJson(Map<String, dynamic> json) {
    return BusinessPerformance(
      period: AnalysisPeriod.fromJson(json['period']),
      revenueTrend: RevenueTrend.fromJson(json['revenue_trend']),
      transactionMetrics: TransactionMetrics.fromJson(json['transaction_metrics']),
      categoryPerformance: (json['category_performance'] as List)
          .map((c) => CategoryPerformance.fromJson(c))
          .toList(),
      marginAnalysis: MarginAnalysis.fromJson(json['margin_analysis']),
    );
  }
}

class AnalysisPeriod {
  final DateTime startDate;
  final DateTime endDate;
  final int days;

  AnalysisPeriod({
    required this.startDate,
    required this.endDate,
    required this.days,
  });

  factory AnalysisPeriod.fromJson(Map<String, dynamic> json) {
    return AnalysisPeriod(
      startDate: DateTime.parse(json['start_date'] as String),
      endDate: DateTime.parse(json['end_date'] as String),
      days: json['days'] as int,
    );
  }
}

class RevenueTrend {
  final double totalRevenue;
  final double avgDailyRevenue;
  final double growthRate;
  final String trend;

  RevenueTrend({
    required this.totalRevenue,
    required this.avgDailyRevenue,
    required this.growthRate,
    required this.trend,
  });

  factory RevenueTrend.fromJson(Map<String, dynamic> json) {
    return RevenueTrend(
      totalRevenue: (json['total_revenue'] as num).toDouble(),
      avgDailyRevenue: (json['avg_daily_revenue'] as num).toDouble(),
      growthRate: (json['growth_rate'] as num).toDouble(),
      trend: json['trend'] as String,
    );
  }
}

class TransactionMetrics {
  final int totalTransactions;
  final int avgDailyTransactions;
  final double avgTransactionValue;

  TransactionMetrics({
    required this.totalTransactions,
    required this.avgDailyTransactions,
    required this.avgTransactionValue,
  });

  factory TransactionMetrics.fromJson(Map<String, dynamic> json) {
    return TransactionMetrics(
      totalTransactions: json['total_transactions'] as int,
      avgDailyTransactions: json['avg_daily_transactions'] as int,
      avgTransactionValue: (json['avg_transaction_value'] as num).toDouble(),
    );
  }
}

class CategoryPerformance {
  final String categoryId;
  final String categoryName;
  final double revenue;
  final int transactionCount;
  final double avgMargin;

  CategoryPerformance({
    required this.categoryId,
    required this.categoryName,
    required this.revenue,
    required this.transactionCount,
    required this.avgMargin,
  });

  factory CategoryPerformance.fromJson(Map<String, dynamic> json) {
    return CategoryPerformance(
      categoryId: json['category_id'] as String,
      categoryName: json['category_name'] as String,
      revenue: (json['revenue'] as num).toDouble(),
      transactionCount: json['transaction_count'] as int,
      avgMargin: (json['avg_margin'] as num).toDouble(),
    );
  }
}

class MarginAnalysis {
  final double avgMargin;
  final double minMargin;
  final double maxMargin;

  MarginAnalysis({
    required this.avgMargin,
    required this.minMargin,
    required this.maxMargin,
  });

  factory MarginAnalysis.fromJson(Map<String, dynamic> json) {
    return MarginAnalysis(
      avgMargin: (json['avg_margin'] as num).toDouble(),
      minMargin: (json['min_margin'] as num).toDouble(),
      maxMargin: (json['max_margin'] as num).toDouble(),
    );
  }
}
```

---

## 9. Business Forecast Data Contract

### Response Structure
```json
{
  "predicted_revenue": "float",
  "confidence": "float",
  "trend": "float",
  "avg_daily_revenue": "float",
  "recommendations": ["string"]
}
```

### Field Specifications
| Field | Type | Required | Validation | Description |
|-------|------|----------|------------|-------------|
| `predicted_revenue` | float | Yes | ≥ 0 | Total predicted revenue |
| `confidence` | float | Yes | 0.0-1.0 | Confidence score |
| `trend` | float | Yes | Any | Trend factor |
| `avg_daily_revenue` | float | Yes | ≥ 0 | Average daily prediction |
| `recommendations` | array | Yes | Non-empty | Strategic recommendations |

### Example Response
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

### Mobile Implementation
```dart
class BusinessForecast {
  final double predictedRevenue;
  final double confidence;
  final double trend;
  final double avgDailyRevenue;
  final List<String> recommendations;

  BusinessForecast({
    required this.predictedRevenue,
    required this.confidence,
    required this.trend,
    required this.avgDailyRevenue,
    required this.recommendations,
  });

  factory BusinessForecast.fromJson(Map<String, dynamic> json) {
    return BusinessForecast(
      predictedRevenue: (json['predicted_revenue'] as num).toDouble(),
      confidence: (json['confidence'] as num).toDouble(),
      trend: (json['trend'] as num).toDouble(),
      avgDailyRevenue: (json['avg_daily_revenue'] as num).toDouble(),
      recommendations: List<String>.from(json['recommendations']),
    );
  }
}
```

---

## 10. Business Recommendations Data Contract

### Response Structure
```json
[
  {
    "type": "string",
    "priority": "string",
    "title": "string",
    "description": "string",
    "action": "string",
    "impact": "string",
    "items": [
      {
        "product_id": "string",
        "product_name": "string",
        "current_stock": "integer",
        "suggested_qty": "integer",
        "reason": "string"
      }
    ]
  }
]
```

### Field Specifications
| Field | Type | Required | Validation | Description |
|-------|------|----------|------------|-------------|
| `type` | string | Yes | Enum | "pricing", "inventory", "product", "category", "marketing", "restock" |
| `priority` | string | Yes | Enum | "low", "medium", "high" |
| `title` | string | Yes | Non-empty | Recommendation title |
| `description` | string | Yes | Non-empty | Detailed description |
| `action` | string | Yes | Non-empty | Specific action |
| `impact` | string | Yes | Non-empty | Expected impact |
| `items` | array | No | - | Specific items (for restock) |

### Restock Item Object Specifications
| Field | Type | Required | Validation | Description |
|-------|------|----------|------------|-------------|
| `product_id` | string | Yes | UUID format | Product identifier |
| `product_name` | string | Yes | Non-empty | Product name |
| `current_stock` | integer | Yes | ≥ 0 | Current stock level |
| `suggested_qty` | integer | Yes | ≥ 0 | Suggested restock quantity |
| `reason` | string | Yes | Non-empty | Restock reason |

### Example Response
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
    "type": "restock",
    "priority": "high",
    "title": "Restock Top 3 Items",
    "description": "Best-selling items need restocking",
    "action": "Order 50 units of Nasi Goreng Spesial",
    "impact": "Maintain sales momentum",
    "items": [
      {
        "product_id": "550e8400-e29b-41d4-a716-446655440000",
        "product_name": "Nasi Goreng Spesial",
        "current_stock": 15,
        "suggested_qty": 50,
        "reason": "High demand, low stock"
      }
    ]
  }
]
```

### Mobile Implementation
```dart
class BusinessRecommendation {
  final String type;
  final String priority;
  final String title;
  final String description;
  final String action;
  final String impact;
  final List<RestockItem>? items;

  BusinessRecommendation({
    required this.type,
    required this.priority,
    required this.title,
    required this.description,
    required this.action,
    required this.impact,
    this.items,
  });

  factory BusinessRecommendation.fromJson(Map<String, dynamic> json) {
    return BusinessRecommendation(
      type: json['type'] as String,
      priority: json['priority'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      action: json['action'] as String,
      impact: json['impact'] as String,
      items: json['items'] != null
          ? (json['items'] as List)
              .map((i) => RestockItem.fromJson(i))
              .toList()
          : null,
    );
  }
}

class RestockItem {
  final String productId;
  final String productName;
  final int currentStock;
  final int suggestedQty;
  final String reason;

  RestockItem({
    required this.productId,
    required this.productName,
    required this.currentStock,
    required this.suggestedQty,
    required this.reason,
  });

  factory RestockItem.fromJson(Map<String, dynamic> json) {
    return RestockItem(
      productId: json['product_id'] as String,
      productName: json['product_name'] as String,
      currentStock: json['current_stock'] as int,
      suggestedQty: json['suggested_qty'] as int,
      reason: json['reason'] as String,
    );
  }
}
```

---

## Data Validation Rules

### Common Validation Rules
1. **UUID Format**: Must match pattern `^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$`
2. **Date Format**: Must be ISO 8601 format `YYYY-MM-DDTHH:mm:ssZ`
3. **Enum Values**: Must match predefined values exactly (case-sensitive)
4. **Non-empty Strings**: Must not be null, empty, or whitespace-only
5. **Non-empty Arrays**: Must contain at least one element
6. **Positive Numbers**: Must be ≥ 0 for quantities, prices, and counts
7. **Percentage Values**: Must be between 0.0 and 1.0 (0% to 100%)
8. **Confidence Scores**: Must be between 0.0 and 1.0

### Error Handling
```dart
class DataValidationException implements Exception {
  final String field;
  final String message;
  final dynamic value;

  DataValidationException({
    required this.field,
    required this.message,
    required this.value,
  });

  @override
  String toString() => 'Validation error for $field: $message (value: $value)';
}

class DataContractValidator {
  static void validateUUID(String value, String fieldName) {
    if (!RegExp(r'^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$')
        .hasMatch(value)) {
      throw DataValidationException(
        field: fieldName,
        message: 'Invalid UUID format',
        value: value,
      );
    }
  }

  static void validatePercentage(double value, String fieldName) {
    if (value < 0.0 || value > 1.0) {
      throw DataValidationException(
        field: fieldName,
        message: 'Percentage must be between 0.0 and 1.0',
        value: value,
      );
    }
  }

  static void validateNonEmptyString(String value, String fieldName) {
    if (value.trim().isEmpty) {
      throw DataValidationException(
        field: fieldName,
        message: 'String cannot be empty',
        value: value,
      );
    }
  }

  static void validateNonEmptyArray(List value, String fieldName) {
    if (value.isEmpty) {
      throw DataValidationException(
        field: fieldName,
        message: 'Array cannot be empty',
        value: value,
      );
    }
  }
}
```

---

## Mobile Integration Examples

### Complete API Service Implementation
```dart
class AIApiService {
  final Dio _dio;
  final String _baseUrl;

  AIApiService({required Dio dio}) 
      : _dio = dio,
        _baseUrl = 'https://api.pos-umkm.com/v1';

  Future<SalesPrediction> getSalesPrediction({
    required String productId,
    int daysAhead = 7,
  }) async {
    try {
      final response = await _dio.get(
        '$_baseUrl/api/ai/sales-prediction/$productId',
        queryParameters: {'days': daysAhead},
      );
      
      // Validate response data
      DataContractValidator.validateUUID(productId, 'product_id');
      
      return SalesPrediction.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleDioException(e);
    } catch (e) {
      throw ApiException('Failed to get sales prediction: $e');
    }
  }

  Future<List<TopProduct>> getTopProducts({
    int limit = 10,
    int daysBack = 30,
  }) async {
    try {
      final response = await _dio.get(
        '$_baseUrl/api/ai/top-products',
        queryParameters: {
          'limit': limit,
          'days': daysBack,
        },
      );
      
      final list = response.data as List<dynamic>;
      return list.map((e) => TopProduct.fromJson(e as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      throw _handleDioException(e);
    } catch (e) {
      throw ApiException('Failed to get top products: $e');
    }
  }

  // ... other methods

  Exception _handleDioException(DioException e) {
    switch (e.response?.statusCode) {
      case 400:
        return ValidationException('Invalid request parameters');
      case 401:
        return UnauthorizedException('Authentication required');
      case 404:
        return NotFoundException('Resource not found');
      case 429:
        return RateLimitException('Too many requests');
      case 500:
        return ServerException('Internal server error');
      default:
        return ApiException('Network error: ${e.message}');
    }
  }
}
```

---

## Changelog

### Version 1.0.0 (2024-01-15)
- Initial data contracts documentation
- All 10 API endpoints documented
- Complete field specifications
- Mobile implementation examples
- Validation rules defined
- Error handling patterns
