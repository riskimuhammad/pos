import 'package:get/get.dart';
import 'package:pos/features/auth/presentation/controllers/auth_controller.dart';
import 'package:pos/features/auth/domain/usecases/login_usecase.dart';
import 'package:pos/features/auth/domain/usecases/logout_usecase.dart';
import 'package:pos/features/auth/domain/usecases/check_session_usecase.dart';

class LoginBinding extends Bindings {
  @override
  void dependencies() {
    // Auth controller is already registered globally in DependencyInjection
    // But we can ensure it's available for this route
    Get.lazyPut<AuthController>(() => AuthController(
      loginUseCase: Get.find<LoginUseCase>(),
      logoutUseCase: Get.find<LogoutUseCase>(),
      checkSessionUseCase: Get.find<CheckSessionUseCase>(),
      hasValidSessionUseCase: Get.find<HasValidSessionUseCase>(),
    ), fenix: true);
  }
}
