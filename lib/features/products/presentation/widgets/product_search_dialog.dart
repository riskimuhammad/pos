import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pos/core/theme/app_theme.dart';

class ProductSearchDialog extends StatefulWidget {
  final List<String> existingProducts;
  final String? selectedProduct;
  final Function(String) onProductSelected;

  const ProductSearchDialog({
    super.key,
    required this.existingProducts,
    this.selectedProduct,
    required this.onProductSelected,
  });

  @override
  State<ProductSearchDialog> createState() => _ProductSearchDialogState();
}

class _ProductSearchDialogState extends State<ProductSearchDialog> {
  final _searchController = TextEditingController();
  List<String> _filteredProducts = [];

  @override
  void initState() {
    super.initState();
    _filteredProducts = widget.existingProducts;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterProducts(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredProducts = widget.existingProducts;
      } else {
        _filteredProducts = widget.existingProducts.where((product) {
          return product.toLowerCase().contains(query.toLowerCase());
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
        height: MediaQuery.of(context).size.height * 0.7,
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
            // Modern Header
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
                      Icons.inventory_2_rounded,
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
                          'Pilih Produk Restok',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${_filteredProducts.length} produk tersedia',
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
                onChanged: _filterProducts,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
                decoration: InputDecoration(
                  hintText: 'Cari produk...',
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
                              _filterProducts('');
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

            const SizedBox(height: 16),

            // Products List
            Expanded(
              child: _filteredProducts.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                      itemCount: _filteredProducts.length,
                      itemBuilder: (context, index) {
                        final product = _filteredProducts[index];
                        final isSelected = product == widget.selectedProduct;
                        
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
                                widget.onProductSelected(product);
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
                                    // Product Icon
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
                                        Icons.inventory_rounded,
                                        color: isSelected ? Colors.white : Colors.grey[600],
                                        size: 24,
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    
                                    // Product Info
                                    Expanded(
                                      child: Text(
                                        product,
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                                          color: isSelected ? AppTheme.primaryColor : Colors.grey[800],
                                          letterSpacing: 0.3,
                                        ),
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
                    ? Icons.inventory_2_outlined
                    : Icons.search_off_rounded,
                size: 48,
                color: Colors.grey[400],
              ),
            ),
            const SizedBox(height: 24),
            
            // Empty State Title
            Text(
              _searchController.text.isEmpty
                  ? 'Belum ada produk'
                  : 'Produk tidak ditemukan',
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
                  ? 'Tambahkan produk pertama Anda'
                  : 'Coba kata kunci lain',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
                fontWeight: FontWeight.w400,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
