import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pos/core/theme/app_theme.dart';
// import 'package:pos/core/localization/language_controller.dart';
import 'package:pos/shared/models/entities/entities.dart';
import 'package:pos/features/products/presentation/widgets/barcode_scanner_dialog.dart';
import 'package:pos/features/products/presentation/widgets/category_search_dialog.dart';
import 'package:pos/features/products/presentation/widgets/product_search_dialog.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:convert';

class ProductFormDialog extends StatefulWidget {
  final Product? product; // null for create, Product for edit
  final Function(Product) onSubmit;

  const ProductFormDialog({
    super.key,
    this.product,
    required this.onSubmit,
  });

  @override
  State<ProductFormDialog> createState() => _ProductFormDialogState();
}

class _ProductFormDialogState extends State<ProductFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _skuController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceBuyController = TextEditingController();
  final _priceSellController = TextEditingController();
  final _minStockController = TextEditingController();
  final _brandController = TextEditingController();
  final _variantController = TextEditingController();
  final _packSizeController = TextEditingController();
  final _reorderPointController = TextEditingController();
  final _reorderQtyController = TextEditingController();
  final _barcodeController = TextEditingController();

  String _selectedCategoryId = 'cat_1';
  String _selectedUnit = 'pcs';
  bool _isActive = true;
  bool _isExpirable = false;
  bool _hasBarcode = false;
  bool _isNewProduct = true; // true for new product, false for existing product
  List<String> _productImages = []; // List of base64 encoded images
  List<String> _existingProductNames = []; // List of existing product names from server
  List<Category> _categories = []; // List of categories
  String? _selectedExistingProduct; // Selected existing product for restock
  Product? _selectedProductData; // Full product data for restock
  int _currentStock = 0; // Current stock from server
  final TextEditingController _newStockController = TextEditingController(); // New stock to add

  final List<String> _units = ['pcs', 'bungkus', 'botol', 'kg', 'gram', 'liter', 'ml', 'ikat', 'paket', 'sachet', 'dus', 'kaleng', 'botol kecil', 'botol besar'];
  final ImagePicker _imagePicker = ImagePicker();
  // late LanguageController _languageController;

  @override
  void initState() {
    super.initState();
    // _languageController = Get.find<LanguageController>();
    _initializeForm();
    _loadExistingProductNames();
    _loadCategories();
  }

  /// Load existing product names from server
  Future<void> _loadExistingProductNames() async {
    try {
      // TODO: Implement API call to get existing product names
      // For now, using dummy data
      _existingProductNames = [
        'Indomie Goreng Rendang',
        'Kopi ABC Sachet 20g',
        'Teh Botol Sosro 350ml',
        'Beras Premium 5kg',
        'Minyak Goreng Bimoli 1L',
        'Gula Pasir 1kg',
        'Garam Dapur 500g',
        'Kecap Manis ABC 275ml',
        'Sambal ABC Extra Pedas 135ml',
        'Susu UHT Ultra 1L',
        'Mie Sedap Goreng',
        'Aqua 600ml',
        'Pocari Sweat 500ml',
        'Nescafe 3in1',
        'Teh Pucuk Harum 350ml',
        'Biskuit Roma Kelapa',
        'Chitato Original',
        'Lays Classic',
        'Oreo Original',
        'KitKat 2 Finger',
      ];
    } catch (e) {
      print('❌ Failed to load existing product names: $e');
    }
  }

  /// Get product data by name (simulate API call)
  Future<Product?> _getProductDataByName(String productName) async {
    try {
      // TODO: Implement API call to get product data by name
      // For now, using dummy data
      final dummyProducts = {
        'Indomie Goreng Rendang': Product(
          id: 'prod_001',
          tenantId: 'default-tenant-id',
          sku: 'IMG001',
          name: 'Indomie Goreng Rendang',
          categoryId: 'cat_1',
          description: 'Mie instan goreng dengan bumbu rendang yang autentik',
          unit: 'bungkus',
          priceBuy: 2500.0,
          priceSell: 3500.0,
          minStock: 10,
          photos: ['https://example.com/indomie.jpg'],
          attributes: {
            'brand': 'Indomie',
            'variant': 'Goreng Rendang',
            'pack_size': '85g',
            'uom': 'bungkus',
            'reorder_point': 10,
            'reorder_qty': 50,
          },
          barcode: '8991002101234',
          hasBarcode: true,
          isExpirable: true,
          isActive: true,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          syncStatus: 'synced',
          lastSyncedAt: DateTime.now(),
        ),
        'Kopi ABC Sachet 20g': Product(
          id: 'prod_002',
          tenantId: 'default-tenant-id',
          sku: 'ABC001',
          name: 'Kopi ABC Sachet 20g',
          categoryId: 'cat_2',
          description: 'Kopi instan sachet 20g',
          unit: 'sachet',
          priceBuy: 500.0,
          priceSell: 750.0,
          minStock: 20,
          photos: ['https://example.com/kopi-abc.jpg'],
          attributes: {
            'brand': 'ABC',
            'variant': 'Sachet',
            'pack_size': '20g',
            'uom': 'sachet',
            'reorder_point': 20,
            'reorder_qty': 100,
          },
          barcode: '8991002101235',
          hasBarcode: true,
          isExpirable: true,
          isActive: true,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          syncStatus: 'synced',
          lastSyncedAt: DateTime.now(),
        ),
        // Add more dummy products as needed
      };

      return dummyProducts[productName];
    } catch (e) {
      print('❌ Failed to get product data: $e');
      return null;
    }
  }

  /// Check if product name exists in server
  bool _isProductNameExisting(String productName) {
    return _existingProductNames.any((name) => 
      name.toLowerCase().contains(productName.toLowerCase()));
  }

  /// Pick image from gallery or camera
  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 80,
      );

      if (image != null) {
        final bytes = await image.readAsBytes();
        final base64String = base64Encode(bytes);
        setState(() {
          _productImages.add(base64String);
        });
        
        Get.snackbar(
          'Success',
          'Image added successfully',
          snackPosition: SnackPosition.TOP,
          backgroundColor: AppTheme.successColor,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to pick image: $e',
        snackPosition: SnackPosition.TOP,
        backgroundColor: AppTheme.errorColor,
        colorText: Colors.white,
      );
    }
  }

  /// Remove image from list
  void _removeImage(int index) {
    setState(() {
      _productImages.removeAt(index);
    });
  }

  /// Load categories from database
  Future<void> _loadCategories() async {
    try {
      // TODO: Implement API call to get categories
      // For now, using dummy data
      _categories = [
        Category(
          id: 'cat_1',
          tenantId: 'default-tenant-id',
          name: 'Makanan Instan',
          isActive: true,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          syncStatus: 'synced',
          lastSyncedAt: DateTime.now(),
        ),
        Category(
          id: 'cat_2',
          tenantId: 'default-tenant-id',
          name: 'Minuman',
          isActive: true,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          syncStatus: 'synced',
          lastSyncedAt: DateTime.now(),
        ),
        Category(
          id: 'cat_3',
          tenantId: 'default-tenant-id',
          name: 'Sembako',
          isActive: true,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          syncStatus: 'synced',
          lastSyncedAt: DateTime.now(),
        ),
        Category(
          id: 'cat_4',
          tenantId: 'default-tenant-id',
          name: 'Bumbu Dapur',
          isActive: true,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          syncStatus: 'synced',
          lastSyncedAt: DateTime.now(),
        ),
        Category(
          id: 'cat_5',
          tenantId: 'default-tenant-id',
          name: 'Perawatan',
          isActive: true,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          syncStatus: 'synced',
          lastSyncedAt: DateTime.now(),
        ),
      ];
    } catch (e) {
      print('❌ Failed to load categories: $e');
    }
  }

  /// Get category name by ID
  String _getCategoryName(String categoryId) {
    final category = _categories.firstWhereOrNull((cat) => cat.id == categoryId);
    return category?.name ?? 'Unknown Category';
  }

  /// Show category search dialog
  void _showCategorySearchDialog() {
    showDialog(
      context: context,
      builder: (context) => CategorySearchDialog(
        categories: _categories,
        selectedCategoryId: _selectedCategoryId,
        onCategorySelected: (category) {
          setState(() {
            _selectedCategoryId = category.id;
          });
        },
        onAddCategory: (category) {
          setState(() {
            _categories.add(category);
            _selectedCategoryId = category.id;
          });
          
        
        },
      ),
    );
  }

  /// Show product search dialog
  void _showProductSearchDialog() {
    showDialog(
      context: context,
      builder: (context) => ProductSearchDialog(
        existingProducts: _existingProductNames,
        selectedProduct: _selectedExistingProduct,
        onProductSelected: (product) async {
          setState(() {
            _selectedExistingProduct = product;
            _nameController.text = product;
          });
          
          // Load product data and auto-fill form
          await _loadAndFillProductData(product);
        },
      ),
    );
  }

  /// Load product data and auto-fill form for restock
  Future<void> _loadAndFillProductData(String productName) async {
    try {
      final productData = await _getProductDataByName(productName);
      if (productData != null) {
        setState(() {
          _selectedProductData = productData;
          
          // Auto-fill all fields except price and stock
          _skuController.text = productData.sku;
          _descriptionController.text = productData.description ?? '';
          _selectedCategoryId = productData.categoryId ?? 'cat_1';
          _selectedUnit = _units.contains(productData.unit) ? productData.unit : 'pcs';
          _minStockController.text = productData.minStock.toString();
          
          // Auto-fill attributes
          _brandController.text = productData.attributes['brand'] ?? '';
          _variantController.text = productData.attributes['variant'] ?? '';
          _packSizeController.text = productData.attributes['pack_size'] ?? '';
          _reorderPointController.text = productData.attributes['reorder_point']?.toString() ?? '';
          _reorderQtyController.text = productData.attributes['reorder_qty']?.toString() ?? '';
          
          // Auto-fill barcode
          _barcodeController.text = productData.barcode ?? '';
          _hasBarcode = productData.hasBarcode;
          _isExpirable = productData.isExpirable;
          _isActive = productData.isActive;
          
          // Set current stock (for display) - simulate current stock
          _currentStock = 25; // TODO: Get actual current stock from server
          
          // Keep price fields empty for user input
          _priceBuyController.clear();
          _priceSellController.clear();
        });
        
        Get.snackbar(
          'Success',
          'Data produk berhasil dimuat. Silakan isi harga dan stok baru.',
          snackPosition: SnackPosition.TOP,
          backgroundColor: AppTheme.successColor,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal memuat data produk: $e',
        snackPosition: SnackPosition.TOP,
        backgroundColor: AppTheme.errorColor,
        colorText: Colors.white,
      );
    }
  }

  /// Build product search field for restock
  Widget _buildProductSearchField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Nama Produk *',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: _showProductSearchDialog,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[400]!),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    _selectedExistingProduct ?? 'Pilih produk yang akan di-restok',
                    style: TextStyle(
                      fontSize: 16,
                      color: _selectedExistingProduct != null 
                          ? Colors.black87 
                          : Colors.grey[500],
                    ),
                  ),
                ),
                Icon(
                  Icons.arrow_drop_down,
                  color: Colors.grey[600],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _initializeForm() {
    if (widget.product != null) {
      // Edit mode
      final product = widget.product!;
      _nameController.text = product.name;
      _skuController.text = product.sku;
      _descriptionController.text = product.description ?? '';
      _priceBuyController.text = product.priceBuy.toString();
      _priceSellController.text = product.priceSell.toString();
      _minStockController.text = product.minStock.toString();
      _brandController.text = product.attributes['brand'] ?? '';
      _variantController.text = product.attributes['variant'] ?? '';
      _packSizeController.text = product.attributes['pack_size'] ?? '';
      _reorderPointController.text = product.attributes['reorder_point']?.toString() ?? '';
      _reorderQtyController.text = product.attributes['reorder_qty']?.toString() ?? '';
      _barcodeController.text = product.barcode ?? '';
      _selectedCategoryId = product.categoryId ?? 'cat_1';
      _selectedUnit = _units.contains(product.unit) ? product.unit : 'pcs';
      _isActive = product.isActive;
      _isExpirable = product.isExpirable;
      _hasBarcode = product.hasBarcode;
      
      // Load existing images if any
      if (product.photos.isNotEmpty) {
        _productImages = List<String>.from(product.photos);
        // Filter out invalid images
        _productImages = _productImages.where((image) => _isValidImage(image)).toList();
      }
      
      // Check if this is a new product or existing
      _isNewProduct = !_isProductNameExisting(product.name);
      
      // If it's an existing product, set the selected product
      if (!_isNewProduct) {
        _selectedExistingProduct = product.name;
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _skuController.dispose();
    _descriptionController.dispose();
    _priceBuyController.dispose();
    _priceSellController.dispose();
    _minStockController.dispose();
    _brandController.dispose();
    _variantController.dispose();
    _packSizeController.dispose();
    _reorderPointController.dispose();
    _reorderQtyController.dispose();
    _barcodeController.dispose();
    _newStockController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.product != null;
    
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Header
            Row(
              children: [
                Icon(
                  isEdit ? Icons.edit : Icons.add,
                  color: AppTheme.primaryColor,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  isEdit ? 'Edit Produk' : 'Tambah Produk',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryColor,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Get.back(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 20),
            
            // Form
            Expanded(
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Basic Information
                      _buildSectionTitle('Informasi Dasar'),
                         const SizedBox(height: 20),
                      
                      // Product Type Selection
                      _buildSectionTitle('Tipe Produk'),
                      const SizedBox(height: 12),
                      _buildProductTypeSelection(),
                         const SizedBox(height: 20),
                      
                      // Image Upload (only for new products)
                      if (_isNewProduct) ...[
                        _buildSectionTitle('Foto Produk'),
                        const SizedBox(height: 12),
                        _buildImageUploadSection(),
                        const SizedBox(height: 20),
                      ],
                      const SizedBox(height: 12),
                      
                      Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: _isNewProduct 
                                ? _buildTextFormField(
                                    controller: _nameController,
                                    label: 'Nama Produk *',
                                    hint: 'Masukkan nama produk',
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Nama produk harus diisi';
                                      }
                                      return null;
                                    },
                                  )
                                : _buildProductSearchField(),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildTextFormField(
                              controller: _skuController,
                              label: 'SKU *',
                              hint: 'Kode produk',
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'SKU harus diisi';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      
                      _buildTextFormField(
                        controller: _descriptionController,
                        label: 'Deskripsi',
                        hint: 'Deskripsi produk (opsional)',
                        maxLines: 3,
                      ),
                      const SizedBox(height: 16),
                      
                      // Category and Unit
                      Column(
                        children: [
                          _buildCategoryDropdown(),
                          const SizedBox(height: 16),
                          _buildUnitDropdown(),
                        ],
                      ),
                      const SizedBox(height: 20),
                      
                      // Pricing
                      _buildSectionTitle('Harga & Stok'),
                      const SizedBox(height: 12),
                      
                      Row(
                        children: [
                          Expanded(
                            child: _buildTextFormField(
                              controller: _priceBuyController,
                              label: 'Harga Beli *',
                              hint: '0',
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Harga beli harus diisi';
                                }
                                if (double.tryParse(value) == null || double.parse(value) <= 0) {
                                  return 'Harga beli harus lebih dari 0';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildTextFormField(
                              controller: _priceSellController,
                              label: 'Harga Jual *',
                              hint: '0',
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Harga jual harus diisi';
                                }
                                if (double.tryParse(value) == null || double.parse(value) <= 0) {
                                  return 'Harga jual harus lebih dari 0';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      
                      Column(
                        children: [
                          // Current Stock Display (only for restock)
                          if (!_isNewProduct && _selectedProductData != null) ...[
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.blue[50],
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.blue[200]!),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.inventory_2_rounded,
                                    color: Colors.blue[600],
                                    size: 24,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Stok Tersedia',
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.blue[800],
                                          ),
                                        ),
                                        Text(
                                          '$_currentStock ${_selectedProductData!.unit}',
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w700,
                                            color: Colors.blue[600],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),
                            
                            // New Stock Input (only for restock)
                            _buildTextFormField(
                              controller: _newStockController,
                              label: 'Stok Baru yang Ditambahkan *',
                              hint: '0',
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Stok baru harus diisi';
                                }
                                if (int.tryParse(value) == null || int.parse(value) <= 0) {
                                  return 'Stok baru harus lebih dari 0';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                          ],
                          
                          _buildTextFormField(
                            controller: _minStockController,
                            label: 'Stok Minimum *',
                            hint: '0',
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Stok minimum harus diisi';
                              }
                              if (int.tryParse(value) == null || int.parse(value) < 0) {
                                return 'Stok minimum tidak boleh negatif';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          _buildTextFormField(
                            controller: _reorderPointController,
                            label: 'Reorder Point',
                            hint: '0',
                            keyboardType: TextInputType.number,
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      
                      // Product Details
                      _buildSectionTitle('Detail Produk'),
                      const SizedBox(height: 12),
                      
                      Column(
                        children: [
                          _buildTextFormField(
                            controller: _brandController,
                            label: 'Brand',
                            hint: 'Nama brand',
                          ),
                          const SizedBox(height: 16),
                          _buildTextFormField(
                            controller: _variantController,
                            label: 'Variant',
                            hint: 'Variant produk',
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      
                      Column(
                        children: [
                          _buildTextFormField(
                            controller: _packSizeController,
                            label: 'Ukuran Kemasan',
                            hint: 'Contoh: 500ml, 1kg',
                          ),
                          const SizedBox(height: 16),
                          _buildTextFormField(
                            controller: _reorderQtyController,
                            label: 'Reorder Quantity',
                            hint: '0',
                            keyboardType: TextInputType.number,
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      
                      // Barcode
                      _buildSectionTitle('Barcode'),
                      const SizedBox(height: 12),
                      
                      Column(
                        children: [
                          _buildBarcodeField(),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Text(
                                'Produk memiliki barcode',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const Spacer(),
                              Switch(
                                value: _hasBarcode,
                                onChanged: (value) {
                                  setState(() {
                                    _hasBarcode = value;
                                    if (!value) {
                                      _barcodeController.clear();
                                    }
                                  });
                                },
                                activeColor: AppTheme.primaryColor,
                              ),
                            ],
                          ),
                        ],
                      ),
                   
                   
                      // Options
                      _buildSectionTitle('Opsi'),
                      const SizedBox(height: 12),
                      
                      Row(
                        children: [
                          Expanded(
                            child: _buildSwitchTile(
                              title: 'Produk Aktif',
                              subtitle: 'Produk dapat dijual',
                              value: _isActive,
                              onChanged: (value) => setState(() => _isActive = value),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildSwitchTile(
                              title: 'Produk Expirable',
                              subtitle: 'Produk memiliki tanggal kadaluarsa',
                              value: _isExpirable,
                              onChanged: (value) => setState(() => _isExpirable = value),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            
            // Actions
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Get.back(),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: BorderSide(color: Colors.grey[400]!),
                    ),
                    child: const Text('Batal'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _submitForm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: Text(
                      isEdit ? 'Update' : 'Simpan',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.bold,
        color: AppTheme.primaryColor,
      ),
    );
  }

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String label,
    String? hint,
    TextInputType? keyboardType,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppTheme.primaryColor),
        ),
      ),
    );
  }

  Widget _buildCategoryDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Kategori *',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: _showCategorySearchDialog,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[400]!),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    _getCategoryName(_selectedCategoryId),
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
                Icon(
                  Icons.arrow_drop_down,
                  color: Colors.grey[600],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildUnitDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedUnit,
      decoration: InputDecoration(
        labelText: 'Satuan *',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppTheme.primaryColor),
        ),
      ),
      items: _units.map((unit) {
        return DropdownMenuItem(
          value: unit,
          child: Text(unit),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          _selectedUnit = value!;
        });
      },
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
          Text(
            subtitle,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 8),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppTheme.primaryColor,
          ),
        ],
      ),
    );
  }

  Widget _buildBarcodeField() {
    return TextFormField(
      controller: _barcodeController,
      decoration: InputDecoration(
        labelText: 'Barcode',
        hintText: 'Kode barcode produk',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppTheme.primaryColor),
        ),
        suffixIcon: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(
                Icons.qr_code_scanner,
                color: AppTheme.primaryColor,
              ),
              onPressed: _scanBarcode,
              tooltip: 'Scan Barcode',
            ),
            if (_barcodeController.text.isNotEmpty)
              IconButton(
                icon: Icon(
                  Icons.clear,
                  color: Colors.grey[600],
                ),
                onPressed: () {
                  _barcodeController.clear();
                  setState(() {});
                },
                tooltip: 'Clear',
              ),
          ],
        ),
      ),
    );
  }

  void _scanBarcode() {
    showDialog(
      context: context,
      builder: (context) => BarcodeScannerDialog(
        onBarcodeScanned: (barcode) {
          setState(() {
            _barcodeController.text = barcode;
            _hasBarcode = true; // Auto-enable barcode when scanned
          });
          
        
        },
      ),
    );
  }

  /// Build product type selection widget
  Widget _buildProductTypeSelection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.grey[50]!,
            Colors.white,
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.grey[200]!,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Tipe Produk',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          Column(
            children: [
              _buildProductTypeOption(
                title: 'Produk Baru',
                subtitle: 'Belum ada di server, perlu foto',
                value: true,
                icon: Icons.add_circle_outline,
              ),
              const SizedBox(height: 12),
              _buildProductTypeOption(
                title: 'Restok',
                subtitle: 'Sudah ada di server, tidak perlu foto',
                value: false,
                icon: Icons.refresh,
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Build individual product type option
  Widget _buildProductTypeOption({
    required String title,
    required String subtitle,
    required bool value,
    required IconData icon,
  }) {
    final isSelected = _isNewProduct == value;
    
    return Material(
      elevation: isSelected ? 2 : 0,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: () {
          setState(() {
            _isNewProduct = value;
          });
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isSelected 
                ? AppTheme.primaryColor.withOpacity(0.1)
                : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected 
                  ? AppTheme.primaryColor.withOpacity(0.3)
                  : Colors.grey[200]!,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isSelected 
                      ? AppTheme.primaryColor
                      : Colors.grey[200],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: isSelected ? Colors.white : Colors.grey[600],
                  size: 20,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                        color: isSelected ? AppTheme.primaryColor : Colors.grey[800],
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              if (isSelected)
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.check_rounded,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  /// Build image upload section
  Widget _buildImageUploadSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.grey[50]!,
            Colors.white,
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.grey[200]!,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.photo_camera_rounded,
                  color: AppTheme.primaryColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Foto Produk',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${_productImages.length}/5',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.primaryColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Image picker buttons - Icon only
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildImagePickerButton(
                icon: Icons.camera_alt_rounded,
                onPressed: _productImages.length < 5 ? () => _pickImage(ImageSource.camera) : null,
                tooltip: 'Ambil dari Kamera',
              ),
              const SizedBox(width: 20),
              _buildImagePickerButton(
                icon: Icons.photo_library_rounded,
                onPressed: _productImages.length < 5 ? () => _pickImage(ImageSource.gallery) : null,
                tooltip: 'Pilih dari Galeri',
              ),
            ],
          ),
          
          // Display selected images
          if (_productImages.isNotEmpty) ...[
            const SizedBox(height: 20),
            const Text(
              'Foto yang dipilih:',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1,
              ),
              itemCount: _productImages.length,
              itemBuilder: (context, index) {
                return Stack(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: _buildImageWidget(_productImages[index]),
                      ),
                    ),
                    Positioned(
                      top: 6,
                      right: 6,
                      child: GestureDetector(
                        onTap: () => _removeImage(index),
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.red.withOpacity(0.3),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.close_rounded,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
          
          if (_productImages.isEmpty)
            Container(
              height: 120,
              margin: const EdgeInsets.only(top: 16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.grey[100]!,
                    Colors.grey[50]!,
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.grey[200]!,
                  style: BorderStyle.solid,
                ),
              ),
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.photo_camera_outlined,
                      size: 32,
                      color: Colors.grey,
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Belum ada foto',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// Build image picker button (icon only)
  Widget _buildImagePickerButton({
    required IconData icon,
    required VoidCallback? onPressed,
    required String tooltip,
  }) {
    return Material(
      elevation: onPressed != null ? 2 : 0,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: onPressed != null
                ? LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppTheme.primaryColor,
                      AppTheme.primaryColor.withOpacity(0.8),
                    ],
                  )
                : null,
            color: onPressed != null ? null : Colors.grey[200],
            borderRadius: BorderRadius.circular(16),
            boxShadow: onPressed != null
                ? [
                    BoxShadow(
                      color: AppTheme.primaryColor.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Icon(
            icon,
            color: onPressed != null ? Colors.white : Colors.grey[400],
            size: 28,
          ),
        ),
      ),
    );
  }

  /// Build image widget with proper validation
  Widget _buildImageWidget(String image) {
    try {
      // Check if it's a base64 string
      if (image.startsWith('data:image/') || _isBase64String(image)) {
        return Image.memory(
          base64Decode(image.replaceFirst(RegExp(r'^data:image/[^;]+;base64,'), '')),
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return _buildImageErrorWidget();
          },
        );
      }
      // Check if it's a network URL
      else if (image.startsWith('http://') || image.startsWith('https://')) {
        return Image.network(
          image,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return _buildImageErrorWidget();
          },
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Container(
              color: Colors.grey[200],
              child: Center(
                child: CircularProgressIndicator(
                  value: loadingProgress.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                      : null,
                ),
              ),
            );
          },
        );
      }
      // Check if it's a local file path
      else if (image.startsWith('/') || image.startsWith('file://')) {
        return Image.asset(
          image.replaceFirst('file://', ''),
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return _buildImageErrorWidget();
          },
        );
      }
      // Default to error widget
      else {
        return _buildImageErrorWidget();
      }
    } catch (e) {
      print('❌ Error loading image: $e');
      return _buildImageErrorWidget();
    }
  }

  /// Check if string is base64
  bool _isBase64String(String str) {
    try {
      base64Decode(str);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Check if image string is valid
  bool _isValidImage(String image) {
    if (image.isEmpty) return false;
    
    try {
      // Check if it's a base64 string
      if (image.startsWith('data:image/') || _isBase64String(image)) {
        return true;
      }
      // Check if it's a network URL
      else if (image.startsWith('http://') || image.startsWith('https://')) {
        return true;
      }
      // Check if it's a local file path
      else if (image.startsWith('/') || image.startsWith('file://')) {
        return true;
      }
      return false;
    } catch (e) {
      print('❌ Invalid image format: $e');
      return false;
    }
  }

  /// Build image error widget
  Widget _buildImageErrorWidget() {
    return Container(
      color: Colors.grey[200],
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.broken_image,
            color: Colors.grey[400],
            size: 32,
          ),
          const SizedBox(height: 4),
          Text(
            'Gagal memuat gambar',
            style: TextStyle(
              color: Colors.grey[500],
              fontSize: 10,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _submitForm() {
    // Additional validation for restock
    if (!_isNewProduct && _selectedExistingProduct == null) {
      Get.snackbar(
        'Error',
        'Pilih produk yang akan di-restok',
        snackPosition: SnackPosition.TOP,
        backgroundColor: AppTheme.errorColor,
        colorText: Colors.white,
      );
      return;
    }
    
    // Additional validation for new stock in restock
    if (!_isNewProduct && (_newStockController.text.isEmpty || int.tryParse(_newStockController.text) == null || int.parse(_newStockController.text) <= 0)) {
      Get.snackbar(
        'Error',
        'Stok baru harus diisi dan lebih dari 0',
        snackPosition: SnackPosition.TOP,
        backgroundColor: AppTheme.errorColor,
        colorText: Colors.white,
      );
      return;
    }
    
    if (_formKey.currentState!.validate()) {
      Product product;
      
      if (_isNewProduct) {
        // Create new product
        product = Product(
          id: 'prod_${DateTime.now().millisecondsSinceEpoch}',
          tenantId: 'default-tenant-id',
          sku: _skuController.text.trim(),
          name: _nameController.text.trim(),
          categoryId: _selectedCategoryId,
          description: _descriptionController.text.trim().isEmpty 
              ? null 
              : _descriptionController.text.trim(),
          unit: _selectedUnit,
          priceBuy: double.parse(_priceBuyController.text),
          priceSell: double.parse(_priceSellController.text),
          minStock: int.parse(_minStockController.text),
          photos: _productImages,
          attributes: {
            'brand': _brandController.text.trim().isEmpty ? null : _brandController.text.trim(),
            'variant': _variantController.text.trim().isEmpty ? null : _variantController.text.trim(),
            'pack_size': _packSizeController.text.trim().isEmpty ? null : _packSizeController.text.trim(),
            'uom': _selectedUnit,
            'reorder_point': _reorderPointController.text.trim().isEmpty 
                ? null 
                : int.tryParse(_reorderPointController.text.trim()),
            'reorder_qty': _reorderQtyController.text.trim().isEmpty 
                ? null 
                : int.tryParse(_reorderQtyController.text.trim()),
          },
          barcode: _hasBarcode && _barcodeController.text.trim().isNotEmpty 
              ? _barcodeController.text.trim() 
              : null,
          hasBarcode: _hasBarcode,
          isExpirable: _isExpirable,
          isActive: _isActive,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          syncStatus: 'pending',
          lastSyncedAt: null,
        );
      } else {
        // Update existing product (restock)
        final newStock = int.parse(_newStockController.text);
        final totalStock = _currentStock + newStock;
        
        product = _selectedProductData!.copyWith(
          priceBuy: double.parse(_priceBuyController.text),
          priceSell: double.parse(_priceSellController.text),
          updatedAt: DateTime.now(),
          syncStatus: 'pending',
          lastSyncedAt: null,
        );
        
        // TODO: Update stock in database
        print('📦 Restock: ${product.name}');
        print('📊 Current Stock: $_currentStock');
        print('➕ New Stock: $newStock');
        print('📈 Total Stock: $totalStock');
      }

      widget.onSubmit(product);
      Get.back();
    }
  }
}
