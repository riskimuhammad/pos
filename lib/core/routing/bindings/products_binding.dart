import 'package:get/get.dart';
import 'package:pos/features/products/presentation/controllers/product_controller.dart';
import 'package:pos/features/products/domain/usecases/get_products.dart';
import 'package:pos/features/products/domain/usecases/create_product.dart';
import 'package:pos/features/products/domain/usecases/update_product.dart';
import 'package:pos/features/products/domain/usecases/search_products.dart';
import 'package:pos/features/products/data/repositories/product_repository_impl.dart';
import 'package:pos/core/sync/product_sync_service.dart';
import 'package:pos/core/data/database_seeder.dart';
import 'package:pos/core/storage/database_helper.dart';
import 'package:pos/core/api/product_api_service.dart';
import 'package:pos/core/api/unit_api_service.dart';
import 'package:pos/core/api/category_api_service.dart';
import 'package:pos/core/repositories/unit_repository.dart';
import 'package:pos/core/repositories/unit_repository_impl.dart';
import 'package:pos/core/repositories/category_repository.dart';
import 'package:pos/core/repositories/category_repository_impl.dart';
import 'package:pos/core/usecases/unit_usecases.dart';
import 'package:pos/core/usecases/category_usecases.dart';
import 'package:pos/core/controllers/unit_controller.dart';
import 'package:pos/core/controllers/category_controller.dart';

import '../../network/network_info.dart';
import '../../storage/local_datasource.dart';

class ProductsBinding extends Bindings {
  @override
  void dependencies() {
    // Ensure dependencies are available, create if not found
    Get.lazyPut<DatabaseHelper>(() => DatabaseHelper());
    Get.lazyPut<LocalDataSource>(() => LocalDataSourceImpl(Get.find<DatabaseHelper>()));
    Get.lazyPut<ProductRepository>(() => ProductRepositoryImpl(
      networkInfo: Get.find<NetworkInfo>(),
      localDataSource: Get.find<LocalDataSource>(),
    ));
    if (!Get.isRegistered<GetProducts>()) {
      Get.lazyPut<GetProducts>(() => GetProducts(Get.find<ProductRepository>()));
    }
    if (!Get.isRegistered<CreateProduct>()) {
      Get.lazyPut<CreateProduct>(() => CreateProduct(Get.find<ProductRepository>()));
    }
    if (!Get.isRegistered<UpdateProduct>()) {
      Get.lazyPut<UpdateProduct>(() => UpdateProduct(Get.find<ProductRepository>()));
    }
    if (!Get.isRegistered<SearchProducts>()) {
      Get.lazyPut<SearchProducts>(() => SearchProducts(Get.find<ProductRepository>()));
    }
            if (!Get.isRegistered<ProductSyncService>()) {
              Get.lazyPut<ProductSyncService>(() => ProductSyncService(
                databaseHelper: Get.find<DatabaseHelper>(),
                databaseSeeder: Get.find<DatabaseSeeder>(),
                networkInfo: Get.find<NetworkInfo>(),
                productApiService: Get.isRegistered<ProductApiService>() ? Get.find<ProductApiService>() : null,
              ));
            }
    if (!Get.isRegistered<DatabaseSeeder>()) {
      Get.lazyPut<DatabaseSeeder>(() => DatabaseSeeder(Get.find<DatabaseHelper>()));
    }
    
    // Unit dependencies
    if (!Get.isRegistered<UnitRepository>()) {
      Get.lazyPut<UnitRepository>(() => UnitRepositoryImpl(
        localDataSource: Get.find<LocalDataSource>(),
        unitApiService: Get.isRegistered<UnitApiService>() ? Get.find<UnitApiService>() : null,
        networkInfo: Get.find<NetworkInfo>(),
      ));
    }
    
    // Category dependencies
    if (!Get.isRegistered<CategoryRepository>()) {
      Get.lazyPut<CategoryRepository>(() => CategoryRepositoryImpl(
        localDataSource: Get.find<LocalDataSource>(),
        categoryApiService: Get.isRegistered<CategoryApiService>() ? Get.find<CategoryApiService>() : null,
        networkInfo: Get.find<NetworkInfo>(),
      ));
    }
    
    if (!Get.isRegistered<GetUnitsUseCase>()) {
      Get.lazyPut<GetUnitsUseCase>(() => GetUnitsUseCase(Get.find<UnitRepository>()));
    }
    if (!Get.isRegistered<CreateUnitUseCase>()) {
      Get.lazyPut<CreateUnitUseCase>(() => CreateUnitUseCase(Get.find<UnitRepository>()));
    }
    if (!Get.isRegistered<UpdateUnitUseCase>()) {
      Get.lazyPut<UpdateUnitUseCase>(() => UpdateUnitUseCase(Get.find<UnitRepository>()));
    }
    if (!Get.isRegistered<DeleteUnitUseCase>()) {
      Get.lazyPut<DeleteUnitUseCase>(() => DeleteUnitUseCase(Get.find<UnitRepository>()));
    }
    if (!Get.isRegistered<SearchUnitsUseCase>()) {
      Get.lazyPut<SearchUnitsUseCase>(() => SearchUnitsUseCase(Get.find<UnitRepository>()));
    }
    
    // Category use cases
    if (!Get.isRegistered<GetCategoriesUseCase>()) {
      Get.lazyPut<GetCategoriesUseCase>(() => GetCategoriesUseCase(Get.find<CategoryRepository>()));
    }
    if (!Get.isRegistered<CreateCategoryUseCase>()) {
      Get.lazyPut<CreateCategoryUseCase>(() => CreateCategoryUseCase(Get.find<CategoryRepository>()));
    }
    if (!Get.isRegistered<UpdateCategoryUseCase>()) {
      Get.lazyPut<UpdateCategoryUseCase>(() => UpdateCategoryUseCase(Get.find<CategoryRepository>()));
    }
    if (!Get.isRegistered<DeleteCategoryUseCase>()) {
      Get.lazyPut<DeleteCategoryUseCase>(() => DeleteCategoryUseCase(Get.find<CategoryRepository>()));
    }
    if (!Get.isRegistered<SearchCategoriesUseCase>()) {
      Get.lazyPut<SearchCategoriesUseCase>(() => SearchCategoriesUseCase(Get.find<CategoryRepository>()));
    }
    
    if (!Get.isRegistered<UnitController>()) {
      Get.put<UnitController>(UnitController(
        getUnitsUseCase: Get.find<GetUnitsUseCase>(),
        createUnitUseCase: Get.find<CreateUnitUseCase>(),
        updateUnitUseCase: Get.find<UpdateUnitUseCase>(),
        deleteUnitUseCase: Get.find<DeleteUnitUseCase>(),
        searchUnitsUseCase: Get.find<SearchUnitsUseCase>(),
      ));
    }
    
    if (!Get.isRegistered<CategoryController>()) {
      Get.put<CategoryController>(CategoryController(
        getCategoriesUseCase: Get.find<GetCategoriesUseCase>(),
        createCategoryUseCase: Get.find<CreateCategoryUseCase>(),
        updateCategoryUseCase: Get.find<UpdateCategoryUseCase>(),
        deleteCategoryUseCase: Get.find<DeleteCategoryUseCase>(),
        searchCategoriesUseCase: Get.find<SearchCategoriesUseCase>(),
      ));
    }

    Get.lazyPut<ProductController>(() => ProductController(
      getProducts: Get.find<GetProducts>(),
      createProduct: Get.find<CreateProduct>(),
      updateProduct: Get.find<UpdateProduct>(),
      searchProducts: Get.find<SearchProducts>(),
      productSyncService: Get.find<ProductSyncService>(),
      databaseSeeder: Get.find<DatabaseSeeder>(),
      localDataSource: Get.find<LocalDataSource>(),
    ));
  }
}
