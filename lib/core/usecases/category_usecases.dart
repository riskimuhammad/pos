import 'package:pos/core/repositories/category_repository.dart';
import 'package:pos/shared/models/entities/entities.dart';

class GetCategoriesUseCase {
  final CategoryRepository _repository;

  GetCategoriesUseCase(this._repository);

  Future<List<Category>> call() async {
    return await _repository.getCategories();
  }
}

class CreateCategoryUseCase {
  final CategoryRepository _repository;

  CreateCategoryUseCase(this._repository);

  Future<Category> call(Category category) async {
    // Validate category name
    if (category.name.trim().isEmpty) {
      throw Exception('Category name cannot be empty');
    }
    
    if (category.name.trim().length < 2) {
      throw Exception('Category name must be at least 2 characters');
    }
    
    // Check if category name already exists
    final nameExists = await _repository.categoryNameExists(category.name.trim());
    if (nameExists) {
      throw Exception('Category name already exists');
    }
    
    return await _repository.createCategory(category);
  }
}

class UpdateCategoryUseCase {
  final CategoryRepository _repository;

  UpdateCategoryUseCase(this._repository);

  Future<Category> call(Category category) async {
    // Validate category name
    if (category.name.trim().isEmpty) {
      throw Exception('Category name cannot be empty');
    }
    
    if (category.name.trim().length < 2) {
      throw Exception('Category name must be at least 2 characters');
    }
    
    // Check if category name already exists (excluding current category)
    final nameExists = await _repository.categoryNameExists(
      category.name.trim(),
      excludeId: category.id,
    );
    if (nameExists) {
      throw Exception('Category name already exists');
    }
    
    return await _repository.updateCategory(category);
  }
}

class DeleteCategoryUseCase {
  final CategoryRepository _repository;

  DeleteCategoryUseCase(this._repository);

  Future<void> call(String categoryId) async {
    if (categoryId.trim().isEmpty) {
      throw Exception('Category ID cannot be empty');
    }
    
    return await _repository.deleteCategory(categoryId);
  }
}

class SearchCategoriesUseCase {
  final CategoryRepository _repository;

  SearchCategoriesUseCase(this._repository);

  Future<List<Category>> call(String query) async {
    if (query.trim().isEmpty) {
      return await _repository.getCategories();
    }
    
    return await _repository.searchCategories(query.trim());
  }
}
