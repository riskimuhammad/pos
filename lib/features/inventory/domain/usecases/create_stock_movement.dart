import 'package:pos/core/errors/failures.dart';
import 'package:pos/shared/models/entities/entities.dart';
import 'package:pos/features/inventory/domain/repositories/stock_movement_repository.dart';
import 'package:pos/features/inventory/domain/repositories/inventory_repository.dart';
import 'package:dartz/dartz.dart';

class CreateStockMovement {
  final StockMovementRepository stockMovementRepository;
  final InventoryRepository inventoryRepository;

  CreateStockMovement({
    required this.stockMovementRepository,
    required this.inventoryRepository,
  });

  Future<Either<Failure, StockMovement>> call(CreateStockMovementParams params) async {
    try {
      print('🔍 CreateStockMovement called with: ${params.stockMovement.toJson()}');
      
      // Validate stock movement
      final validation = _validateStockMovement(params.stockMovement);
      if (validation != null) {
        print('❌ Validation failed: $validation');
        return Left(ValidationFailure(message: validation));
      }

      // Create stock movement
      print('🔍 Creating stock movement...');
      final movementResult = await stockMovementRepository.createStockMovement(params.stockMovement);
      
      return movementResult.fold(
        (failure) {
          print('❌ Stock movement creation failed: ${failure.message}');
          return Left(failure);
        },
        (movement) async {
          print('✅ Stock movement created, updating inventory...');
          // Update inventory quantity
          final updateResult = await inventoryRepository.updateInventoryQuantity(
            productId: params.stockMovement.productId,
            locationId: params.stockMovement.locationId,
            quantityChange: params.stockMovement.quantity,
          );
          
          return updateResult.fold(
            (failure) {
              print('❌ Inventory update failed: ${failure.message}');
              return Left(failure);
            },
            (_) {
              print('✅ Stock movement and inventory update completed');
              return Right(movement);
            },
          );
        },
      );
    } catch (e) {
      print('❌ Exception in CreateStockMovement: $e');
      return Left(DatabaseFailure(message: e.toString()));
    }
  }

  String? _validateStockMovement(StockMovement movement) {
    if (movement.quantity == 0) {
      return 'Quantity cannot be zero';
    }
    
    if (movement.type == StockMovementType.sale && movement.quantity > 0) {
      return 'Sale quantity must be negative';
    }
    
    if (movement.type == StockMovementType.purchase && movement.quantity < 0) {
      return 'Purchase quantity must be positive';
    }
    
    return null;
  }
}

class CreateStockMovementParams {
  final StockMovement stockMovement;

  CreateStockMovementParams({required this.stockMovement});
}
