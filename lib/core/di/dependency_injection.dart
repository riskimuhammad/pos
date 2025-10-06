import 'package:get/get.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:get_storage/get_storage.dart';
import 'package:pos/core/network/network_info.dart';
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

class DependencyInjection {
  static Future<void> init() async {
    // Core dependencies
    Get.lazyPut<Connectivity>(() => Connectivity());
    Get.lazyPut<NetworkInfo>(() => NetworkInfoImpl(connectivity: Get.find<Connectivity>()));
    Get.lazyPut<DatabaseHelper>(() => DatabaseHelper());
    Get.lazyPut<LocalDataSource>(() => LocalDataSourceImpl(Get.find<DatabaseHelper>()));
    
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
      useMockData: true, // Set to false when API is ready
    ));

    // Auth use cases
    Get.lazyPut<LoginUseCase>(() => LoginUseCase(Get.find<AuthRepository>()));
    Get.lazyPut<LogoutUseCase>(() => LogoutUseCase(Get.find<AuthRepository>()));
    Get.lazyPut<CheckSessionUseCase>(() => CheckSessionUseCase(Get.find<AuthRepository>()));
    Get.lazyPut<HasValidSessionUseCase>(() => HasValidSessionUseCase(Get.find<AuthRepository>()));

    // Auth controller
    Get.lazyPut<AuthController>(() => AuthController(
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
  }
}
