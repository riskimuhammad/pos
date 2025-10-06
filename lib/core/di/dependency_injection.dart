import 'package:get/get.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:pos/core/network/network_info.dart';
import 'package:pos/core/storage/database_helper.dart';
import 'package:pos/core/storage/local_datasource.dart';
import 'package:pos/features/products/data/repositories/product_repository_impl.dart';
import 'package:pos/features/products/domain/usecases/get_products.dart';
import 'package:pos/features/products/domain/usecases/create_product.dart';
import 'package:pos/features/products/domain/usecases/search_products.dart';
import 'package:pos/features/products/presentation/controllers/product_controller.dart';

class DependencyInjection {
  static Future<void> init() async {
    // Core dependencies
    Get.lazyPut<Connectivity>(() => Connectivity());
    Get.lazyPut<NetworkInfo>(() => NetworkInfoImpl(connectivity: Get.find<Connectivity>()));
    Get.lazyPut<DatabaseHelper>(() => DatabaseHelper());
    Get.lazyPut<LocalDataSource>(() => LocalDataSourceImpl(Get.find<DatabaseHelper>()));

    // Repository dependencies
    Get.lazyPut<ProductRepository>(() => ProductRepositoryImpl(
      networkInfo: Get.find<NetworkInfo>(),
      localDataSource: Get.find<LocalDataSource>(),
    ));

    // Use case dependencies
    Get.lazyPut<GetProducts>(() => GetProducts(Get.find<ProductRepository>()));
    Get.lazyPut<CreateProduct>(() => CreateProduct(Get.find<ProductRepository>()));
    Get.lazyPut<SearchProducts>(() => SearchProducts(Get.find<ProductRepository>()));

    // Controller dependencies
    Get.lazyPut<ProductController>(() => ProductController(
      getProducts: Get.find<GetProducts>(),
      createProduct: Get.find<CreateProduct>(),
      searchProducts: Get.find<SearchProducts>(),
    ));
  }
}
