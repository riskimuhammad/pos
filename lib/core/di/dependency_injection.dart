import 'package:get/get.dart';
// duplicate removed
import 'package:dio/dio.dart';
import 'package:get_storage/get_storage.dart';
import 'package:pos/core/network/network_info.dart';
import 'package:sqflite_sqlcipher/sqflite.dart';
import 'package:pos/core/storage/database_helper.dart';
import 'package:pos/core/storage/local_datasource.dart';
import 'package:pos/features/auth/data/datasources/auth_local_datasource.dart';
import 'package:pos/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:pos/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:pos/features/auth/domain/usecases/login_usecase.dart';
import 'package:pos/features/auth/domain/usecases/logout_usecase.dart';
import 'package:pos/features/auth/domain/usecases/check_session_usecase.dart';
import 'package:pos/features/auth/presentation/controllers/auth_controller.dart';
import 'package:pos/features/products/data/repositories/product_repository_impl.dart';
import 'package:pos/features/products/domain/usecases/get_products.dart';
import 'package:pos/features/products/domain/usecases/create_product.dart';
import 'package:pos/features/products/domain/usecases/search_products.dart';
import 'package:pos/features/products/presentation/controllers/product_controller.dart';
import 'package:pos/features/pos/presentation/controllers/dashboard_controller.dart';
import 'package:pos/features/ai_scan/presentation/controllers/ai_scan_controller.dart';
import 'package:pos/features/ai_assistant/presentation/controllers/ai_assistant_controller.dart';
import 'package:pos/core/sync/presentation/controllers/sync_controller.dart';
import 'package:pos/core/sync/data/datasources/sync_local_datasource.dart';
import 'package:pos/core/sync/data/datasources/sync_remote_datasource.dart';
import 'package:pos/core/sync/data/repositories/sync_repository_impl.dart';
import 'package:pos/core/sync/domain/repositories/sync_repository.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:pos/core/localization/language_controller.dart';
import 'package:pos/core/ai/model_manager.dart';
import 'package:pos/core/ai/ai_data_service.dart';
// import 'package:pos/core/ai/yolo_detector.dart';
import 'package:pos/core/ai/local_product_detector.dart';
import 'package:pos/core/ai/sales_predictor.dart';
import 'package:pos/core/ai/price_recommender.dart';
import 'package:pos/core/ai/warung_assistant.dart';
// import 'package:pos/core/ai/ai_api_service.dart';

// Global feature toggles (switch to true when backend is ready)
const bool kEnableRemoteApi = false; // affects auth repository data source
const bool kEnableSync = false;      // prepare for switching SyncRemoteDataSource

class DependencyInjection {
  static Future<void> init() async {
    // Core dependencies
    Get.lazyPut<Connectivity>(() => Connectivity());
    Get.lazyPut<NetworkInfo>(() => NetworkInfoImpl(connectivity: Get.find<Connectivity>()));
    Get.lazyPut<DatabaseHelper>(() => DatabaseHelper());
    Get.lazyPut<LocalDataSource>(() => LocalDataSourceImpl(Get.find<DatabaseHelper>()));
    // Register encrypted SQLite Database instance
    final Database dbInstance = await Get.find<DatabaseHelper>().database;
    Get.put<Database>(dbInstance, permanent: true);
    
    // HTTP Client
    Get.lazyPut<Dio>(() => Dio());
    
    // Storage
    Get.lazyPut<GetStorage>(() => GetStorage());

    // Auth dependencies
    Get.lazyPut<AuthLocalDataSource>(() => AuthLocalDataSourceImpl(Get.find<GetStorage>()));
    Get.lazyPut<AuthRemoteDataSource>(() => AuthRemoteDataSourceImpl(Get.find<Dio>()));
    Get.lazyPut<AuthRepository>(() => AuthRepositoryImpl(
      localDataSource: Get.find<AuthLocalDataSource>(),
      remoteDataSource: Get.find<AuthRemoteDataSource>(),
      networkInfo: Get.find<NetworkInfo>(),
      useMockData: !kEnableRemoteApi, // flip to false when API is ready
    ));

    // Auth use cases
    Get.lazyPut<LoginUseCase>(() => LoginUseCase(Get.find<AuthRepository>()));
    Get.lazyPut<LogoutUseCase>(() => LogoutUseCase(Get.find<AuthRepository>()));
    Get.lazyPut<CheckSessionUseCase>(() => CheckSessionUseCase(Get.find<AuthRepository>()));
    Get.lazyPut<HasValidSessionUseCase>(() => HasValidSessionUseCase(Get.find<AuthRepository>()));

    // Auth controller - Use put instead of lazyPut for immediate initialization
    Get.put<AuthController>(AuthController(
      loginUseCase: Get.find<LoginUseCase>(),
      logoutUseCase: Get.find<LogoutUseCase>(),
      checkSessionUseCase: Get.find<CheckSessionUseCase>(),
      hasValidSessionUseCase: Get.find<HasValidSessionUseCase>(),
    ));

    // Repository dependencies
    Get.lazyPut<ProductRepository>(() => ProductRepositoryImpl(
      networkInfo: Get.find<NetworkInfo>(),
      localDataSource: Get.find<LocalDataSource>(),
    ));

    // Use case dependencies
    Get.lazyPut<GetProducts>(() => GetProducts(Get.find<ProductRepository>()));
    Get.lazyPut<CreateProduct>(() => CreateProduct(Get.find<ProductRepository>()));
    Get.lazyPut<SearchProducts>(() => SearchProducts(Get.find<ProductRepository>()));

    // Controller dependencies
    Get.lazyPut<ProductController>(() => ProductController(
      getProducts: Get.find<GetProducts>(),
      createProduct: Get.find<CreateProduct>(),
      searchProducts: Get.find<SearchProducts>(),
    ));

    // Dashboard controller
    Get.lazyPut<DashboardController>(() => DashboardController());

    // AI Scan controller
    Get.lazyPut<AIScanController>(() => AIScanController());
    
    // AI Assistant controller
    Get.lazyPut<AIAssistantController>(() => AIAssistantController());

    // Sync dependencies
    Get.lazyPut<SyncLocalDataSource>(() => SyncLocalDataSourceImpl(database: Get.find<Database>()));
    // When real API is ready, switch this registration based on kEnableSync
    Get.lazyPut<SyncRemoteDataSource>(() => MockSyncRemoteDataSource());
    Get.lazyPut<SyncRepository>(() => SyncRepositoryImpl(
      localDataSource: Get.find(),
      remoteDataSource: Get.find(),
      connectivity: Get.find(),
    ));
    Get.lazyPut<SyncController>(() => SyncController(
      syncRepository: Get.find(),
      connectivity: Get.find(),
    ));

    // AI services
    Get.lazyPut<AIModelManager>(() => AIModelManager(dio: Get.find<Dio>(), storage: Get.find<GetStorage>()));
    Get.lazyPut<AIDataService>(() => AIDataService(database: Get.find<Database>()));
    // YOLO disabled in local-only mode
    Get.lazyPut<LocalProductDetector>(() => LocalProductDetector(
      databaseHelper: Get.find<DatabaseHelper>(),
    ));
    
    // AI Warung Assistant services
    Get.lazyPut<SalesPredictor>(() => SalesPredictor(
      databaseHelper: Get.find<DatabaseHelper>(),
    ));
    Get.lazyPut<PriceRecommender>(() => PriceRecommender(
      databaseHelper: Get.find<DatabaseHelper>(),
    ));
    Get.lazyPut<WarungAssistant>(() => WarungAssistant(
      databaseHelper: Get.find<DatabaseHelper>(),
      salesPredictor: Get.find<SalesPredictor>(),
      priceRecommender: Get.find<PriceRecommender>(),
    ));

    // Language controller
    Get.put<LanguageController>(LanguageController());
  }
}
