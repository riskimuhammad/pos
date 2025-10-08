import 'package:get/get.dart';
import 'package:pos/features/products/presentation/controllers/product_controller.dart';
import 'package:pos/features/products/domain/usecases/get_products.dart';
import 'package:pos/features/products/domain/usecases/create_product.dart';
import 'package:pos/features/products/domain/usecases/search_products.dart';
import 'package:pos/features/products/data/repositories/product_repository_impl.dart';
import 'package:pos/core/sync/product_sync_service.dart';
import 'package:pos/core/data/database_seeder.dart';
import 'package:pos/core/storage/database_helper.dart';

class ProductsBinding extends Bindings {
  @override
  void dependencies() {
    // Ensure dependencies are available, create if not found
    if (!Get.isRegistered<GetProducts>()) {
      Get.lazyPut<GetProducts>(() => GetProducts(Get.find<ProductRepository>()));
    }
    if (!Get.isRegistered<CreateProduct>()) {
      Get.lazyPut<CreateProduct>(() => CreateProduct(Get.find<ProductRepository>()));
    }
    if (!Get.isRegistered<SearchProducts>()) {
      Get.lazyPut<SearchProducts>(() => SearchProducts(Get.find<ProductRepository>()));
    }
    if (!Get.isRegistered<ProductSyncService>()) {
      Get.lazyPut<ProductSyncService>(() => ProductSyncService(
        databaseHelper: Get.find<DatabaseHelper>(),
        databaseSeeder: Get.find<DatabaseSeeder>(),
        apiService: null,
      ));
    }
    if (!Get.isRegistered<DatabaseSeeder>()) {
      Get.lazyPut<DatabaseSeeder>(() => DatabaseSeeder(Get.find<DatabaseHelper>()));
    }

    Get.lazyPut<ProductController>(() => ProductController(
      getProducts: Get.find<GetProducts>(),
      createProduct: Get.find<CreateProduct>(),
      searchProducts: Get.find<SearchProducts>(),
      productSyncService: Get.find<ProductSyncService>(),
      databaseSeeder: Get.find<DatabaseSeeder>(),
    ));
  }
}
