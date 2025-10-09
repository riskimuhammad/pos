import 'package:pos/core/errors/failures.dart';
import 'package:pos/shared/models/entities/entities.dart';
import 'package:pos/features/inventory/domain/repositories/inventory_repository.dart';
import 'package:dartz/dartz.dart';

class GetLowStockProducts {
  final InventoryRepository repository;

  GetLowStockProducts(this.repository);

  Future<Either<Failure, List<Inventory>>> call(GetLowStockProductsParams params) async {
    try {
      final lowStockInventories = await repository.getLowStockInventories(
        tenantId: params.tenantId,
        locationId: params.locationId,
      );
      return lowStockInventories;
    } catch (e) {
      return Left(DatabaseFailure(message: e.toString()));
    }
  }
}

class GetLowStockProductsParams {
  final String tenantId;
  final String? locationId;

  GetLowStockProductsParams({
    required this.tenantId,
    this.locationId,
  });
}
