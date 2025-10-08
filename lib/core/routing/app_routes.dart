import 'package:get/get.dart';
import 'package:pos/features/auth/presentation/pages/login_page.dart';
import 'package:pos/features/pos/presentation/pages/dashboard_page.dart';
import 'package:pos/features/ai_assistant/presentation/pages/ai_assistant_page.dart';
import 'package:pos/features/auth/presentation/middleware/auth_middleware.dart';
import 'package:pos/features/auth/presentation/middleware/guest_middleware.dart' as guest;
import 'package:pos/core/routing/bindings/login_binding.dart';
import 'package:pos/core/routing/bindings/dashboard_binding.dart';
import 'package:pos/core/routing/bindings/ai_assistant_binding.dart';

class AppRoutes {
  static const String login = '/login';
  static const String dashboard = '/dashboard';
  static const String aiAssistant = '/ai-assistant';
  
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
  ];
}
