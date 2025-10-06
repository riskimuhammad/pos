import 'package:pos/core/repositories/base_repository.dart';
import 'package:pos/core/storage/local_datasource.dart';
import 'package:pos/core/network/network_info.dart';
import 'package:pos/shared/models/entities/entities.dart';

abstract class ProductRepository {
  Future<List<Product>> getProducts(String tenantId);
  Future<Product?> getProduct(String id);
  Future<Product?> getProductBySku(String sku);
  Future<Product?> getProductByBarcode(String barcode);
  Future<List<Product>> getProductsByCategory(String categoryId);
  Future<List<Product>> searchProducts(String query);
  Future<Product> createProduct(Product product);
  Future<Product> updateProduct(Product product);
  Future<void> deleteProduct(String id);
  Future<List<Product>> getLowStockProducts(String tenantId);
}

class ProductRepositoryImpl extends BaseRepository implements ProductRepository {
  final LocalDataSource localDataSource;

  ProductRepositoryImpl({
    required NetworkInfo networkInfo,
    required this.localDataSource,
  }) : super(networkInfo);

  @override
  Future<List<Product>> getProducts(String tenantId) async {
    return await handleDatabaseOperation(() async {
      return await localDataSource.getProductsByTenant(tenantId);
    });
  }

  @override
  Future<Product?> getProduct(String id) async {
    return await handleDatabaseOperation(() async {
      return await localDataSource.getProduct(id);
    });
  }

  @override
  Future<Product?> getProductBySku(String sku) async {
    return await handleDatabaseOperation(() async {
      return await localDataSource.getProductBySku(sku);
    });
  }

  @override
  Future<Product?> getProductByBarcode(String barcode) async {
    return await handleDatabaseOperation(() async {
      return await localDataSource.getProductByBarcode(barcode);
    });
  }

  @override
  Future<List<Product>> getProductsByCategory(String categoryId) async {
    return await handleDatabaseOperation(() async {
      return await localDataSource.getProductsByCategory(categoryId);
    });
  }

  @override
  Future<List<Product>> searchProducts(String query) async {
    return await handleDatabaseOperation(() async {
      return await localDataSource.searchProducts(query);
    });
  }

  @override
  Future<Product> createProduct(Product product) async {
    return await handleDatabaseOperation(() async {
      return await localDataSource.createProduct(product);
    });
  }

  @override
  Future<Product> updateProduct(Product product) async {
    return await handleDatabaseOperation(() async {
      return await localDataSource.updateProduct(product);
    });
  }

  @override
  Future<void> deleteProduct(String id) async {
    return await handleDatabaseOperation(() async {
      return await localDataSource.deleteProduct(id);
    });
  }

  @override
  Future<List<Product>> getLowStockProducts(String tenantId) async {
    return await handleDatabaseOperation(() async {
      final inventories = await localDataSource.getLowStockInventories(tenantId);
      final products = <Product>[];
      
      for (final inventory in inventories) {
        final product = await localDataSource.getProduct(inventory.productId);
        if (product != null) {
          products.add(product);
        }
      }
      
      return products;
    });
  }
}
