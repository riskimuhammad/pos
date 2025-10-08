import 'package:get/get.dart';
import 'package:pos/features/pos/presentation/controllers/dashboard_controller.dart';

class DashboardBinding extends Bindings {
  @override
  void dependencies() {
    // Dashboard controller
    Get.lazyPut<DashboardController>(() => DashboardController());
  }
}
