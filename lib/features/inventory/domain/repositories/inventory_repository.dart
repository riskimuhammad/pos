import 'package:pos/core/errors/failures.dart';
import 'package:pos/shared/models/entities/entities.dart';
import 'package:dartz/dartz.dart';

abstract class InventoryRepository {
  Future<Either<Failure, List<Inventory>>> getInventory({
    required String tenantId,
    String? locationId,
    String? search,
    int page = 1,
    int limit = 50,
  });
  
  Future<Either<Failure, Inventory?>> getInventoryByProductAndLocation({
    required String productId,
    required String locationId,
  });
  
  Future<Either<Failure, Inventory>> updateInventory(Inventory inventory);
  
  Future<Either<Failure, void>> updateInventoryQuantity({
    required String productId,
    required String locationId,
    required int quantityChange,
  });
  
  Future<Either<Failure, List<Inventory>>> getLowStockInventories({
    required String tenantId,
    String? locationId,
  });
  
  Future<Either<Failure, double>> getInventoryValue({
    required String tenantId,
    String? locationId,
  });
  
  Future<Either<Failure, int>> getCurrentStock({
    required String productId,
    String? locationId,
  });
}
