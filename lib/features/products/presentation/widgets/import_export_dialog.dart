import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pos/core/theme/app_theme.dart';
import 'package:pos/core/services/csv_service.dart';
import 'package:pos/features/products/presentation/controllers/product_controller.dart';
import 'package:pos/shared/models/entities/entities.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

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
  final CsvService _csvService = CsvService();

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
                    AppLocalizations.of(context)!.importExport,
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
                tabs: [
                  Tab(text: AppLocalizations.of(context)!.importCsv),
                  Tab(text: AppLocalizations.of(context)!.exportCsv),
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
            title: AppLocalizations.of(context)!.downloadTemplate,
            subtitle: 'Download template untuk import produk',
            onTap: _downloadTemplate,
            color: AppTheme.primaryColor,
          ),
          const SizedBox(height: 12),
          
          // File Upload
          _buildActionCard(
            icon: Icons.upload_file,
            title: AppLocalizations.of(context)!.uploadCsv,
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
            title: AppLocalizations.of(context)!.exportAllProducts,
            subtitle: 'Export semua ${widget.products.length} produk',
            onTap: () => _exportProducts(widget.products),
            color: AppTheme.successColor,
          ),
          const SizedBox(height: 12),
          
          _buildActionCard(
            icon: Icons.filter_list,
            title: AppLocalizations.of(context)!.exportActiveProducts,
            subtitle: 'Export hanya produk yang aktif',
            onTap: () => _exportActiveProducts(),
            color: AppTheme.primaryColor,
          ),
          const SizedBox(height: 12),
          
          _buildActionCard(
            icon: Icons.inventory,
            title: AppLocalizations.of(context)!.exportLowStockProducts,
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
            '• barcode (Barcode)\n'
            '• reorder_point (Titik Pemesanan Ulang)\n'
            '• reorder_qty (Jumlah Pemesanan Ulang)\n'
            '• is_active (Aktif: Yes/No atau Iya/Tidak)\n'
            '• is_expirable (Bisa Kadaluarsa: Yes/No atau Iya/Tidak)\n'
            '• has_barcode (Ada Barcode: Yes/No atau Iya/Tidak)',
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
    _csvService.downloadTemplate(context);
  }

  void _uploadCSV() async {
    try {
      // Show loading
      Get.dialog(
        const Center(
          child: CircularProgressIndicator(),
        ),
        barrierDismissible: false,
      );
      
      // Pick and parse CSV
      final csvData = await _csvService.pickAndParseCSV(context);
      
      // Close loading dialog
      Get.back();
      
      if (csvData != null && csvData.isNotEmpty) {
        // Convert CSV data to Product objects
        final products = _csvService.csvDataToProducts(csvData, 'default-tenant-id');
        
        if (products.isNotEmpty) {
          // Show confirmation dialog
          final confirmed = await Get.dialog<bool>(
            AlertDialog(
              title: const Text('Konfirmasi Import'),
              content: Text('Apakah Anda yakin ingin mengimport ${products.length} produk?'),
              actions: [
                TextButton(
                  onPressed: () => Get.back(result: false),
                  child: const Text('Batal'),
                ),
                TextButton(
                  onPressed: () => Get.back(result: true),
                  child: const Text('Import'),
                ),
              ],
            ),
          );
          
          if (confirmed == true) {
            // Import products
            widget.onImportProducts(products);
            Get.back(); // Close import/export dialog
          }
        }
      }
    } catch (e) {
      // Close loading dialog if still open
      if (Get.isDialogOpen == true) {
        Get.back();
      }
      
      Get.snackbar(
        'Error',
        'Gagal mengupload CSV: $e',
        snackPosition: SnackPosition.TOP,
        backgroundColor: AppTheme.errorColor,
        colorText: Colors.white,
      );
    }
  }

  void _exportProducts(List<Product> products) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final filename = 'products_export_$timestamp.csv';
    _csvService.exportProductsToCSV(products, filename, context);
  }

  void _exportActiveProducts() {
    final activeProducts = widget.products.where((p) => p.isActive).toList();
    _exportProducts(activeProducts);
  }

  void _exportLowStockProducts() async {
    try {
      // Show loading
      Get.dialog(
        const Center(
          child: CircularProgressIndicator(),
        ),
        barrierDismissible: false,
      );
      
      // Get low stock products using the proper method from ProductController
      // We need to access the controller to get real low stock data
      final productController = Get.find<ProductController>();
      final lowStockProducts = await productController.getLowStockProducts();
      
      // Close loading dialog
      Get.back();
      
      if (lowStockProducts.isNotEmpty) {
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        final filename = 'low_stock_products_$timestamp.csv';
        _csvService.exportProductsToCSV(lowStockProducts, filename, context);
      } else {
        Get.snackbar(
          'Info',
          'Tidak ada produk dengan stok rendah',
          snackPosition: SnackPosition.TOP,
          backgroundColor: AppTheme.warningColor,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      // Close loading dialog if still open
      if (Get.isDialogOpen == true) {
        Get.back();
      }
      
      Get.snackbar(
        'Error',
        'Gagal mengekspor produk stok rendah: $e',
        snackPosition: SnackPosition.TOP,
        backgroundColor: AppTheme.errorColor,
        colorText: Colors.white,
      );
    }
  }
}
