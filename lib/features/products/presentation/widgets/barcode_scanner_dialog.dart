import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pos/core/theme/app_theme.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:pos/core/services/permission_service.dart';

class BarcodeScannerDialog extends StatefulWidget {
  final Function(String) onBarcodeScanned;

  const BarcodeScannerDialog({
    super.key,
    required this.onBarcodeScanned,
  });

  @override
  State<BarcodeScannerDialog> createState() => _BarcodeScannerDialogState();
}

class _BarcodeScannerDialogState extends State<BarcodeScannerDialog> {
  final TextEditingController _barcodeController = TextEditingController();
  bool _isScanning = false;

  @override
  void dispose() {
    _barcodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                children: [
                  Icon(
                    Icons.qr_code_scanner,
                    color: AppTheme.primaryColor,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Scan Barcode',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Get.back(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),
            
            // Scrollable Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
            
                    // Scanner Preview Placeholder
                    Container(
                      height: 150,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.qr_code_scanner,
                            size: 48,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Real Camera Scanner',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Tap "Mulai Scan" to open camera',
                            style: TextStyle(
                              color: Colors.grey[500],
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Manual Input
                    Text(
                      'Atau masukkan barcode secara manual:',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 12),
                    
                    TextField(
                      controller: _barcodeController,
                      decoration: InputDecoration(
                        labelText: 'Barcode',
                        hintText: 'Masukkan kode barcode',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: AppTheme.primaryColor),
                        ),
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () => _barcodeController.clear(),
                        ),
                      ),
                      onSubmitted: (value) {
                        if (value.trim().isNotEmpty) {
                          widget.onBarcodeScanned(value.trim());
                          Get.back();
                        }
                      },
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
            
            // Fixed Actions at Bottom
            Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.back(),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        side: BorderSide(color: Colors.grey[400]!),
                      ),
                      child: const Text('Batal'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isScanning ? null : _startScanning,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: _isScanning
                          ? const SizedBox(
                              height: 16,
                              width: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Text(
                              'Mulai Scan',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _startScanning() async {
    setState(() {
      _isScanning = true;
    });

    try {
      // Check camera permission first
      final permissionService = Get.find<PermissionService>();
      final hasPermission = await permissionService.checkAndRequestCameraPermission();
      
      if (!hasPermission) {
        if (mounted) {
          setState(() {
            _isScanning = false;
          });
        }
        return;
      }

      // Use real barcode scanner
      final String barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
        '#ff6666', // Line color
        'Cancel', // Cancel button text
        true, // Show flash icon
        ScanMode.DEFAULT, // Scan mode
      );

      if (mounted) {
        setState(() {
          _isScanning = false;
        });

        // Check if scan was successful and not cancelled
        if (barcodeScanRes != '-1' && barcodeScanRes.isNotEmpty) {
          // Close dialog first
          Get.back();
          
          // Then call callback
          widget.onBarcodeScanned(barcodeScanRes);
          
         
        } else {
          // Scan was cancelled - close dialog
          Get.back();
          
          Get.snackbar(
            'Scan Cancelled',
            'Barcode scanning was cancelled',
            snackPosition: SnackPosition.TOP,
            backgroundColor: AppTheme.warningColor,
            colorText: Colors.white,
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isScanning = false;
        });
        
        // Fallback to mock scanning if real scanner fails
        
        Get.snackbar(
          'Scanner Error',
          'Using fallback scanner: $e',
          snackPosition: SnackPosition.TOP,
          backgroundColor: AppTheme.warningColor,
          colorText: Colors.white,
        );
      }
    }
  }

}
