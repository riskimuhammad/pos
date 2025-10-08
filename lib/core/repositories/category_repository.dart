import 'package:pos/shared/models/entities/entities.dart';

abstract class CategoryRepository {
  /// Get all categories
  Future<List<Category>> getCategories();

  /// Get category by ID
  Future<Category?> getCategoryById(String id);

  /// Create new category
  Future<Category> createCategory(Category category);

  /// Update category
  Future<Category> updateCategory(Category category);

  /// Delete category
  Future<void> deleteCategory(String id);

  /// Search categories by name
  Future<List<Category>> searchCategories(String query);

  /// Check if category name exists
  Future<bool> categoryNameExists(String name, {String? excludeId});

  /// Sync categories with server
  Future<void> syncCategories();

  /// Get categories from server
  Future<List<Category>> getCategoriesFromServer();

  /// Create category on server
  Future<Category> createCategoryOnServer(Category category);

  /// Update category on server
  Future<Category> updateCategoryOnServer(Category category);

  /// Delete category from server
  Future<void> deleteCategoryFromServer(String id);
}
