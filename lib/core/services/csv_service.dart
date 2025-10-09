import 'dart:io';
import 'package:csv/csv.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:pos/core/theme/app_theme.dart';
import 'package:pos/shared/models/entities/entities.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class CsvService {
  
  /// Download CSV template for product import
  Future<void> downloadTemplate(BuildContext context) async {
    try {
      // Create CSV template with headers
      final headers = [
        'name',
        'sku', 
        'category',
        'price_buy',
        'price_sell',
        'min_stock',
        'unit',
        'description',
        'brand',
        'variant',
        'pack_size',
        'barcode',
        'reorder_point',
        'reorder_qty',
        'is_active',
        'is_expirable',
        'has_barcode'
      ];
      
      // Create sample data
      final sampleData = [
        [
          'Sample Product 1',
          'SKU001',
          'Electronics',
          '100000',
          '150000',
          '10',
          'pcs',
          'Sample description',
          'Brand A',
          'Variant 1',
          '1kg',
          '1234567890123',
          '5',
          '20',
          'Yes',
          'No',
          'Yes'
        ],
        [
          'Sample Product 2',
          'SKU002', 
          'Food & Beverage',
          '50000',
          '75000',
          '20',
          'box',
          'Another sample',
          'Brand B',
          'Variant 2',
          '500ml',
          '',
          '10',
          '50',
          'Yes',
          'Yes',
          'No'
        ]
      ];
      
      // Combine headers and sample data
      final csvData = [headers, ...sampleData];
      
      // Convert to CSV string
      final csvString = const ListToCsvConverter().convert(csvData);
      
      // Get downloads directory
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/product_template.csv');
      
      // Write CSV file
      await file.writeAsString(csvString);
      
      Get.snackbar(
        AppLocalizations.of(context)!.templateDownloaded,
        AppLocalizations.of(context)!.templateDownloadedDesc,
        snackPosition: SnackPosition.TOP,
        backgroundColor: AppTheme.successColor,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );
      
      // Open share dialog
      await _shareFile(file, 'product_template.csv', context);
      
    } catch (e) {
      print('❌ Error downloading template: $e');
      Get.snackbar(
        AppLocalizations.of(context)!.error,
        '${AppLocalizations.of(context)!.failedToDownloadTemplate}: $e',
        snackPosition: SnackPosition.TOP,
        backgroundColor: AppTheme.errorColor,
        colorText: Colors.white,
      );
    }
  }
  
  /// Pick and parse CSV file for import
  Future<List<Map<String, dynamic>>?> pickAndParseCSV(BuildContext context) async {
    try {
      // Pick CSV file
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv'],
        allowMultiple: false,
      );
      
      if (result == null) {
        return null; // User cancelled
      }
      
      // Read file content
      final file = File(result.files.first.path!);
      final csvString = await file.readAsString();
      
      // Parse CSV
      final csvData = const CsvToListConverter().convert(csvString);
      
      if (csvData.isEmpty) {
        throw Exception('File CSV kosong');
      }
      
      // Get headers (first row)
      final headers = csvData.first.map((e) => e.toString().toLowerCase().trim()).toList().cast<String>();
      
      // Validate required headers
      final requiredHeaders = ['name', 'sku', 'category', 'price_buy', 'price_sell', 'min_stock', 'unit'];
      final missingHeaders = requiredHeaders.where((h) => !headers.contains(h)).toList();
      
      if (missingHeaders.isNotEmpty) {
        throw Exception('Header yang diperlukan tidak ditemukan: ${missingHeaders.join(', ')}');
      }
      
      // Convert to list of maps
      final List<Map<String, dynamic>> products = [];
      
      for (int i = 1; i < csvData.length; i++) { // Skip header row
        final row = csvData[i];
        final Map<String, dynamic> product = {};
        
        for (int j = 0; j < headers.length && j < row.length; j++) {
          final value = row[j]?.toString().trim();
          if (value != null && value.isNotEmpty) {
            product[headers[j]] = value;
          }
        }
        
        // Only add if has required fields
        if (product.containsKey('name') && 
            product.containsKey('sku') && 
            product.containsKey('category') &&
            product.containsKey('price_buy') &&
            product.containsKey('price_sell') &&
            product.containsKey('min_stock') &&
            product.containsKey('unit')) {
          products.add(product);
        }
      }
      
      if (products.isEmpty) {
        throw Exception('Tidak ada data produk yang valid ditemukan');
      }
      
      Get.snackbar(
        AppLocalizations.of(context)!.csvParsed,
        AppLocalizations.of(context)!.csvParsedDesc(products.length),
        snackPosition: SnackPosition.TOP,
        backgroundColor: AppTheme.successColor,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );
      
      return products;
      
    } catch (e) {
      print('❌ Error parsing CSV: $e');
      Get.snackbar(
        AppLocalizations.of(context)!.error,
        '${AppLocalizations.of(context)!.failedToParseCsv}: $e',
        snackPosition: SnackPosition.TOP,
        backgroundColor: AppTheme.errorColor,
        colorText: Colors.white,
      );
      return null;
    }
  }
  
  /// Convert products to CSV format
  String productsToCSV(List<Product> products) {
    try {
      // Define headers
      final headers = [
        'id',
        'name',
        'sku',
        'category_id',
        'category_name',
        'description',
        'unit',
        'price_buy',
        'price_sell',
        'min_stock',
        'reorder_point',
        'reorder_qty',
        'brand',
        'variant',
        'pack_size',
        'barcode',
        'is_active',
        'is_expirable',
        'has_barcode',
        'created_at',
        'updated_at',
        'sync_status'
      ];
      
      // Convert products to CSV rows
      final csvData = [headers];
      
      for (final product in products) {
        final row = [
          product.id,
          product.name,
          product.sku,
          product.categoryId,
          '', // category_name - will be filled by caller if needed
          product.description ?? '',
          product.unit,
          product.priceBuy.toString(),
          product.priceSell.toString(),
          product.minStock.toString(),
          product.attributes['reorder_point']?.toString() ?? '',
          product.attributes['reorder_qty']?.toString() ?? '',
          product.attributes['brand']?.toString() ?? '',
          product.attributes['variant']?.toString() ?? '',
          product.attributes['pack_size']?.toString() ?? '',
          product.barcode ?? '',
          product.isActive ? 'Yes' : 'No',
          product.isExpirable ? 'Yes' : 'No',
          product.hasBarcode ? 'Yes' : 'No',
          product.createdAt.toIso8601String(),
          product.updatedAt.toIso8601String(),
          product.syncStatus,
        ].cast<String>();
        csvData.add(row);
      }
      
      // Convert to CSV string
      return const ListToCsvConverter().convert(csvData);
      
    } catch (e) {
      print('❌ Error converting products to CSV: $e');
      throw Exception('Gagal mengkonversi produk ke CSV: $e');
    }
  }
  
  /// Export products to CSV file
  Future<void> exportProductsToCSV(List<Product> products, String filename, BuildContext context) async {
    try {
      // Convert products to CSV
      final csvString = productsToCSV(products);
      
      // Get downloads directory
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/$filename');
      
      // Write CSV file
      await file.writeAsString(csvString);
      
      // Show success message
      Get.snackbar(
        AppLocalizations.of(context)!.exportSuccess,
        AppLocalizations.of(context)!.exportSuccessDesc(products.length),
        snackPosition: SnackPosition.TOP,
        backgroundColor: AppTheme.successColor,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );
      
      // Open share dialog
      await _shareFile(file, filename, context);
      
    } catch (e) {
      print('❌ Error exporting products: $e');
      Get.snackbar(
        AppLocalizations.of(context)!.error,
        '${AppLocalizations.of(context)!.failedToExportProducts}: $e',
        snackPosition: SnackPosition.TOP,
        backgroundColor: AppTheme.errorColor,
        colorText: Colors.white,
      );
    }
  }
  
  /// Share file using native share dialog
  Future<void> _shareFile(File file, String filename, BuildContext context) async {
    try {
      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'Export Data Produk - $filename',
        subject: 'Data Produk CSV Export',
      );
    } catch (e) {
      print('❌ Error sharing file: $e');
      
      // Show fallback message with file location
      Get.snackbar(
        AppLocalizations.of(context)!.fileSaved,
        AppLocalizations.of(context)!.fileSavedDesc(file.path),
        snackPosition: SnackPosition.TOP,
        backgroundColor: AppTheme.primaryColor,
        colorText: Colors.white,
        duration: const Duration(seconds: 4),
      );
    }
  }
  
  /// Convert CSV data to Product objects
  List<Product> csvDataToProducts(List<Map<String, dynamic>> csvData, String tenantId) {
    final List<Product> products = [];
    
    for (final data in csvData) {
      try {
        final product = Product(
          id: 'prod_${DateTime.now().millisecondsSinceEpoch}_${products.length}',
          tenantId: tenantId,
          sku: data['sku']?.toString().trim() ?? '',
          name: data['name']?.toString().trim() ?? '',
          categoryId: data['category_id']?.toString().trim() ?? '',
          description: data['description']?.toString().trim(),
          unit: data['unit']?.toString().trim() ?? '',
          priceBuy: double.tryParse(data['price_buy']?.toString() ?? '0') ?? 0.0,
          priceSell: double.tryParse(data['price_sell']?.toString() ?? '0') ?? 0.0,
          minStock: int.tryParse(data['min_stock']?.toString() ?? '0') ?? 0,
          photos: [], // Will be empty for imported products
          attributes: {
            'brand': data['brand']?.toString().trim(),
            'variant': data['variant']?.toString().trim(),
            'pack_size': data['pack_size']?.toString().trim(),
            'uom': data['unit']?.toString().trim(),
            'reorder_point': int.tryParse(data['reorder_point']?.toString() ?? ''),
            'reorder_qty': int.tryParse(data['reorder_qty']?.toString() ?? ''),
          },
          barcode: data['barcode']?.toString().trim(),
          hasBarcode: _parseBooleanValue(data['has_barcode']),
          isExpirable: _parseBooleanValue(data['is_expirable']),
          isActive: _parseBooleanValue(data['is_active'], defaultValue: true), // Default to true
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          syncStatus: 'pending',
          lastSyncedAt: null,
        );
        
        products.add(product);
        
      } catch (e) {
        print('❌ Error converting CSV row to product: $e');
        // Continue with other products
      }
    }
    
    return products;
  }
  
  /// Parse boolean value from CSV data
  /// Accepts: Yes/No, Iya/Tidak, true/false, 1/0
  bool _parseBooleanValue(dynamic value, {bool defaultValue = false}) {
    if (value == null) return defaultValue;
    
    final stringValue = value.toString().toLowerCase().trim();
    
    // Handle Yes/No
    if (stringValue == 'yes' || stringValue == 'iya') return true;
    if (stringValue == 'no' || stringValue == 'tidak') return false;
    
    // Handle true/false
    if (stringValue == 'true') return true;
    if (stringValue == 'false') return false;
    
    // Handle 1/0
    if (stringValue == '1') return true;
    if (stringValue == '0') return false;
    
    // Default value if not recognized
    return defaultValue;
  }
}
