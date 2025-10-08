import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pos/core/theme/app_theme.dart';
import 'package:pos/shared/models/entities/entities.dart';
import 'package:pos/features/products/presentation/controllers/product_controller.dart';
import 'package:pos/core/controllers/category_controller.dart';
import 'package:pos/features/products/presentation/widgets/product_card.dart';
import 'package:pos/features/products/presentation/widgets/product_search_bar.dart';
import 'package:pos/features/products/presentation/widgets/category_filter.dart';
import 'package:pos/features/products/presentation/widgets/add_product_fab.dart';
import 'package:pos/features/products/presentation/widgets/product_form_dialog.dart';
import 'package:pos/features/products/presentation/widgets/product_details_dialog.dart';
import 'package:pos/features/products/presentation/widgets/import_export_dialog.dart';

class ProductsPage extends StatefulWidget {
  const ProductsPage({super.key});

  @override
  State<ProductsPage> createState() => _ProductsPageState();
}

class _ProductsPageState extends State<ProductsPage> with TickerProviderStateMixin {
  late ProductController _controller;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _controller = Get.find<ProductController>();
    _tabController = TabController(length: 2, vsync: this);
    
    // Ensure data is loaded when page opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controller.loadProducts();
      // Also load categories for the filter
      Get.find<CategoryController>().loadCategories();
    });
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
          'Kelola Produk',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppTheme.primaryColor,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.sync, color: Colors.white),
            onPressed: _controller.loadProducts,
            tooltip: 'Refresh',
          ),
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert, color: Colors.white),
            onSelected: _handleMenuAction,
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'import',
                child: Row(
                  children: [
                    Icon(Icons.upload_file, color: AppTheme.primaryColor),
                    SizedBox(width: 12),
                    Text('Import CSV'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'export',
                child: Row(
                  children: [
                    Icon(Icons.download, color: AppTheme.primaryColor),
                    SizedBox(width: 12),
                    Text('Export Data'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'categories',
                child: Row(
                  children: [
                    Icon(Icons.category, color: AppTheme.primaryColor),
                    SizedBox(width: 12),
                    Text('Kelola Kategori'),
                  ],
                ),
              ),
             
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Search and Filter Section
          Container(
            color: Colors.white,
            padding: EdgeInsets.all(16),
            child: Column(
              children: [
                ProductSearchBar(
                  onSearchChanged: _controller.performSearch,
                  onSearchCleared: _controller.clearSearch,
                  onBarcodeScanned: _handleBarcodeScanned,
                ),
                SizedBox(height: 12),
                CategoryFilter(
                  onCategorySelected: _controller.filterByCategory,
                  onCategoryCleared: _controller.clearCategoryFilter,
                ),
              ],
            ),
          ),
          
          // Stats Section
          Container(
            color: Colors.white,
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Obx(() => Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Total Produk',
                    '${_controller.products.length}',
                    Icons.inventory_2,
                    AppTheme.primaryColor,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    'Aktif',
                    '${_controller.products.where((p) => p.isActive).length}',
                    Icons.check_circle,
                    AppTheme.successColor,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: FutureBuilder<List<Product>>(
                    future: _controller.getLowStockProducts(),
                    builder: (context, snapshot) {
                      final lowStockCount = snapshot.hasData ? snapshot.data!.length : 0;
                      return _buildStatCard(
                        'Stok Rendah',
                        '$lowStockCount',
                        Icons.warning,
                        AppTheme.warningColor,
                      );
                    },
                  ),
                ),
              ],
            )),
          ),
          
          // Products List
          Expanded(
            child: Obx(() {
              if (_controller.isLoading.value) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Memuat produk...',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                );
              }

              if (_controller.hasError) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Gagal memuat produk',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[700],
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        _controller.errorMessage.value,
                        style: TextStyle(
                          color: Colors.grey[600],
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: _controller.loadProducts,
                        icon: Icon(Icons.refresh),
                        label: Text('Coba Lagi'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryColor,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                );
              }

              final products = _controller.displayedProducts;
              
              if (products.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.inventory_2_outlined,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Belum ada produk',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[700],
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Tambahkan produk pertama Anda',
                        style: TextStyle(
                          color: Colors.grey[600],
                        ),
                      ),
                      SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: () => _showAddProductDialog(),
                        icon: Icon(Icons.add),
                        label: Text('Tambah Produk'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryColor,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                );
              }

              return RefreshIndicator(
                onRefresh: _controller.loadProducts,
                color: AppTheme.primaryColor,
                child: ListView.builder(
                  padding: EdgeInsets.all(16),
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    final product = products[index];
                    return ProductCard(
                      product: product,
                      onTap: () => _showProductDetails(product),
                      onEdit: () => _showEditProductDialog(product),
                      onDelete: () => _showDeleteConfirmation(product),
                    );
                  },
                ),
              );
            }),
          ),
        ],
      ),
      floatingActionButton: AddProductFAB(
        onPressed: _showAddProductDialog,
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _handleMenuAction(String action) {
    switch (action) {
      case 'import':
        _showImportDialog();
        break;
      case 'export':
        _showExportDialog();
        break;
      case 'categories':
        _showCategoriesDialog();
        break;
      case 'debug_barcode':
        _controller.debugBarcodeInfo();
        Get.snackbar(
          'Debug Info',
          'Barcode debug info printed to console',
          snackPosition: SnackPosition.TOP,
        );
        break;
    }
  }

  void _showAddProductDialog() {
    
    Get.dialog(
      ProductFormDialog(
        onSubmit: (product) {
          _controller.createNewProduct(product);
        },
      ),
    );
  }

  void _showEditProductDialog(Product product) {
    Get.dialog(
      ProductFormDialog(
        product: product,
        onSubmit: (updatedProduct) {
          _controller.updateProductData(updatedProduct);
        },
      ),
    );
  }

  void _showProductDetails(Product product) {
    Get.dialog(
      ProductDetailsDialog(product: product),
    );
  }

  void _showDeleteConfirmation(Product product) {
    Get.dialog(
      AlertDialog(
        title: Text('Hapus Produk'),
        content: Text('Apakah Anda yakin ingin menghapus "${product.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              _controller.deleteProduct(product.id);
            },
            child: Text(
              'Hapus',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  void _showImportDialog() {
    Get.dialog(
      ImportExportDialog(
        products: _controller.products,
        onImportProducts: (importedProducts) async {
          try {
            // Show loading
            Get.dialog(
              const Center(
                child: CircularProgressIndicator(),
              ),
              barrierDismissible: false,
            );
            
            // Import products using ProductController
            for (final product in importedProducts) {
              await _controller.createNewProduct(product);
            }
            
            // Close loading dialog
            Get.back();
            
            // Show success message
            Get.snackbar(
              'Import Berhasil',
              '${importedProducts.length} produk berhasil diimport',
              snackPosition: SnackPosition.TOP,
              backgroundColor: AppTheme.successColor,
              colorText: Colors.white,
              duration: const Duration(seconds: 3),
            );
            
          } catch (e) {
            // Close loading dialog if still open
            if (Get.isDialogOpen == true) {
              Get.back();
            }
            
            Get.snackbar(
              'Error',
              'Gagal mengimport produk: $e',
              snackPosition: SnackPosition.TOP,
              backgroundColor: AppTheme.errorColor,
              colorText: Colors.white,
            );
          }
        },
      ),
    );
  }

  void _showExportDialog() {
    Get.dialog(
      ImportExportDialog(
        products: _controller.products,
        onImportProducts: (importedProducts) {
          // Not used in export mode
        },
      ),
    );
  }

  void _showCategoriesDialog() {
    Get.snackbar(
      'Info',
      'Fitur kelola kategori akan segera tersedia',
      snackPosition: SnackPosition.TOP,
    );
  }

  void _handleBarcodeScanned(String barcode) {
    // Search for product with this barcode
    _controller.searchByBarcode(barcode);
    
 
  }
}
