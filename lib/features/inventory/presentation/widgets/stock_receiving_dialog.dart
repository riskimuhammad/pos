import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pos/core/theme/app_theme.dart';
import 'package:pos/shared/models/entities/entities.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:pos/features/inventory/presentation/widgets/product_dropdown.dart';
import 'package:pos/features/inventory/presentation/widgets/location_dropdown.dart';

class StockReceivingDialog extends StatefulWidget {
  final Inventory? inventory; // If provided, pre-fill the form
  final Function(String productId, String locationId, int quantity, String referenceId, String? notes)? onSubmit;

  const StockReceivingDialog({
    super.key,
    this.inventory,
    this.onSubmit,
  });

  @override
  State<StockReceivingDialog> createState() => _StockReceivingDialogState();
}

class _StockReceivingDialogState extends State<StockReceivingDialog> {
  final _formKey = GlobalKey<FormState>();
  final _quantityController = TextEditingController();
  final _referenceIdController = TextEditingController();
  final _notesController = TextEditingController();
  
  String? _selectedProductId;
  String? _selectedLocationId;

  @override
  void initState() {
    super.initState();
    if (widget.inventory != null) {
      _selectedProductId = widget.inventory!.productId;
      _selectedLocationId = widget.inventory!.locationId;
    }
  }

  @override
  void dispose() {
    _quantityController.dispose();
    _referenceIdController.dispose();
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
                        Icons.receipt,
                        color: AppTheme.successColor,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          AppLocalizations.of(context)!.stockReceiving,
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
                  
                  // Location Selection
                  if (widget.inventory == null) ...[
                    Text(
                      AppLocalizations.of(context)!.location,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    LocationDropdown(
                      selectedLocationId: _selectedLocationId,
                    onLocationSelected: (locationId) {
                      setState(() {
                        _selectedLocationId = locationId;
                      });
                    },
                    ),
                    const SizedBox(height: 16),
                  ],
                  
                  // Quantity Input
                  TextFormField(
                    controller: _quantityController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(context)!.receivedQuantity,
                      hintText: AppLocalizations.of(context)!.receivedQuantityHint,
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.add_box),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Jumlah diterima harus diisi';
                      }
                      final quantity = int.tryParse(value);
                      if (quantity == null || quantity <= 0) {
                        return 'Masukkan jumlah yang valid';
                      }
                      return null;
                    },
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Reference ID Input
                  TextFormField(
                    controller: _referenceIdController,
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(context)!.referenceId,
                      hintText: AppLocalizations.of(context)!.referenceIdHint,
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.receipt_long),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'ID Referensi harus diisi';
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
                            backgroundColor: AppTheme.successColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text('Receive'),
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
      if (_selectedProductId == null || _selectedLocationId == null) {
        Get.snackbar(
          'Error',
          'Pilih produk dan lokasi terlebih dahulu',
          snackPosition: SnackPosition.TOP,
          backgroundColor: AppTheme.errorColor,
          colorText: Colors.white,
        );
        return;
      }

      final quantity = int.parse(_quantityController.text);
      final referenceId = _referenceIdController.text.trim();
      final notes = _notesController.text.trim().isEmpty ? null : _notesController.text.trim();

      widget.onSubmit?.call(
        _selectedProductId!,
        _selectedLocationId!,
        quantity,
        referenceId,
        notes,
      );

      Navigator.of(context).pop();
    }
  }
}
