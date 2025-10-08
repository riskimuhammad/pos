import 'package:get/get.dart';
import 'package:pos/features/pos/presentation/controllers/dashboard_controller.dart';
import 'package:pos/features/products/presentation/controllers/product_controller.dart';
import 'package:pos/features/products/domain/usecases/get_products.dart';
import 'package:pos/features/products/domain/usecases/create_product.dart';
import 'package:pos/features/products/domain/usecases/search_products.dart';
import 'package:pos/features/products/data/repositories/product_repository_impl.dart';
import 'package:pos/core/network/network_info.dart';
import 'package:pos/core/storage/local_datasource.dart';

class DashboardBinding extends Bindings {
  @override
  void dependencies() {
    // Dashboard controller
    Get.lazyPut<DashboardController>(() => DashboardController());
    
    // Product dependencies (if not already registered globally)
    if (!Get.isRegistered<ProductController>()) {
      Get.lazyPut<ProductRepository>(() => ProductRepositoryImpl(
        networkInfo: Get.find<NetworkInfo>(),
        localDataSource: Get.find<LocalDataSource>(),
      ));
      
      Get.lazyPut<GetProducts>(() => GetProducts(Get.find<ProductRepository>()));
      Get.lazyPut<CreateProduct>(() => CreateProduct(Get.find<ProductRepository>()));
      Get.lazyPut<SearchProducts>(() => SearchProducts(Get.find<ProductRepository>()));
      
      Get.lazyPut<ProductController>(() => ProductController(
        getProducts: Get.find<GetProducts>(),
        createProduct: Get.find<CreateProduct>(),
        searchProducts: Get.find<SearchProducts>(),
      ));
    }
  }
}
