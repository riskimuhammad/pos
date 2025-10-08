import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pos/core/theme/app_theme.dart';
import 'package:pos/core/localization/language_controller.dart';
import 'package:pos/shared/models/entities/entities.dart';
import 'package:pos/core/controllers/category_controller.dart';

class ProductDetailsDialog extends StatelessWidget {
  final Product product;

  const ProductDetailsDialog({
    super.key,
    required this.product,
  });

  @override
  Widget build(BuildContext context) {
    final languageController = Get.find<LanguageController>();
    
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
                  Icons.info_outline,
                  color: AppTheme.primaryColor,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Detail Produk',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Get.back(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 20),
            
            // Content
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Product Image
                    if (product.photos.isNotEmpty) ...[
                      _buildProductImage(),
                      const SizedBox(height: 20),
                    ],
                    
                    // Basic Information
                    _buildSection(
                      title: 'Informasi Dasar',
                      icon: Icons.info,
                      children: [
                        _buildInfoRow('Nama Produk', product.name),
                        _buildInfoRow('SKU', product.sku),
                        _buildInfoRow('Kategori', _getCategoryName(product.categoryId ?? 'cat_1')),
                        _buildInfoRow('Deskripsi', product.description ?? '-'),
                        _buildInfoRow('Satuan', product.unit),
                        _buildInfoRow('Status', product.isActive ? 'Aktif' : 'Tidak Aktif'),
                      ],
                    ),
                    const SizedBox(height: 20),
                    
                    // Pricing Information
                    _buildSection(
                      title: 'Informasi Harga',
                      icon: Icons.attach_money,
                      children: [
                        _buildInfoRow('Harga Beli', languageController.formatCurrency(product.priceBuy)),
                        _buildInfoRow('Harga Jual', languageController.formatCurrency(product.priceSell)),
                        _buildInfoRow('Margin', _calculateMargin()),
                        _buildInfoRow('Margin %', '${_calculateMarginPercent().toStringAsFixed(1)}%'),
                      ],
                    ),
                    const SizedBox(height: 20),
                    
                    // Stock Information
                    _buildSection(
                      title: 'Informasi Stok',
                      icon: Icons.inventory,
                      children: [
                        _buildInfoRow('Stok Minimum', '${product.minStock} ${product.unit}'),
                        _buildInfoRow('Reorder Point', product.attributes['reorder_point']?.toString() ?? '-'),
                        _buildInfoRow('Reorder Quantity', product.attributes['reorder_qty']?.toString() ?? '-'),
                        _buildInfoRow('Barcode', product.barcode ?? '-'),
                        _buildInfoRow('Has Barcode', product.hasBarcode ? 'Ya' : 'Tidak'),
                        _buildInfoRow('Expirable', product.isExpirable ? 'Ya' : 'Tidak'),
                      ],
                    ),
                    const SizedBox(height: 20),
                    
                    // Product Details
                    if (product.attributes['brand'] != null || product.attributes['variant'] != null || product.attributes['pack_size'] != null) ...[
                      _buildSection(
                        title: 'Detail Produk',
                        icon: Icons.shopping_bag,
                        children: [
                          if (product.attributes['brand'] != null) _buildInfoRow('Brand', product.attributes['brand']!),
                          if (product.attributes['variant'] != null) _buildInfoRow('Variant', product.attributes['variant']!),
                          if (product.attributes['pack_size'] != null) _buildInfoRow('Ukuran Kemasan', product.attributes['pack_size']!),
                        ],
                      ),
                      const SizedBox(height: 20),
                    ],
                    
                    // Timestamps
                    _buildSection(
                      title: 'Informasi Sistem',
                      icon: Icons.access_time,
                      children: [
                        _buildInfoRow('Dibuat', _formatDateTime(product.createdAt)),
                        _buildInfoRow('Diupdate', _formatDateTime(product.updatedAt)),
                        _buildInfoRow('Sync Status', product.syncStatus),
                        if (product.lastSyncedAt != null)
                          _buildInfoRow('Terakhir Sync', _formatDateTime(product.lastSyncedAt!)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            
            // Actions
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => Get.back(),
                    icon: const Icon(Icons.close),
                    label: const Text('Tutup'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductImage() {
    return Container(
      height: 200,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.network(
          product.photos.first,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              color: Colors.grey[100],
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.image_not_supported,
                    size: 48,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Gambar tidak tersedia',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: AppTheme.primaryColor,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
          ),
          const Text(': '),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getCategoryName(String categoryId) {
    try {
      if (Get.isRegistered<CategoryController>()) {
        final categoryController = Get.find<CategoryController>();
        final category = categoryController.getCategoryById(categoryId);
        return category?.name ?? 'Kategori Tidak Ditemukan';
      } else {
        return 'Kategori Tidak Ditemukan';
      }
    } catch (e) {
      print('❌ Error getting category name: $e');
      return 'Kategori Tidak Ditemukan';
    }
  }

  String _calculateMargin() {
    final margin = product.priceSell - product.priceBuy;
    final languageController = Get.find<LanguageController>();
    return languageController.formatCurrency(margin);
  }

  double _calculateMarginPercent() {
    if (product.priceSell == 0) return 0;
    return ((product.priceSell - product.priceBuy) / product.priceSell) * 100;
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}
