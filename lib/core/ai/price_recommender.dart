// import 'dart:math'; // removed unused import
import 'package:get/get.dart';
import 'package:pos/core/storage/database_helper.dart';

class PriceRecommender extends GetxController {
  final DatabaseHelper _databaseHelper;
  
  PriceRecommender({required DatabaseHelper databaseHelper}) 
      : _databaseHelper = databaseHelper;

  // Rekomendasi harga optimal berdasarkan analisis kompetitif dan margin
  Future<PriceRecommendation> recommendPrice({
    required String productId,
    double? competitorPrice,
    double? targetMargin,
  }) async {
    final db = await _databaseHelper.database;
    
    // Ambil data produk
    final productData = await db.query(
      'products',
      where: 'id = ?',
      whereArgs: [productId],
    );
    
    if (productData.isEmpty) {
      throw Exception('Product not found');
    }
    
    final product = productData.first;
    final currentPrice = (product['price_sell'] as num).toDouble();
    final costPrice = (product['price_buy'] as num).toDouble();
    
    // Analisis penjualan dengan harga saat ini
    final salesAnalysis = await _analyzeSalesAtPrice(productId, currentPrice);
    
    // Hitung margin saat ini
    final currentMargin = costPrice > 0 ? ((currentPrice - costPrice) / currentPrice) * 100 : 0.0;
    
    // Target margin (default 30% jika tidak ditentukan)
    final targetMarginPercent = targetMargin ?? 30.0;
    
    // Rekomendasi harga berdasarkan berbagai strategi
    final recommendations = <PriceStrategy>[];
    
    // 1. Margin-based pricing
    if (costPrice > 0) {
      final marginBasedPrice = costPrice / (1 - targetMarginPercent / 100);
      recommendations.add(PriceStrategy(
        type: PriceStrategyType.marginBased,
        price: marginBasedPrice,
        confidence: 0.8,
        reasoning: 'Harga berdasarkan margin ${targetMarginPercent.toInt()}%',
      ));
    }
    
    // 2. Competitor-based pricing
    if (competitorPrice != null) {
      final competitivePrice = competitorPrice * 0.95; // 5% lebih murah
      recommendations.add(PriceStrategy(
        type: PriceStrategyType.competitive,
        price: competitivePrice,
        confidence: 0.7,
        reasoning: '5% lebih murah dari kompetitor',
      ));
    }
    
    // 3. Demand-based pricing
    final demandBasedPrice = await _calculateDemandBasedPrice(productId, salesAnalysis);
    if (demandBasedPrice != null) {
      recommendations.add(PriceStrategy(
        type: PriceStrategyType.demandBased,
        price: demandBasedPrice,
        confidence: 0.6,
        reasoning: 'Berdasarkan analisis permintaan',
      ));
    }
    
    // 4. Psychological pricing
    final psychologicalPrice = _applyPsychologicalPricing(currentPrice);
    recommendations.add(PriceStrategy(
      type: PriceStrategyType.psychological,
      price: psychologicalPrice,
      confidence: 0.5,
      reasoning: 'Harga psikologis yang menarik',
    ));
    
    // Pilih rekomendasi terbaik
    final bestRecommendation = recommendations.reduce((a, b) => 
      a.confidence > b.confidence ? a : b);
    
    return PriceRecommendation(
      productId: productId,
      currentPrice: currentPrice,
      recommendedPrice: bestRecommendation.price,
      currentMargin: currentMargin,
      targetMargin: targetMarginPercent,
      priceChange: bestRecommendation.price - currentPrice,
      priceChangePercent: ((bestRecommendation.price - currentPrice) / currentPrice) * 100,
      strategies: recommendations,
      bestStrategy: bestRecommendation,
      impact: _calculatePriceImpact(bestRecommendation.price, currentPrice, salesAnalysis),
    );
  }

  // Rekomendasi produk untuk ditambahkan ke inventory
  Future<List<ProductRecommendation>> recommendProducts({
    int limit = 10,
  }) async {
    final db = await _databaseHelper.database;
    
    // Analisis kategori yang paling menguntungkan
    final profitableCategories = await db.rawQuery('''
      SELECT 
        p.category_id,
        c.name as category_name,
        AVG((p.price_sell - p.price_buy) / p.price_sell * 100) as avg_margin,
        SUM(ti.quantity) as total_sales,
        COUNT(DISTINCT p.id) as product_count
      FROM products p
      LEFT JOIN categories c ON p.category_id = c.id
      LEFT JOIN transaction_items ti ON p.id = ti.product_id
      LEFT JOIN transactions t ON ti.transaction_id = t.id AND t.status = 'completed'
      WHERE p.is_active = 1
      GROUP BY p.category_id, c.name
      HAVING avg_margin > 20 AND total_sales > 0
      ORDER BY avg_margin DESC, total_sales DESC
    ''');
    
    final recommendations = <ProductRecommendation>[];
    
    for (final category in profitableCategories.take(limit)) {
      final categoryId = category['category_id'] as String?;
      final categoryName = category['category_name'] as String? ?? 'Unknown';
      final avgMargin = (category['avg_margin'] as num).toDouble();
      final totalSales = category['total_sales'] as int;
      
      // Generate product suggestions based on category
      final suggestions = _generateProductSuggestions(categoryName, avgMargin);
      
      recommendations.add(ProductRecommendation(
        categoryId: categoryId,
        categoryName: categoryName,
        avgMargin: avgMargin,
        totalSales: totalSales,
        suggestions: suggestions,
        reasoning: 'Kategori dengan margin tinggi (${avgMargin.toInt()}%) dan penjualan bagus',
      ));
    }
    
    return recommendations;
  }

  // Analisis produk yang perlu di-review harganya
  Future<List<PriceReviewItem>> getProductsNeedingPriceReview() async {
    final db = await _databaseHelper.database;
    
    // Produk dengan margin rendah atau tidak ada penjualan
    final reviewItems = await db.rawQuery('''
      SELECT 
        p.id,
        p.name,
        p.price_sell,
        p.price_buy,
        p.category_id,
        c.name as category_name,
        (p.price_sell - p.price_buy) / p.price_sell * 100 as margin_percent,
        COALESCE(SUM(ti.quantity), 0) as total_sales,
        COALESCE(MAX(t.created_at), 0) as last_sale_date
      FROM products p
      LEFT JOIN categories c ON p.category_id = c.id
      LEFT JOIN transaction_items ti ON p.id = ti.product_id
      LEFT JOIN transactions t ON ti.transaction_id = t.id AND t.status = 'completed'
      WHERE p.is_active = 1
      GROUP BY p.id, p.name, p.price_sell, p.price_buy, p.category_id, c.name
      HAVING margin_percent < 15 OR total_sales = 0 OR last_sale_date < ?
      ORDER BY margin_percent ASC, total_sales ASC
    ''', [DateTime.now().subtract(const Duration(days: 30)).millisecondsSinceEpoch]);
    
    return reviewItems.map((row) => PriceReviewItem(
      productId: row['id'] as String,
      productName: row['name'] as String,
      currentPrice: (row['price_sell'] as num).toDouble(),
      costPrice: (row['price_buy'] as num).toDouble(),
      marginPercent: (row['margin_percent'] as num).toDouble(),
      totalSales: row['total_sales'] as int,
      lastSaleDate: DateTime.fromMillisecondsSinceEpoch(row['last_sale_date'] as int),
      issues: _identifyPriceIssues(
        margin: (row['margin_percent'] as num).toDouble(),
        sales: row['total_sales'] as int,
        lastSale: DateTime.fromMillisecondsSinceEpoch(row['last_sale_date'] as int),
      ),
    )).toList();
  }

  // Analisis penjualan pada harga tertentu
  Future<SalesAnalysis> _analyzeSalesAtPrice(String productId, double price) async {
    final db = await _databaseHelper.database;
    
    final salesData = await db.rawQuery('''
      SELECT 
        COUNT(*) as transaction_count,
        SUM(ti.quantity) as total_quantity,
        AVG(ti.unit_price) as avg_price,
        MIN(ti.unit_price) as min_price,
        MAX(ti.unit_price) as max_price
      FROM transaction_items ti
      JOIN transactions t ON ti.transaction_id = t.id
      WHERE ti.product_id = ? 
        AND t.status = 'completed'
        AND ti.unit_price BETWEEN ? AND ?
    ''', [productId, price * 0.9, price * 1.1]);
    
    final data = salesData.first;
    return SalesAnalysis(
      transactionCount: data['transaction_count'] as int,
      totalQuantity: data['total_quantity'] as int,
      avgPrice: (data['avg_price'] as num).toDouble(),
      minPrice: (data['min_price'] as num).toDouble(),
      maxPrice: (data['max_price'] as num).toDouble(),
    );
  }

  // Hitung harga berdasarkan permintaan
  Future<double?> _calculateDemandBasedPrice(String productId, SalesAnalysis analysis) async {
    if (analysis.transactionCount < 5) return null;
    
    // Simple demand curve: jika penjualan tinggi, bisa naikkan harga sedikit
    final demandFactor = analysis.totalQuantity / analysis.transactionCount;
    final currentAvgPrice = analysis.avgPrice;
    
    if (demandFactor > 2) {
      return currentAvgPrice * 1.05; // Naik 5% jika demand tinggi
    } else if (demandFactor < 1) {
      return currentAvgPrice * 0.95; // Turun 5% jika demand rendah
    }
    
    return currentAvgPrice;
  }

  // Terapkan psychological pricing
  double _applyPsychologicalPricing(double price) {
    if (price < 10000) {
      // Harga di bawah 10k: gunakan .900
      return (price ~/ 1000) * 1000 + 900;
    } else if (price < 100000) {
      // Harga 10k-100k: gunakan .990
      return (price ~/ 1000) * 1000 + 990;
    } else {
      // Harga di atas 100k: gunakan .999
      return (price ~/ 1000) * 1000 + 999;
    }
  }

  // Hitung dampak perubahan harga
  PriceImpact _calculatePriceImpact(double newPrice, double currentPrice, SalesAnalysis analysis) {
    final priceChangePercent = ((newPrice - currentPrice) / currentPrice) * 100;
    
    // Estimasi dampak pada penjualan (simplified)
    double salesImpact = 0;
    if (priceChangePercent > 0) {
      salesImpact = -priceChangePercent * 0.5; // Penjualan turun 0.5% per 1% kenaikan harga
    } else {
      salesImpact = -priceChangePercent * 0.3; // Penjualan naik 0.3% per 1% penurunan harga
    }
    
    return PriceImpact(
      salesImpact: salesImpact,
      revenueImpact: priceChangePercent + salesImpact,
      marginImpact: priceChangePercent,
    );
  }

  // Generate saran produk berdasarkan kategori
  List<String> _generateProductSuggestions(String categoryName, double avgMargin) {
    final suggestions = <String>[];
    
    switch (categoryName.toLowerCase()) {
      case 'minuman':
        suggestions.addAll(['Air Mineral Premium', 'Jus Segar', 'Kopi Instan Premium']);
        break;
      case 'makanan':
        suggestions.addAll(['Mie Instan Premium', 'Snack Sehat', 'Biskuit Organik']);
        break;
      case 'kecantikan':
        suggestions.addAll(['Shampoo Anti Ketombe', 'Sabun Mandi Aromaterapi', 'Lotion Kulit']);
        break;
      default:
        suggestions.addAll(['Produk Premium', 'Varian Baru', 'Bundle Package']);
    }
    
    return suggestions.take(3).toList();
  }

  // Identifikasi masalah harga
  List<String> _identifyPriceIssues({
    required double margin,
    required int sales,
    required DateTime lastSale,
  }) {
    final issues = <String>[];
    
    if (margin < 15) {
      issues.add('Margin terlalu rendah (${margin.toInt()}%)');
    }
    
    if (sales == 0) {
      issues.add('Belum ada penjualan');
    } else if (lastSale.isBefore(DateTime.now().subtract(const Duration(days: 30)))) {
      issues.add('Tidak ada penjualan dalam 30 hari terakhir');
    }
    
    return issues;
  }
}

// Data Models
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
      strategies: ((json['strategies'] as List<dynamic>)
              .map((e) => PriceStrategy.fromJson(e as Map<String, dynamic>))
              .toList()),
      bestStrategy: PriceStrategy.fromJson(json['best_strategy'] as Map<String, dynamic>),
      impact: PriceImpact.fromJson(json['impact'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'product_id': productId,
      'current_price': currentPrice,
      'recommended_price': recommendedPrice,
      'current_margin': currentMargin,
      'target_margin': targetMargin,
      'price_change': priceChange,
      'price_change_percent': priceChangePercent,
      'strategies': strategies.map((e) => e.toJson()).toList(),
      'best_strategy': bestStrategy.toJson(),
      'impact': impact.toJson(),
    };
  }
}

class PriceStrategy {
  final PriceStrategyType type;
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
      type: PriceStrategyType.values.firstWhere(
        (e) => e.name == (json['type'] as String? ?? 'marginBased'),
        orElse: () => PriceStrategyType.marginBased,
      ),
      price: (json['price'] as num).toDouble(),
      confidence: (json['confidence'] as num).toDouble(),
      reasoning: json['reasoning'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type.name,
      'price': price,
      'confidence': confidence,
      'reasoning': reasoning,
    };
  }
}

class ProductRecommendation {
  final String? categoryId;
  final String categoryName;
  final double avgMargin;
  final int totalSales;
  final List<String> suggestions;
  final String reasoning;

  ProductRecommendation({
    required this.categoryId,
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
      totalSales: (json['total_sales'] as num).toInt(),
      suggestions: (json['suggestions'] as List<dynamic>).cast<String>(),
      reasoning: json['reasoning'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'category_id': categoryId,
      'category_name': categoryName,
      'avg_margin': avgMargin,
      'total_sales': totalSales,
      'suggestions': suggestions,
      'reasoning': reasoning,
    };
  }
}

class PriceReviewItem {
  final String productId;
  final String productName;
  final double currentPrice;
  final double costPrice;
  final double marginPercent;
  final int totalSales;
  final DateTime lastSaleDate;
  final List<String> issues;

  PriceReviewItem({
    required this.productId,
    required this.productName,
    required this.currentPrice,
    required this.costPrice,
    required this.marginPercent,
    required this.totalSales,
    required this.lastSaleDate,
    required this.issues,
  });

  factory PriceReviewItem.fromJson(Map<String, dynamic> json) {
    return PriceReviewItem(
      productId: json['product_id'] as String,
      productName: json['product_name'] as String,
      currentPrice: (json['current_price'] as num).toDouble(),
      costPrice: (json['cost_price'] as num).toDouble(),
      marginPercent: (json['margin_percent'] as num).toDouble(),
      totalSales: (json['total_sales'] as num).toInt(),
      lastSaleDate: DateTime.parse(json['last_sale_date'] as String),
      issues: (json['issues'] as List<dynamic>).cast<String>(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'product_id': productId,
      'product_name': productName,
      'current_price': currentPrice,
      'cost_price': costPrice,
      'margin_percent': marginPercent,
      'total_sales': totalSales,
      'last_sale_date': lastSaleDate.toIso8601String(),
      'issues': issues,
    };
  }
}

class SalesAnalysis {
  final int transactionCount;
  final int totalQuantity;
  final double avgPrice;
  final double minPrice;
  final double maxPrice;

  SalesAnalysis({
    required this.transactionCount,
    required this.totalQuantity,
    required this.avgPrice,
    required this.minPrice,
    required this.maxPrice,
  });

  factory SalesAnalysis.fromJson(Map<String, dynamic> json) {
    return SalesAnalysis(
      transactionCount: (json['transaction_count'] as num).toInt(),
      totalQuantity: (json['total_quantity'] as num).toInt(),
      avgPrice: (json['avg_price'] as num).toDouble(),
      minPrice: (json['min_price'] as num).toDouble(),
      maxPrice: (json['max_price'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'transaction_count': transactionCount,
      'total_quantity': totalQuantity,
      'avg_price': avgPrice,
      'min_price': minPrice,
      'max_price': maxPrice,
    };
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

  Map<String, dynamic> toJson() {
    return {
      'sales_impact': salesImpact,
      'revenue_impact': revenueImpact,
      'margin_impact': marginImpact,
    };
  }
}

enum PriceStrategyType {
  marginBased,
  competitive,
  demandBased,
  psychological,
}
