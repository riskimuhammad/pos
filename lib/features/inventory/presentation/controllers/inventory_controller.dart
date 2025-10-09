import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pos/core/errors/failures.dart';
import 'package:pos/shared/models/entities/entities.dart';
import 'package:pos/features/inventory/domain/usecases/get_inventory.dart';
import 'package:pos/features/inventory/domain/usecases/create_stock_movement.dart';
import 'package:pos/features/inventory/domain/usecases/get_stock_movements.dart';
import 'package:pos/features/inventory/domain/usecases/get_locations.dart';
import 'package:pos/features/inventory/domain/usecases/get_low_stock_products.dart';
import 'package:pos/core/theme/app_theme.dart';

class InventoryController extends GetxController {
  final GetInventory getInventory;
  final CreateStockMovement createStockMovement;
  final GetStockMovements getStockMovements;
  final GetLocations getLocations;
  final GetLowStockProducts getLowStockProducts;

  InventoryController({
    required this.getInventory,
    required this.createStockMovement,
    required this.getStockMovements,
    required this.getLocations,
    required this.getLowStockProducts,
  });

  // Observable variables
  final RxList<Inventory> inventoryItems = <Inventory>[].obs;
  final RxList<StockMovement> stockMovements = <StockMovement>[].obs;
  final RxList<Location> locations = <Location>[].obs;
  final RxBool isLoading = false.obs;
  final RxString selectedLocationId = ''.obs;
  final RxString searchQuery = ''.obs;
  final RxString errorMessage = ''.obs;

  // Getters
  List<Inventory> get filteredInventory => _applyFilters();
  int get totalProducts => inventoryItems.length;
  int get lowStockCount => inventoryItems.where((item) => item.isLowStock).length;
  int get outOfStockCount => inventoryItems.where((item) => item.isOutOfStock).length;
  double get totalInventoryValue => _calculateTotalValue();

  @override
  void onInit() {
    super.onInit();
    loadInventory();
    loadLocations();
  }

  Future<void> loadInventory() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      
      final result = await getInventory(GetInventoryParams(
        tenantId: 'default-tenant-id', // Will be replaced with user session
        locationId: selectedLocationId.value.isEmpty ? null : selectedLocationId.value,
      ));
      
      result.fold(
        (failure) => _handleFailure(failure),
        (inventory) => inventoryItems.assignAll(inventory),
      );
    } catch (e) {
      errorMessage.value = 'Failed to load inventory: $e';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadLocations() async {
    try {
      final result = await getLocations(GetLocationsParams(
        tenantId: 'default-tenant-id', // Will be replaced with user session
      ));
      
      result.fold(
        (failure) => _handleFailure(failure),
        (locationList) => locations.assignAll(locationList),
      );
    } catch (e) {
      errorMessage.value = 'Failed to load locations: $e';
    }
  }

  Future<void> loadStockMovements(String productId) async {
    try {
      final result = await getStockMovements(GetStockMovementsParams(
        productId: productId,
        limit: 50,
      ));
      
      result.fold(
        (failure) => _handleFailure(failure),
        (movements) => stockMovements.value = movements,
      );
    } catch (e) {
      errorMessage.value = 'Failed to load stock movements: $e';
    }
  }

  Future<void> performStockAdjustment({
    required String productId,
    required String locationId,
    required int physicalCount,
    required String reason,
    String? notes,
  }) async {
    try {
      isLoading.value = true;
      
      // Get current stock
      final currentStock = await _getCurrentStock(productId, locationId);
      final adjustment = physicalCount - currentStock;
      
      // Create stock movement
      final stockMovement = StockMovement(
        id: 'sm_${DateTime.now().millisecondsSinceEpoch}',
        tenantId: 'default-tenant-id',
        productId: productId,
        locationId: locationId,
        type: StockMovementType.adjustment,
        quantity: adjustment,
        notes: 'Stock adjustment: $reason. ${notes ?? ''}',
        userId: 'current-user-id',
        createdAt: DateTime.now(),
      );
      
      final result = await createStockMovement(CreateStockMovementParams(
        stockMovement: stockMovement,
      ));
      
      result.fold(
        (failure) => _handleFailure(failure),
        (movement) {
          // Update local inventory list
          _updateInventoryQuantity(productId, locationId, adjustment);
          
          Get.snackbar(
            'Success',
            'Stock adjusted successfully',
            snackPosition: SnackPosition.TOP,
            backgroundColor: AppTheme.successColor,
            colorText: Colors.white,
          );
        },
      );
    } catch (e) {
      errorMessage.value = 'Failed to adjust stock: $e';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> performStockTransfer({
    required String productId,
    required String fromLocationId,
    required String toLocationId,
    required int quantity,
    required String reason,
    String? notes,
  }) async {
    try {
      isLoading.value = true;
      
      // Create outbound movement
      final outboundMovement = StockMovement(
        id: 'sm_out_${DateTime.now().millisecondsSinceEpoch}',
        tenantId: 'default-tenant-id',
        productId: productId,
        locationId: fromLocationId,
        type: StockMovementType.transfer,
        quantity: -quantity, // Negative for outbound
        notes: 'Transfer to $toLocationId: $reason. ${notes ?? ''}',
        userId: 'current-user-id',
        createdAt: DateTime.now(),
      );
      
      // Create inbound movement
      final inboundMovement = StockMovement(
        id: 'sm_in_${DateTime.now().millisecondsSinceEpoch}',
        tenantId: 'default-tenant-id',
        productId: productId,
        locationId: toLocationId,
        type: StockMovementType.transfer,
        quantity: quantity, // Positive for inbound
        notes: 'Transfer from $fromLocationId: $reason. ${notes ?? ''}',
        userId: 'current-user-id',
        createdAt: DateTime.now(),
      );
      
      // Create both movements
      await createStockMovement(CreateStockMovementParams(stockMovement: outboundMovement));
      await createStockMovement(CreateStockMovementParams(stockMovement: inboundMovement));
      
      // Update local inventory quantities
      _updateInventoryQuantity(productId, fromLocationId, -quantity);
      _updateInventoryQuantity(productId, toLocationId, quantity);
      
      Get.snackbar(
        'Success',
        'Stock transferred successfully',
        snackPosition: SnackPosition.TOP,
        backgroundColor: AppTheme.successColor,
        colorText: Colors.white,
      );
    } catch (e) {
      errorMessage.value = 'Failed to transfer stock: $e';
    } finally {
      isLoading.value = false;
    }
  }

  void setLocationFilter(String? locationId) {
    selectedLocationId.value = locationId ?? '';
    _applyFilters();
  }

  void setSearchQuery(String query) {
    searchQuery.value = query;
    _applyFilters();
  }

  List<Inventory> _applyFilters() {
    var filtered = inventoryItems.toList();
    
    // Filter by location
    if (selectedLocationId.value.isNotEmpty) {
      filtered = filtered.where((item) => item.locationId == selectedLocationId.value).toList();
    }
    
    // Filter by search query
    if (searchQuery.value.isNotEmpty) {
      filtered = filtered.where((item) => 
        item.productId.toLowerCase().contains(searchQuery.value.toLowerCase())
      ).toList();
    }
    
    return filtered;
  }

  double _calculateTotalValue() {
    // This would need to be implemented with proper product price lookup
    return inventoryItems.fold(0.0, (sum, item) => sum + (item.quantity * 0.0));
  }

  Future<int> _getCurrentStock(String productId, String locationId) async {
    // This would need to be implemented with proper stock calculation
    return 0;
  }

  void _updateInventoryQuantity(String productId, String locationId, int quantityChange) {
    final index = inventoryItems.indexWhere(
      (item) => item.productId == productId && item.locationId == locationId,
    );
    
    if (index != -1) {
      final currentItem = inventoryItems[index];
      final updatedItem = currentItem.copyWith(
        quantity: currentItem.quantity + quantityChange,
        updatedAt: DateTime.now(),
      );
      inventoryItems[index] = updatedItem;
    }
  }

  void _handleFailure(Failure failure) {
    errorMessage.value = failure.message;
    Get.snackbar(
      'Error',
      failure.message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: AppTheme.errorColor,
      colorText: Colors.white,
    );
  }
}
