import 'package:pos/core/errors/failures.dart';
import 'package:pos/shared/models/entities/entities.dart';
import 'package:pos/features/inventory/domain/repositories/stock_movement_repository.dart';
import 'package:dartz/dartz.dart';

class GetStockMovements {
  final StockMovementRepository repository;

  GetStockMovements(this.repository);

  Future<Either<Failure, List<StockMovement>>> call(GetStockMovementsParams params) async {
    try {
      final movements = await repository.getStockMovements(
        productId: params.productId,
        locationId: params.locationId,
        type: params.type,
        startDate: params.startDate,
        endDate: params.endDate,
        page: params.page,
        limit: params.limit,
      );
      return movements;
    } catch (e) {
      return Left(DatabaseFailure(message: e.toString()));
    }
  }
}

class GetStockMovementsParams {
  final String productId;
  final String? locationId;
  final StockMovementType? type;
  final DateTime? startDate;
  final DateTime? endDate;
  final int page;
  final int limit;

  GetStockMovementsParams({
    required this.productId,
    this.locationId,
    this.type,
    this.startDate,
    this.endDate,
    this.page = 1,
    this.limit = 50,
  });
}
