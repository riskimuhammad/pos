import 'package:flutter/material.dart';
import 'package:pos/core/theme/app_theme.dart';

class AddProductFAB extends StatelessWidget {
  final VoidCallback onPressed;

  const AddProductFAB({
    super.key,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: onPressed,
      backgroundColor: AppTheme.primaryColor,
      foregroundColor: Colors.white,
      icon: Icon(Icons.add, size: 20),
      label: Text(
        'Tambah Produk',
        style: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
      ),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    );
  }
}
