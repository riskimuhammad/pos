import 'package:pos/core/network/network_info.dart';
import 'package:pos/core/storage/local_datasource.dart';
import 'package:pos/core/api/category_api_service.dart';
import 'package:pos/core/repositories/category_repository.dart';
import 'package:pos/shared/models/entities/entities.dart';
import 'package:pos/core/constants/app_constants.dart';
import 'package:pos/features/auth/presentation/controllers/auth_controller.dart';
import 'package:get/get.dart';

class CategoryRepositoryImpl implements CategoryRepository {
  final LocalDataSource _localDataSource;
  final CategoryApiService? _categoryApiService;
  final NetworkInfo _networkInfo;

  CategoryRepositoryImpl({
    required LocalDataSource localDataSource,
    CategoryApiService? categoryApiService,
    required NetworkInfo networkInfo,
  }) : _localDataSource = localDataSource,
       _categoryApiService = categoryApiService,
       _networkInfo = networkInfo;

  /// Get current tenant ID from auth session
  String _getCurrentTenantId() {
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

  @override
  Future<List<Category>> getCategories() async {
    try {
      final tenantId = _getCurrentTenantId();
      // Always get from local first
      final localCategories = await _localDataSource.getCategoriesByTenant(tenantId);
      
      // If API is enabled and online, sync with server
      if (AppConstants.kEnableRemoteApi && 
          _categoryApiService != null && 
          await _networkInfo.isConnected) {
        try {
          await syncCategories();
          // Return updated local categories after sync
          return await _localDataSource.getCategoriesByTenant(tenantId);
        } catch (e) {
          print('⚠️ Failed to sync categories, using local data: $e');
        }
      }
      
      return localCategories;
    } catch (e) {
      print('❌ Error getting categories: $e');
      return [];
    }
  }

  @override
  Future<Category?> getCategoryById(String id) async {
    try {
      return await _localDataSource.getCategory(id);
    } catch (e) {
      print('❌ Error getting category by ID: $e');
      return null;
    }
  }

  @override
  Future<Category> createCategory(Category category) async {
    try {
      // Save to local first
      final createdCategory = await _localDataSource.createCategory(category);
      
      // If API is enabled and online, sync to server
      if (AppConstants.kEnableRemoteApi && 
          _categoryApiService != null && 
          await _networkInfo.isConnected) {
        try {
          await createCategoryOnServer(createdCategory);
        } catch (e) {
          print('⚠️ Failed to sync category to server: $e');
          // Add to pending sync queue
          await _localDataSource.addToPendingSyncQueue(
            'CREATE',
            'categories',
            createdCategory.toJson(),
          );
        }
      }
      
      return createdCategory;
    } catch (e) {
      print('❌ Error creating category: $e');
      rethrow;
    }
  }

  @override
  Future<Category> updateCategory(Category category) async {
    try {
      // Update local first
      final updatedCategory = await _localDataSource.updateCategory(category);
      
      // If API is enabled and online, sync to server
      if (AppConstants.kEnableRemoteApi && 
          _categoryApiService != null && 
          await _networkInfo.isConnected) {
        try {
          await updateCategoryOnServer(updatedCategory);
        } catch (e) {
          print('⚠️ Failed to sync category update to server: $e');
          // Add to pending sync queue
          await _localDataSource.addToPendingSyncQueue(
            'UPDATE',
            'categories',
            updatedCategory.toJson(),
          );
        }
      }
      
      return updatedCategory;
    } catch (e) {
      print('❌ Error updating category: $e');
      rethrow;
    }
  }

  @override
  Future<void> deleteCategory(String id) async {
    try {
      // Delete from local first
      await _localDataSource.deleteCategory(id);
      
      // If API is enabled and online, sync to server
      if (AppConstants.kEnableRemoteApi && 
          _categoryApiService != null && 
          await _networkInfo.isConnected) {
        try {
          await deleteCategoryFromServer(id);
        } catch (e) {
          print('⚠️ Failed to sync category deletion to server: $e');
          // Add to pending sync queue
          await _localDataSource.addToPendingSyncQueue(
            'DELETE',
            'categories',
            null,
            entityId: id,
          );
        }
      }
    } catch (e) {
      print('❌ Error deleting category: $e');
      rethrow;
    }
  }

  @override
  Future<List<Category>> searchCategories(String query) async {
    try {
      final tenantId = _getCurrentTenantId();
      // For now, use local search - can be enhanced with API search later
      final allCategories = await _localDataSource.getCategoriesByTenant(tenantId);
      return allCategories.where((category) => 
        category.name.toLowerCase().contains(query.toLowerCase())
      ).toList();
    } catch (e) {
      print('❌ Error searching categories: $e');
      return [];
    }
  }

  @override
  Future<bool> categoryNameExists(String name, {String? excludeId}) async {
    try {
      final tenantId = _getCurrentTenantId();
      final categories = await _localDataSource.getCategoriesByTenant(tenantId);
      return categories.any((category) => 
        category.name.toLowerCase() == name.toLowerCase() && 
        category.id != excludeId
      );
    } catch (e) {
      print('❌ Error checking category name: $e');
      return false;
    }
  }

  @override
  Future<void> syncCategories() async {
    if (!AppConstants.kEnableRemoteApi || _categoryApiService == null) {
      print('⚠️ API sync disabled, skipping category sync');
      return;
    }

    try {
      final tenantId = _getCurrentTenantId();
      // Get categories from server
      final serverCategories = await getCategoriesFromServer();
      
      // Get local categories
      final localCategories = await _localDataSource.getCategoriesByTenant(tenantId);
      
      // Sync logic: update local with server data
      for (final serverCategory in serverCategories) {
        final localCategory = localCategories.firstWhere(
          (category) => category.id == serverCategory.id,
          orElse: () => Category(
            id: '',
            tenantId: '',
            name: '',
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        );
        
        if (localCategory.id.isEmpty) {
          // New category from server, add to local
          await _localDataSource.createCategory(serverCategory);
        } else if (serverCategory.updatedAt.isAfter(localCategory.updatedAt)) {
          // Server has newer version, update local
          await _localDataSource.updateCategory(serverCategory);
        }
      }
      
      print('✅ Categories synced successfully');
    } catch (e) {
      print('❌ Error syncing categories: $e');
      rethrow;
    }
  }

  @override
  Future<List<Category>> getCategoriesFromServer() async {
    if (_categoryApiService == null) {
      throw Exception('CategoryApiService not available');
    }
    
    try {
      final tenantId = _getCurrentTenantId();
      return await _categoryApiService.getCategories(
        tenantId: tenantId,
      );
    } catch (e) {
      print('❌ Error getting categories from server: $e');
      rethrow;
    }
  }

  @override
  Future<Category> createCategoryOnServer(Category category) async {
    if (_categoryApiService == null) {
      throw Exception('CategoryApiService not available');
    }
    
    try {
      return await _categoryApiService.createCategory(category);
    } catch (e) {
      print('❌ Error creating category on server: $e');
      rethrow;
    }
  }

  @override
  Future<Category> updateCategoryOnServer(Category category) async {
    if (_categoryApiService == null) {
      throw Exception('CategoryApiService not available');
    }
    
    try {
      return await _categoryApiService.updateCategory(category);
    } catch (e) {
      print('❌ Error updating category on server: $e');
      rethrow;
    }
  }

  @override
  Future<void> deleteCategoryFromServer(String id) async {
    if (_categoryApiService == null) {
      throw Exception('CategoryApiService not available');
    }
    
    try {
      await _categoryApiService.deleteCategory(id);
    } catch (e) {
      print('❌ Error deleting category from server: $e');
      rethrow;
    }
  }
}
