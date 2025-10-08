import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pos/core/theme/app_theme.dart';
import 'package:pos/core/controllers/category_controller.dart';

class CategoryFilter extends StatefulWidget {
  final Function(String) onCategorySelected;
  final VoidCallback onCategoryCleared;

  const CategoryFilter({
    super.key,
    required this.onCategorySelected,
    required this.onCategoryCleared,
  });

  @override
  State<CategoryFilter> createState() => _CategoryFilterState();
}

class _CategoryFilterState extends State<CategoryFilter> {
  String? _selectedCategory;

  @override
  Widget build(BuildContext context) {
    final categoryController = Get.find<CategoryController>();
    
    return Container(
      height: 40,
      child: Obx(() {
        final categories = categoryController.categories.map((c) => c.name).toList();
        
        return ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: categories.length + 1, // +1 for "All" option
          itemBuilder: (context, index) {
            if (index == 0) {
              // "All" option
              return _buildCategoryChip(
                'Semua',
                _selectedCategory == null,
                () {
                  setState(() {
                    _selectedCategory = null;
                  });
                  widget.onCategoryCleared();
                },
              );
            }
            
            final category = categories[index - 1];
            final isSelected = _selectedCategory == category;
            
            return _buildCategoryChip(
              category,
              isSelected,
              () {
                setState(() {
                  _selectedCategory = category;
                });
                // Find category ID by name
                final categoryObj = categoryController.categories.firstWhereOrNull((c) => c.name == category);
                widget.onCategorySelected(categoryObj?.id ?? '');
              },
            );
          },
        );
      }),
    );
  }

  Widget _buildCategoryChip(String label, bool isSelected, VoidCallback onTap) {
    return Container(
      margin: EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            color: isSelected ? Colors.white : AppTheme.textPrimary,
          ),
        ),
        selected: isSelected,
        onSelected: (selected) => onTap(),
        backgroundColor: Colors.grey[100],
        selectedColor: AppTheme.primaryColor,
        checkmarkColor: Colors.white,
        side: BorderSide(
          color: isSelected ? AppTheme.primaryColor : Colors.grey[300]!,
          width: 1,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 0),
      ),
    );
  }
}
