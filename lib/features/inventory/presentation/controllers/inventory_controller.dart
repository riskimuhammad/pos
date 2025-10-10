import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pos/core/errors/failures.dart';
import 'package:pos/shared/models/entities/entities.dart';
import 'package:pos/features/inventory/domain/usecases/get_inventory.dart';
import 'package:pos/features/inventory/domain/usecases/create_stock_movement.dart';
import 'package:pos/features/inventory/domain/usecases/get_stock_movements.dart';
import 'package:pos/features/inventory/domain/usecases/get_locations.dart';
import 'package:pos/features/inventory/domain/usecases/get_low_stock_products.dart';
import 'package:pos/features/auth/presentation/controllers/auth_controller.dart';
import 'package:pos/core/data/database_seeder.dart';
import 'package:pos/core/storage/local_datasource.dart';
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
  final RxDouble totalInventoryValue = 0.0.obs;
  final RxString errorMessage = ''.obs;

  /// Get current user ID from auth session
  String get _currentUserId {
    try {
      final authController = Get.find<AuthController>();
      final session = authController.currentSession.value;
      if (session != null && session.user.id.isNotEmpty) {
        return session.user.id;
      }
    } catch (e) {
      print('⚠️ AuthController not found, using system user: $e');
    }
    return 'system'; // Fallback to system user
  }

  /// Get current tenant ID from auth session
  String get _currentTenantId {
    try {
      final authController = Get.find<AuthController>();
      final session = authController.currentSession.value;
      if (session != null && session.tenant.id.isNotEmpty) {
        return session.tenant.id;
      }
    } catch (e) {
      print('⚠️ AuthController not found, using default tenant: $e');
    }
    return 'default-tenant-id'; // Fallback to default tenant
  }

  /// Get current tenant name from auth session
  String get _getCurrentTenantName {
    try {
      final authController = Get.find<AuthController>();
      final session = authController.currentSession.value;
      if (session != null && session.tenant.name.isNotEmpty) {
        return session.tenant.name;
      }
    } catch (e) {
      print('⚠️ AuthController not found, using default tenant name: $e');
    }
    return 'Default Tenant'; // Fallback to default tenant name
  }

  /// Get current tenant email from auth session
  String get _getCurrentTenantEmail {
    try {
      final authController = Get.find<AuthController>();
      final session = authController.currentSession.value;
      if (session != null && session.tenant.email != null && session.tenant.email!.isNotEmpty) {
        return session.tenant.email!;
      }
    } catch (e) {
      print('⚠️ AuthController not found, using default tenant email: $e');
    }
    return 'default@tenant.com'; // Fallback to default tenant email
  }

  // Getters
  List<Inventory> get filteredInventory => _applyFilters();
  int get totalProducts => inventoryItems.length;
  int get lowStockCount => _getLowStockItems().length;
  int get outOfStockCount => inventoryItems.where((item) => item.isOutOfStock).length;
  double get totalInventoryValueAmount => totalInventoryValue.value;
  
  // Get low stock items with proper logic
  List<Inventory> _getLowStockItems() {
    return inventoryItems.where((item) {
      // Check if item is out of stock first
      if (item.isOutOfStock) return false;
      
      // For now, use simple threshold until we implement proper product lookup
      // TODO: Implement proper low stock check using product.reorderPoint
      return item.availableQuantity <= 5;
    }).toList();
  }

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
        tenantId: _currentTenantId,
        locationId: selectedLocationId.value.isEmpty ? null : selectedLocationId.value,
      ));
      
      result.fold(
        (failure) => _handleFailure(failure),
        (inventory) {
          inventoryItems.assignAll(inventory);
          // Calculate total inventory value after loading inventory
          _calculateTotalInventoryValue();
        },
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
        tenantId: _currentTenantId,
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
      
      // Ensure tenant, location, and user exist before creating stock movement
      final databaseSeeder = Get.find<DatabaseSeeder>();
      final tenantName = _getCurrentTenantName;
      final tenantEmail = _getCurrentTenantEmail;
      await databaseSeeder.ensureTenantAndLocationExist(
        _currentTenantId, 
        tenantName, 
        tenantEmail
      );
      
      // Ensure current user exists in database
      final currentUserId = _currentUserId;
      final authController = Get.find<AuthController>();
      final session = authController.currentSession.value;
      if (session != null) {
        await databaseSeeder.ensureUserExists(
          currentUserId,
          _currentTenantId,
          session.user.username,
          session.user.email ?? 'user@tenant.com',
          session.user.fullName ?? session.user.username,
          session.user.role,
        );
      }
      
      // Get current stock
      final currentStock = await getCurrentStock(productId, locationId);
      final adjustment = physicalCount - currentStock;
      
      // Create stock movement
      final stockMovement = StockMovement(
        id: 'sm_${DateTime.now().millisecondsSinceEpoch}',
        tenantId: _currentTenantId,
        productId: productId,
        locationId: locationId,
        type: StockMovementType.adjustment,
        quantity: adjustment,
        notes: 'Stock adjustment: $reason. ${notes ?? ''}',
        userId: _currentUserId,
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
        tenantId: _currentTenantId,
        productId: productId,
        locationId: fromLocationId,
        type: StockMovementType.transfer,
        quantity: -quantity, // Negative for outbound
        notes: 'Transfer to $toLocationId: $reason. ${notes ?? ''}',
        userId: _currentUserId,
        createdAt: DateTime.now(),
      );
      
      // Create inbound movement
      final inboundMovement = StockMovement(
        id: 'sm_in_${DateTime.now().millisecondsSinceEpoch}',
        tenantId: _currentTenantId,
        productId: productId,
        locationId: toLocationId,
        type: StockMovementType.transfer,
        quantity: quantity, // Positive for inbound
        notes: 'Transfer from $fromLocationId: $reason. ${notes ?? ''}',
        userId: _currentUserId,
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
    _calculateTotalInventoryValue();
  }


  Future<void> performStockReceiving({
    required String productId,
    required String locationId,
    required int quantity,
    required String referenceId,
    String? notes,
  }) async {
    try {
      isLoading.value = true;
      
      // Create stock movement for receiving
      final stockMovement = StockMovement(
        id: 'sm_${DateTime.now().millisecondsSinceEpoch}',
        tenantId: _currentTenantId,
        productId: productId,
        locationId: locationId,
        type: StockMovementType.purchase,
        quantity: quantity,
        referenceType: 'purchase_order',
        referenceId: referenceId,
        notes: 'Stock receiving from PO: $referenceId. ${notes ?? ''}',
        userId: _currentUserId,
        createdAt: DateTime.now(),
      );
      
      final result = await createStockMovement(CreateStockMovementParams(
        stockMovement: stockMovement,
      ));
      
      result.fold(
        (failure) => _handleFailure(failure),
        (movement) {
          // Update local inventory list
          _updateInventoryQuantity(productId, locationId, quantity);
          
          Get.snackbar(
            'Success',
            'Stock received successfully',
            snackPosition: SnackPosition.TOP,
            backgroundColor: AppTheme.successColor,
            colorText: Colors.white,
          );
        },
      );
    } catch (e) {
      errorMessage.value = 'Failed to receive stock: $e';
    } finally {
      isLoading.value = false;
    }
  }

  void setSearchQuery(String query) {
    searchQuery.value = query;
    _applyFilters();
    _calculateTotalInventoryValue();
  }

  List<Inventory> _applyFilters() {
    var filtered = inventoryItems.toList();
    
    // Filter by location
    if (selectedLocationId.value.isNotEmpty) {
      filtered = filtered.where((item) => item.locationId == selectedLocationId.value).toList();
    }
    
    // Filter by search query (will be handled by UI with product name lookup)
    // For now, just return all items - search will be handled in UI layer
    if (searchQuery.value.isNotEmpty) {
      // TODO: Implement proper product name search
      // This requires async product name lookup, so we'll handle it in UI
    }
    
    return filtered;
  }

  /// Calculate total inventory value using cost price (modal)
  /// This represents the total investment in inventory
  Future<void> _calculateTotalInventoryValue() async {
    try {
      double totalValue = 0.0;
      final localDataSource = Get.find<LocalDataSource>();
      
      for (final item in inventoryItems) {
        try {
          final product = await localDataSource.getProduct(item.productId);
          if (product != null) {
            // Use cost price (modal) for inventory valuation
            final itemValue = item.quantity * product.priceBuy;
            totalValue += itemValue;
            print('📊 ${product.name}: ${item.quantity} x ${product.priceBuy} = $itemValue');
          }
        } catch (e) {
          print('❌ Error getting product price for ${item.productId}: $e');
        }
      }
      
      totalInventoryValue.value = totalValue;
      print('💰 Total Inventory Value (Modal): ${totalValue.toStringAsFixed(2)}');
    } catch (e) {
      print('❌ Error calculating total inventory value: $e');
      totalInventoryValue.value = 0.0;
    }
  }

  Future<int> getCurrentStock(String productId, String locationId) async {
    try {
      print('🔍 Getting current stock for product: $productId, location: $locationId');
      final result = await getInventory(GetInventoryParams(
        tenantId: _currentTenantId,
        locationId: locationId,
      ));
      
      return result.fold(
        (failure) {
          print('❌ Failed to get inventory: $failure');
          return 0;
        },
        (inventories) {
          print('📦 Found ${inventories.length} inventory items for location $locationId');
          final inventory = inventories.firstWhere(
            (inv) => inv.productId == productId && inv.locationId == locationId,
            orElse: () {
              print('⚠️ No inventory found for product $productId at location $locationId');
              return Inventory(
                id: '',
                tenantId: '',
                productId: productId,
                locationId: locationId,
                quantity: 0,
                reserved: 0,
                updatedAt: DateTime.now(),
              );
            },
          );
          print('✅ Found inventory: quantity = ${inventory.quantity}');
          return inventory.quantity;
        },
      );
    } catch (e) {
      print('Error getting current stock: $e');
      return 0;
    }
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
