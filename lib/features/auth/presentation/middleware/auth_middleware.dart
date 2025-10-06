import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';

class AuthMiddleware extends GetMiddleware {
  @override
  int? get priority => 1;

  @override
  RouteSettings? redirect(String? route) {
    final AuthController authController = Get.find<AuthController>();
    
    // Check if user is logged in
    if (!authController.isLoggedIn.value) {
      return const RouteSettings(name: '/login');
    }
    
    // Check if session is still valid
    final session = authController.currentSession.value;
    if (session == null || !session.isValid) {
      // Clear invalid session and redirect to login
      authController.logout();
      return const RouteSettings(name: '/login');
    }
    
    return null; // Allow navigation
  }
}

class GuestMiddleware extends GetMiddleware {
  @override
  int? get priority => 1;

  @override
  RouteSettings? redirect(String? route) {
    final AuthController authController = Get.find<AuthController>();
    
    // If user is already logged in, redirect to dashboard
    if (authController.isLoggedIn.value) {
      return const RouteSettings(name: '/dashboard');
    }
    
    return null; // Allow navigation
  }
}
