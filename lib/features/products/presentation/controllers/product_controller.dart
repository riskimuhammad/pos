import 'package:get/get.dart';
import 'package:pos/core/errors/failures.dart';
import 'package:pos/features/products/domain/usecases/get_products.dart';
import 'package:pos/features/products/domain/usecases/create_product.dart';
import 'package:pos/features/products/domain/usecases/search_products.dart';
import 'package:pos/shared/models/entities/entities.dart';

class ProductController extends GetxController {
  final GetProducts getProducts;
  final CreateProduct createProduct;
  final SearchProducts searchProducts;

  ProductController({
    required this.getProducts,
    required this.createProduct,
    required this.searchProducts,
  });

  // Observable variables
  final RxList<Product> products = <Product>[].obs;
  final RxList<Product> filteredProducts = <Product>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isCreating = false.obs;
  final RxString searchQuery = ''.obs;
  final RxString selectedCategoryId = ''.obs;
  final RxString errorMessage = ''.obs;

  // Getters
  List<Product> get allProducts => products;
  List<Product> get displayedProducts => filteredProducts.isEmpty ? products : filteredProducts;
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

      // TODO: Get tenant ID from auth service
      const tenantId = 'default-tenant-id';
      
      final result = await getProducts(tenantId);
      result.fold(
        (failure) => _handleFailure(failure),
        (productList) {
          products.value = productList;
          _applyFilters();
        },
      );
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
        (createdProduct) {
          products.add(createdProduct);
          _applyFilters();
          Get.snackbar('Success', 'Product created successfully');
        },
      );
    } catch (e) {
      errorMessage.value = 'Failed to create product: $e';
    } finally {
      isCreating.value = false;
    }
  }

  Future<void> performSearch(String query) async {
    try {
      searchQuery.value = query;
      
      if (query.trim().isEmpty) {
        filteredProducts.clear();
        _applyFilters();
        return;
      }

      final result = await searchProducts(query);
      result.fold(
        (failure) => _handleFailure(failure),
        (searchResults) {
          filteredProducts.value = searchResults;
        },
      );
    } catch (e) {
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

  void _applyFilters() {
    if (searchQuery.value.isEmpty && selectedCategoryId.value.isEmpty) {
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
      return products.firstWhere((product) => product.barcode == barcode);
    } catch (e) {
      return null;
    }
  }

  List<Product> getProductsByCategory(String categoryId) {
    return products.where((product) => product.categoryId == categoryId).toList();
  }

  List<Product> getLowStockProducts() {
    return products.where((product) => product.minStock > 0).toList();
  }
}
