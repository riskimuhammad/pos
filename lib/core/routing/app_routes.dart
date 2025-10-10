import 'package:get/get.dart';
import 'package:pos/features/auth/presentation/pages/login_page.dart';
import 'package:pos/features/pos/presentation/pages/dashboard_page.dart';
import 'package:pos/features/ai_assistant/presentation/pages/ai_assistant_page.dart';
import 'package:pos/features/products/presentation/pages/products_page.dart';
import 'package:pos/features/inventory/presentation/pages/inventory_page.dart';
import 'package:pos/features/inventory/presentation/pages/location_management_page.dart';
import 'package:pos/features/inventory/presentation/controllers/location_controller.dart';
import 'package:pos/features/inventory/domain/repositories/location_repository.dart';
import 'package:pos/features/auth/presentation/middleware/auth_middleware.dart';
import 'package:pos/features/auth/presentation/middleware/guest_middleware.dart' as guest;
import 'package:pos/core/routing/bindings/login_binding.dart';
import 'package:pos/core/routing/bindings/dashboard_binding.dart';
import 'package:pos/core/routing/bindings/ai_assistant_binding.dart';
import 'package:pos/core/routing/bindings/products_binding.dart';
import 'package:pos/features/inventory/data/bindings/inventory_binding.dart';

class AppRoutes {
  static const String login = '/login';
  static const String dashboard = '/dashboard';
  static const String aiAssistant = '/ai-assistant';
  static const String products = '/products';
  static const String inventory = '/inventory';
  static const String locations = '/locations';
  
  static List<GetPage> get pages => [
    GetPage(
      name: login,
      page: () => const LoginPage(),
      transition: Transition.fadeIn,
          middlewares: [guest.GuestMiddleware()],
      binding: LoginBinding(),
    ),
    GetPage(
      name: dashboard,
      page: () => const DashboardPage(),
      transition: Transition.fadeIn,
      middlewares: [AuthMiddleware()],
      binding: DashboardBinding(),
    ),
    GetPage(
      name: aiAssistant,
      page: () => const AIAssistantPage(),
      transition: Transition.rightToLeft,
      middlewares: [AuthMiddleware()],
      binding: AIAssistantBinding(),
    ),
    GetPage(
      name: products,
      page: () => const ProductsPage(),
      transition: Transition.rightToLeft,
      middlewares: [AuthMiddleware()],
      binding: ProductsBinding(),
    ),
    GetPage(
      name: inventory,
      page: () => const InventoryPage(),
      transition: Transition.rightToLeft,
      middlewares: [AuthMiddleware()],
      binding: InventoryBinding(),
    ),
    GetPage(
      name: locations,
      page: () => const LocationManagementPage(),
      transition: Transition.rightToLeft,
      middlewares: [AuthMiddleware()],
      binding: BindingsBuilder(() {
        // Ensure LocationRepository available from InventoryBinding dependencies
        if (!Get.isRegistered<LocationRepository>()) {
          InventoryBinding().dependencies();
        }
        Get.lazyPut<LocationController>(() => LocationController(locationRepository: Get.find<LocationRepository>()));
      }),
    ),
  ];
}
