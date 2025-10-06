import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/theme/app_theme.dart';
import '../controllers/auth_controller.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthController authController = Get.find<AuthController>();
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppTheme.spacing24),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height - 
                         MediaQuery.of(context).padding.top - 
                         MediaQuery.of(context).padding.bottom - 
                         (AppTheme.spacing24 * 2),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
              // Logo
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(
                  Icons.point_of_sale,
                  size: 50,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 32),
              
              // Title
              Text(
                'Selamat Datang',
                style: AppTheme.heading1.copyWith(
                  color: AppTheme.primaryColor,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              
              Text(
                'Masuk ke akun POS UMKM Anda',
                style: AppTheme.bodyLarge.copyWith(
                  color: AppTheme.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),
              
              // Username Field
              Obx(() => TextFormField(
                controller: authController.usernameController,
                decoration: const InputDecoration(
                  labelText: 'Username atau Email',
                  hintText: 'admin, kasir1, manager1 atau email',
                  prefixIcon: Icon(Icons.person_outline),
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
                enabled: !authController.isLoading.value,
                onChanged: (_) => authController.clearError(),
              )),
              const SizedBox(height: 16),
              
              // Password Field
              Obx(() => TextFormField(
                controller: authController.passwordController,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  prefixIcon: Icon(Icons.lock_outline),
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
                enabled: !authController.isLoading.value,
                onChanged: (_) => authController.clearError(),
              )),
              const SizedBox(height: 16),
              
              // Error Message
              Obx(() => authController.errorMessage.value.isNotEmpty
                  ? Container(
                      padding: const EdgeInsets.all(12),
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: AppTheme.errorColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppTheme.errorColor.withOpacity(0.3)),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.error_outline, color: AppTheme.errorColor, size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              authController.errorMessage.value,
                              style: TextStyle(color: AppTheme.errorColor),
                            ),
                          ),
                        ],
                      ),
                    )
                  : const SizedBox.shrink()),
              
              // Login Button
              Obx(() => SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: authController.canLogin ? authController.login : null,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: authController.isLoading.value
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text(
                          'Masuk',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                ),
              )),
              const SizedBox(height: 16),
              
              // Forgot Password
              TextButton(
                onPressed: () {
                  // TODO: Implement forgot password
                },
                child: const Text('Lupa Password?'),
              ),
            ],
            ),
          ),
        ),
      ),
    );
  }
}
