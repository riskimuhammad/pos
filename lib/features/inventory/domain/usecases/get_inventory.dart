import 'package:pos/core/errors/failures.dart';
import 'package:pos/shared/models/entities/entities.dart';
import 'package:pos/features/inventory/domain/repositories/inventory_repository.dart';
import 'package:dartz/dartz.dart';

class GetInventory {
  final InventoryRepository repository;

  GetInventory(this.repository);

  Future<Either<Failure, List<Inventory>>> call(GetInventoryParams params) async {
    try {
      final inventory = await repository.getInventory(
        tenantId: params.tenantId,
        locationId: params.locationId,
        search: params.search,
        page: params.page,
        limit: params.limit,
      );
      return inventory;
    } catch (e) {
      return Left(DatabaseFailure(message: e.toString()));
    }
  }
}

class GetInventoryParams {
  final String tenantId;
  final String? locationId;
  final String? search;
  final int page;
  final int limit;

  GetInventoryParams({
    required this.tenantId,
    this.locationId,
    this.search,
    this.page = 1,
    this.limit = 50,
  });
}
