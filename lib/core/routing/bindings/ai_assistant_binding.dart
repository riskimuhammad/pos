import 'package:get/get.dart';
import 'package:pos/features/ai_assistant/presentation/controllers/ai_assistant_controller.dart';
import 'package:pos/core/ai/ai_data_service.dart';
import 'package:pos/core/ai/sales_predictor.dart';
import 'package:pos/core/ai/price_recommender.dart';
import 'package:pos/core/ai/warung_assistant.dart';
import 'package:pos/core/storage/database_helper.dart';
import 'package:sqflite_sqlcipher/sqflite.dart';

class AIAssistantBinding extends Bindings {
  @override
  void dependencies() {
    // AI Assistant controller
    Get.lazyPut<AIAssistantController>(() => AIAssistantController());
    
    // AI services (if not already registered globally)
    if (!Get.isRegistered<AIDataService>()) {
      Get.lazyPut<AIDataService>(() => AIDataService(database: Get.find<Database>()));
    }
    
    if (!Get.isRegistered<SalesPredictor>()) {
      Get.lazyPut<SalesPredictor>(() => SalesPredictor(
        databaseHelper: Get.find<DatabaseHelper>(),
      ));
    }
    
    if (!Get.isRegistered<PriceRecommender>()) {
      Get.lazyPut<PriceRecommender>(() => PriceRecommender(
        databaseHelper: Get.find<DatabaseHelper>(),
      ));
    }
    
    if (!Get.isRegistered<WarungAssistant>()) {
      Get.lazyPut<WarungAssistant>(() => WarungAssistant(
        databaseHelper: Get.find<DatabaseHelper>(),
        salesPredictor: Get.find<SalesPredictor>(),
        priceRecommender: Get.find<PriceRecommender>(),
      ));
    }
  }
}
