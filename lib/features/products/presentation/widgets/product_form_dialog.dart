import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pos/core/theme/app_theme.dart';
// import 'package:pos/core/localization/language_controller.dart';
import 'package:pos/shared/models/entities/entities.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:pos/features/products/presentation/widgets/barcode_scanner_dialog.dart';
import 'package:pos/features/products/presentation/widgets/category_search_dialog.dart';
import 'package:pos/features/products/presentation/widgets/unit_search_dialog.dart';
import 'package:pos/core/controllers/unit_controller.dart';
import 'package:pos/core/controllers/category_controller.dart';
import 'package:pos/core/storage/local_datasource.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:convert';
import 'package:intl/intl.dart';

import '../../../../core/api/unit_api_service.dart';
import '../../../../core/network/network_info.dart';
import '../../../../core/repositories/unit_repository.dart';
import '../../../../core/repositories/unit_repository_impl.dart';
import '../../../../core/usecases/unit_usecases.dart';

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

  String? _selectedCategoryId; // No default - user must add category first
  String? _selectedUnitId; // No default - user must add unit first
  bool _isActive = true;
  bool _isExpirable = false;
  bool _hasBarcode = false;
  bool _isNewProduct = true; // true for new product, false for existing product
  List<String> _productImages = []; // List of base64 encoded images
  List<Category> _categories = []; // List of categories
  DateTime? _expiryDate; // Expiry date for expirable products

  final ImagePicker _imagePicker = ImagePicker();
  late UnitController _unitController;
  // late LanguageController _languageController;

  @override
  void initState() {
    super.initState();
    // _languageController = Get.find<LanguageController>();
   _setupInit();
    _initializeForm();
    _loadCategories();
    _loadUnits();
  }
_setupInit(){
  if (!Get.isRegistered<UnitController>()) {
    Get.put<Dio>(Dio());
    Get.put<UnitApiService>(UnitApiService(
      dio: Get.find<Dio>(),
    ));
    Get.put<UnitRepository>(UnitRepositoryImpl(
      localDataSource: Get.find<LocalDataSource>(),
      unitApiService: Get.isRegistered<UnitApiService>() ? Get.find<UnitApiService>() : null,
      networkInfo: Get.find<NetworkInfo>(),
    ));
    Get.put<GetUnitsUseCase>(GetUnitsUseCase(
      Get.find<UnitRepository>(),
    ));
    Get.put<CreateUnitUseCase>(CreateUnitUseCase(
      Get.find<UnitRepository>(),
    ));
    Get.put<UpdateUnitUseCase>(UpdateUnitUseCase(
      Get.find<UnitRepository>(),
    ));
    Get.put<DeleteUnitUseCase>(DeleteUnitUseCase(
      Get.find<UnitRepository>(),
    ));
    Get.put<SearchUnitsUseCase>(SearchUnitsUseCase(
      Get.find<UnitRepository>(),
    ));
  _unitController =  Get.put<UnitController>(UnitController(
      getUnitsUseCase: Get.find<GetUnitsUseCase>(),
      createUnitUseCase: Get.find<CreateUnitUseCase>(),
      updateUnitUseCase: Get.find<UpdateUnitUseCase>(),
      deleteUnitUseCase: Get.find<DeleteUnitUseCase>(),
      searchUnitsUseCase: Get.find<SearchUnitsUseCase>(),
    ));
  }else{
   _unitController = Get.find<UnitController>();

  }
 
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
      // Load from local database
      if (Get.isRegistered<CategoryController>()) {
        final categoryController = Get.find<CategoryController>();
        await categoryController.loadCategories();
        _categories = categoryController.categories;
      } else {
        print('⚠️ CategoryController not registered, loading from service directly');
        // Fallback: load directly from datasource
        final localDataSource = Get.find<LocalDataSource>();
        _categories = await localDataSource.getCategoriesByTenant('default-tenant-id');
      }
    } catch (e) {
      print('❌ Failed to load categories: $e');
      _categories = [];
    }
  }

  /// Load units from database
  Future<void> _loadUnits() async {
    try {
      if (Get.isRegistered<UnitController>()) {
        await _unitController.loadUnits();
        // Units loaded from controller
      } else {
        print('⚠️ UnitController not registered, loading from service directly');
        // Fallback: load directly from datasource
        final localDataSource = Get.find<LocalDataSource>();
        await localDataSource.getUnitsByTenant('default-tenant-id');
      }
      // No default seeding - users must add their own units
    } catch (e) {
      print('❌ Failed to load units: $e');
    }
  }

  /// Get category name by ID
  String _getCategoryName(String? categoryId) {
    if (categoryId == null) return 'Pilih Kategori';
    final category = _categories.firstWhereOrNull((cat) => cat.id == categoryId);
    return category?.name ?? 'Kategori Tidak Ditemukan';
  }

  /// Get unit name by ID
  String _getUnitName(String? unitId) {
    if (unitId == null) return 'Pilih Satuan';
    final unit = _unitController.getUnitById(unitId);
    return unit?.name ?? 'Satuan Tidak Ditemukan';
  }

  /// Validate that category and unit exist before saving product
  bool _validateCategoryAndUnit() {
    // Check if category is selected and exists
    if (_selectedCategoryId == null) {
      Get.snackbar(
        'Kategori Belum Dipilih',
        'Silakan pilih atau tambahkan kategori terlebih dahulu.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: AppTheme.errorColor,
        colorText: Colors.white,
        duration: const Duration(seconds: 4),
        mainButton: TextButton(
          onPressed: () {
            Get.back(); // Close snackbar
            _showCategorySearchDialog(); // Open category dialog
          },
          child: const Text(
            'Pilih Kategori',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
      );
      return false;
    }

    final categoryExists = _categories.any((cat) => cat.id == _selectedCategoryId);
    if (!categoryExists) {
      Get.snackbar(
        'Kategori Tidak Ditemukan',
        'Kategori yang dipilih tidak ditemukan. Silakan pilih kategori lain atau tambahkan kategori baru.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: AppTheme.errorColor,
        colorText: Colors.white,
        duration: const Duration(seconds: 4),
        mainButton: TextButton(
          onPressed: () {
            Get.back(); // Close snackbar
            _showCategorySearchDialog(); // Open category dialog
          },
          child: const Text(
            'Pilih Kategori',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
      );
      return false;
    }

    // Check if unit is selected and exists
    if (_selectedUnitId == null) {
      Get.snackbar(
        'Satuan Belum Dipilih',
        'Silakan pilih atau tambahkan satuan terlebih dahulu.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: AppTheme.errorColor,
        colorText: Colors.white,
        duration: const Duration(seconds: 4),
        mainButton: TextButton(
          onPressed: () {
            Get.back(); // Close snackbar
            _showUnitSearchDialog(); // Open unit dialog
          },
          child: const Text(
            'Pilih Satuan',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
      );
      return false;
    }

    final unitExists = _unitController.units.any((unit) => unit.id == _selectedUnitId);
    if (!unitExists) {
      Get.snackbar(
        'Satuan Tidak Ditemukan',
        'Satuan yang dipilih tidak ditemukan. Silakan pilih satuan lain atau tambahkan satuan baru.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: AppTheme.errorColor,
        colorText: Colors.white,
        duration: const Duration(seconds: 4),
        mainButton: TextButton(
          onPressed: () {
            Get.back(); // Close snackbar
            _showUnitSearchDialog(); // Open unit dialog
          },
          child: const Text(
            'Pilih Satuan',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
      );
      return false;
    }

    return true;
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
        onAddCategory: (category) async {
          // Refresh categories from database
          await _loadCategories();
          setState(() {
            _selectedCategoryId = category.id;
          });
        },
      ),
    );
  }

  /// Show unit search dialog
  void _showUnitSearchDialog() {
    showDialog(
      context: context,
      builder: (context) => UnitSearchDialog(
        units: _unitController.units,
        selectedUnitId: _selectedUnitId,
        onUnitSelected: (unit) {
          setState(() {
            _selectedUnitId = unit.id;
          });
        },
        onAddUnit: (unit) async {
          // Refresh units from database
          await _loadUnits();
          setState(() {
            _selectedUnitId = unit.id;
          });
        },
      ),
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
      _selectedCategoryId = product.categoryId;
      // Find unit by name and set ID
      final unit = _unitController.getUnitByName(product.unit);
      _selectedUnitId = unit?.id;
      _isActive = product.isActive;
      _isExpirable = product.isExpirable;
      _hasBarcode = product.hasBarcode;
      
      // Load expiry date if available
      if (product.attributes['expiry_date'] != null) {
        try {
          _expiryDate = DateTime.parse(product.attributes['expiry_date']);
        } catch (e) {
          print('❌ Error parsing expiry date: $e');
          _expiryDate = null;
        }
      }
      
      // Load existing images if any
      if (product.photos.isNotEmpty) {
        _productImages = List<String>.from(product.photos);
        // Filter out invalid images
        _productImages = _productImages.where((image) => _isValidImage(image)).toList();
      }
      
      // This is edit mode, not a new product
      _isNewProduct = false;
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
                  isEdit ? AppLocalizations.of(context)!.editProduct : AppLocalizations.of(context)!.newProduct,
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
                   
                      
                      
                      // Image Upload
                      _buildSectionTitle('Foto Produk'),
                      const SizedBox(height: 12),
                      _buildImageUploadSection(),
                      const SizedBox(height: 20),
                      const SizedBox(height: 12),
                         // Basic Information
                      _buildSectionTitle('Informasi Dasar'),
                         const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: _buildTextFormField(
                              controller: _nameController,
                              label: 'Nama Produk *',
                              hint: 'Masukkan nama produk',
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Nama produk harus diisi';
                                }
                                return null;
                              },
                            ),
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
                        label: AppLocalizations.of(context)!.productDescription,
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
                      const SizedBox(height: 20),
                      
                      // Product Details
                      _buildSectionTitle('Detail Produk'),
                      const SizedBox(height: 12),
                      
                      Column(
                        children: [
                          _buildTextFormField(
                            controller: _brandController,
                            label: AppLocalizations.of(context)!.productBrand,
                            hint: 'Nama brand',
                          ),
                          const SizedBox(height: 16),
                          _buildTextFormField(
                            controller: _variantController,
                            label: AppLocalizations.of(context)!.productVariant,
                            hint: 'Variant produk',
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      
                      Column(
                        children: [
                          _buildTextFormField(
                            controller: _packSizeController,
                            label: AppLocalizations.of(context)!.packSize,
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
                      _buildSectionTitle(AppLocalizations.of(context)!.productBarcode),
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
                              onChanged: (value) => setState(() {
                                _isExpirable = value;
                                if (!value) {
                                  _expiryDate = null; // Clear expiry date if disabled
                                }
                              }),
                            ),
                          ),
                        ],
                      ),
                      
                      // Expiry date field (only show if expirable is enabled)
                      if (_isExpirable) ...[
                        const SizedBox(height: 20),
                        _buildExpiryDateField(),
                      ],
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
                    child: Text(AppLocalizations.of(context)!.cancel),
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
                      isEdit ? AppLocalizations.of(context)!.update : AppLocalizations.of(context)!.save,
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Satuan *',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: _showUnitSearchDialog,
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
                    _getUnitName(_selectedUnitId),
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
        labelText: AppLocalizations.of(context)!.productBarcode,
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

  /// Build expiry date field
  Widget _buildExpiryDateField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Tanggal Kadaluarsa *',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: _selectExpiryDate,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[400]!),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  color: Colors.grey[600],
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _expiryDate != null 
                        ? DateFormat('dd MMMM yyyy', 'id').format(_expiryDate!)
                        : 'Pilih tanggal kadaluarsa',
                    style: TextStyle(
                      fontSize: 16,
                      color: _expiryDate != null 
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

  /// Select expiry date
  Future<void> _selectExpiryDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _expiryDate ?? DateTime.now().add(const Duration(days: 30)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)), // 5 years from now
      locale: const Locale('id', 'ID'),
    );
    
    if (picked != null && picked != _expiryDate) {
      setState(() {
        _expiryDate = picked;
      });
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
    
    // Additional validation for expiry date
    if (_isExpirable && _expiryDate == null) {
      Get.snackbar(
        'Error',
        'Tanggal kadaluarsa harus diisi untuk produk expirable',
        snackPosition: SnackPosition.TOP,
        backgroundColor: AppTheme.errorColor,
        colorText: Colors.white,
      );
      return;
    }
    
    if (_formKey.currentState!.validate()) {
      // Validate that category and unit exist
      if (!_validateCategoryAndUnit()) {
        return;
      }
      
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
          unit: _getUnitName(_selectedUnitId),
          priceBuy: double.parse(_priceBuyController.text),
          priceSell: double.parse(_priceSellController.text),
          minStock: int.parse(_minStockController.text),
          photos: _productImages,
          attributes: {
            'brand': _brandController.text.trim().isEmpty ? null : _brandController.text.trim(),
            'variant': _variantController.text.trim().isEmpty ? null : _variantController.text.trim(),
            'pack_size': _packSizeController.text.trim().isEmpty ? null : _packSizeController.text.trim(),
            'uom': _getUnitName(_selectedUnitId),
            'reorder_point': _reorderPointController.text.trim().isEmpty 
                ? null 
                : int.tryParse(_reorderPointController.text.trim()),
            'reorder_qty': _reorderQtyController.text.trim().isEmpty 
                ? null 
                : int.tryParse(_reorderQtyController.text.trim()),
            'expiry_date': _isExpirable && _expiryDate != null 
                ? _expiryDate!.toIso8601String() 
                : null,
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
        // Update existing product (edit mode)
        product = widget.product!.copyWith(
          sku: _skuController.text.trim(),
          name: _nameController.text.trim(),
          categoryId: _selectedCategoryId,
          description: _descriptionController.text.trim().isEmpty 
              ? null 
              : _descriptionController.text.trim(),
          unit: _getUnitName(_selectedUnitId),
          priceBuy: double.parse(_priceBuyController.text),
          priceSell: double.parse(_priceSellController.text),
          minStock: int.parse(_minStockController.text),
          photos: _productImages,
          attributes: {
            'brand': _brandController.text.trim().isEmpty ? null : _brandController.text.trim(),
            'variant': _variantController.text.trim().isEmpty ? null : _variantController.text.trim(),
            'pack_size': _packSizeController.text.trim().isEmpty ? null : _packSizeController.text.trim(),
            'uom': _getUnitName(_selectedUnitId),
            'reorder_point': _reorderPointController.text.trim().isEmpty 
                ? null 
                : int.tryParse(_reorderPointController.text.trim()),
            'reorder_qty': _reorderQtyController.text.trim().isEmpty 
                ? null 
                : int.tryParse(_reorderQtyController.text.trim()),
            'expiry_date': _isExpirable && _expiryDate != null 
                ? _expiryDate!.toIso8601String() 
                : null,
          },
          barcode: _hasBarcode && _barcodeController.text.trim().isNotEmpty 
              ? _barcodeController.text.trim() 
              : null,
          hasBarcode: _hasBarcode,
          isExpirable: _isExpirable,
          isActive: _isActive,
          updatedAt: DateTime.now(),
          syncStatus: 'pending',
          lastSyncedAt: null,
        );
        
        print('✏️ Edit Product: ${product.name}');
        print('📊 Updated SKU: ${product.sku}');
        print('💰 Updated Price: ${product.priceSell}');
      }

      widget.onSubmit(product);
      Get.back();
    }
  }
}
