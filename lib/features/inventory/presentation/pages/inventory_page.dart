import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pos/core/theme/app_theme.dart';
import 'package:pos/shared/models/entities/entities.dart';
import 'package:pos/features/inventory/presentation/controllers/inventory_controller.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:pos/features/inventory/presentation/widgets/inventory_card.dart';
import 'package:pos/features/inventory/presentation/widgets/stock_operation_dialog.dart';
import 'package:pos/features/inventory/presentation/widgets/stock_adjustment_dialog.dart';
import 'package:pos/features/inventory/presentation/widgets/stock_transfer_dialog.dart';
import 'package:pos/features/inventory/presentation/widgets/stock_receiving_dialog.dart';

class InventoryPage extends StatefulWidget {
  const InventoryPage({super.key});

  @override
  State<InventoryPage> createState() => _InventoryPageState();
}

class _InventoryPageState extends State<InventoryPage> with TickerProviderStateMixin {
  late InventoryController _controller;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    
    if (Get.isRegistered<InventoryController>()) {
      _controller = Get.find<InventoryController>();
    } else {
      _controller = Get.put(InventoryController(
        getInventory: Get.find(),
        createStockMovement: Get.find(),
        getStockMovements: Get.find(),
        getLocations: Get.find(),
        getLowStockProducts: Get.find(),
      ));
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)!.inventory,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: AppTheme.primaryColor,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list, color: Colors.white),
            onPressed: () => _showFilterDialog(),
          ),
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () => _controller.loadInventory(),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: [
            Tab(
              icon: const Icon(Icons.inventory_2),
              text: AppLocalizations.of(context)!.allProducts,
            ),
            Tab(
              icon: const Icon(Icons.warning),
              text: AppLocalizations.of(context)!.lowStock,
            ),
            Tab(
              icon: const Icon(Icons.error),
              text: AppLocalizations.of(context)!.outOfStock,
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Stats Cards
          _buildStatsCards(),
          
          // Search Bar
          _buildSearchBar(),
          
          // Tab Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildInventoryList(),
                _buildLowStockList(),
                _buildOutOfStockList(),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showStockOperationDialog(),
        icon: const Icon(Icons.add),
        label: Text(AppLocalizations.of(context)!.stockOperation),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
      ),
    );
  }

  Widget _buildStatsCards() {
    return Container(
      height: 120,
      padding: const EdgeInsets.all(16),
      child: Obx(() => ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _buildStatCard(
            AppLocalizations.of(context)!.totalProducts,
            '${_controller.totalProducts}',
            Icons.inventory_2,
            Colors.blue,
          ),
          _buildStatCard(
            AppLocalizations.of(context)!.lowStock,
            '${_controller.lowStockCount}',
            Icons.warning,
            Colors.orange,
          ),
          _buildStatCard(
            AppLocalizations.of(context)!.outOfStock,
            '${_controller.outOfStockCount}',
            Icons.error,
            Colors.red,
          ),
          _buildStatCard(
            AppLocalizations.of(context)!.totalValue,
            'Rp ${_controller.totalInventoryValue.toStringAsFixed(0)}',
            Icons.attach_money,
            Colors.green,
          ),
        ],
      )),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      width: 140,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: TextField(
        onChanged: (value) => _controller.setSearchQuery(value),
        decoration: InputDecoration(
          hintText: AppLocalizations.of(context)!.searchProducts,
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
    );
  }

  Widget _buildInventoryList() {
    return Obx(() {
      if (_controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      final filteredInventory = _controller.filteredInventory;

      if (filteredInventory.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.inventory_2_outlined,
                size: 64,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 16),
              Text(
                AppLocalizations.of(context)!.noInventoryFound,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        );
      }

      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: filteredInventory.length,
        itemBuilder: (context, index) {
          final inventory = filteredInventory[index];
          return InventoryCard(
            inventory: inventory,
            onTap: () => _showInventoryDetails(inventory),
            onAdjust: () => _showStockAdjustment(inventory),
            onTransfer: () => _showStockTransfer(inventory),
          );
        },
      );
    });
  }

  Widget _buildLowStockList() {
    return Obx(() {
      final lowStockItems = _controller.inventoryItems.where((item) => item.isLowStock).toList();

      if (lowStockItems.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.check_circle_outline,
                size: 64,
                color: Colors.green[400],
              ),
              const SizedBox(height: 16),
              Text(
                AppLocalizations.of(context)!.noLowStockProducts,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        );
      }

      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: lowStockItems.length,
        itemBuilder: (context, index) {
          final inventory = lowStockItems[index];
          return InventoryCard(
            inventory: inventory,
            onTap: () => _showInventoryDetails(inventory),
            onAdjust: () => _showStockAdjustment(inventory),
            onTransfer: () => _showStockTransfer(inventory),
          );
        },
      );
    });
  }

  Widget _buildOutOfStockList() {
    return Obx(() {
      final outOfStockItems = _controller.inventoryItems.where((item) => item.isOutOfStock).toList();

      if (outOfStockItems.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.check_circle_outline,
                size: 64,
                color: Colors.green[400],
              ),
              const SizedBox(height: 16),
              Text(
                AppLocalizations.of(context)!.noOutOfStockProducts,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        );
      }

      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: outOfStockItems.length,
        itemBuilder: (context, index) {
          final inventory = outOfStockItems[index];
          return InventoryCard(
            inventory: inventory,
            onTap: () => _showInventoryDetails(inventory),
            onAdjust: () => _showStockAdjustment(inventory),
            onTransfer: () => _showStockTransfer(inventory),
          );
        },
      );
    });
  }

  void _showFilterDialog() {
    Get.dialog(
      AlertDialog(
        title: Text(AppLocalizations.of(context)!.filterInventory),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Obx(() => DropdownButtonFormField<String>(
              value: _controller.selectedLocationId.value.isEmpty 
                  ? null 
                  : _controller.selectedLocationId.value,
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context)!.location,
                border: const OutlineInputBorder(),
              ),
              items: [
                DropdownMenuItem<String>(
                  value: '',
                  child: Text(AppLocalizations.of(context)!.allLocations),
                ),
                ..._controller.locations.map((location) => DropdownMenuItem<String>(
                  value: location.id,
                  child: Text(location.name),
                )),
              ],
              onChanged: (value) => _controller.setLocationFilter(value),
            )),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              _controller.loadInventory();
            },
            child: Text(AppLocalizations.of(context)!.apply),
          ),
        ],
      ),
    );
  }

  void _showStockOperationDialog() {
    Get.dialog(
      StockOperationDialog(
        onStockAdjustment: () {
          Get.back();
          _showStockAdjustmentDialog();
        },
        onStockTransfer: () {
          Get.back();
          _showStockTransferDialog();
        },
        onStockReceiving: () {
          Get.back();
          _showStockReceivingDialog();
        },
      ),
    );
  }

  void _showStockAdjustmentDialog() {
    Get.dialog(
      StockAdjustmentDialog(
        onSubmit: (productId, locationId, physicalCount, reason, notes) {
          _controller.performStockAdjustment(
            productId: productId,
            locationId: locationId,
            physicalCount: physicalCount,
            reason: reason,
            notes: notes,
          );
        },
      ),
    );
  }

  void _showStockTransferDialog() {
    Get.dialog(
      StockTransferDialog(
        onSubmit: (productId, fromLocationId, toLocationId, quantity, notes) {
          _controller.performStockTransfer(
            productId: productId,
            fromLocationId: fromLocationId,
            toLocationId: toLocationId,
            quantity: quantity,
            reason: 'Stock transfer',
            notes: notes,
          );
        },
      ),
    );
  }

  void _showStockReceivingDialog() {
    Get.dialog(
      StockReceivingDialog(
        onSubmit: (productId, locationId, quantity, referenceId, notes) {
          _controller.performStockReceiving(
            productId: productId,
            locationId: locationId,
            quantity: quantity,
            referenceId: referenceId,
            notes: notes,
          );
        },
      ),
    );
  }

  void _showStockAdjustment(Inventory inventory) {
    Get.dialog(
      StockAdjustmentDialog(
        inventory: inventory,
        onSubmit: (productId, locationId, physicalCount, reason, notes) {
          _controller.performStockAdjustment(
            productId: productId,
            locationId: locationId,
            physicalCount: physicalCount,
            reason: reason,
            notes: notes,
          );
        },
      ),
    );
  }

  void _showStockTransfer(Inventory inventory) {
    Get.dialog(
      StockTransferDialog(
        inventory: inventory,
        onSubmit: (productId, fromLocationId, toLocationId, quantity, notes) {
          _controller.performStockTransfer(
            productId: productId,
            fromLocationId: fromLocationId,
            toLocationId: toLocationId,
            quantity: quantity,
            reason: 'Stock transfer',
            notes: notes,
          );
        },
      ),
    );
  }

  void _showInventoryDetails(Inventory inventory) {
    // Show inventory details dialog
    Get.dialog(
      AlertDialog(
        title: Text(AppLocalizations.of(context)!.inventoryDetails),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Product ID: ${inventory.productId}'),
            Text('Location ID: ${inventory.locationId}'),
            Text('Quantity: ${inventory.quantity}'),
            Text('Reserved: ${inventory.reserved}'),
            Text('Available: ${inventory.availableQuantity}'),
            Text('Updated: ${inventory.updatedAt}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(AppLocalizations.of(context)!.close),
          ),
        ],
      ),
    );
  }


}
