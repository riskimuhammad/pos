import 'package:pos/core/errors/failures.dart';
import 'package:pos/shared/models/entities/entities.dart';
import 'package:pos/features/inventory/domain/repositories/stock_movement_repository.dart';
import 'package:pos/core/storage/local_datasource.dart';
import 'package:pos/core/network/network_info.dart';
import 'package:pos/core/repositories/base_repository.dart';
import 'package:dartz/dartz.dart';

class StockMovementRepositoryImpl extends BaseRepository implements StockMovementRepository {
  final LocalDataSource localDataSource;

  StockMovementRepositoryImpl({
    required NetworkInfo networkInfo,
    required this.localDataSource,
  }) : super(networkInfo);

  @override
  Future<Either<Failure, StockMovement>> createStockMovement(StockMovement movement) async {
    return await handleDatabaseOperation(() async {
      final createdMovement = await localDataSource.createStockMovement(movement);
      return Right(createdMovement);
    });
  }

  @override
  Future<Either<Failure, List<StockMovement>>> getStockMovements({
    required String productId,
    String? locationId,
    StockMovementType? type,
    DateTime? startDate,
    DateTime? endDate,
    int page = 1,
    int limit = 50,
  }) async {
    return await handleDatabaseOperation(() async {
      if (locationId != null) {
        final movements = await localDataSource.getStockMovementsByLocation(locationId);
        return Right(movements);
      } else {
        final movements = await localDataSource.getStockMovementsByProduct(productId);
        return Right(movements);
      }
    });
  }

  @override
  Future<Either<Failure, List<StockMovement>>> getStockMovementsByDateRange({
    required String tenantId,
    required DateTime startDate,
    required DateTime endDate,
    String? locationId,
  }) async {
    return await handleDatabaseOperation(() async {
      // This would need to be implemented in LocalDataSource
      // For now, return empty list
      return const Right(<StockMovement>[]);
    });
  }

  @override
  Future<Either<Failure, Map<String, int>>> getStockMovementSummary({
    required String productId,
    required String locationId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    return await handleDatabaseOperation(() async {
      final movements = await localDataSource.getStockMovementsByProduct(productId);
      
      int totalIn = 0;
      int totalOut = 0;
      int totalAdjustments = 0;
      
      for (final movement in movements) {
        if (movement.locationId == locationId) {
          switch (movement.type) {
            case StockMovementType.purchase:
            case StockMovementType.return_:
              totalIn += movement.quantity.abs();
              break;
            case StockMovementType.sale:
            case StockMovementType.damage:
            case StockMovementType.expired:
              totalOut += movement.quantity.abs();
              break;
            case StockMovementType.adjustment:
              totalAdjustments += movement.quantity;
              break;
            case StockMovementType.transfer:
              if (movement.quantity > 0) {
                totalIn += movement.quantity;
              } else {
                totalOut += movement.quantity.abs();
              }
              break;
          }
        }
      }
      
      return Right({
        'total_in': totalIn,
        'total_out': totalOut,
        'total_adjustments': totalAdjustments,
      });
    });
  }
}
