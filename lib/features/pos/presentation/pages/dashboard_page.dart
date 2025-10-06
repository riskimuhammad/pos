import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthController authController = Get.find<AuthController>();
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'logout') {
                authController.logout();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout),
                    SizedBox(width: 8),
                    Text('Logout'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppTheme.spacing16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Section
            Obx(() => Card(
              child: Padding(
                padding: const EdgeInsets.all(AppTheme.spacing16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Selamat Datang, ${authController.userDisplayName}!',
                      style: AppTheme.heading3,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      authController.tenantName,
                      style: AppTheme.bodyMedium.copyWith(
                        color: AppTheme.primaryColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Role: ${authController.userRole.toUpperCase()}',
                      style: AppTheme.bodySmall.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Siap untuk melayani pelanggan hari ini?',
                      style: AppTheme.bodyMedium.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            )),
            const SizedBox(height: 24),
            
            // Quick Actions
            const Text(
              'Aksi Cepat',
              style: AppTheme.heading4,
            ),
            const SizedBox(height: 16),
            
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: [
                  _buildQuickActionCard(
                    icon: Icons.point_of_sale,
                    title: 'Transaksi Baru',
                    color: AppTheme.primaryColor,
                    onTap: () {
                      // TODO: Navigate to POS
                    },
                  ),
                  _buildQuickActionCard(
                    icon: Icons.inventory,
                    title: 'Inventory',
                    color: AppTheme.secondaryColor,
                    onTap: () {
                      // TODO: Navigate to Inventory
                    },
                  ),
                  _buildQuickActionCard(
                    icon: Icons.shopping_cart,
                    title: 'Produk',
                    color: AppTheme.warningColor,
                    onTap: () {
                      // TODO: Navigate to Products
                    },
                  ),
                  _buildQuickActionCard(
                    icon: Icons.analytics,
                    title: 'Laporan',
                    color: AppTheme.infoColor,
                    onTap: () {
                      // TODO: Navigate to Reports
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Quick transaction
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildQuickActionCard({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppTheme.radius12),
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.spacing16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppTheme.radius12),
                ),
                child: Icon(
                  icon,
                  size: 30,
                  color: color,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: AppTheme.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
