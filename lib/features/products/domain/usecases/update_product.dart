import 'package:dartz/dartz.dart';
import 'package:pos/core/errors/failures.dart';
import 'package:pos/features/products/data/repositories/product_repository_impl.dart';
import 'package:pos/shared/models/entities/entities.dart';

class UpdateProduct {
  final ProductRepository repository;

  UpdateProduct(this.repository);

  Future<Either<Failure, Product>> call(Product product) async {
    try {
      // Validate product data
      if (product.name.isEmpty) {
        return Left(ValidationFailure(message: 'Product name is required'));
      }
      if (product.sku.isEmpty) {
        return Left(ValidationFailure(message: 'Product SKU is required'));
      }
      if (product.priceSell <= 0) {
        return Left(ValidationFailure(message: 'Product price must be greater than 0'));
      }

      // Check if SKU already exists (excluding current product)
      final existingProduct = await repository.getProductBySku(product.sku);
      if (existingProduct != null && existingProduct.id != product.id) {
        return Left(ValidationFailure(message: 'Product with SKU ${product.sku} already exists'));
      }

      // Check if barcode already exists (excluding current product)
      if (product.barcode != null && product.barcode!.isNotEmpty) {
        final existingBarcode = await repository.getProductByBarcode(product.barcode!);
        if (existingBarcode != null && existingBarcode.id != product.id) {
          return Left(ValidationFailure(message: 'Product with barcode ${product.barcode} already exists'));
        }
      }

      final updatedProduct = await repository.updateProduct(product);
      return Right(updatedProduct);
    } on Failure catch (failure) {
      return Left(failure);
    } catch (e) {
      return Left(UnexpectedFailure(message: e.toString()));
    }
  }
}
