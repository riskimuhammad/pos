import 'package:dio/dio.dart';
import 'package:pos/core/ai/sales_predictor.dart';
import 'package:pos/core/ai/price_recommender.dart';
import 'package:pos/core/ai/warung_assistant.dart';

class AIApiService {
  final Dio _dio;

  AIApiService({required Dio dio}) : _dio = dio;

  Future<SalesPrediction> getSalesPrediction({
    required String productId,
    int daysAhead = 7,
  }) async {
    final response = await _dio.get(
      '/api/ai/sales-prediction/$productId',
      queryParameters: {'days': daysAhead},
    );
    return SalesPrediction.fromJson(response.data as Map<String, dynamic>);
  }

  Future<List<TopProduct>> getTopProducts({int limit = 10, int daysBack = 30}) async {
    final response = await _dio.get(
      '/api/ai/top-products',
      queryParameters: {'limit': limit, 'days': daysBack},
    );
    final list = response.data as List<dynamic>;
    return list.map((e) => TopProduct.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<List<TopCategory>> getTopCategories({int limit = 5, int daysBack = 30}) async {
    final response = await _dio.get(
      '/api/ai/top-categories',
      queryParameters: {'limit': limit, 'days': daysBack},
    );
    final list = response.data as List<dynamic>;
    return list.map((e) => TopCategory.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<PriceRecommendation> getPriceRecommendation({
    required String productId,
    double? competitorPrice,
    double? targetMargin,
  }) async {
    final response = await _dio.post(
      '/api/ai/price-recommendation',
      data: {
        'product_id': productId,
        if (competitorPrice != null) 'competitor_price': competitorPrice,
        if (targetMargin != null) 'target_margin': targetMargin,
      },
    );
    return PriceRecommendation.fromJson(response.data as Map<String, dynamic>);
  }

  Future<List<PriceReviewItem>> getPriceReviewItems() async {
    final response = await _dio.get('/api/ai/price-review-items');
    final list = response.data as List<dynamic>;
    return list.map((e) => PriceReviewItem.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<List<ProductRecommendation>> getProductRecommendations({int limit = 10}) async {
    final response = await _dio.get(
      '/api/ai/product-recommendations',
      queryParameters: {'limit': limit},
    );
    final list = response.data as List<dynamic>;
    return list.map((e) => ProductRecommendation.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<WarungInsight> getDailyInsight() async {
    final response = await _dio.get('/api/ai/daily-insight');
    return WarungInsight.fromJson(response.data as Map<String, dynamic>);
  }

  Future<BusinessPerformance> getBusinessPerformance({int daysBack = 30}) async {
    final response = await _dio.get(
      '/api/ai/business-performance',
      queryParameters: {'days': daysBack},
    );
    return BusinessPerformance.fromJson(response.data as Map<String, dynamic>);
  }

  Future<BusinessForecast> getBusinessForecast({int daysAhead = 30}) async {
    final response = await _dio.get(
      '/api/ai/business-forecast',
      queryParameters: {'days': daysAhead},
    );
    return BusinessForecast.fromJson(response.data as Map<String, dynamic>);
  }

  Future<List<BusinessRecommendation>> getBusinessRecommendations() async {
    final response = await _dio.get('/api/ai/business-recommendations');
    final list = response.data as List<dynamic>;
    return list.map((e) => BusinessRecommendation.fromJson(e as Map<String, dynamic>)).toList();
  }
}


