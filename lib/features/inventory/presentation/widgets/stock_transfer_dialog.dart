import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pos/core/theme/app_theme.dart';
import 'package:pos/shared/models/entities/entities.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:pos/features/inventory/presentation/widgets/product_dropdown.dart';
import 'package:pos/features/inventory/presentation/widgets/location_dropdown.dart';

class StockTransferDialog extends StatefulWidget {
  final Inventory? inventory; // If provided, pre-fill the form
  final Function(String productId, String fromLocationId, String toLocationId, int quantity, String? notes)? onSubmit;

  const StockTransferDialog({
    super.key,
    this.inventory,
    this.onSubmit,
  });

  @override
  State<StockTransferDialog> createState() => _StockTransferDialogState();
}

class _StockTransferDialogState extends State<StockTransferDialog> {
  final _formKey = GlobalKey<FormState>();
  final _quantityController = TextEditingController();
  final _notesController = TextEditingController();
  
  String? _selectedProductId;
  String? _selectedFromLocationId;
  String? _selectedToLocationId;
  int _availableStock = 0;

  @override
  void initState() {
    super.initState();
    if (widget.inventory != null) {
      _selectedProductId = widget.inventory!.productId;
      _selectedFromLocationId = widget.inventory!.locationId;
      _availableStock = widget.inventory!.quantity;
    }
  }

  @override
  void dispose() {
    _quantityController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    children: [
                      const Icon(
                        Icons.swap_horiz,
                        color: AppTheme.secondaryColor,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          AppLocalizations.of(context)!.stockTransfer,
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
                  
                  // Product Selection
                  if (widget.inventory == null) ...[
                    Text(
                      AppLocalizations.of(context)!.product,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ProductDropdown(
                      selectedProductId: _selectedProductId,
                    onProductSelected: (productId) {
                      setState(() {
                        _selectedProductId = productId;
                      });
                    },
                    ),
                    const SizedBox(height: 16),
                  ],
                  
                  // From Location Selection
                  if (widget.inventory == null) ...[
                    Text(
                      AppLocalizations.of(context)!.fromLocation,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    LocationDropdown(
                      selectedLocationId: _selectedFromLocationId,
                    onLocationSelected: (locationId) {
                      setState(() {
                        _selectedFromLocationId = locationId;
                      });
                    },
                    ),
                    const SizedBox(height: 16),
                  ],
                  
                  // Available Stock Display
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.blue.withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.inventory_2, color: Colors.blue, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          '${AppLocalizations.of(context)!.availableStock}: $_availableStock',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.blue,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // To Location Selection
                  Text(
                    AppLocalizations.of(context)!.toLocation,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  LocationDropdown(
                    selectedLocationId: _selectedToLocationId,
                    onLocationSelected: (locationId) {
                      setState(() {
                        _selectedToLocationId = locationId;
                      });
                    },
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Quantity Input
                  TextFormField(
                    controller: _quantityController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(context)!.transferQuantity,
                      hintText: AppLocalizations.of(context)!.transferQuantityHint,
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.swap_horiz),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Jumlah transfer harus diisi';
                      }
                      final quantity = int.tryParse(value);
                      if (quantity == null || quantity <= 0) {
                        return 'Masukkan jumlah yang valid';
                      }
                      if (quantity > _availableStock) {
                        return 'Jumlah tidak boleh melebihi stok tersedia';
                      }
                      return null;
                    },
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Notes Input
                  TextFormField(
                    controller: _notesController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(context)!.notesOptional,
                      hintText: AppLocalizations.of(context)!.notesOptionalHint,
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.note),
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.of(context).pop(),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text(AppLocalizations.of(context)!.cancel),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _submitForm,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.secondaryColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text(AppLocalizations.of(context)!.transfer),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      if (_selectedProductId == null || _selectedFromLocationId == null || _selectedToLocationId == null) {
        Get.snackbar(
          'Error',
          'Pilih produk dan lokasi terlebih dahulu',
          snackPosition: SnackPosition.TOP,
          backgroundColor: AppTheme.errorColor,
          colorText: Colors.white,
        );
        return;
      }

      if (_selectedFromLocationId == _selectedToLocationId) {
        Get.snackbar(
          'Error',
          'Lokasi asal dan tujuan tidak boleh sama',
          snackPosition: SnackPosition.TOP,
          backgroundColor: AppTheme.errorColor,
          colorText: Colors.white,
        );
        return;
      }

      final quantity = int.parse(_quantityController.text);
      final notes = _notesController.text.trim().isEmpty ? null : _notesController.text.trim();

      widget.onSubmit?.call(
        _selectedProductId!,
        _selectedFromLocationId!,
        _selectedToLocationId!,
        quantity,
        notes,
      );

      Navigator.of(context).pop();
    }
  }
}
