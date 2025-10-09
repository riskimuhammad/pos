import 'package:flutter/material.dart';
import 'package:pos/core/theme/app_theme.dart';
import 'package:pos/shared/models/entities/entities.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:pos/core/storage/local_datasource.dart';
import 'package:get/get.dart';

class InventoryCard extends StatelessWidget {
  final Inventory inventory;
  final VoidCallback? onTap;
  final VoidCallback? onAdjust;
  final VoidCallback? onTransfer;

  const InventoryCard({
    super.key,
    required this.inventory,
    this.onTap,
    this.onAdjust,
    this.onTransfer,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row
              Row(
                children: [
                  // Product Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        FutureBuilder<String>(
                          future: _getProductName(inventory.productId),
                          builder: (context, snapshot) {
                            if (snapshot.hasData) {
                              return Text(
                                snapshot.data!,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.textPrimary,
                                ),
                              );
                            }
                            return Text(
                              'Loading...',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey[400],
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'ID: ${inventory.productId}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Stock Level Indicator
                  _buildStockLevelIndicator(),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // Stock Information
              Row(
                children: [
                  Expanded(
                    child: _buildStockInfo(
                      AppLocalizations.of(context)!.quantity,
                      '${inventory.quantity}',
                      Icons.inventory_2,
                      Colors.blue,
                    ),
                  ),
                  Expanded(
                    child: _buildStockInfo(
                      AppLocalizations.of(context)!.reserved,
                      '${inventory.reserved}',
                      Icons.lock,
                      Colors.orange,
                    ),
                  ),
                  Expanded(
                    child: _buildStockInfo(
                      AppLocalizations.of(context)!.available,
                      '${inventory.availableQuantity}',
                      Icons.check_circle,
                      Colors.green,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: onAdjust,
                      icon: const Icon(Icons.edit, size: 16),
                      label: Text(AppLocalizations.of(context)!.adjust),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppTheme.primaryColor,
                        side: const BorderSide(color: AppTheme.primaryColor),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: onTransfer,
                      icon: const Icon(Icons.swap_horiz, size: 16),
                      label: Text(AppLocalizations.of(context)!.transfer),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppTheme.secondaryColor,
                        side: const BorderSide(color: AppTheme.secondaryColor),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 8),
              
              // Last Updated
              Text(
                '${AppLocalizations.of(context)!.lastUpdated}: ${_formatDate(inventory.updatedAt)}',
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.grey[500],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStockLevelIndicator() {
    Color indicatorColor;
    IconData indicatorIcon;
    String indicatorText;

    if (inventory.isOutOfStock) {
      indicatorColor = Colors.red;
      indicatorIcon = Icons.error;
      indicatorText = 'Out of Stock';
    } else if (inventory.isLowStock) {
      indicatorColor = Colors.orange;
      indicatorIcon = Icons.warning;
      indicatorText = 'Low Stock';
    } else {
      indicatorColor = Colors.green;
      indicatorIcon = Icons.check_circle;
      indicatorText = 'In Stock';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: indicatorColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: indicatorColor.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(indicatorIcon, size: 14, color: indicatorColor),
          const SizedBox(width: 4),
          Text(
            indicatorText,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: indicatorColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStockInfo(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  Future<String> _getProductName(String productId) async {
    try {
      final localDataSource = Get.find<LocalDataSource>();
      final product = await localDataSource.getProduct(productId);
      return product?.name ?? 'Unknown Product';
    } catch (e) {
      return 'Unknown Product';
    }
  }
}
