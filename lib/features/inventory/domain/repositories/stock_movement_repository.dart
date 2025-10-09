import 'package:pos/core/errors/failures.dart';
import 'package:pos/shared/models/entities/entities.dart';
import 'package:dartz/dartz.dart';

abstract class StockMovementRepository {
  Future<Either<Failure, StockMovement>> createStockMovement(StockMovement movement);
  
  Future<Either<Failure, List<StockMovement>>> getStockMovements({
    required String productId,
    String? locationId,
    StockMovementType? type,
    DateTime? startDate,
    DateTime? endDate,
    int page = 1,
    int limit = 50,
  });
  
  Future<Either<Failure, List<StockMovement>>> getStockMovementsByDateRange({
    required String tenantId,
    required DateTime startDate,
    required DateTime endDate,
    String? locationId,
  });
  
  Future<Either<Failure, Map<String, int>>> getStockMovementSummary({
    required String productId,
    required String locationId,
    DateTime? startDate,
    DateTime? endDate,
  });
}
