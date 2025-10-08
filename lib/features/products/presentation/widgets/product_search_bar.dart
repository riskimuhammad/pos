import 'package:flutter/material.dart';
import 'package:pos/core/theme/app_theme.dart';

class ProductSearchBar extends StatefulWidget {
  final Function(String) onSearchChanged;
  final VoidCallback onSearchCleared;

  const ProductSearchBar({
    super.key,
    required this.onSearchChanged,
    required this.onSearchCleared,
  });

  @override
  State<ProductSearchBar> createState() => _ProductSearchBarState();
}

class _ProductSearchBarState extends State<ProductSearchBar> {
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Cari produk...',
          hintStyle: TextStyle(
            color: Colors.grey[500],
            fontSize: 14,
          ),
          prefixIcon: Icon(
            Icons.search,
            color: Colors.grey[500],
            size: 20,
          ),
          suffixIcon: _isSearching
              ? IconButton(
                  icon: Icon(
                    Icons.clear,
                    color: Colors.grey[500],
                    size: 20,
                  ),
                  onPressed: _clearSearch,
                )
              : IconButton(
                  icon: Icon(
                    Icons.qr_code_scanner,
                    color: AppTheme.primaryColor,
                    size: 20,
                  ),
                  onPressed: _scanBarcode,
                  tooltip: 'Scan Barcode',
                ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
        style: TextStyle(
          fontSize: 14,
          color: AppTheme.textPrimary,
        ),
        onChanged: (value) {
          setState(() {
            _isSearching = value.isNotEmpty;
          });
          widget.onSearchChanged(value);
        },
        onSubmitted: (value) {
          widget.onSearchChanged(value);
        },
      ),
    );
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() {
      _isSearching = false;
    });
    widget.onSearchCleared();
  }

  void _scanBarcode() {
    // TODO: Implement barcode scanning
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Fitur scan barcode akan segera tersedia'),
        backgroundColor: AppTheme.primaryColor,
      ),
    );
  }
}
