import 'package:pos/core/errors/failures.dart';
import 'package:pos/shared/models/entities/entities.dart';
import 'package:pos/features/inventory/domain/repositories/inventory_repository.dart';
import 'package:pos/core/storage/local_datasource.dart';
import 'package:pos/core/network/network_info.dart';
import 'package:pos/core/repositories/base_repository.dart';
import 'package:pos/core/api/inventory_api_service.dart';
import 'package:pos/core/constants/app_constants.dart';
import 'package:dartz/dartz.dart';

class InventoryRepositoryImpl extends BaseRepository implements InventoryRepository {
  final LocalDataSource localDataSource;
  final InventoryApiService? inventoryApiService;

  InventoryRepositoryImpl({
    required NetworkInfo networkInfo,
    required this.localDataSource,
    this.inventoryApiService,
  }) : super(networkInfo);

  @override
  Future<Either<Failure, List<Inventory>>> getInventory({
    required String tenantId,
    String? locationId,
    String? search,
    int page = 1,
    int limit = 50,
  }) async {
    return await handleOfflineFirstOperation(
      localOperation: () async {
        if (locationId != null) {
          final inventories = await localDataSource.getInventoriesByLocation(locationId);
          return Right(inventories);
        } else {
          // Get all inventories for tenant
          final inventories = <Inventory>[];
          final locations = await localDataSource.getLocationsByTenant(tenantId);
          
          for (final location in locations) {
            final locationInventories = await localDataSource.getInventoriesByLocation(location.id);
            inventories.addAll(locationInventories);
          }
          
          return Right(inventories);
        }
      },
      networkOperation: () async {
        // If API is enabled and online, sync with server
        if (AppConstants.kEnableRemoteApi && 
            inventoryApiService != null && 
            await networkInfo.isConnected) {
          try {
            await syncInventories(tenantId);
            // Return updated local inventories after sync
            if (locationId != null) {
              final inventories = await localDataSource.getInventoriesByLocation(locationId);
              return Right(inventories);
            } else {
              final inventories = <Inventory>[];
              final locations = await localDataSource.getLocationsByTenant(tenantId);
              
              for (final location in locations) {
                final locationInventories = await localDataSource.getInventoriesByLocation(location.id);
                inventories.addAll(locationInventories);
              }
              
              return Right(inventories);
            }
          } catch (e) {
            print('⚠️ Failed to sync inventories, using local data: $e');
            // Fallback to local data
            if (locationId != null) {
              final inventories = await localDataSource.getInventoriesByLocation(locationId);
              return Right(inventories);
            } else {
              final inventories = <Inventory>[];
              final locations = await localDataSource.getLocationsByTenant(tenantId);
              
              for (final location in locations) {
                final locationInventories = await localDataSource.getInventoriesByLocation(location.id);
                inventories.addAll(locationInventories);
              }
              
              return Right(inventories);
            }
          }
        }
        throw Exception('API not available');
      },
    );
  }

  @override
  Future<Either<Failure, Inventory?>> getInventoryByProductAndLocation({
    required String productId,
    required String locationId,
  }) async {
    return await handleDatabaseOperation(() async {
      final inventory = await localDataSource.getInventory(productId, locationId);
      return Right(inventory);
    });
  }

  @override
  Future<Either<Failure, Inventory>> updateInventory(Inventory inventory) async {
    return await handleOfflineFirstOperation(
      localOperation: () async {
        final updatedInventory = await localDataSource.updateInventory(inventory);
        return Right(updatedInventory);
      },
      networkOperation: () async {
        // If API is enabled and online, sync to server
        if (AppConstants.kEnableRemoteApi && 
            inventoryApiService != null && 
            await networkInfo.isConnected) {
          try {
            await inventoryApiService!.updateInventory(inventory);
            print('✅ Inventory updated on server: ${inventory.id}');
          } catch (e) {
            print('⚠️ Failed to update inventory on server: $e');
            // Continue with local update even if server fails
          }
        }
        
        final updatedInventory = await localDataSource.updateInventory(inventory);
        return Right(updatedInventory);
      },
    );
  }

  @override
  Future<Either<Failure, void>> updateInventoryQuantity({
    required String productId,
    required String locationId,
    required int quantityChange,
  }) async {
    return await handleDatabaseOperation(() async {
      final inventory = await localDataSource.getInventory(productId, locationId);
      if (inventory != null) {
        final updatedInventory = inventory.copyWith(
          quantity: inventory.quantity + quantityChange,
          updatedAt: DateTime.now(),
        );
        await localDataSource.updateInventory(updatedInventory);
      }
      return const Right(null);
    });
  }

  @override
  Future<Either<Failure, List<Inventory>>> getLowStockInventories({
    required String tenantId,
    String? locationId,
  }) async {
    return await handleDatabaseOperation(() async {
      final inventories = await localDataSource.getLowStockInventories(tenantId);
      return Right(inventories);
    });
  }

  @override
  Future<Either<Failure, double>> getInventoryValue({
    required String tenantId,
    String? locationId,
  }) async {
    return await handleDatabaseOperation(() async {
      final inventories = await getInventory(
        tenantId: tenantId,
        locationId: locationId,
      );
      
      return inventories.fold(
        (failure) => Left(failure),
        (inventoryList) {
          double totalValue = 0.0;
          for (final inventory in inventoryList) {
            // Get product price from product data
            // This would need to be implemented with proper product lookup
            totalValue += inventory.quantity * 0.0; // Placeholder
          }
          return Right(totalValue);
        },
      );
    });
  }

  @override
  Future<Either<Failure, int>> getCurrentStock({
    required String productId,
    String? locationId,
  }) async {
    return await handleDatabaseOperation(() async {
      final currentStock = await localDataSource.getCurrentStock(productId);
      return Right(currentStock);
    });
  }

  // Sync inventories with server
  Future<void> syncInventories(String tenantId) async {
    if (!AppConstants.kEnableRemoteApi || inventoryApiService == null) {
      print('⚠️ API sync disabled, skipping inventory sync');
      return;
    }

    try {
      // Get inventories from server
      final serverResponse = await inventoryApiService!.getInventoryByLocation(tenantId);
      final serverInventories = (serverResponse['data'] as List)
          .map((json) => Inventory.fromJson(json))
          .toList();
      
      // Get local inventories
      final localInventories = <Inventory>[];
      final locations = await localDataSource.getLocationsByTenant(tenantId);
      
      for (final location in locations) {
        final locationInventories = await localDataSource.getInventoriesByLocation(location.id);
        localInventories.addAll(locationInventories);
      }
      
      // Sync logic: update local with server data
      for (final serverInventory in serverInventories) {
        final localInventory = localInventories.firstWhere(
          (inventory) => inventory.id == serverInventory.id,
          orElse: () => Inventory(
            id: '',
            tenantId: '',
            productId: '',
            locationId: '',
            quantity: 0,
            reserved: 0,
            updatedAt: DateTime.now(),
          ),
        );
        
        if (localInventory.id.isEmpty) {
          // New inventory from server, add to local
          await localDataSource.createInventory(serverInventory);
        } else if (serverInventory.updatedAt.isAfter(localInventory.updatedAt)) {
          // Server has newer version, update local
          await localDataSource.updateInventory(serverInventory);
        }
      }
      
      print('✅ Inventories synced successfully');
    } catch (e) {
      print('❌ Error syncing inventories: $e');
      rethrow;
    }
  }
}
