import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pos/core/errors/failures.dart';
import 'package:pos/features/products/domain/usecases/get_products.dart';
import 'package:pos/features/products/domain/usecases/create_product.dart';
import 'package:pos/features/products/domain/usecases/update_product.dart';
import 'package:pos/features/products/domain/usecases/search_products.dart';
import 'package:pos/features/inventory/domain/usecases/get_inventory.dart';
import 'package:pos/features/auth/presentation/controllers/auth_controller.dart';
import 'package:pos/shared/models/entities/entities.dart';
import 'package:pos/core/sync/product_sync_service.dart';
import 'package:pos/core/data/database_seeder.dart';
import 'package:pos/core/storage/local_datasource.dart';
import 'package:pos/core/theme/app_theme.dart';

class ProductController extends GetxController {
  final GetProducts getProducts;
  final CreateProduct createProduct;
  final UpdateProduct updateProduct;
  final SearchProducts searchProducts;
  final GetInventory getInventory;
  final ProductSyncService productSyncService;
  final DatabaseSeeder databaseSeeder;
  final LocalDataSource localDataSource;

  ProductController({
    required this.getProducts,
    required this.createProduct,
    required this.updateProduct,
    required this.searchProducts,
    required this.getInventory,
    required this.productSyncService,
    required this.databaseSeeder,
    required this.localDataSource,
  });

  // Observable variables
  final RxList<Product> products = <Product>[].obs;
  final RxList<Product> filteredProducts = <Product>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isCreating = false.obs;
  final RxString searchQuery = ''.obs;
  final RxString selectedCategoryId = ''.obs;
  final RxString errorMessage = ''.obs;
  final RxDouble totalProductValue = 0.0.obs;

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

  // Getters
  List<Product> get allProducts => products;
  List<Product> get displayedProducts {
    final result = filteredProducts.isEmpty ? products : filteredProducts;
    print('📊 displayedProducts: ${result.length} products (filtered: ${filteredProducts.length}, total: ${products.length})');
    return result;
  }
  bool get hasProducts => products.isNotEmpty;
  bool get hasError => errorMessage.value.isNotEmpty;

  @override
  void onInit() {
    super.onInit();
    loadProducts();
  }

  Future<void> loadProducts() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      // Use sync service to get products (handles dummy data vs server sync)
      final productList = await productSyncService.syncProducts();
      products.value = productList;
      _applyFilters();
      _calculateTotalProductValue();
      
    } catch (e) {
      errorMessage.value = 'Failed to load products: $e';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> createNewProduct(Product product) async {
    try {
      isCreating.value = true;
      errorMessage.value = '';

      final result = await createProduct(product);
      result.fold(
        (failure) => _handleFailure(failure),
        (createdProduct) async {
          // Create initial inventory record
          try {
            await localDataSource.createInitialInventory(createdProduct);
            print('✅ Initial inventory created for: ${createdProduct.name}');
          } catch (e) {
            print('❌ Failed to create initial inventory: $e');
            // Continue anyway - product is created, just inventory failed
          }
          
          products.add(createdProduct);
          _applyFilters();
          _calculateTotalProductValue();
          
          // Sync to server if enabled
          productSyncService.syncProductToServer(createdProduct);
          
          Get.snackbar('Success', 'Product created successfully');
        },
      );
    } catch (e) {
      errorMessage.value = 'Failed to create product: $e';
    } finally {
      isCreating.value = false;
    }
  }

  Future<void> updateProductData(Product product) async {
    try {
      isCreating.value = true;
      errorMessage.value = '';

      final result = await updateProduct.call(product);
      result.fold(
        (failure) => _handleFailure(failure),
        (updatedProduct) {
          // Find and replace the product in the list
          final index = products.indexWhere((p) => p.id == product.id);
          if (index != -1) {
            products[index] = updatedProduct;
            _applyFilters();
            _calculateTotalProductValue();
          }
          
          // Sync to server if enabled
          productSyncService.updateProductOnServer(updatedProduct);
          
          Get.snackbar(
            'Success',
            'Product updated successfully',
            snackPosition: SnackPosition.TOP,
            backgroundColor: AppTheme.successColor,
            colorText: Colors.white,
            duration: const Duration(seconds: 2),
          );
        },
      );
    } catch (e) {
      errorMessage.value = 'Failed to update product: $e';
      Get.snackbar(
        'Error',
        'Failed to update product: $e',
        snackPosition: SnackPosition.TOP,
        backgroundColor: AppTheme.errorColor,
        colorText: Colors.white,
      );
    } finally {
      isCreating.value = false;
    }
  }


  Future<void> searchByBarcode(String barcode) async {
    try {
      searchQuery.value = barcode;
      errorMessage.value = '';

      print('🔍 Searching for barcode: "$barcode"');
      print('📦 Total products loaded: ${products.length}');
      
      // Debug: Print all products with barcodes
      final productsWithBarcode = products.where((p) => p.barcode != null && p.barcode!.isNotEmpty).toList();
      print('🏷️ Products with barcodes: ${productsWithBarcode.length}');
      for (final p in productsWithBarcode) {
        print('  - ${p.name}: "${p.barcode}" (hasBarcode: ${p.hasBarcode})');
      }

      // Use exact barcode match first, then fuzzy matching
      final product = getProductByBarcode(barcode);
      if (product != null) {
        filteredProducts.value = [product];
     
      } else {
        filteredProducts.clear();
        
        // Try to find similar barcode and suggest fix
        print('🔧 No exact match found, checking for similar barcodes...');
        await fixBarcodeIfSimilar(barcode, '');
        
        Get.snackbar('Not Found', 'No product found with barcode: $barcode');
        print('❌ No product found with barcode: "$barcode"');
      }
    } catch (e) {
      errorMessage.value = 'Failed to search by barcode: $e';
      Get.snackbar('Error', 'Failed to search by barcode: $e');
      print('❌ Barcode search error: $e');
    }
  }

  Future<void> performSearch(String query) async {
    try {
      print('🔍 performSearch called with query: "$query"');
      searchQuery.value = query;
      
      if (query.trim().isEmpty) {
        print('🔍 Query is empty, clearing filters');
        filteredProducts.clear();
        _applyFilters();
        return;
      }

      print('🔍 Searching in database for: "$query"');
      final result = await searchProducts(query);
      result.fold(
        (failure) {
          print('❌ Search failed: $failure');
          _handleFailure(failure);
        },
        (searchResults) {
          print('✅ Search results: ${searchResults.length} products found');
          for (final product in searchResults) {
            print('  - ${product.name}');
          }
          filteredProducts.value = searchResults;
        },
      );
    } catch (e) {
      print('❌ Search error: $e');
      errorMessage.value = 'Failed to search products: $e';
    }
  }

  void filterByCategory(String? categoryId) {
    selectedCategoryId.value = categoryId ?? '';
    _applyFilters();
  }

  void clearFilters() {
    searchQuery.value = '';
    selectedCategoryId.value = '';
    filteredProducts.clear();
  }

  void clearSearch() {
    searchQuery.value = '';
    _applyFilters();
  }

  void clearCategoryFilter() {
    selectedCategoryId.value = '';
    _applyFilters();
  }

  void _applyFilters() {
    if (searchQuery.value.isEmpty && selectedCategoryId.value.isEmpty) {
      // No filters applied, show all products
      filteredProducts.clear();
      return;
    }

    var filtered = products.where((product) {
      bool matchesSearch = true;
      bool matchesCategory = true;

      if (searchQuery.value.isNotEmpty) {
        matchesSearch = product.name.toLowerCase().contains(searchQuery.value.toLowerCase()) ||
                       product.sku.toLowerCase().contains(searchQuery.value.toLowerCase());
      }

      if (selectedCategoryId.value.isNotEmpty) {
        matchesCategory = product.categoryId == selectedCategoryId.value;
      }

      return matchesSearch && matchesCategory;
    }).toList();

    filteredProducts.value = filtered;
  }

  void _handleFailure(Failure failure) {
    String message;
    if (failure is ValidationFailure) {
      message = failure.message;
    } else if (failure is DatabaseFailure) {
      message = 'Database error: ${failure.message}';
    } else if (failure is NetworkFailure) {
      message = 'Network error: ${failure.message}';
    } else {
      message = 'An unexpected error occurred: ${failure.message}';
    }
    errorMessage.value = message;
    Get.snackbar('Error', message);
  }

  void clearError() {
    errorMessage.value = '';
  }

  // Product management methods
  Product? getProductById(String id) {
    try {
      return products.firstWhere((product) => product.id == id);
    } catch (e) {
      return null;
    }
  }

  Product? getProductBySku(String sku) {
    try {
      return products.firstWhere((product) => product.sku == sku);
    } catch (e) {
      return null;
    }
  }

  Product? getProductByBarcode(String barcode) {
    try {
      // Clean the input barcode (trim whitespace)
      final cleanBarcode = barcode.trim();
      
      // Try exact match first
      var product = products.firstWhere(
        (product) => product.barcode != null && product.barcode!.trim() == cleanBarcode,
        orElse: () => throw StateError('No product found'),
      );
      
      return product;
    } catch (e) {
      // If exact match fails, try fuzzy matching for similar barcodes
      try {
        final cleanBarcode = barcode.trim();
        final productsWithBarcode = products.where((p) => p.barcode != null && p.barcode!.isNotEmpty).toList();
        
        // Try fuzzy matching - find barcodes with high similarity
        for (final product in productsWithBarcode) {
          final storedBarcode = product.barcode!.trim();
          
          // Check if barcodes are very similar (1-2 character difference)
          if (_isBarcodeSimilar(cleanBarcode, storedBarcode)) {
            print('🔍 Fuzzy match found: "$cleanBarcode" ≈ "$storedBarcode"');
            return product;
          }
        }
        
        return null;
      } catch (e2) {
        return null;
      }
    }
  }

  // Helper method to check if two barcodes are similar
  bool _isBarcodeSimilar(String barcode1, String barcode2) {
    if (barcode1.length != barcode2.length) return false;
    
    int differences = 0;
    for (int i = 0; i < barcode1.length; i++) {
      if (barcode1[i] != barcode2[i]) {
        differences++;
        if (differences > 2) return false; // Allow max 2 character differences
      }
    }
    
    return differences <= 2; // Similar if 2 or fewer differences
  }

  List<Product> getProductsByCategory(String categoryId) {
    return products.where((product) => product.categoryId == categoryId).toList();
  }

  Future<List<Product>> getLowStockProducts() async {
    try {
      return await localDataSource.getLowStockProducts(_currentTenantId);
    } catch (e) {
      print('❌ Error getting low stock products: $e');
      return <Product>[];
    }
  }

  // Helper method to get current stock for a product
  Future<int> getCurrentStock(String productId) async {
    try {
      return await localDataSource.getCurrentStock(productId);
    } catch (e) {
      print('❌ Error getting current stock for product $productId: $e');
      return 0;
    }
  }

  // Delete product
  Future<void> deleteProduct(String productId) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      // Delete from database first
      await localDataSource.deleteProduct(productId);
      
      // Also delete related inventory records
      try {
        final inventories = await localDataSource.getInventoriesByProduct(productId);
        for (final inventory in inventories) {
          await localDataSource.deleteInventory(inventory.id);
        }
        print('✅ Deleted ${inventories.length} inventory records for product: $productId');
      } catch (e) {
        print('⚠️ Failed to delete inventory records: $e');
        // Continue with product deletion even if inventory deletion fails
      }
      
      // Remove from local list
      products.removeWhere((product) => product.id == productId);
      filteredProducts.removeWhere((product) => product.id == productId);
      _calculateTotalProductValue();
      
      // Sync to server if enabled
      productSyncService.deleteProductFromServer(productId);
      
      Get.snackbar(
        'Success',
        'Product deleted successfully',
        snackPosition: SnackPosition.TOP,
        backgroundColor: AppTheme.successColor,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );
    } catch (e) {
      errorMessage.value = 'Failed to delete product: $e';
      Get.snackbar(
        'Error',
        'Failed to delete product: $e',
        snackPosition: SnackPosition.TOP,
        backgroundColor: AppTheme.errorColor,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Force refresh from server
  Future<void> forceRefresh() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final productList = await productSyncService.forceRefreshFromServer();
      products.value = productList;
      _applyFilters();
      
      Get.snackbar(
        'Success',
        'Products refreshed successfully',
        snackPosition: SnackPosition.TOP,
      );
    } catch (e) {
      errorMessage.value = 'Failed to refresh products: $e';
    } finally {
      isLoading.value = false;
    }
  }

  // Get sync status
  String getSyncStatus() {
    return productSyncService.getSyncStatus();
  }

  // Check if server sync is available
  bool isServerSyncAvailable() {
    return productSyncService.isServerSyncAvailable();
  }

  // Debug method to get all products with barcodes
  List<Product> getProductsWithBarcodes() {
    return products.where((product) => 
      product.barcode != null && 
      product.barcode!.isNotEmpty
    ).toList();
  }

  // Debug method to print barcode info
  void debugBarcodeInfo() {
    print('🔍 DEBUG: Barcode Information');
    print('📦 Total products: ${products.length}');
    
    final productsWithBarcode = getProductsWithBarcodes();
    print('🏷️ Products with barcodes: ${productsWithBarcode.length}');
    
    for (final product in productsWithBarcode) {
      print('  - ID: ${product.id}');
      print('    Name: ${product.name}');
      print('    Barcode: "${product.barcode}"');
      print('    HasBarcode: ${product.hasBarcode}');
      print('    Barcode length: ${product.barcode?.length ?? 0}');
      print('    Barcode type: ${product.barcode.runtimeType}');
      print('    ---');
    }
  }

  // Method to fix barcode if it's similar to existing one
  Future<void> fixBarcodeIfSimilar(String scannedBarcode, String productName) async {
    try {
      final productsWithBarcode = getProductsWithBarcodes();
      
      for (final product in productsWithBarcode) {
        if (product.name.toLowerCase().contains(productName.toLowerCase()) ||
            productName.toLowerCase().contains(product.name.toLowerCase())) {
          
          final storedBarcode = product.barcode!.trim();
          
          if (_isBarcodeSimilar(scannedBarcode, storedBarcode)) {
            print('🔧 Found similar barcode for ${product.name}:');
            print('   Scanned: "$scannedBarcode"');
            print('   Stored:  "$storedBarcode"');
            print('   Suggest updating stored barcode to match scanned one');
            
            // Show dialog to user to confirm update
            Get.dialog(
              AlertDialog(
                title: Text('Barcode Mismatch Detected'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Product: ${product.name}'),
                    SizedBox(height: 8),
                    Text('Scanned: $scannedBarcode'),
                    Text('Stored: $storedBarcode'),
                    SizedBox(height: 8),
                    Text('Do you want to update the stored barcode?'),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () => Get.back(),
                    child: Text('Cancel'),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      Get.back();
                      await _updateProductBarcode(product, scannedBarcode);
                    },
                    child: Text('Update'),
                  ),
                ],
              ),
            );
            return;
          }
        }
      }
      
      print('❌ No similar barcode found for "$scannedBarcode"');
    } catch (e) {
      print('❌ Error fixing barcode: $e');
    }
  }

  // Helper method to update product barcode
  Future<void> _updateProductBarcode(Product product, String newBarcode) async {
    try {
      final updatedProduct = product.copyWith(barcode: newBarcode);
      await updateProduct(updatedProduct);
      Get.snackbar('Success', 'Barcode updated for ${product.name}');
    } catch (e) {
      Get.snackbar('Error', 'Failed to update barcode: $e');
    }
  }

  /// Calculate total product value using cost price (modal) and inventory quantity
  /// This matches the calculation method used in inventory menu exactly
  Future<void> _calculateTotalProductValue() async {
    try {
      double totalValue = 0.0;
      
      // Use the same method as inventory controller to get inventory data
      final result = await getInventory(GetInventoryParams(
        tenantId: _currentTenantId,
        locationId: null, // Get all locations
      ));
      
      result.fold(
        (failure) {
          print('❌ Failed to get inventory for total calculation: $failure');
          totalProductValue.value = 0.0;
        },
        (inventories) async {
          for (final inventory in inventories) {
            try {
              // Get product details
              final product = await localDataSource.getProduct(inventory.productId);
              if (product != null) {
                // Use cost price (modal) for product valuation - same as inventory menu
                final itemValue = inventory.quantity * product.priceBuy;
                totalValue += itemValue;
                print('📊 ${product.name}: ${inventory.quantity} x ${product.priceBuy} = $itemValue');
              }
            } catch (e) {
              print('❌ Error getting product price for ${inventory.productId}: $e');
            }
          }
          
          totalProductValue.value = totalValue;
          print('💰 Total Product Value (Modal): ${totalValue.toStringAsFixed(2)}');
        },
      );
    } catch (e) {
      print('❌ Error calculating total product value: $e');
      totalProductValue.value = 0.0;
    }
  }
}
