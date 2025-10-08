import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:get/get.dart';

class PermissionService extends GetxService {
  static PermissionService get to => Get.find();

  /// Check if camera permission is granted
  Future<bool> isCameraPermissionGranted() async {
    final status = await Permission.camera.status;
    return status.isGranted;
  }

  /// Request camera permission
  Future<bool> requestCameraPermission() async {
    final status = await Permission.camera.request();
    return status.isGranted;
  }

  /// Check and request camera permission with user-friendly messages
  Future<bool> checkAndRequestCameraPermission() async {
    // Check current status
    final status = await Permission.camera.status;
    
    if (status.isGranted) {
      return true;
    }
    
    if (status.isDenied) {
      // Request permission
      final result = await Permission.camera.request();
      if (result.isGranted) {
        Get.snackbar(
          'Permission Granted',
          'Camera permission has been granted',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Get.theme.primaryColor,
          colorText: Get.theme.colorScheme.onPrimary,
        );
        return true;
      }
    }
    
    if (status.isPermanentlyDenied) {
      // Show dialog to open app settings
      Get.dialog(
        AlertDialog(
          title: const Text('Camera Permission Required'),
          content: const Text(
            'Camera permission is permanently denied. Please enable it in app settings to use barcode scanner.',
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Get.back();
                openAppSettings();
              },
              child: const Text('Open Settings'),
            ),
          ],
        ),
      );
      return false;
    }
    
    return false;
  }

  /// Get permission status with user-friendly message
  Future<String> getCameraPermissionStatus() async {
    final status = await Permission.camera.status;
    
    switch (status) {
      case PermissionStatus.granted:
        return 'Camera permission is granted';
      case PermissionStatus.denied:
        return 'Camera permission is denied';
      case PermissionStatus.restricted:
        return 'Camera permission is restricted';
      case PermissionStatus.limited:
        return 'Camera permission is limited';
      case PermissionStatus.permanentlyDenied:
        return 'Camera permission is permanently denied';
      case PermissionStatus.provisional:
        return 'Camera permission is provisional';
    }
  }

  /// Check all required permissions for barcode scanning
  Future<Map<String, bool>> checkAllPermissions() async {
    return {
      'camera': await isCameraPermissionGranted(),
    };
  }

  /// Request all required permissions
  Future<Map<String, bool>> requestAllPermissions() async {
    return {
      'camera': await requestCameraPermission(),
    };
  }
}
