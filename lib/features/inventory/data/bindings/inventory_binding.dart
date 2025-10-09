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
import 'package:pos/core/network/network_info.dart';
import 'package:pos/core/storage/local_datasource.dart';
import 'package:pos/core/api/inventory_api_service.dart';
import 'package:dio/dio.dart';

import '../../../../core/storage/database_helper.dart';

class InventoryBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DatabaseHelper>(() => DatabaseHelper());
    Get.lazyPut<LocalDataSource>(() => LocalDataSourceImpl(Get.find<DatabaseHelper>()));
    // API Services
    Get.lazyPut<InventoryApiService>(
      () => InventoryApiServiceImpl(Get.find<Dio>()),
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

    // Controller
    Get.lazyPut<InventoryController>(
      () => InventoryController(
        getInventory: Get.find<GetInventory>(),
        createStockMovement: Get.find<CreateStockMovement>(),
        getStockMovements: Get.find<GetStockMovements>(),
        getLocations: Get.find<GetLocations>(),
        getLowStockProducts: Get.find<GetLowStockProducts>(),
      ),
    );
  }
}
