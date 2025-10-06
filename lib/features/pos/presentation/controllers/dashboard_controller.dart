import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pos/features/auth/presentation/controllers/auth_controller.dart';
import 'package:pos/core/localization/language_controller.dart';

class DashboardController extends GetxController {
  final AuthController authController = Get.find<AuthController>();
  final LanguageController languageController = Get.find<LanguageController>();

  // Observable variables
  final RxBool isLoading = false.obs;
  final RxString selectedPeriod = 'today'.obs;

  // Today's stats
  final RxInt todayTransactions = 0.obs;
  final RxDouble todaySales = 0.0.obs;
  final RxInt todayProductsSold = 0.obs;
  final RxDouble averageTransaction = 0.0.obs;

  // Recent activities
  final RxList<Map<String, dynamic>> recentActivities = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    _loadDashboardData();
    _loadRecentActivities();
  }

  Future<void> _loadDashboardData() async {
    isLoading.value = true;
    
    try {
      // Simulate API call - replace with real data later
      await Future.delayed(const Duration(seconds: 1));
      
      // Mock data for today's stats
      todayTransactions.value = 24;
      todaySales.value = 2400000.0; // Rp 2.4M
      todayProductsSold.value = 156;
      averageTransaction.value = 100000.0; // Rp 100K
      
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal memuat data dashboard: $e',
        snackPosition: SnackPosition.TOP,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _loadRecentActivities() async {
    try {
      // Mock data for recent activities
      recentActivities.value = [
        {
          'id': '1',
          'type': 'transaction',
          'title': 'Transaksi #TRX001',
          'subtitle': 'Rp 150.000',
          'time': '2 menit yang lalu',
          'icon': 'receipt_long',
          'color': 'success',
        },
        {
          'id': '2',
          'type': 'product',
          'title': 'Produk baru ditambahkan',
          'subtitle': 'Indomie Goreng',
          'time': '15 menit yang lalu',
          'icon': 'add_circle',
          'color': 'info',
        },
        {
          'id': '3',
          'type': 'inventory',
          'title': 'Stok rendah',
          'subtitle': 'Aqua 600ml',
          'time': '1 jam yang lalu',
          'icon': 'warning',
          'color': 'warning',
        },
        {
          'id': '4',
          'type': 'user',
          'title': 'User login',
          'subtitle': 'Kasir 1',
          'time': '2 jam yang lalu',
          'icon': 'person',
          'color': 'primary',
        },
        {
          'id': '5',
          'type': 'return',
          'title': 'Retur barang',
          'subtitle': 'Beras 5kg',
          'time': '3 jam yang lalu',
          'icon': 'undo',
          'color': 'warning',
        },
      ];
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal memuat aktivitas terbaru: $e',
        snackPosition: SnackPosition.TOP,
      );
    }
  }

  // Format currency using language controller
  String formatCurrency(double amount) {
    return languageController.formatCurrency(amount);
  }

  // Refresh dashboard data
  Future<void> refreshDashboard() async {
    await _loadDashboardData();
    await _loadRecentActivities();
  }

  // Change period filter
  void changePeriod(String period) {
    selectedPeriod.value = period;
    _loadDashboardData();
  }

  // Navigate to POS
  void navigateToPOS() {
    // TODO: Implement navigation to POS
    Get.snackbar(
      'Info',
      'Navigasi ke POS akan segera tersedia',
      snackPosition: SnackPosition.TOP,
    );
  }

  // Navigate to Products
  void navigateToProducts() {
    // TODO: Implement navigation to Products
    Get.snackbar(
      'Info',
      'Navigasi ke Produk akan segera tersedia',
      snackPosition: SnackPosition.TOP,
    );
  }

  // Navigate to Inventory
  void navigateToInventory() {
    // TODO: Implement navigation to Inventory
    Get.snackbar(
      'Info',
      'Navigasi ke Inventory akan segera tersedia',
      snackPosition: SnackPosition.TOP,
    );
  }

  // Navigate to Reports
  void navigateToReports() {
    // TODO: Implement navigation to Reports
    Get.snackbar(
      'Info',
      'Navigasi ke Laporan akan segera tersedia',
      snackPosition: SnackPosition.TOP,
    );
  }

  // Navigate to Users
  void navigateToUsers() {
    // TODO: Implement navigation to Users
    Get.snackbar(
      'Info',
      'Navigasi ke Pengguna akan segera tersedia',
      snackPosition: SnackPosition.TOP,
    );
  }

  // Navigate to Settings
  void navigateToSettings() {
    // TODO: Implement navigation to Settings
    Get.snackbar(
      'Info',
      'Navigasi ke Pengaturan akan segera tersedia',
      snackPosition: SnackPosition.TOP,
    );
  }

  // Open barcode scanner
  void openBarcodeScanner() {
    // TODO: Implement barcode scanner
    Get.snackbar(
      'Info',
      'Scanner barcode akan segera tersedia',
      snackPosition: SnackPosition.TOP,
    );
  }

  // Open AI camera scan
  void openAICameraScan() {
    Get.toNamed('/ai-scan');
  }

  // Show AI features info
  void showAIFeaturesInfo() {
    Get.dialog(
      AlertDialog(
        title: const Text('Fitur AI Unggulan'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Deteksi Produk dengan Kamera',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              '• Scan produk tanpa barcode menggunakan teknologi AI\n'
              '• Tingkat akurasi 80%+ untuk produk yang sudah dilatih\n'
              '• On-device inference untuk kecepatan optimal\n'
              '• Fallback ke cloud inference jika diperlukan\n'
              '• Feedback loop untuk meningkatkan akurasi model',
            ),
            SizedBox(height: 16),
            Text(
              'Teknologi:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 4),
            Text('• TensorFlow Lite (MobileNetV2)\n• Input: 224x224 RGB\n• Confidence threshold: 70%'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }

  // Get user display name
  String get userDisplayName => authController.userDisplayName;

  // Get tenant name
  String get tenantName => authController.tenantName;

  // Get user role
  String get userRole => authController.userRole;
}
