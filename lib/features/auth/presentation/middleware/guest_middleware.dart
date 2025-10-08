import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pos/features/auth/presentation/controllers/auth_controller.dart';

class GuestMiddleware extends GetMiddleware {
  @override
  int? get priority => 1;

  @override
  RouteSettings? redirect(String? route) {
    // Check if user is already logged in
    try {
      final authController = Get.find<AuthController>();
      if (authController.isLoggedIn.value) {
        // User is already logged in, redirect to dashboard
        return const RouteSettings(name: '/dashboard');
      }
    } catch (e) {
      // AuthController not found, continue to login page
    }
    
    // User is not logged in, allow access to login page
    return null;
  }
}
