import 'package:get/get.dart';
import 'package:pos/features/inventory/domain/repositories/inventory_repository.dart';
import 'package:pos/features/inventory/domain/repositories/stock_movement_repository.dart';
import 'package:pos/features/inventory/domain/repositories/location_repository.dart';
import 'package:pos/features/inventory/data/repositories/inventory_repository_impl.dart';
import 'package:pos/features/inventory/data/repositories/stock_movement_repository_impl.dart';
import 'package:pos/features/inventory/data/repositories/location_repository_impl.dart';
import 'package:pos/features/inventory/domain/usecases/get_inventory.dart';
import 'package:pos/features/inventory/domain/usecases/create_stock_movement.dart';
import 'package:pos/features/inventory/domain/usecases/get_stock_movements.dart';
import 'package:pos/features/inventory/domain/usecases/get_locations.dart';
import 'package:pos/features/inventory/domain/usecases/get_low_stock_products.dart';
import 'package:pos/features/inventory/presentation/controllers/inventory_controller.dart';
import 'package:pos/features/products/presentation/controllers/product_controller.dart';
import 'package:pos/features/products/domain/usecases/create_product.dart';
import 'package:pos/features/products/domain/usecases/get_products.dart';
import 'package:pos/features/products/domain/usecases/search_products.dart';
import 'package:pos/features/products/domain/usecases/update_product.dart';
import 'package:pos/features/products/data/repositories/product_repository_impl.dart';
import 'package:pos/core/sync/product_sync_service.dart';
import 'package:pos/core/network/network_info.dart';
import 'package:pos/core/storage/local_datasource.dart';
import 'package:pos/core/api/inventory_api_service.dart';
import 'package:pos/core/api/product_api_service.dart';
import 'package:pos/core/data/database_seeder.dart';
import 'package:dio/dio.dart';

import '../../../../core/storage/database_helper.dart';

class InventoryBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DatabaseHelper>(() => DatabaseHelper());
    Get.lazyPut<LocalDataSource>(
        () => LocalDataSourceImpl(Get.find<DatabaseHelper>()));
    Get.lazyPut<DatabaseSeeder>(
        () => DatabaseSeeder(Get.find<DatabaseHelper>()));
    // API Services
    Get.lazyPut<InventoryApiService>(
      () => InventoryApiServiceImpl(Get.find<Dio>()),
    );
    Get.lazyPut<ProductApiService>(
      () => ProductApiService(dio: Get.find<Dio>()),
    );

    // Repositories
    Get.lazyPut<InventoryRepository>(
      () => InventoryRepositoryImpl(
        networkInfo: Get.find<NetworkInfo>(),
        localDataSource: Get.find<LocalDataSource>(),
        inventoryApiService: Get.find<InventoryApiService>(),
      ),
    );

    Get.lazyPut<StockMovementRepository>(
      () => StockMovementRepositoryImpl(
        networkInfo: Get.find<NetworkInfo>(),
        localDataSource: Get.find<LocalDataSource>(),
      ),
    );

    Get.lazyPut<LocationRepository>(
      () => LocationRepositoryImpl(
        networkInfo: Get.find<NetworkInfo>(),
        localDataSource: Get.find<LocalDataSource>(),
      ),
    );

    // Product Repository
    Get.lazyPut<ProductRepository>(
      () => ProductRepositoryImpl(
        networkInfo: Get.find<NetworkInfo>(),
        localDataSource: Get.find<LocalDataSource>(),
      ),
    );

    // Use Cases
    Get.lazyPut<GetInventory>(
      () => GetInventory(Get.find<InventoryRepository>()),
    );

    Get.lazyPut<CreateStockMovement>(
      () => CreateStockMovement(
        stockMovementRepository: Get.find<StockMovementRepository>(),
        inventoryRepository: Get.find<InventoryRepository>(),
      ),
    );

    Get.lazyPut<GetStockMovements>(
      () => GetStockMovements(Get.find<StockMovementRepository>()),
    );

    Get.lazyPut<GetLocations>(
      () => GetLocations(Get.find<LocationRepository>()),
    );

    Get.lazyPut<GetLowStockProducts>(
      () => GetLowStockProducts(Get.find<InventoryRepository>()),
    );

    // Product Use Cases
    Get.lazyPut<CreateProduct>(
        () => CreateProduct(Get.find<ProductRepository>()));
    Get.lazyPut<GetProducts>(() => GetProducts(Get.find<ProductRepository>()));
    Get.lazyPut<SearchProducts>(
        () => SearchProducts(Get.find<ProductRepository>()));
    Get.lazyPut<UpdateProduct>(
        () => UpdateProduct(Get.find<ProductRepository>()));

    // Product Sync Service
    Get.lazyPut<ProductSyncService>(
      () => ProductSyncService(
        databaseHelper: Get.find<DatabaseHelper>(),
        databaseSeeder: Get.find<DatabaseSeeder>(),
        networkInfo: Get.find<NetworkInfo>(),
        productApiService: Get.find<ProductApiService>(),
      ),
    );

    // Controllers
    Get.lazyPut<InventoryController>(
      () => InventoryController(
        getInventory: Get.find<GetInventory>(),
        createStockMovement: Get.find<CreateStockMovement>(),
        getStockMovements: Get.find<GetStockMovements>(),
        getLocations: Get.find<GetLocations>(),
        getLowStockProducts: Get.find<GetLowStockProducts>(),
      ),
    );
    Get.put<CreateProduct>(CreateProduct(Get.find<ProductRepository>()));
    Get.put<GetProducts>(GetProducts(Get.find<ProductRepository>()));
    Get.put<SearchProducts>(SearchProducts(Get.find<ProductRepository>()));
    Get.put<UpdateProduct>(UpdateProduct(Get.find<ProductRepository>()));
    Get.put<ProductSyncService>(ProductSyncService(
        databaseHelper: Get.find<DatabaseHelper>(),
        databaseSeeder: Get.find<DatabaseSeeder>(),
        networkInfo: Get.find<NetworkInfo>(),
        productApiService: Get.find<ProductApiService>(),
      ));
    Get.lazyPut<ProductController>(
      () => ProductController(
        getInventory: Get.find<GetInventory>(),
        createProduct: Get.find<CreateProduct>(),
        getProducts: Get.find<GetProducts>(),
        searchProducts: Get.find<SearchProducts>(),
        updateProduct: Get.find<UpdateProduct>(),
        productSyncService: Get.find<ProductSyncService>(),
        databaseSeeder: Get.find<DatabaseSeeder>(),
        localDataSource: Get.find<LocalDataSource>(),
      ),
      fenix: true, // Allow recreation when needed
    );
  }
}
