import 'package:dartz/dartz.dart';
import 'package:pos/core/errors/failures.dart';
import 'package:pos/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:pos/features/auth/data/models/auth_request.dart';
import 'package:pos/features/auth/data/models/user_session.dart';

class LoginUseCase {
  final AuthRepository repository;

  LoginUseCase(this.repository);

  Future<Either<Failure, UserSession>> call(AuthRequest request) async {
    try {
      // Basic validation
      if (request.username.trim().isEmpty) {
        return const Left(ValidationFailure(message: 'Username tidak boleh kosong'));
      }

      if (request.password.trim().isEmpty) {
        return const Left(ValidationFailure(message: 'Password tidak boleh kosong'));
      }

      if (request.username.length < 3) {
        return const Left(ValidationFailure(message: 'Username minimal 3 karakter'));
      }

      if (request.password.length < 6) {
        return const Left(ValidationFailure(message: 'Password minimal 6 karakter'));
      }

      // Call repository
      final session = await repository.login(request);
      return Right(session);
    } on Failure catch (failure) {
      return Left(failure);
    } catch (e) {
      return Left(UnexpectedFailure(message: 'Login gagal: $e'));
    }
  }
}
