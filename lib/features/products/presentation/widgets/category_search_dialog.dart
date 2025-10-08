import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pos/core/theme/app_theme.dart';
import 'package:pos/shared/models/entities/entities.dart';
import 'package:pos/features/products/presentation/widgets/add_category_dialog.dart';

class CategorySearchDialog extends StatefulWidget {
  final List<Category> categories;
  final String? selectedCategoryId;
  final Function(Category) onCategorySelected;
  final Function(Category) onAddCategory;

  const CategorySearchDialog({
    super.key,
    required this.categories,
    this.selectedCategoryId,
    required this.onCategorySelected,
    required this.onAddCategory,
  });

  @override
  State<CategorySearchDialog> createState() => _CategorySearchDialogState();
}

class _CategorySearchDialogState extends State<CategorySearchDialog> {
  final _searchController = TextEditingController();
  List<Category> _filteredCategories = [];

  @override
  void initState() {
    super.initState();
    _filteredCategories = widget.categories;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterCategories(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredCategories = widget.categories;
      } else {
        _filteredCategories = widget.categories.where((category) {
          return category.name.toLowerCase().contains(query.toLowerCase());
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      elevation: 8,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.75,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white,
              Colors.grey[50]!,
            ],
          ),
        ),
        child: Column(
          children: [
            // Modern Header with Glass Effect
            Container(
              padding: const EdgeInsets.fromLTRB(24, 20, 16, 20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppTheme.primaryColor,
                    AppTheme.primaryColor.withOpacity(0.8),
                  ],
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryColor.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.category_rounded,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Pilih Kategori',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${_filteredCategories.length} kategori tersedia',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: IconButton(
                      onPressed: () => Get.back(),
                      icon: const Icon(
                        Icons.close_rounded,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Modern Search Bar
            Container(
              margin: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                controller: _searchController,
                onChanged: _filterCategories,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
                decoration: InputDecoration(
                  hintText: 'Cari kategori...',
                  hintStyle: TextStyle(
                    color: Colors.grey[500],
                    fontWeight: FontWeight.w400,
                  ),
                  prefixIcon: Container(
                    margin: const EdgeInsets.all(12),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.search_rounded,
                      color: AppTheme.primaryColor,
                      size: 20,
                    ),
                  ),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? Container(
                          margin: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: IconButton(
                            icon: Icon(
                              Icons.clear_rounded,
                              color: Colors.grey[600],
                              size: 18,
                            ),
                            onPressed: () {
                              _searchController.clear();
                              _filterCategories('');
                            },
                          ),
                        )
                      : null,
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(
                      color: AppTheme.primaryColor.withOpacity(0.3),
                      width: 2,
                    ),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                ),
              ),
            ),

            // Modern Add Category Button
            Container(
              margin: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Material(
                elevation: 2,
                borderRadius: BorderRadius.circular(16),
                child: InkWell(
                  onTap: _showAddCategoryDialog,
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppTheme.successColor,
                          AppTheme.successColor.withOpacity(0.8),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.successColor.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.add_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'Tambah Kategori Baru',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Modern Categories List
            Expanded(
              child: _filteredCategories.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                      itemCount: _filteredCategories.length,
                      itemBuilder: (context, index) {
                        final category = _filteredCategories[index];
                        final isSelected = category.id == widget.selectedCategoryId;
                        
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: Material(
                            elevation: isSelected ? 6 : 2,
                            borderRadius: BorderRadius.circular(16),
                            shadowColor: isSelected 
                                ? AppTheme.primaryColor.withOpacity(0.3)
                                : Colors.black.withOpacity(0.1),
                            child: InkWell(
                              onTap: () {
                                widget.onCategorySelected(category);
                                Get.back();
                              },
                              borderRadius: BorderRadius.circular(16),
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  gradient: isSelected
                                      ? LinearGradient(
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                          colors: [
                                            AppTheme.primaryColor.withOpacity(0.1),
                                            AppTheme.primaryColor.withOpacity(0.05),
                                          ],
                                        )
                                      : null,
                                  color: isSelected ? null : Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  border: isSelected
                                      ? Border.all(
                                          color: AppTheme.primaryColor.withOpacity(0.3),
                                          width: 2,
                                        )
                                      : null,
                                ),
                                child: Row(
                                  children: [
                                    // Modern Category Icon
                                    Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        gradient: isSelected
                                            ? LinearGradient(
                                                begin: Alignment.topLeft,
                                                end: Alignment.bottomRight,
                                                colors: [
                                                  AppTheme.primaryColor,
                                                  AppTheme.primaryColor.withOpacity(0.8),
                                                ],
                                              )
                                            : null,
                                        color: isSelected ? null : Colors.grey[100],
                                        borderRadius: BorderRadius.circular(12),
                                        boxShadow: isSelected
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
                                        Icons.category_rounded,
                                        color: isSelected ? Colors.white : Colors.grey[600],
                                        size: 24,
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    
                                    // Category Info
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            category.name,
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                                              color: isSelected ? AppTheme.primaryColor : Colors.grey[800],
                                              letterSpacing: 0.3,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            'ID: ${category.id}',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey[500],
                                              fontWeight: FontWeight.w400,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    
                                    // Selection Indicator
                                    if (isSelected)
                                      Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: AppTheme.primaryColor,
                                          borderRadius: BorderRadius.circular(20),
                                          boxShadow: [
                                            BoxShadow(
                                              color: AppTheme.primaryColor.withOpacity(0.3),
                                              blurRadius: 8,
                                              offset: const Offset(0, 2),
                                            ),
                                          ],
                                        ),
                                        child: const Icon(
                                          Icons.check_rounded,
                                          color: Colors.white,
                                          size: 20,
                                        ),
                                      )
                                    else
                                      Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: Colors.grey[200],
                                          borderRadius: BorderRadius.circular(20),
                                        ),
                                        child: Icon(
                                          Icons.radio_button_unchecked_rounded,
                                          color: Colors.grey[400],
                                          size: 20,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
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
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Modern Empty State Icon
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.grey[100]!,
                    Colors.grey[50]!,
                  ],
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 20,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(
                _searchController.text.isEmpty
                    ? Icons.category_outlined
                    : Icons.search_off_rounded,
                size: 48,
                color: Colors.grey[400],
              ),
            ),
            const SizedBox(height: 24),
            
            // Empty State Title
            Text(
              _searchController.text.isEmpty
                  ? 'Belum ada kategori'
                  : 'Kategori tidak ditemukan',
              style: TextStyle(
                fontSize: 20,
                color: Colors.grey[700],
                fontWeight: FontWeight.w600,
                letterSpacing: 0.3,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            
            // Empty State Subtitle
            Text(
              _searchController.text.isEmpty
                  ? 'Tambahkan kategori pertama Anda untuk mengorganisir produk'
                  : 'Coba kata kunci lain atau tambahkan kategori baru',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
                fontWeight: FontWeight.w400,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            
            // Modern Add Button
            Material(
              elevation: 4,
              borderRadius: BorderRadius.circular(16),
              child: InkWell(
                onTap: _showAddCategoryDialog,
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppTheme.primaryColor,
                        AppTheme.primaryColor.withOpacity(0.8),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primaryColor.withOpacity(0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.add_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Tambah Kategori',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddCategoryDialog() async {
    Get.back();
    final result = await showDialog<Category>(
      context: context,
      builder: (context) => AddCategoryDialog(
        onSubmit: (category) {
          // Don't close the dialog yet, just return the category
          Navigator.of(context).pop(category);
        },
      ),
    );
    
    if (result != null) {
      // Add the new category to the list
      widget.onAddCategory(result);
      
      // Update the filtered list
      _filteredCategories = widget.categories;
      
      // Select the new category
      widget.onCategorySelected(result);
      
      // Close the category search dialog
      Get.back();
    }
  }
}
