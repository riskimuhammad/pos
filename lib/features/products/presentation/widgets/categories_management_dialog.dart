import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pos/core/theme/app_theme.dart';
import 'package:pos/core/controllers/category_controller.dart';
import 'package:pos/shared/models/entities/entities.dart';
import 'package:pos/features/products/presentation/widgets/add_category_dialog.dart';

class CategoriesManagementDialog extends StatefulWidget {
  const CategoriesManagementDialog({super.key});

  @override
  State<CategoriesManagementDialog> createState() => _CategoriesManagementDialogState();
}

class _CategoriesManagementDialogState extends State<CategoriesManagementDialog> {
  final CategoryController _categoryController = Get.find<CategoryController>();
  final TextEditingController _searchController = TextEditingController();
  List<Category> _filteredCategories = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCategories();
    _searchController.addListener(_filterCategories);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadCategories() async {
    setState(() => _isLoading = true);
    try {
      await _categoryController.loadCategories();
      _filteredCategories = _categoryController.categories;
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal memuat kategori: $e',
        snackPosition: SnackPosition.TOP,
        backgroundColor: AppTheme.errorColor,
        colorText: Colors.white,
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _filterCategories() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredCategories = _categoryController.categories;
      } else {
        _filteredCategories = _categoryController.categories
            .where((category) => category.name.toLowerCase().contains(query))
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.8,
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Header
            Row(
              children: [
                Icon(
                  Icons.category,
                  color: AppTheme.primaryColor,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Kelola Kategori',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryColor,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  onPressed: () => Get.back(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 20),
            
            // Search Bar
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Cari kategori...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
            const SizedBox(height: 16),
            
            // Add Category Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _showAddCategoryDialog,
                icon: const Icon(Icons.add),
                label: const Text('Tambah Kategori'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            
            // Categories List
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _filteredCategories.isEmpty
                      ? _buildEmptyState()
                      : ListView.builder(
                          itemCount: _filteredCategories.length,
                          itemBuilder: (context, index) {
                            final category = _filteredCategories[index];
                            return _buildCategoryCard(category);
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.category_outlined,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            _searchController.text.isEmpty
                ? 'Belum ada kategori'
                : 'Kategori tidak ditemukan',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _searchController.text.isEmpty
                ? 'Tambahkan kategori pertama Anda'
                : 'Coba kata kunci lain',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryCard(Category category) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
          child: Icon(
            Icons.category,
            color: AppTheme.primaryColor,
          ),
        ),
        title: Text(
          category.name,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        subtitle: Text(
          'ID: ${category.id}',
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 12,
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              onPressed: () => _showEditCategoryDialog(category),
              icon: const Icon(Icons.edit, size: 20),
              color: AppTheme.primaryColor,
              tooltip: 'Edit',
            ),
            IconButton(
              onPressed: () => _showDeleteConfirmation(category),
              icon: const Icon(Icons.delete, size: 20),
              color: Colors.red[400],
              tooltip: 'Hapus',
            ),
          ],
        ),
      ),
    );
  }

  void _showAddCategoryDialog() {
    Get.dialog(
      AddCategoryDialog(
        onSubmit: (category) {
          _loadCategories(); // Reload categories
         Navigator.of(context).pop(category);
          Get.snackbar(
        'Berhasil',
        'Kategori "${category.name}" berhasil ditambahkan',
        snackPosition: SnackPosition.TOP,
        backgroundColor: AppTheme.successColor,
        colorText: Colors.white,
      );
        },
      ),
    );

  }

  void _showEditCategoryDialog(Category category) {
    final TextEditingController nameController = TextEditingController(text: category.name);
    
    Get.dialog(
      AlertDialog(
        title: const Text('Edit Kategori'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Nama Kategori',
                border: OutlineInputBorder(),
              ),
              autofocus: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.trim().isEmpty) {
                Get.snackbar(
                  'Error',
                  'Nama kategori tidak boleh kosong',
                  snackPosition: SnackPosition.TOP,
                  backgroundColor: AppTheme.errorColor,
                  colorText: Colors.white,
                );
                return;
              }
              
              await _updateCategory(category, nameController.text.trim());
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              foregroundColor: Colors.white,
            ),
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(Category category) {
    Get.dialog(
      AlertDialog(
        title: const Text('Konfirmasi Hapus'),
        content: Text('Apakah Anda yakin ingin menghapus kategori "${category.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () async {
              Get.back(); // Close confirmation dialog
              await _deleteCategory(category);
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }

  Future<void> _updateCategory(Category category, String newName) async {
    try {
      // Close edit dialog first
      Get.back();
      
      // Show loading
      Get.dialog(
        const Center(
          child: CircularProgressIndicator(),
        ),
        barrierDismissible: false,
      );
      // Update category
      final updatedCategory = category.copyWith(
        name: newName,
        updatedAt: DateTime.now(),
      );
      
      await _categoryController.updateCategory(updatedCategory);
      
      // Close loading dialog
   Navigator.of(context).pop(category);

      
      // Reload categories
      await _loadCategories();
      
      Get.snackbar(
        'Berhasil',
        'Kategori "$newName" berhasil diperbarui',
        snackPosition: SnackPosition.TOP,
        backgroundColor: AppTheme.successColor,
        colorText: Colors.white,
      );
    } catch (e) {
      // Close loading dialog if still open
      if (Get.isDialogOpen == true) {
        Get.back();
      }
      
      Get.snackbar(
        'Error',
        'Gagal memperbarui kategori: $e',
        snackPosition: SnackPosition.TOP,
        backgroundColor: AppTheme.errorColor,
        colorText: Colors.white,
      );
    }
  }

  Future<void> _deleteCategory(Category category) async {
    try {
      // Show loading
      Get.dialog(
        const Center(
          child: CircularProgressIndicator(),
        ),
        barrierDismissible: false,
      );

      // Delete category
      await _categoryController.deleteCategory(category.id);
      
      // Close loading dialog
     Navigator.of(context).pop(category);

      
      // Reload categories
      await _loadCategories();
     
    } catch (e) {
      // Close loading dialog if still open
      if (Get.isDialogOpen == true) {
        Get.back();
      }
      
      Get.snackbar(
        'Error',
        'Gagal menghapus kategori: $e',
        snackPosition: SnackPosition.TOP,
        backgroundColor: AppTheme.errorColor,
        colorText: Colors.white,
      );
    }
  }
}
