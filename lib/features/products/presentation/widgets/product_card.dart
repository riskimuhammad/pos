import 'package:flutter/material.dart';
import 'package:pos/core/theme/app_theme.dart';
import 'package:pos/core/localization/language_controller.dart';
import 'package:pos/shared/models/entities/entities.dart';
import 'package:get/get.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const ProductCard({
    super.key,
    required this.product,
    this.onTap,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final languageController = Get.find<LanguageController>();
    
    return Card(
      margin: EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Row(
            children: [
              // Product Image
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.grey[200],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: product.photos.isNotEmpty
                      ? Image.network(
                          product.photos.first,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Icon(
                              Icons.inventory_2,
                              color: Colors.grey[400],
                              size: 30,
                            );
                          },
                        )
                      : Icon(
                          Icons.inventory_2,
                          color: Colors.grey[400],
                          size: 30,
                        ),
                ),
              ),
              
              SizedBox(width: 12),
              
              // Product Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Product Name
                    Text(
                      product.name,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    
                    SizedBox(height: 4),
                    
                    // SKU and Category
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            product.sku,
                            style: TextStyle(
                              fontSize: 12,
                              color: AppTheme.primaryColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            product.categoryId ?? 'Uncategorized',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    
                    SizedBox(height: 8),
                    
                    // Price and Stock
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            languageController.formatCurrency(product.priceSell),
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.successColor,
                            ),
                          ),
                        ),
                        _buildStockIndicator(),
                      ],
                    ),
                    
                    // Brand and Variant (if available)
                    if (product.attributes['brand'] != null || product.attributes['variant'] != null) ...[
                      SizedBox(height: 4),
                      Text(
                        '${product.attributes['brand'] ?? ''} ${product.attributes['variant'] ?? ''}'.trim(),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[500],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              
              // Action Buttons
              Column(
                children: [
                  IconButton(
                    icon: Icon(Icons.edit, size: 20),
                    onPressed: onEdit,
                    color: AppTheme.primaryColor,
                    tooltip: 'Edit',
                  ),
                  IconButton(
                    icon: Icon(Icons.delete, size: 20),
                    onPressed: onDelete,
                    color: Colors.red[400],
                    tooltip: 'Delete',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStockIndicator() {
    Color stockColor;
    String stockText;
    
    // Get stock from inventory or use minStock as fallback
    final currentStock = product.attributes['current_stock'] as int? ?? product.minStock;
    final reorderPoint = product.attributes['reorder_point'] as int? ?? product.minStock;
    
    if (currentStock <= 0) {
      stockColor = Colors.red;
      stockText = 'Habis';
    } else if (currentStock <= reorderPoint) {
      stockColor = Colors.orange;
      stockText = '$currentStock';
    } else {
      stockColor = AppTheme.successColor;
      stockText = '$currentStock';
    }
    
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: stockColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: stockColor.withOpacity(0.3)),
      ),
      child: Text(
        stockText,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: stockColor,
        ),
      ),
    );
  }
}
