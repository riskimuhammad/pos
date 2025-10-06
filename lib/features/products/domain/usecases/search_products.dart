import 'package:dartz/dartz.dart';
import 'package:pos/core/errors/failures.dart';
import 'package:pos/features/products/data/repositories/product_repository_impl.dart';
import 'package:pos/shared/models/entities/entities.dart';

class SearchProducts {
  final ProductRepository repository;

  SearchProducts(this.repository);

  Future<Either<Failure, List<Product>>> call(String query) async {
    try {
      if (query.trim().isEmpty) {
        return Left(ValidationFailure(message: 'Search query cannot be empty'));
      }

      final products = await repository.searchProducts(query.trim());
      return Right(products);
    } on Failure catch (failure) {
      return Left(failure);
    } catch (e) {
      return Left(UnexpectedFailure(message: e.toString()));
    }
  }
}
