import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import 'core/theme/app_theme.dart';
import 'core/constants/app_constants.dart';
import 'core/di/dependency_injection.dart';
import 'features/auth/presentation/controllers/auth_controller.dart';
import 'features/auth/presentation/pages/login_page.dart';
import 'features/auth/presentation/middleware/auth_middleware.dart';
import 'features/pos/presentation/pages/dashboard_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize GetStorage
  try {
    await GetStorage.init();
  } catch (e) {
    // Handle initialization error (e.g., in test environment)
    // GetStorage initialization failed in test environment
    debugPrint('GetStorage initialization failed: $e');
  }
  
  // Initialize dependencies
  await DependencyInjection.init();
  
  runApp(const PosApp());
}

class PosApp extends StatelessWidget {
  const PosApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: AppConstants.appName,
      theme: AppTheme.lightTheme,
      debugShowCheckedModeBanner: false,
      defaultTransition: Transition.cupertino,
      transitionDuration: const Duration(milliseconds: 300),
      home: const SplashScreen(),
      getPages: [
        GetPage(
          name: '/login',
          page: () => const LoginPage(),
          transition: Transition.fadeIn,
          middlewares: [GuestMiddleware()],
        ),
        GetPage(
          name: '/dashboard',
          page: () => const DashboardPage(),
          transition: Transition.fadeIn,
          middlewares: [AuthMiddleware()],
        ),
      ],
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    // Simulate app initialization
    await Future.delayed(const Duration(seconds: 2));

    // Check if user has valid session
    try {
      final authController = Get.find<AuthController>();
      final hasSession = await authController.checkSession();

      if (hasSession) {
        Get.offNamed('/dashboard');
      } else {
        Get.offNamed('/login');
      }
    } catch (e) {
      // If AuthController fails, go to login
      debugPrint('Error during session check: $e');
      Get.offNamed('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // App Logo
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: const Icon(
                Icons.point_of_sale,
                size: 60,
                color: AppTheme.primaryColor,
              ),
            ),
            const SizedBox(height: 32),
            
            // App Name
            const Text(
              AppConstants.appName,
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontFamily: 'Inter',
              ),
            ),
            const SizedBox(height: 8),
            
            // App Description
            const Text(
              'Point of Sale untuk UMKM',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white70,
                fontFamily: 'Inter',
              ),
            ),
            const SizedBox(height: 48),
            
            // Loading Indicator
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}