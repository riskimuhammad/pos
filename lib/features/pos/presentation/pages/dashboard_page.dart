import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../controllers/dashboard_controller.dart';
import '../../../../shared/widgets/language_switcher.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthController authController = Get.find<AuthController>();
    final DashboardController dashboardController = Get.find<DashboardController>();

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: CustomScrollView(
        slivers: [
          // Modern App Bar
          SliverAppBar(
            expandedHeight: 160,
            floating: false,
            pinned: true,
            elevation: 0,
            backgroundColor: AppTheme.primaryColor,
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.only(left: 16, bottom: 16),
              title: Obx(() => Text(
                AppLocalizations.of(context)!.hello(authController.userDisplayName),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                  shadows: [
                    Shadow(
                      offset: Offset(0, 1),
                      blurRadius: 2,
                      color: Colors.black26,
                    ),
                  ],
                ),
              )),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppTheme.primaryColor,
                      AppTheme.primaryVariant,
                      AppTheme.primaryColor.withOpacity(0.9),
                    ],
                    stops: const [0.0, 0.6, 1.0],
                  ),
                ),
                child: Stack(
                  children: [
                    // Subtle decorative elements
                    Positioned(
                      top: -30,
                      right: -30,
                      child: Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              Colors.white.withOpacity(0.12),
                              Colors.white.withOpacity(0.04),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: -20,
                      left: -20,
                      child: Container(
                        width: 70,
                        height: 70,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              Colors.white.withOpacity(0.08),
                              Colors.white.withOpacity(0.02),
                            ],
                          ),
                        ),
                      ),
                    ),
                    // Main content positioned at bottom
                    Positioned(
                      left: 16,
                      right: 16,
                      bottom: 50,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Obx(() => Text(
                            authController.tenantName,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              shadows: [
                                Shadow(
                                  offset: Offset(0, 1),
                                  blurRadius: 2,
                                  color: Colors.black26,
                                ),
                              ],
                            ),
                          )),
                          const SizedBox(height: 6),
                          Obx(() => Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.25),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.3),
                                width: 0.5,
                              ),
                            ),
                            child: Text(
                              authController.userRole.toUpperCase(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.5,
                              ),
                            ),
                          )),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              // Language Switcher
              Container(
                margin: const EdgeInsets.only(right: 8),
                child: const LanguageSwitcher(),
              ),
              // Notifications
              Container(
                margin: const EdgeInsets.only(right: 4),
                child: IconButton(
                  icon: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.notifications_outlined,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  onPressed: () {
                    // TODO: Navigate to notifications
                  },
                ),
              ),
              // Profile Menu
              Container(
                margin: const EdgeInsets.only(right: 8),
                child: PopupMenuButton<String>(
                  icon: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.account_circle_outlined,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  onSelected: (value) {
                    if (value == 'logout') {
                      authController.logout();
                    }
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'profile',
                      child: Row(
                        children: [
                          const Icon(Icons.person_outline, color: AppTheme.primaryColor),
                          const SizedBox(width: 12),
                          Text(AppLocalizations.of(context)!.profile),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'settings',
                      child: Row(
                        children: [
                          const Icon(Icons.settings_outlined, color: AppTheme.primaryColor),
                          const SizedBox(width: 12),
                          Text(AppLocalizations.of(context)!.settings),
                        ],
                      ),
                    ),
                    const PopupMenuDivider(),
                    PopupMenuItem(
                      value: 'logout',
                      child: Row(
                        children: [
                          const Icon(Icons.logout, color: Colors.red),
                          const SizedBox(width: 12),
                          Text(
                            AppLocalizations.of(context)!.logout,
                            style: const TextStyle(color: Colors.red),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Dashboard Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Today's Stats
                  _buildTodayStats(context),
                  const SizedBox(height: 24),

                  // Quick Actions
                  _buildQuickActions(),
                  const SizedBox(height: 24),

                  // Main Menu Grid
                  _buildMainMenuGrid(),
                  const SizedBox(height: 24),

                  // AI Features Section
                  _buildAIFeaturesSection(),
                  const SizedBox(height: 24),

                  // Recent Activity
                  _buildRecentActivity(),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: dashboardController.navigateToPOS,
        backgroundColor: AppTheme.primaryColor,
        icon: const Icon(Icons.point_of_sale, color: Colors.white),
        label: const Text(
          'Transaksi Baru',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  Widget _buildTodayStats(context) {
    final DashboardController dashboardController = Get.find<DashboardController>();
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.of(context)!.today,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          Obx(() => Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  AppLocalizations.of(context)!.transactions,
                  dashboardController.todayTransactions.value.toString(),
                  Icons.receipt_long,
                  AppTheme.primaryColor,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  AppLocalizations.of(context)!.sales,
                  dashboardController.formatCurrency(dashboardController.todaySales.value),
                  Icons.attach_money,
                  AppTheme.successColor,
                ),
              ),
            ],
          )),
          const SizedBox(height: 12),
          Obx(() => Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  AppLocalizations.of(context)!.productsSold,
                  dashboardController.todayProductsSold.value.toString(),
                  Icons.inventory_2,
                  AppTheme.infoColor,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  AppLocalizations.of(context)!.average,
                  dashboardController.formatCurrency(dashboardController.averageTransaction.value),
                  Icons.trending_up,
                  AppTheme.warningColor,
                ),
              ),
            ],
          )),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    final DashboardController dashboardController = Get.find<DashboardController>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Aksi Cepat',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildQuickActionButton(
                'Scan Barcode',
                Icons.qr_code_scanner,
                AppTheme.primaryColor,
                dashboardController.openBarcodeScanner,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildQuickActionButton(
                'AI Scan',
                Icons.camera_alt,
                AppTheme.secondaryColor,
                dashboardController.openAICameraScan,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickActionButton(String title, IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.2)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainMenuGrid() {
    final DashboardController dashboardController = Get.find<DashboardController>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Menu Utama',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.2,
          children: [
            _buildMenuCard(
              'Point of Sale',
              'Transaksi penjualan',
              Icons.point_of_sale,
              AppTheme.primaryColor,
              dashboardController.navigateToPOS,
            ),
            _buildMenuCard(
              'Produk',
              'Kelola produk',
              Icons.inventory_2,
              AppTheme.infoColor,
              dashboardController.navigateToProducts,
            ),
            _buildMenuCard(
              'Inventory',
              'Kelola stok',
              Icons.warehouse,
              AppTheme.warningColor,
              dashboardController.navigateToInventory,
            ),
            _buildMenuCard(
              'Laporan',
              'Analisis & laporan',
              Icons.analytics,
              AppTheme.successColor,
              dashboardController.navigateToReports,
            ),
            _buildMenuCard(
              'Pengguna',
              'Kelola user',
              Icons.people,
              AppTheme.secondaryColor,
              dashboardController.navigateToUsers,
            ),
            _buildMenuCard(
              'Pengaturan',
              'Konfigurasi sistem',
              Icons.settings,
              AppTheme.textSecondary,
              dashboardController.navigateToSettings,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMenuCard(String title, String subtitle, IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 12,
                color: AppTheme.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAIFeaturesSection() {
    final DashboardController dashboardController = Get.find<DashboardController>();
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.primaryColor.withOpacity(0.1),
            AppTheme.secondaryColor.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.primaryColor.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.psychology,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Fitur AI Unggulan',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'Deteksi Produk dengan Kamera',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Scan produk tanpa barcode menggunakan teknologi AI. Tingkat akurasi 80%+ untuk produk yang sudah dilatih.',
            style: TextStyle(
              fontSize: 14,
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: dashboardController.openAICameraScan,
                  icon: const Icon(Icons.camera_alt, size: 18),
                  label: const Text('Coba AI Scan'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              OutlinedButton.icon(
                onPressed: dashboardController.showAIFeaturesInfo,
                icon: const Icon(Icons.info_outline, size: 18),
                label: const Text('Info'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.primaryColor,
                  side: BorderSide(color: AppTheme.primaryColor),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRecentActivity() {
    final DashboardController dashboardController = Get.find<DashboardController>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Aktivitas Terbaru',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Obx(() => Column(
            children: dashboardController.recentActivities.take(3).map((activity) {
              return Column(
                children: [
                  _buildActivityItem(
                    activity['title'],
                    activity['subtitle'],
                    activity['time'],
                    _getIconFromString(activity['icon']),
                    _getColorFromString(activity['color']),
                  ),
                  if (activity != dashboardController.recentActivities.last)
                    const Divider(),
                ],
              );
            }).toList(),
          )),
        ),
      const SizedBox(height: 44),
      ],
    );
  }

  Widget _buildActivityItem(String title, String subtitle, String time, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Text(
            time,
            style: const TextStyle(
              fontSize: 12,
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getIconFromString(String iconName) {
    switch (iconName) {
      case 'receipt_long':
        return Icons.receipt_long;
      case 'add_circle':
        return Icons.add_circle;
      case 'warning':
        return Icons.warning;
      case 'person':
        return Icons.person;
      case 'undo':
        return Icons.undo;
      default:
        return Icons.info;
    }
  }

  Color _getColorFromString(String colorName) {
    switch (colorName) {
      case 'success':
        return AppTheme.successColor;
      case 'info':
        return AppTheme.infoColor;
      case 'warning':
        return AppTheme.warningColor;
      case 'primary':
        return AppTheme.primaryColor;
      case 'secondary':
        return AppTheme.secondaryColor;
      default:
        return AppTheme.textSecondary;
    }
  }
}
