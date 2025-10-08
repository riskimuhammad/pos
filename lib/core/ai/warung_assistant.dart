import 'dart:math';
import 'package:get/get.dart';
import 'package:pos/core/storage/database_helper.dart';
import 'package:pos/core/ai/sales_predictor.dart';
import 'package:pos/core/ai/price_recommender.dart';
import 'package:pos/core/ai/ai_api_service.dart';
import 'package:pos/core/constants/app_constants.dart';

class WarungAssistant extends GetxController {
  final DatabaseHelper _databaseHelper;
  final SalesPredictor _salesPredictor;
  final PriceRecommender _priceRecommender;
  final AIApiService? _apiService;
  
  WarungAssistant({
    required DatabaseHelper databaseHelper,
    required SalesPredictor salesPredictor,
    required PriceRecommender priceRecommender,
    AIApiService? apiService,
  }) : _databaseHelper = databaseHelper,
       _salesPredictor = salesPredictor,
       _priceRecommender = priceRecommender,
       _apiService = apiService;

  // Dashboard utama dengan insight bisnis
  Future<WarungInsight> getDailyInsight() async {
    // Try API first if enabled
    if (AppConstants.kEnableRemoteApi && _apiService != null) {
      try {
        return await _apiService!.getDailyInsight();
      } catch (e) {
        print('API call failed, falling back to local calculation: $e');
      }
    }
    
    final db = await _databaseHelper.database;
    
    // Data hari ini
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day).millisecondsSinceEpoch;
    final endOfDay = startOfDay + (24 * 60 * 60 * 1000) - 1;
    
    // Penjualan hari ini
    final todaySales = await db.rawQuery('''
      SELECT 
        COUNT(*) as transaction_count,
        SUM(total) as total_revenue,
        AVG(total) as avg_transaction_value
      FROM transactions 
      WHERE created_at BETWEEN ? AND ? 
        AND status = 'completed'
    ''', [startOfDay, endOfDay]);
    
    // Produk terlaris hari ini
    final todayTopProducts = await db.rawQuery('''
      SELECT 
        ti.product_id,
        p.name as product_name,
        SUM(ti.quantity) as quantity_sold,
        SUM(ti.subtotal) as revenue
      FROM transaction_items ti
      JOIN transactions t ON ti.transaction_id = t.id
      JOIN products p ON ti.product_id = p.id
      WHERE t.created_at BETWEEN ? AND ? 
        AND t.status = 'completed'
      GROUP BY ti.product_id, p.name
      ORDER BY quantity_sold DESC
      LIMIT 5
    ''', [startOfDay, endOfDay]);
    
    // Stok yang perlu diperhatikan
    final lowStockItems = await db.rawQuery('''
      SELECT 
        p.id,
        p.name,
        p.min_stock,
        SUM(i.quantity) as current_stock
      FROM products p
      LEFT JOIN inventory i ON p.id = i.product_id
      WHERE p.is_active = 1
      GROUP BY p.id, p.name, p.min_stock
      HAVING current_stock <= p.min_stock
      ORDER BY current_stock ASC
    ''');
    
    // Analisis trend mingguan
    final weeklyTrend = await _analyzeWeeklyTrend();
    
    // Rekomendasi aksi
    final recommendations = await _generateActionRecommendations(
      todaySales: todaySales.first,
      lowStockCount: lowStockItems.length,
      weeklyTrend: weeklyTrend,
    );
    
    return WarungInsight(
      date: today,
      todaySales: TodaySales(
        transactionCount: todaySales.first['transaction_count'] as int,
        totalRevenue: (todaySales.first['total_revenue'] as num?)?.toDouble() ?? 0.0,
        avgTransactionValue: (todaySales.first['avg_transaction_value'] as num?)?.toDouble() ?? 0.0,
      ),
      topProducts: todayTopProducts.map((row) => TopProductToday(
        productId: row['product_id'] as String,
        productName: row['product_name'] as String,
        quantitySold: row['quantity_sold'] as int,
        revenue: (row['revenue'] as num).toDouble(),
      )).toList(),
      lowStockItems: lowStockItems.map((row) => LowStockItem(
        productId: row['id'] as String,
        productName: row['name'] as String,
        currentStock: row['current_stock'] as int,
        minStock: row['min_stock'] as int,
      )).toList(),
      weeklyTrend: weeklyTrend,
      recommendations: recommendations,
    );
  }

  // Analisis performa bisnis
  Future<BusinessPerformance> getBusinessPerformance({
    int daysBack = 30,
  }) async {
    // Try API first if enabled
    if (AppConstants.kEnableRemoteApi && _apiService != null) {
      try {
        return await _apiService!.getBusinessPerformance(daysBack: daysBack);
      } catch (e) {
        print('API call failed, falling back to local calculation: $e');
      }
    }
    
    final db = await _databaseHelper.database;
    final startDate = DateTime.now().subtract(Duration(days: daysBack)).millisecondsSinceEpoch;
    
    // Revenue trend
    final revenueData = await db.rawQuery('''
      SELECT 
        DATE(created_at/1000, 'unixepoch') as sale_date,
        SUM(total) as daily_revenue,
        COUNT(*) as transaction_count
      FROM transactions 
      WHERE created_at >= ? 
        AND status = 'completed'
      GROUP BY DATE(created_at/1000, 'unixepoch')
      ORDER BY sale_date DESC
    ''', [startDate]);
    
    // Kategori performa
    final categoryPerformance = await db.rawQuery('''
      SELECT 
        p.category_id,
        c.name as category_name,
        SUM(ti.subtotal) as revenue,
        SUM(ti.quantity) as quantity_sold,
        COUNT(DISTINCT ti.product_id) as product_count
      FROM transaction_items ti
      JOIN transactions t ON ti.transaction_id = t.id
      JOIN products p ON ti.product_id = p.id
      LEFT JOIN categories c ON p.category_id = c.id
      WHERE t.created_at >= ? 
        AND t.status = 'completed'
      GROUP BY p.category_id, c.name
      ORDER BY revenue DESC
    ''', [startDate]);
    
    // Analisis margin
    final marginAnalysis = await db.rawQuery('''
      SELECT 
        AVG((p.price_sell - p.price_buy) / p.price_sell * 100) as avg_margin,
        MIN((p.price_sell - p.price_buy) / p.price_sell * 100) as min_margin,
        MAX((p.price_sell - p.price_buy) / p.price_sell * 100) as max_margin
      FROM products p
      WHERE p.is_active = 1 AND p.price_buy > 0
    ''');
    
    return BusinessPerformance(
      revenueTrend: revenueData.map((row) => DailyRevenue(
        date: DateTime.parse(row['sale_date'] as String),
        revenue: (row['daily_revenue'] as num).toDouble(),
        transactionCount: row['transaction_count'] as int,
      )).toList(),
      categoryPerformance: categoryPerformance.map((row) => CategoryPerformance(
        categoryId: row['category_id'] as String?,
        categoryName: row['category_name'] as String? ?? 'Unknown',
        revenue: (row['revenue'] as num).toDouble(),
        quantitySold: row['quantity_sold'] as int,
        productCount: row['product_count'] as int,
      )).toList(),
      marginAnalysis: MarginAnalysis(
        avgMargin: (marginAnalysis.first['avg_margin'] as num?)?.toDouble() ?? 0.0,
        minMargin: (marginAnalysis.first['min_margin'] as num?)?.toDouble() ?? 0.0,
        maxMargin: (marginAnalysis.first['max_margin'] as num?)?.toDouble() ?? 0.0,
      ),
    );
  }

  // Rekomendasi strategi bisnis
  Future<List<BusinessRecommendation>> getBusinessRecommendations() async {
    // Try API first if enabled
    if (AppConstants.kEnableRemoteApi && _apiService != null) {
      try {
        return await _apiService!.getBusinessRecommendations();
      } catch (e) {
        print('API call failed, falling back to local calculation: $e');
      }
    }
    
    final recommendations = <BusinessRecommendation>[];
    
    // 1. Analisis produk yang perlu di-review
    final priceReviewItems = await _priceRecommender.getProductsNeedingPriceReview();
    if (priceReviewItems.isNotEmpty) {
      recommendations.add(BusinessRecommendation(
        type: RecommendationType.pricing,
        priority: Priority.high,
        title: 'Review Harga Produk',
        description: '${priceReviewItems.length} produk perlu review harga',
        action: 'Review dan sesuaikan harga untuk meningkatkan margin',
        impact: 'Meningkatkan profit margin hingga 20%',
      ));
    }
    
    // 2. Analisis stok
    final lowStockCount = await _getLowStockCount();
    if (lowStockCount > 0) {
      recommendations.add(BusinessRecommendation(
        type: RecommendationType.inventory,
        priority: Priority.high,
        title: 'Restock Produk',
        description: '$lowStockCount produk stok rendah',
        action: 'Segera restock produk yang stoknya menipis',
        impact: 'Mencegah kehilangan penjualan',
      ));
    }
    
    // 3. Analisis produk terlaris
    final topProducts = await _salesPredictor.getTopProducts(limit: 5);
    if (topProducts.isNotEmpty) {
      recommendations.add(BusinessRecommendation(
        type: RecommendationType.product,
        priority: Priority.medium,
        title: 'Ekspansi Produk Terlaris',
        description: '${topProducts.first.productName} adalah produk terlaris',
        action: 'Tambah varian atau stok produk terlaris',
        impact: 'Meningkatkan revenue hingga 15%',
      ));
    }
    
    // 4. Analisis kategori
    final topCategories = await _salesPredictor.getTopCategories(limit: 3);
    if (topCategories.isNotEmpty) {
      recommendations.add(BusinessRecommendation(
        type: RecommendationType.category,
        priority: Priority.medium,
        title: 'Fokus Kategori Menguntungkan',
        description: 'Kategori ${topCategories.first.categoryName} paling menguntungkan',
        action: 'Ekspansi produk di kategori yang menguntungkan',
        impact: 'Meningkatkan profit margin kategori',
      ));
    }
    
    return recommendations;
  }

  // Prediksi dan perencanaan
  Future<BusinessForecast> getBusinessForecast({
    int daysAhead = 30,
  }) async {
    // Try API first if enabled
    if (AppConstants.kEnableRemoteApi && _apiService != null) {
      try {
        return await _apiService!.getBusinessForecast(daysAhead: daysAhead);
      } catch (e) {
        print('API call failed, falling back to local calculation: $e');
      }
    }
    
    final db = await _databaseHelper.database;
    
    // Analisis trend revenue 30 hari terakhir
    final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30)).millisecondsSinceEpoch;
    final revenueData = await db.rawQuery('''
      SELECT 
        DATE(created_at/1000, 'unixepoch') as sale_date,
        SUM(total) as daily_revenue
      FROM transactions 
      WHERE created_at >= ? 
        AND status = 'completed'
      GROUP BY DATE(created_at/1000, 'unixepoch')
      ORDER BY sale_date ASC
    ''', [thirtyDaysAgo]);
    
    if (revenueData.isEmpty) {
    return BusinessForecast(
      predictedRevenue: 0.0,
      confidence: 0.0,
      trend: 0.0,
      avgDailyRevenue: 0.0,
      recommendations: ['Tidak ada data historis untuk prediksi'],
    );
    }
    
    // Hitung rata-rata dan trend
    final dailyRevenues = revenueData.map((row) => (row['daily_revenue'] as num).toDouble()).toList();
    final avgDailyRevenue = dailyRevenues.reduce((a, b) => a + b) / dailyRevenues.length;
    
    // Simple trend calculation
    final trend = _calculateRevenueTrend(dailyRevenues);
    
    // Prediksi revenue
    final predictedRevenue = avgDailyRevenue * daysAhead * (1 + trend);
    
    // Confidence berdasarkan konsistensi data
    final confidence = _calculateRevenueConfidence(dailyRevenues);
    
    // Generate recommendations
    final recommendations = _generateForecastRecommendations(
      predictedRevenue: predictedRevenue,
      trend: trend,
      avgDailyRevenue: avgDailyRevenue,
    );
    
    return BusinessForecast(
      predictedRevenue: predictedRevenue,
      confidence: confidence,
      trend: trend,
      avgDailyRevenue: avgDailyRevenue,
      recommendations: recommendations,
    );
  }

  // Helper methods
  Future<WeeklyTrend> _analyzeWeeklyTrend() async {
    final db = await _databaseHelper.database;
    final weekAgo = DateTime.now().subtract(const Duration(days: 7)).millisecondsSinceEpoch;
    
    final weeklyData = await db.rawQuery('''
      SELECT 
        DATE(created_at/1000, 'unixepoch') as sale_date,
        SUM(total) as daily_revenue,
        COUNT(*) as transaction_count
      FROM transactions 
      WHERE created_at >= ? 
        AND status = 'completed'
      GROUP BY DATE(created_at/1000, 'unixepoch')
      ORDER BY sale_date ASC
    ''', [weekAgo]);
    
    if (weeklyData.length < 2) {
      return WeeklyTrend.stable;
    }
    
    final revenues = weeklyData.map((row) => (row['daily_revenue'] as num).toDouble()).toList();
    final trend = _calculateRevenueTrend(revenues);
    
    if (trend > 0.1) return WeeklyTrend.increasing;
    if (trend < -0.1) return WeeklyTrend.decreasing;
    return WeeklyTrend.stable;
  }

  Future<List<ActionRecommendation>> _generateActionRecommendations({
    required Map<String, Object?> todaySales,
    required int lowStockCount,
    required WeeklyTrend weeklyTrend,
  }) async {
    final recommendations = <ActionRecommendation>[];
    
    final transactionCount = todaySales['transaction_count'] as int;
    // final totalRevenue = (todaySales['total_revenue'] as num?)?.toDouble() ?? 0.0; // unused variable
    
    if (transactionCount == 0) {
      recommendations.add(ActionRecommendation(
        type: ActionType.promotion,
        title: 'Lakukan Promosi',
        description: 'Belum ada transaksi hari ini',
        priority: Priority.high,
      ));
    }
    
    if (lowStockCount > 0) {
      recommendations.add(ActionRecommendation(
        type: ActionType.inventory,
        title: 'Restock Segera',
        description: '$lowStockCount produk stok rendah',
        priority: Priority.high,
      ));
    }
    
    if (weeklyTrend == WeeklyTrend.decreasing) {
      recommendations.add(ActionRecommendation(
        type: ActionType.marketing,
        title: 'Evaluasi Strategi',
        description: 'Penjualan menurun minggu ini',
        priority: Priority.medium,
      ));
    }
    
    return recommendations;
  }

  Future<int> _getLowStockCount() async {
    final db = await _databaseHelper.database;
    final result = await db.rawQuery('''
      SELECT COUNT(*) as count
      FROM products p
      LEFT JOIN inventory i ON p.id = i.product_id
      WHERE p.is_active = 1
      GROUP BY p.id, p.min_stock
      HAVING SUM(i.quantity) <= p.min_stock
    ''');
    
    return result.length;
  }

  double _calculateRevenueTrend(List<double> revenues) {
    if (revenues.length < 2) return 0.0;
    
    final n = revenues.length;
    final x = List.generate(n, (i) => i.toDouble());
    final y = revenues;
    
    final sumX = x.reduce((a, b) => a + b);
    final sumY = y.reduce((a, b) => a + b);
    final sumXY = x.asMap().entries.map((e) => e.value * y[e.key]).reduce((a, b) => a + b);
    final sumXX = x.map((xi) => xi * xi).reduce((a, b) => a + b);
    
    final slope = (n * sumXY - sumX * sumY) / (n * sumXX - sumX * sumX);
    return slope / (sumY / n);
  }

  double _calculateRevenueConfidence(List<double> revenues) {
    if (revenues.length < 2) return 0.0;
    
    final mean = revenues.reduce((a, b) => a + b) / revenues.length;
    final variance = revenues.map((r) => (r - mean) * (r - mean)).reduce((a, b) => a + b) / revenues.length;
    final stdDev = sqrt(variance);
    
    final coefficient = stdDev / mean;
    return (1.0 - coefficient.clamp(0.0, 1.0));
  }

  List<String> _generateForecastRecommendations({
    required double predictedRevenue,
    required double trend,
    required double avgDailyRevenue,
  }) {
    final recommendations = <String>[];
    
    if (trend > 0.1) {
      recommendations.add('📈 Trend positif! Pertimbangkan ekspansi atau penambahan stok.');
    } else if (trend < -0.1) {
      recommendations.add('📉 Trend menurun. Evaluasi strategi pemasaran dan harga.');
    }
    
    if (predictedRevenue > avgDailyRevenue * 30 * 1.2) {
      recommendations.add('💰 Prediksi revenue tinggi. Siapkan kapasitas operasional.');
    }
    
    return recommendations;
  }
}

// Data Models
class WarungInsight {
  final DateTime date;
  final TodaySales todaySales;
  final List<TopProductToday> topProducts;
  final List<LowStockItem> lowStockItems;
  final WeeklyTrend weeklyTrend;
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
      todaySales: TodaySales.fromJson(json['today_sales'] as Map<String, dynamic>),
      topProducts: ((json['top_products'] as List<dynamic>)
              .map((e) => TopProductToday.fromJson(e as Map<String, dynamic>))
              .toList()),
      lowStockItems: ((json['low_stock_items'] as List<dynamic>)
              .map((e) => LowStockItem.fromJson(e as Map<String, dynamic>))
              .toList()),
      weeklyTrend: _weeklyTrendFromString(json['weekly_trend'] as String?),
      recommendations: ((json['recommendations'] as List<dynamic>)
              .map((e) => ActionRecommendation.fromJson(e as Map<String, dynamic>))
              .toList()),
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'today_sales': todaySales.toJson(),
      'top_products': topProducts.map((e) => e.toJson()).toList(),
      'low_stock_items': lowStockItems.map((e) => e.toJson()).toList(),
      'weekly_trend': weeklyTrend.name,
      'recommendations': recommendations.map((e) => e.toJson()).toList(),
    };
  }
}

class BusinessPerformance {
  final List<DailyRevenue> revenueTrend;
  final List<CategoryPerformance> categoryPerformance;
  final MarginAnalysis marginAnalysis;

  BusinessPerformance({
    required this.revenueTrend,
    required this.categoryPerformance,
    required this.marginAnalysis,
  });

  factory BusinessPerformance.fromJson(Map<String, dynamic> json) {
    return BusinessPerformance(
      revenueTrend: ((json['revenue_trend'] as List<dynamic>)
              .map((e) => DailyRevenue.fromJson(e as Map<String, dynamic>))
              .toList()),
      categoryPerformance: ((json['category_performance'] as List<dynamic>)
              .map((e) => CategoryPerformance.fromJson(e as Map<String, dynamic>))
              .toList()),
      marginAnalysis: MarginAnalysis.fromJson(json['margin_analysis'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'revenue_trend': revenueTrend.map((e) => e.toJson()).toList(),
      'category_performance': categoryPerformance.map((e) => e.toJson()).toList(),
      'margin_analysis': marginAnalysis.toJson(),
    };
  }
}

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
      recommendations: (json['recommendations'] as List<dynamic>).cast<String>(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'predicted_revenue': predictedRevenue,
      'confidence': confidence,
      'trend': trend,
      'avg_daily_revenue': avgDailyRevenue,
      'recommendations': recommendations,
    };
  }
}

class BusinessRecommendation {
  final RecommendationType type;
  final Priority priority;
  final String title;
  final String description;
  final String action;
  final String impact;

  BusinessRecommendation({
    required this.type,
    required this.priority,
    required this.title,
    required this.description,
    required this.action,
    required this.impact,
  });

  factory BusinessRecommendation.fromJson(Map<String, dynamic> json) {
    return BusinessRecommendation(
      type: _recommendationTypeFromString(json['type'] as String?),
      priority: _priorityFromString(json['priority'] as String?),
      title: json['title'] as String,
      description: json['description'] as String,
      action: json['action'] as String,
      impact: json['impact'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type.name,
      'priority': priority.name,
      'title': title,
      'description': description,
      'action': action,
      'impact': impact,
    };
  }
}

class ActionRecommendation {
  final ActionType type;
  final String title;
  final String description;
  final Priority priority;

  ActionRecommendation({
    required this.type,
    required this.title,
    required this.description,
    required this.priority,
  });

  factory ActionRecommendation.fromJson(Map<String, dynamic> json) {
    return ActionRecommendation(
      type: _actionTypeFromString(json['type'] as String?),
      title: json['title'] as String,
      description: json['description'] as String,
      priority: _priorityFromString(json['priority'] as String?),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type.name,
      'title': title,
      'description': description,
      'priority': priority.name,
    };
  }
}

// Supporting classes
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
      transactionCount: (json['transaction_count'] as num).toInt(),
      totalRevenue: (json['total_revenue'] as num).toDouble(),
      avgTransactionValue: (json['avg_transaction_value'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'transaction_count': transactionCount,
      'total_revenue': totalRevenue,
      'avg_transaction_value': avgTransactionValue,
    };
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
      quantitySold: (json['quantity_sold'] as num).toInt(),
      revenue: (json['revenue'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'product_id': productId,
      'product_name': productName,
      'quantity_sold': quantitySold,
      'revenue': revenue,
    };
  }
}

class LowStockItem {
  final String productId;
  final String productName;
  final int currentStock;
  final int minStock;

  LowStockItem({
    required this.productId,
    required this.productName,
    required this.currentStock,
    required this.minStock,
  });

  factory LowStockItem.fromJson(Map<String, dynamic> json) {
    return LowStockItem(
      productId: json['product_id'] as String,
      productName: json['product_name'] as String,
      currentStock: (json['current_stock'] as num).toInt(),
      minStock: (json['min_stock'] as num).toInt(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'product_id': productId,
      'product_name': productName,
      'current_stock': currentStock,
      'min_stock': minStock,
    };
  }
}

class DailyRevenue {
  final DateTime date;
  final double revenue;
  final int transactionCount;

  DailyRevenue({
    required this.date,
    required this.revenue,
    required this.transactionCount,
  });

  factory DailyRevenue.fromJson(Map<String, dynamic> json) {
    return DailyRevenue(
      date: DateTime.parse(json['date'] as String),
      revenue: (json['revenue'] as num).toDouble(),
      transactionCount: (json['transaction_count'] as num).toInt(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'revenue': revenue,
      'transaction_count': transactionCount,
    };
  }
}

class CategoryPerformance {
  final String? categoryId;
  final String categoryName;
  final double revenue;
  final int quantitySold;
  final int productCount;

  CategoryPerformance({
    required this.categoryId,
    required this.categoryName,
    required this.revenue,
    required this.quantitySold,
    required this.productCount,
  });

  factory CategoryPerformance.fromJson(Map<String, dynamic> json) {
    return CategoryPerformance(
      categoryId: json['category_id'] as String?,
      categoryName: json['category_name'] as String,
      revenue: (json['revenue'] as num).toDouble(),
      quantitySold: (json['quantity_sold'] as num).toInt(),
      productCount: (json['product_count'] as num).toInt(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'category_id': categoryId,
      'category_name': categoryName,
      'revenue': revenue,
      'quantity_sold': quantitySold,
      'product_count': productCount,
    };
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

  Map<String, dynamic> toJson() {
    return {
      'avg_margin': avgMargin,
      'min_margin': minMargin,
      'max_margin': maxMargin,
    };
  }
}

// Enums
enum WeeklyTrend { increasing, decreasing, stable }
enum RecommendationType { pricing, inventory, product, category, marketing }
enum ActionType { promotion, inventory, marketing, pricing }
enum Priority { low, medium, high }

WeeklyTrend _weeklyTrendFromString(String? value) {
  switch (value) {
    case 'increasing':
      return WeeklyTrend.increasing;
    case 'decreasing':
      return WeeklyTrend.decreasing;
    case 'stable':
    default:
      return WeeklyTrend.stable;
  }
}

RecommendationType _recommendationTypeFromString(String? value) {
  switch (value) {
    case 'pricing':
      return RecommendationType.pricing;
    case 'inventory':
      return RecommendationType.inventory;
    case 'product':
      return RecommendationType.product;
    case 'category':
      return RecommendationType.category;
    case 'marketing':
    default:
      return RecommendationType.marketing;
  }
}

ActionType _actionTypeFromString(String? value) {
  switch (value) {
    case 'promotion':
      return ActionType.promotion;
    case 'inventory':
      return ActionType.inventory;
    case 'pricing':
      return ActionType.pricing;
    case 'marketing':
    default:
      return ActionType.marketing;
  }
}

Priority _priorityFromString(String? value) {
  switch (value) {
    case 'high':
      return Priority.high;
    case 'medium':
      return Priority.medium;
    case 'low':
    default:
      return Priority.low;
  }
}
