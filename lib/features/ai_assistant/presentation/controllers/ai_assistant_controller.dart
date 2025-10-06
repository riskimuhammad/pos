import 'package:get/get.dart';
import 'package:pos/core/ai/warung_assistant.dart';
import 'package:pos/core/ai/sales_predictor.dart';
import 'package:pos/core/ai/price_recommender.dart';

class AIAssistantController extends GetxController with GetSingleTickerProviderStateMixin {
  late final WarungAssistant warungAssistant;
  late final SalesPredictor salesPredictor;
  late final PriceRecommender priceRecommender;
  
  // State
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final RxString selectedTab = 'insight'.obs;
  
  // Data
  final Rx<WarungInsight?> dailyInsight = Rx<WarungInsight?>(null);
  final Rx<BusinessPerformance?> businessPerformance = Rx<BusinessPerformance?>(null);
  final Rx<BusinessForecast?> businessForecast = Rx<BusinessForecast?>(null);
  final RxList<BusinessRecommendation> recommendations = <BusinessRecommendation>[].obs;
  final RxList<TopProduct> topProducts = <TopProduct>[].obs;
  final RxList<TopCategory> topCategories = <TopCategory>[].obs;
  final RxList<PriceReviewItem> priceReviewItems = <PriceReviewItem>[].obs;

  @override
  void onInit() {
    super.onInit();
    warungAssistant = Get.find<WarungAssistant>();
    salesPredictor = Get.find<SalesPredictor>();
    priceRecommender = Get.find<PriceRecommender>();
    
    loadDailyInsight();
  }

  // Load daily insight
  Future<void> loadDailyInsight() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      
      final insight = await warungAssistant.getDailyInsight();
      dailyInsight.value = insight;
      
    } catch (e) {
      errorMessage.value = 'Failed to load daily insight: $e';
    } finally {
      isLoading.value = false;
    }
  }

  // Load business performance
  Future<void> loadBusinessPerformance({int daysBack = 30}) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      
      final performance = await warungAssistant.getBusinessPerformance(daysBack: daysBack);
      businessPerformance.value = performance;
      
    } catch (e) {
      errorMessage.value = 'Failed to load business performance: $e';
    } finally {
      isLoading.value = false;
    }
  }

  // Load business forecast
  Future<void> loadBusinessForecast({int daysAhead = 30}) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      
      final forecast = await warungAssistant.getBusinessForecast(daysAhead: daysAhead);
      businessForecast.value = forecast;
      
    } catch (e) {
      errorMessage.value = 'Failed to load business forecast: $e';
    } finally {
      isLoading.value = false;
    }
  }

  // Load recommendations
  Future<void> loadRecommendations() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      
      final recs = await warungAssistant.getBusinessRecommendations();
      recommendations.assignAll(recs);
      
    } catch (e) {
      errorMessage.value = 'Failed to load recommendations: $e';
    } finally {
      isLoading.value = false;
    }
  }

  // Load top products
  Future<void> loadTopProducts({int limit = 10, int daysBack = 30}) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      
      final products = await salesPredictor.getTopProducts(limit: limit, daysBack: daysBack);
      topProducts.assignAll(products);
      
    } catch (e) {
      errorMessage.value = 'Failed to load top products: $e';
    } finally {
      isLoading.value = false;
    }
  }

  // Load top categories
  Future<void> loadTopCategories({int limit = 5, int daysBack = 30}) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      
      final categories = await salesPredictor.getTopCategories(limit: limit, daysBack: daysBack);
      topCategories.assignAll(categories);
      
    } catch (e) {
      errorMessage.value = 'Failed to load top categories: $e';
    } finally {
      isLoading.value = false;
    }
  }

  // Load price review items
  Future<void> loadPriceReviewItems() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      
      final items = await priceRecommender.getProductsNeedingPriceReview();
      priceReviewItems.assignAll(items);
      
    } catch (e) {
      errorMessage.value = 'Failed to load price review items: $e';
    } finally {
      isLoading.value = false;
    }
  }

  // Get price recommendation for specific product
  Future<PriceRecommendation?> getPriceRecommendation(String productId) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      
      final recommendation = await priceRecommender.recommendPrice(productId: productId);
      return recommendation;
      
    } catch (e) {
      errorMessage.value = 'Failed to get price recommendation: $e';
      return null;
    } finally {
      isLoading.value = false;
    }
  }

  // Get sales prediction for specific product
  Future<SalesPrediction?> getSalesPrediction(String productId, {int daysAhead = 7}) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      
      final prediction = await salesPredictor.predictSales(
        productId: productId,
        daysAhead: daysAhead,
      );
      return prediction;
      
    } catch (e) {
      errorMessage.value = 'Failed to get sales prediction: $e';
      return null;
    } finally {
      isLoading.value = false;
    }
  }

  // Get stock prediction for specific product
  Future<StockPrediction?> getStockPrediction(String productId, {int daysAhead = 7}) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      
      final prediction = await salesPredictor.predictStock(
        productId: productId,
        daysAhead: daysAhead,
      );
      return prediction;
      
    } catch (e) {
      errorMessage.value = 'Failed to get stock prediction: $e';
      return null;
    } finally {
      isLoading.value = false;
    }
  }

  // Change tab
  void changeTab(String tab) {
    selectedTab.value = tab;
    
    // Load data based on tab
    switch (tab) {
      case 'insight':
        loadDailyInsight();
        break;
      case 'performance':
        loadBusinessPerformance();
        break;
      case 'forecast':
        loadBusinessForecast();
        break;
      case 'recommendations':
        loadRecommendations();
        break;
      case 'products':
        loadTopProducts();
        loadTopCategories();
        break;
      case 'pricing':
        loadPriceReviewItems();
        break;
    }
  }

  // Refresh all data
  Future<void> refreshAll() async {
    await Future.wait([
      loadDailyInsight(),
      loadBusinessPerformance(),
      loadBusinessForecast(),
      loadRecommendations(),
      loadTopProducts(),
      loadTopCategories(),
      loadPriceReviewItems(),
    ]);
  }

  // Clear error
  void clearError() {
    errorMessage.value = '';
  }
}
