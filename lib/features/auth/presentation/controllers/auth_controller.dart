import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pos/core/errors/failures.dart';
import 'package:pos/features/auth/domain/usecases/login_usecase.dart';
import 'package:pos/features/auth/domain/usecases/logout_usecase.dart';
import 'package:pos/features/auth/domain/usecases/check_session_usecase.dart';
import 'package:pos/features/auth/data/models/auth_request.dart';
import 'package:pos/features/auth/data/models/user_session.dart';

class AuthController extends GetxController {
  final LoginUseCase loginUseCase;
  final LogoutUseCase logoutUseCase;
  final CheckSessionUseCase checkSessionUseCase;
  final HasValidSessionUseCase hasValidSessionUseCase;

  AuthController({
    required this.loginUseCase,
    required this.logoutUseCase,
    required this.checkSessionUseCase,
    required this.hasValidSessionUseCase,
  });

  // Observable variables
  final RxBool isLoading = false.obs;
  final RxBool isLoggedIn = false.obs;
  final RxString errorMessage = ''.obs;
  final Rx<UserSession?> currentSession = Rx<UserSession?>(null);

  // Form controllers
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    _checkInitialSession();
  }

  @override
  void onClose() {
    usernameController.dispose();
    passwordController.dispose();
    super.onClose();
  }

  Future<void> _checkInitialSession() async {
    isLoading.value = true;
    
    final result = await hasValidSessionUseCase();
    result.fold(
      (failure) {
        isLoggedIn.value = false;
        currentSession.value = null;
      },
      (hasValidSession) {
        if (hasValidSession) {
          _loadCurrentSession();
        } else {
          isLoggedIn.value = false;
          currentSession.value = null;
        }
      },
    );
    
    isLoading.value = false;
  }

  Future<void> _loadCurrentSession() async {
    final result = await checkSessionUseCase();
    result.fold(
      (failure) {
        isLoggedIn.value = false;
        currentSession.value = null;
      },
      (session) {
        if (session != null && session.isValid) {
          isLoggedIn.value = true;
          currentSession.value = session;
        } else {
          isLoggedIn.value = false;
          currentSession.value = null;
        }
      },
    );
  }

  Future<void> login() async {
    if (isLoading.value) return;

    isLoading.value = true;
    errorMessage.value = '';

    final request = AuthRequest(
      username: usernameController.text.trim(),
      password: passwordController.text.trim(),
      deviceId: 'device_${DateTime.now().millisecondsSinceEpoch}',
      deviceName: 'POS Device',
      osVersion: 'Android 13',
      appVersion: '1.0.0',
    );

    final result = await loginUseCase(request);
    
    result.fold(
      (failure) => _handleFailure(failure),
      (session) {
        isLoggedIn.value = true;
        currentSession.value = session;
        errorMessage.value = '';
        
        // Clear form
        usernameController.clear();
        passwordController.clear();
        
        // Navigate to dashboard
        Get.offNamed('/dashboard');
        
        // Show success message
        Get.snackbar(
          'Berhasil',
          'Selamat datang, ${session.user.fullName ?? session.user.username}!',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Get.theme.primaryColor,
          colorText: Get.theme.colorScheme.onPrimary,
        );
      },
    );

    isLoading.value = false;
  }

  Future<void> logout() async {
    if (isLoading.value) return;

    isLoading.value = true;

    final result = await logoutUseCase();
    
    result.fold(
      (failure) {
        _handleFailure(failure);
        // Even if logout fails, clear local session
        isLoggedIn.value = false;
        currentSession.value = null;
      },
      (_) {
        isLoggedIn.value = false;
        currentSession.value = null;
        
        // Navigate to login
        Get.offAllNamed('/login');
        
        // Show success message
        Get.snackbar(
          'Berhasil',
          'Anda telah logout',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Get.theme.primaryColor,
          colorText: Get.theme.colorScheme.onPrimary,
        );
      },
    );

    isLoading.value = false;
  }

  void _handleFailure(Failure failure) {
    String message;
    
    if (failure is ValidationFailure) {
      message = failure.message;
    } else if (failure is AuthenticationFailure) {
      message = failure.message;
    } else if (failure is NetworkFailure) {
      message = 'Tidak ada koneksi internet';
    } else if (failure is ServerFailure) {
      message = 'Server error: ${failure.message}';
    } else {
      message = 'Terjadi kesalahan: ${failure.message}';
    }
    
    errorMessage.value = message;
    Get.snackbar(
      'Error',
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: Get.theme.colorScheme.error,
      colorText: Get.theme.colorScheme.onError,
    );
  }

  void clearError() {
    errorMessage.value = '';
  }

  // Getters for UI
  bool get canLogin => 
      usernameController.text.trim().isNotEmpty && 
      passwordController.text.trim().isNotEmpty &&
      !isLoading.value;

  String get userDisplayName {
    final session = currentSession.value;
    if (session != null) {
      return session.user.fullName ?? session.user.username;
    }
    return '';
  }

  String get userRole {
    final session = currentSession.value;
    if (session != null) {
      return session.user.role;
    }
    return '';
  }

  String get tenantName {
    final session = currentSession.value;
    if (session != null) {
      return session.tenant.name;
    }
    return '';
  }

  // Method untuk check session dari main.dart
  Future<bool> checkSession() async {
    final result = await hasValidSessionUseCase();
    return result.fold(
      (failure) => false,
      (hasValidSession) {
        if (hasValidSession) {
          _loadCurrentSession();
          return true;
        }
        return false;
      },
    );
  }
}
