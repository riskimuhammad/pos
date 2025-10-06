import 'package:dartz/dartz.dart';
import 'package:pos/core/errors/failures.dart';
import 'package:pos/features/auth/data/repositories/auth_repository_impl.dart';

class LogoutUseCase {
  final AuthRepository repository;

  LogoutUseCase(this.repository);

  Future<Either<Failure, void>> call() async {
    try {
      await repository.logout();
      return const Right(null);
    } on Failure catch (failure) {
      return Left(failure);
    } catch (e) {
      return Left(UnexpectedFailure(message: 'Logout gagal: $e'));
    }
  }
}
