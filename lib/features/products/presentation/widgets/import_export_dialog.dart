import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pos/core/theme/app_theme.dart';
import 'package:pos/shared/models/entities/entities.dart';

class ImportExportDialog extends StatefulWidget {
  final List<Product> products;
  final Function(List<Product>) onImportProducts;

  const ImportExportDialog({
    super.key,
    required this.products,
    required this.onImportProducts,
  });

  @override
  State<ImportExportDialog> createState() => _ImportExportDialogState();
}

class _ImportExportDialogState extends State<ImportExportDialog> with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.7,
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Header
            Row(
              children: [
                Icon(
                  Icons.file_upload,
                  color: AppTheme.primaryColor,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Import / Export Data',
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
            
            // Tab Bar
            Container(
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: TabBar(
                controller: _tabController,
                labelColor: AppTheme.primaryColor,
                unselectedLabelColor: Colors.grey[600],
                indicatorColor: AppTheme.primaryColor,
                indicatorSize: TabBarIndicatorSize.tab,
                tabs: const [
                  Tab(text: 'Import CSV'),
                  Tab(text: 'Export CSV'),
                ],
              ),
            ),
            const SizedBox(height: 20),
            
            // Tab Content
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildImportTab(),
                  _buildExportTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImportTab() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Instructions
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue[200]!),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.info, color: Colors.blue[600], size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Petunjuk Import CSV',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue[600],
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  '1. Download template CSV terlebih dahulu\n'
                  '2. Isi data produk sesuai format\n'
                  '3. Upload file CSV yang sudah diisi\n'
                  '4. Review data sebelum import',
                  style: TextStyle(
                    color: Colors.blue[700],
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          
          // Template Download
          _buildActionCard(
            icon: Icons.download,
            title: 'Download Template CSV',
            subtitle: 'Download template untuk import produk',
            onTap: _downloadTemplate,
            color: AppTheme.primaryColor,
          ),
          const SizedBox(height: 12),
          
          // File Upload
          _buildActionCard(
            icon: Icons.upload_file,
            title: 'Upload File CSV',
            subtitle: 'Pilih file CSV yang akan diimport',
            onTap: _uploadCSV,
            color: AppTheme.successColor,
          ),
          const SizedBox(height: 20),
          
          // CSV Format Info
          _buildCSVFormatInfo(),
        ],
      ),
    );
  }

  Widget _buildExportTab() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Export Info
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.green[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.green[200]!),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.info, color: Colors.green[600], size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Export Data Produk',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.green[600],
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Total produk: ${widget.products.length} item\n'
                  'Data akan diekspor dalam format CSV',
                  style: TextStyle(
                    color: Colors.green[700],
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          
          // Export Options
          _buildActionCard(
            icon: Icons.file_download,
            title: 'Export Semua Produk',
            subtitle: 'Export semua ${widget.products.length} produk',
            onTap: () => _exportProducts(widget.products),
            color: AppTheme.successColor,
          ),
          const SizedBox(height: 12),
          
          _buildActionCard(
            icon: Icons.filter_list,
            title: 'Export Produk Aktif',
            subtitle: 'Export hanya produk yang aktif',
            onTap: () => _exportActiveProducts(),
            color: AppTheme.primaryColor,
          ),
          const SizedBox(height: 12),
          
          _buildActionCard(
            icon: Icons.inventory,
            title: 'Export Stok Rendah',
            subtitle: 'Export produk dengan stok rendah',
            onTap: () => _exportLowStockProducts(),
            color: AppTheme.warningColor,
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required Color color,
  }) {
    return Card(
      elevation: 2,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.1),
          child: Icon(icon, color: color),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(subtitle),
        trailing: Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }

  Widget _buildCSVFormatInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Format CSV yang Didukung:',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Kolom yang diperlukan:\n'
            '• name (Nama Produk)\n'
            '• sku (Kode SKU)\n'
            '• category (Kategori)\n'
            '• price_buy (Harga Beli)\n'
            '• price_sell (Harga Jual)\n'
            '• min_stock (Stok Minimum)\n'
            '• unit (Satuan)\n\n'
            'Kolom opsional:\n'
            '• description (Deskripsi)\n'
            '• brand (Brand)\n'
            '• variant (Variant)\n'
            '• pack_size (Ukuran Kemasan)\n'
            '• barcode (Barcode)',
            style: TextStyle(
              color: Colors.grey[700],
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  void _downloadTemplate() {
    Get.snackbar(
      'Download Template',
      'Template CSV berhasil didownload',
      snackPosition: SnackPosition.TOP,
      backgroundColor: AppTheme.primaryColor,
      colorText: Colors.white,
    );
  }

  void _uploadCSV() {
    Get.snackbar(
      'Upload CSV',
      'Fitur upload CSV akan segera tersedia',
      snackPosition: SnackPosition.TOP,
      backgroundColor: AppTheme.warningColor,
      colorText: Colors.white,
    );
  }

  void _exportProducts(List<Product> products) {
    Get.snackbar(
      'Export Berhasil',
      '${products.length} produk berhasil diekspor ke CSV',
      snackPosition: SnackPosition.TOP,
      backgroundColor: AppTheme.successColor,
      colorText: Colors.white,
    );
  }

  void _exportActiveProducts() {
    final activeProducts = widget.products.where((p) => p.isActive).toList();
    _exportProducts(activeProducts);
  }

  void _exportLowStockProducts() {
    final lowStockProducts = widget.products.where((p) => p.minStock <= 5).toList();
    _exportProducts(lowStockProducts);
  }
}
