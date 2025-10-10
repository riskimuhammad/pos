import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pos/core/theme/app_theme.dart';
import 'package:pos/shared/models/entities/entities.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:pos/features/inventory/presentation/widgets/product_dropdown.dart';
import 'package:pos/features/inventory/presentation/widgets/location_dropdown.dart';

class StockAdjustmentDialog extends StatefulWidget {
  final Inventory? inventory; // If provided, pre-fill the form
  final Function(String productId, String locationId, int physicalCount, String reason, String? notes)? onSubmit;

  const StockAdjustmentDialog({
    super.key,
    this.inventory,
    this.onSubmit,
  });

  @override
  State<StockAdjustmentDialog> createState() => _StockAdjustmentDialogState();
}

class _StockAdjustmentDialogState extends State<StockAdjustmentDialog> {
  final _formKey = GlobalKey<FormState>();
  final _physicalCountController = TextEditingController();
  final _reasonController = TextEditingController();
  final _notesController = TextEditingController();
  
  String? _selectedProductId;
  String? _selectedLocationId;
  int _currentStock = 0;
  int _physicalCount = 0;
  int _adjustment = 0;

  @override
  void initState() {
    super.initState();
    if (widget.inventory != null) {
      _selectedProductId = widget.inventory!.productId;
      _selectedLocationId = widget.inventory!.locationId;
      _currentStock = widget.inventory!.quantity;
      _physicalCountController.text = _currentStock.toString();
      _calculateAdjustment();
    }
  }

  @override
  void dispose() {
    _physicalCountController.dispose();
    _reasonController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _calculateAdjustment() {
    setState(() {
      _physicalCount = int.tryParse(_physicalCountController.text) ?? 0;
      _adjustment = _physicalCount - _currentStock;
    });
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
                        Icons.edit,
                        color: AppTheme.primaryColor,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          AppLocalizations.of(context)!.stockAdjustment,
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
                  
                  // Current Stock Display
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
                          '${AppLocalizations.of(context)!.currentStock}: $_currentStock',
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
                  
                  // Physical Count Input
                  TextFormField(
                    controller: _physicalCountController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(context)!.physicalCount,
                      hintText: AppLocalizations.of(context)!.physicalCountHint,
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.inventory),
                    ),
                    onChanged: (value) => _calculateAdjustment(),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Jumlah fisik harus diisi';
                      }
                      final count = int.tryParse(value);
                      if (count == null || count < 0) {
                        return 'Masukkan angka yang valid';
                      }
                      return null;
                    },
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Adjustment Display
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: _adjustment >= 0 ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: _adjustment >= 0 ? Colors.green.withOpacity(0.3) : Colors.red.withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          _adjustment >= 0 ? Icons.trending_up : Icons.trending_down,
                          color: _adjustment >= 0 ? Colors.green : Colors.red,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${AppLocalizations.of(context)!.adjustment}: ${_adjustment >= 0 ? '+' : ''}$_adjustment',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: _adjustment >= 0 ? Colors.green : Colors.red,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Reason Input
                  TextFormField(
                    controller: _reasonController,
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(context)!.reasonForAdjustment,
                      hintText: AppLocalizations.of(context)!.reasonForAdjustmentHint,
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.info),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Alasan penyesuaian harus diisi';
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
                            backgroundColor: AppTheme.primaryColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text(AppLocalizations.of(context)!.adjust),
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

      final physicalCount = int.parse(_physicalCountController.text);
      final reason = _reasonController.text.trim();
      final notes = _notesController.text.trim().isEmpty ? null : _notesController.text.trim();

      widget.onSubmit?.call(
        _selectedProductId!,
        _selectedLocationId!,
        physicalCount,
        reason,
        notes,
      );

      Navigator.of(context).pop();
    }
  }
}
