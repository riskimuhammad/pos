import 'package:get/get.dart';
import 'package:pos/core/usecases/category_usecases.dart';
import 'package:pos/shared/models/entities/entities.dart';

class CategoryController extends GetxController {
  final GetCategoriesUseCase _getCategoriesUseCase;
  final CreateCategoryUseCase _createCategoryUseCase;
  final UpdateCategoryUseCase _updateCategoryUseCase;
  final DeleteCategoryUseCase _deleteCategoryUseCase;
  final SearchCategoriesUseCase _searchCategoriesUseCase;

  CategoryController({
    required GetCategoriesUseCase getCategoriesUseCase,
    required CreateCategoryUseCase createCategoryUseCase,
    required UpdateCategoryUseCase updateCategoryUseCase,
    required DeleteCategoryUseCase deleteCategoryUseCase,
    required SearchCategoriesUseCase searchCategoriesUseCase,
  }) : _getCategoriesUseCase = getCategoriesUseCase,
       _createCategoryUseCase = createCategoryUseCase,
       _updateCategoryUseCase = updateCategoryUseCase,
       _deleteCategoryUseCase = deleteCategoryUseCase,
       _searchCategoriesUseCase = searchCategoriesUseCase;

  // Observable state
  final RxList<Category> _categories = <Category>[].obs;
  final RxBool _isLoading = false.obs;
  final RxString _searchQuery = ''.obs;
  final RxList<Category> _filteredCategories = <Category>[].obs;

  // Getters
  List<Category> get categories => _categories;
  bool get isLoading => _isLoading.value;
  String get searchQuery => _searchQuery.value;
  List<Category> get filteredCategories => _filteredCategories;

  @override
  void onInit() {
    super.onInit();
    loadCategories();
  }

  /// Load all categories
  Future<void> loadCategories() async {
    try {
      _isLoading.value = true;
      final categories = await _getCategoriesUseCase();
      _categories.assignAll(categories);
      _filteredCategories.assignAll(categories);
    } catch (e) {
      print('❌ Error loading categories: $e');
      Get.snackbar(
        'Error',
        'Failed to load categories: $e',
        snackPosition: SnackPosition.TOP,
      );
    } finally {
      _isLoading.value = false;
    }
  }

  /// Create new category
  Future<void> createCategory(Category category) async {
    try {
      _isLoading.value = true;
      final createdCategory = await _createCategoryUseCase(category);
      _categories.add(createdCategory);
      _filteredCategories.add(createdCategory);
     
    } catch (e) {
      print('❌ Error creating category: $e');
      Get.snackbar(
        'Error',
        'Failed to create category: $e',
        snackPosition: SnackPosition.TOP,
      );
    } finally {
      _isLoading.value = false;
    }
  }

  /// Update category
  Future<void> updateCategory(Category category) async {
    try {
      _isLoading.value = true;
      final updatedCategory = await _updateCategoryUseCase(category);
      
      // Update in lists
      final index = _categories.indexWhere((c) => c.id == category.id);
      if (index != -1) {
        _categories[index] = updatedCategory;
      }
      
      final filteredIndex = _filteredCategories.indexWhere((c) => c.id == category.id);
      if (filteredIndex != -1) {
        _filteredCategories[filteredIndex] = updatedCategory;
      }
      
    
    } catch (e) {
      print('❌ Error updating category: $e');
      Get.snackbar(
        'Error',
        'Failed to update category: $e',
        snackPosition: SnackPosition.TOP,
      );
    } finally {
      _isLoading.value = false;
    }
  }

  /// Delete category
  Future<void> deleteCategory(String categoryId) async {
    try {
      _isLoading.value = true;
      await _deleteCategoryUseCase(categoryId);
      
      // Remove from lists
      _categories.removeWhere((c) => c.id == categoryId);
      _filteredCategories.removeWhere((c) => c.id == categoryId);
   
    } catch (e) {
      print('❌ Error deleting category: $e');
      Get.snackbar(
        'Error',
        'Failed to delete category: $e',
        snackPosition: SnackPosition.TOP,
      );
    } finally {
      _isLoading.value = false;
    }
  }

  /// Search categories
  Future<void> searchCategories(String query) async {
    try {
      _searchQuery.value = query;
      
      if (query.trim().isEmpty) {
        _filteredCategories.assignAll(_categories);
        return;
      }
      
      final results = await _searchCategoriesUseCase(query);
      _filteredCategories.assignAll(results);
    } catch (e) {
      print('❌ Error searching categories: $e');
      Get.snackbar(
        'Error',
        'Failed to search categories: $e',
        snackPosition: SnackPosition.TOP,
      );
    }
  }

  /// Clear search
  void clearSearch() {
    _searchQuery.value = '';
    _filteredCategories.assignAll(_categories);
  }

  /// Get category by ID
  Category? getCategoryById(String id) {
    try {
      return _categories.firstWhere((category) => category.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Get category by name
  Category? getCategoryByName(String name) {
    try {
      return _categories.firstWhere((category) => category.name.toLowerCase() == name.toLowerCase());
    } catch (e) {
      return null;
    }
  }

  /// Refresh categories
  Future<void> refreshCategories() async {
    await loadCategories();
  }
}
