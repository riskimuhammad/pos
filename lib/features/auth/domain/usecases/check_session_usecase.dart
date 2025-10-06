import 'package:dartz/dartz.dart';
import 'package:pos/core/errors/failures.dart';
import 'package:pos/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:pos/features/auth/data/models/user_session.dart';

class CheckSessionUseCase {
  final AuthRepository repository;

  CheckSessionUseCase(this.repository);

  Future<Either<Failure, UserSession?>> call() async {
    try {
      final session = await repository.getCurrentSession();
      return Right(session);
    } on Failure catch (failure) {
      return Left(failure);
    } catch (e) {
      return Left(UnexpectedFailure(message: 'Gagal memeriksa session: $e'));
    }
  }
}

class HasValidSessionUseCase {
  final AuthRepository repository;

  HasValidSessionUseCase(this.repository);

  Future<Either<Failure, bool>> call() async {
    try {
      final hasValidSession = await repository.hasValidSession();
      return Right(hasValidSession);
    } on Failure catch (failure) {
      return Left(failure);
    } catch (e) {
      return Left(UnexpectedFailure(message: 'Gagal memeriksa validitas session: $e'));
    }
  }
}
