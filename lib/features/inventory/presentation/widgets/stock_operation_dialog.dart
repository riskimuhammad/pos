import 'package:flutter/material.dart';
import 'package:pos/core/theme/app_theme.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class StockOperationDialog extends StatelessWidget {
  final VoidCallback? onStockAdjustment;
  final VoidCallback? onStockTransfer;
  final VoidCallback? onStockReceiving;

  const StockOperationDialog({
    super.key,
    this.onStockAdjustment,
    this.onStockTransfer,
    this.onStockReceiving,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Row(
              children: [
                const Icon(
                  Icons.inventory_2,
                  color: AppTheme.primaryColor,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    AppLocalizations.of(context)!.stockOperation,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Operation Options
            _buildOperationOption(
              context,
              icon: Icons.edit,
              title: AppLocalizations.of(context)!.stockAdjustment,
              subtitle: AppLocalizations.of(context)!.stockAdjustmentDesc,
              color: AppTheme.primaryColor,
              onTap: onStockAdjustment,
            ),
            
            const SizedBox(height: 16),
            
            _buildOperationOption(
              context,
              icon: Icons.swap_horiz,
              title: AppLocalizations.of(context)!.stockTransfer,
              subtitle: AppLocalizations.of(context)!.stockTransferDesc,
              color: AppTheme.secondaryColor,
              onTap: onStockTransfer,
            ),
            
            const SizedBox(height: 16),
            
            _buildOperationOption(
              context,
              icon: Icons.receipt,
              title: AppLocalizations.of(context)!.stockReceiving,
              subtitle: AppLocalizations.of(context)!.stockReceivingDesc,
              color: AppTheme.successColor,
              onTap: onStockReceiving,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOperationOption(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: color.withOpacity(0.2)),
          borderRadius: BorderRadius.circular(12),
          color: color.withOpacity(0.05),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: color,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Colors.grey[400],
            ),
          ],
        ),
      ),
    );
  }
}
