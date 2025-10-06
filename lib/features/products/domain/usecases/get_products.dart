import 'package:dartz/dartz.dart';
import 'package:pos/core/errors/failures.dart';
import 'package:pos/features/products/data/repositories/product_repository_impl.dart';
import 'package:pos/shared/models/entities/entities.dart';

class GetProducts {
  final ProductRepository repository;

  GetProducts(this.repository);

  Future<Either<Failure, List<Product>>> call(String tenantId) async {
    try {
      final products = await repository.getProducts(tenantId);
      return Right(products);
    } on Failure catch (failure) {
      return Left(failure);
    } catch (e) {
      return Left(UnexpectedFailure(message: e.toString()));
    }
  }
}
