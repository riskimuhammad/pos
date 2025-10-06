import 'dart:math';
import 'package:get/get.dart';
import 'package:pos/core/storage/database_helper.dart';
// import 'package:pos/core/ai/ai_api_service.dart';
// import 'package:pos/core/constants/app_constants.dart';

class SalesPredictor extends GetxController {
  final DatabaseHelper _databaseHelper;
  // final AIApiService? _apiService;
  
  SalesPredictor({
    required DatabaseHelper databaseHelper,
    // AIApiService? apiService,
  }) : _databaseHelper = databaseHelper;

  // Prediksi penjualan berdasarkan data historis
  Future<SalesPrediction> predictSales({
    required String productId,
    int daysAhead = 7,
  }) async {
    // Local calculation
    final db = await _databaseHelper.database;
    
    // Ambil data penjualan 30 hari terakhir
    final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30)).millisecondsSinceEpoch;
    
    final salesData = await db.rawQuery('''
      SELECT 
        DATE(created_at/1000, 'unixepoch') as sale_date,
        SUM(quantity) as daily_quantity,
        AVG(unit_price) as avg_price
      FROM transaction_items ti
      JOIN transactions t ON ti.transaction_id = t.id
      WHERE ti.product_id = ? 
        AND t.created_at >= ?
        AND t.status = 'completed'
      GROUP BY DATE(created_at/1000, 'unixepoch')
      ORDER BY sale_date DESC
    ''', [productId, thirtyDaysAgo]);

    if (salesData.isEmpty) {
    return SalesPrediction(
      productId: productId,
      predictedQuantity: 0,
      confidence: 0.0,
      trend: SalesTrend.stable,
      recommendations: ['Tidak ada data penjualan historis'],
      dailyAverage: 0.0,
      trendPercentage: 0,
    );
    }

    // Analisis trend dan prediksi
    final quantities = salesData.map((row) => (row['daily_quantity'] as int?) ?? 0).toList();
    final avgDailySales = quantities.reduce((a, b) => a + b) / quantities.length;
    
    // Hitung trend (linear regression sederhana)
    final trend = _calculateTrend(quantities);
    
    // Prediksi untuk hari-hari ke depan
    final predictedQuantity = (avgDailySales * daysAhead * (1 + trend)).round();
    
    // Confidence berdasarkan konsistensi data
    final confidence = _calculateConfidence(quantities);
    
    // Generate recommendations
    final recommendations = _generateRecommendations(
      predictedQuantity: predictedQuantity,
      trend: trend,
      avgDailySales: avgDailySales,
      productId: productId,
    );

    return SalesPrediction(
      productId: productId,
      predictedQuantity: predictedQuantity,
      confidence: confidence,
      trend: _getTrendType(trend),
      recommendations: recommendations,
      dailyAverage: avgDailySales,
      trendPercentage: (trend * 100).round(),
    );
  }

  // Prediksi stok yang dibutuhkan
  Future<StockPrediction> predictStock({
    required String productId,
    int daysAhead = 7,
  }) async {
    final salesPrediction = await predictSales(productId: productId, daysAhead: daysAhead);
    final db = await _databaseHelper.database;
    
    // Ambil stok saat ini
    final currentStock = await db.rawQuery('''
      SELECT SUM(quantity) as total_stock
      FROM inventory i
      WHERE i.product_id = ?
    ''', [productId]);
    
    final currentStockValue = (currentStock.first['total_stock'] as int?) ?? 0;
    
    // Hitung stok yang dibutuhkan
    final requiredStock = salesPrediction.predictedQuantity;
    final stockDeficit = requiredStock - currentStockValue;
    
    // Hitung lead time (asumsi 3 hari untuk restock)
    final leadTimeDays = 3;
    final urgentStock = (salesPrediction.dailyAverage * leadTimeDays).round();
    
    return StockPrediction(
      productId: productId,
      currentStock: currentStockValue,
      predictedNeed: requiredStock,
      stockDeficit: stockDeficit,
      urgentStock: urgentStock,
      recommendations: _generateStockRecommendations(
        stockDeficit: stockDeficit,
        urgentStock: urgentStock,
        trend: salesPrediction.trend,
      ),
    );
  }

  // Analisis produk terlaris
  Future<List<TopProduct>> getTopProducts({
    int limit = 10,
    int daysBack = 30,
  }) async {
    final db = await _databaseHelper.database;
    final daysAgo = DateTime.now().subtract(Duration(days: daysBack)).millisecondsSinceEpoch;
    
    final topProducts = await db.rawQuery('''
      SELECT 
        ti.product_id,
        p.name as product_name,
        p.category_id,
        c.name as category_name,
        SUM(ti.quantity) as total_quantity,
        SUM(ti.subtotal) as total_revenue,
        AVG(ti.unit_price) as avg_price,
        COUNT(DISTINCT t.id) as transaction_count
      FROM transaction_items ti
      JOIN transactions t ON ti.transaction_id = t.id
      JOIN products p ON ti.product_id = p.id
      LEFT JOIN categories c ON p.category_id = c.id
      WHERE t.created_at >= ? 
        AND t.status = 'completed'
      GROUP BY ti.product_id, p.name, p.category_id, c.name
      ORDER BY total_quantity DESC
      LIMIT ?
    ''', [daysAgo, limit]);

    return topProducts.map((row) => TopProduct(
      productId: row['product_id'] as String,
      productName: row['product_name'] as String,
      categoryName: row['category_name'] as String? ?? 'Unknown',
      totalQuantity: row['total_quantity'] as int,
      totalRevenue: (row['total_revenue'] as num).toDouble(),
      avgPrice: (row['avg_price'] as num).toDouble(),
      transactionCount: row['transaction_count'] as int,
    )).toList();
  }

  // Analisis kategori terlaris
  Future<List<TopCategory>> getTopCategories({
    int limit = 5,
    int daysBack = 30,
  }) async {
    final db = await _databaseHelper.database;
    final daysAgo = DateTime.now().subtract(Duration(days: daysBack)).millisecondsSinceEpoch;
    
    final topCategories = await db.rawQuery('''
      SELECT 
        p.category_id,
        c.name as category_name,
        SUM(ti.quantity) as total_quantity,
        SUM(ti.subtotal) as total_revenue,
        COUNT(DISTINCT ti.product_id) as product_count
      FROM transaction_items ti
      JOIN transactions t ON ti.transaction_id = t.id
      JOIN products p ON ti.product_id = p.id
      LEFT JOIN categories c ON p.category_id = c.id
      WHERE t.created_at >= ? 
        AND t.status = 'completed'
        AND p.category_id IS NOT NULL
      GROUP BY p.category_id, c.name
      ORDER BY total_revenue DESC
      LIMIT ?
    ''', [daysAgo, limit]);

    return topCategories.map((row) => TopCategory(
      categoryId: row['category_id'] as String,
      categoryName: row['category_name'] as String,
      totalQuantity: row['total_quantity'] as int,
      totalRevenue: (row['total_revenue'] as num).toDouble(),
      productCount: row['product_count'] as int,
    )).toList();
  }

  // Hitung trend menggunakan linear regression sederhana
  double _calculateTrend(List<int> quantities) {
    if (quantities.length < 2) return 0.0;
    
    final n = quantities.length;
    final x = List.generate(n, (i) => i.toDouble());
    final y = quantities.map((q) => q.toDouble()).toList();
    
    // Linear regression: y = mx + b
    final sumX = x.reduce((a, b) => a + b);
    final sumY = y.reduce((a, b) => a + b);
    final sumXY = x.asMap().entries.map((e) => e.value * y[e.key]).reduce((a, b) => a + b);
    final sumXX = x.map((xi) => xi * xi).reduce((a, b) => a + b);
    
    final slope = (n * sumXY - sumX * sumY) / (n * sumXX - sumX * sumX);
    return slope / (sumY / n); // Normalize by average
  }

  // Hitung confidence berdasarkan variasi data
  double _calculateConfidence(List<int> quantities) {
    if (quantities.length < 2) return 0.0;
    
    final mean = quantities.reduce((a, b) => a + b) / quantities.length;
    final variance = quantities.map((q) => pow(q - mean, 2)).reduce((a, b) => a + b) / quantities.length;
    final stdDev = sqrt(variance);
    
    // Confidence tinggi jika variasi rendah
    final coefficient = stdDev / mean;
    return (1.0 - coefficient.clamp(0.0, 1.0));
  }

  SalesTrend _getTrendType(double trend) {
    if (trend > 0.1) return SalesTrend.increasing;
    if (trend < -0.1) return SalesTrend.decreasing;
    return SalesTrend.stable;
  }

  List<String> _generateRecommendations({
    required int predictedQuantity,
    required double trend,
    required double avgDailySales,
    required String productId,
  }) {
    final recommendations = <String>[];
    
    if (trend > 0.1) {
      recommendations.add('📈 Penjualan meningkat! Pertimbangkan untuk menambah stok.');
    } else if (trend < -0.1) {
      recommendations.add('📉 Penjualan menurun. Evaluasi strategi pemasaran.');
    }
    
    if (predictedQuantity > avgDailySales * 10) {
      recommendations.add('⚠️ Prediksi penjualan tinggi. Pastikan stok mencukupi.');
    }
    
    if (avgDailySales < 1) {
      recommendations.add('💡 Produk jarang terjual. Pertimbangkan promosi atau review harga.');
    }
    
    return recommendations;
  }

  List<String> _generateStockRecommendations({
    required int stockDeficit,
    required int urgentStock,
    required SalesTrend trend,
  }) {
    final recommendations = <String>[];
    
    if (stockDeficit > 0) {
      recommendations.add('🚨 Stok kurang $stockDeficit unit. Segera restock!');
    } else if (stockDeficit < -urgentStock) {
      recommendations.add('📦 Stok berlebih. Pertimbangkan promosi untuk mengurangi stok.');
    }
    
    if (trend == SalesTrend.increasing) {
      recommendations.add('📈 Trend naik. Siapkan stok ekstra untuk antisipasi lonjakan permintaan.');
    }
    
    return recommendations;
  }
}

// Data Models
class SalesPrediction {
  final String productId;
  final int predictedQuantity;
  final double confidence;
  final SalesTrend trend;
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
      predictedQuantity: (json['predicted_quantity'] as num).toInt(),
      confidence: (json['confidence'] as num).toDouble(),
      trend: _trendFromString(json['trend'] as String?),
      recommendations: (json['recommendations'] as List<dynamic>?)?.cast<String>() ?? const [],
      dailyAverage: (json['daily_average'] as num?)?.toDouble() ?? 0.0,
      trendPercentage: (json['trend_percentage'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'product_id': productId,
      'predicted_quantity': predictedQuantity,
      'confidence': confidence,
      'trend': trend.name,
      'recommendations': recommendations,
      'daily_average': dailyAverage,
      'trend_percentage': trendPercentage,
    };
  }
}

class StockPrediction {
  final String productId;
  final int currentStock;
  final int predictedNeed;
  final int stockDeficit;
  final int urgentStock;
  final List<String> recommendations;

  StockPrediction({
    required this.productId,
    required this.currentStock,
    required this.predictedNeed,
    required this.stockDeficit,
    required this.urgentStock,
    required this.recommendations,
  });
}

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
      categoryName: json['category_name'] as String? ?? 'Unknown',
      totalQuantity: (json['total_quantity'] as num).toInt(),
      totalRevenue: (json['total_revenue'] as num).toDouble(),
      avgPrice: (json['avg_price'] as num).toDouble(),
      transactionCount: (json['transaction_count'] as num).toInt(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'product_id': productId,
      'product_name': productName,
      'category_name': categoryName,
      'total_quantity': totalQuantity,
      'total_revenue': totalRevenue,
      'avg_price': avgPrice,
      'transaction_count': transactionCount,
    };
  }
}

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
      totalQuantity: (json['total_quantity'] as num).toInt(),
      totalRevenue: (json['total_revenue'] as num).toDouble(),
      productCount: (json['product_count'] as num).toInt(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'category_id': categoryId,
      'category_name': categoryName,
      'total_quantity': totalQuantity,
      'total_revenue': totalRevenue,
      'product_count': productCount,
    };
  }
}

enum SalesTrend { increasing, decreasing, stable }

SalesTrend _trendFromString(String? value) {
  switch (value) {
    case 'increasing':
      return SalesTrend.increasing;
    case 'decreasing':
      return SalesTrend.decreasing;
    case 'stable':
    default:
      return SalesTrend.stable;
  }
}
