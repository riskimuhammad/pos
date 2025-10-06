import 'package:pos/core/errors/failures.dart';
import 'package:pos/core/errors/exceptions.dart';
import 'package:pos/core/network/network_info.dart';

abstract class BaseRepository {
  final NetworkInfo networkInfo;

  BaseRepository(this.networkInfo);

  Future<T> handleDatabaseOperation<T>(Future<T> Function() operation) async {
    try {
      return await operation();
    } on DatabaseException catch (e) {
      throw DatabaseFailure(message: e.message);
    } catch (e) {
      throw UnexpectedFailure(message: e.toString());
    }
  }

  Future<T> handleNetworkOperation<T>(Future<T> Function() operation) async {
    try {
      if (await networkInfo.isConnected) {
        return await operation();
      } else {
        throw NetworkFailure(message: 'No internet connection');
      }
    } on ServerException catch (e) {
      throw ServerFailure(message: e.message);
    } on NetworkException catch (e) {
      throw NetworkFailure(message: e.message);
    } catch (e) {
      throw UnexpectedFailure(message: e.toString());
    }
  }

  Future<T> handleOfflineFirstOperation<T>({
    required Future<T> Function() localOperation,
    Future<T> Function()? networkOperation,
  }) async {
    try {
      // Always try local operation first
      return await localOperation();
    } catch (e) {
      // If local fails and we have network, try network operation
      if (networkOperation != null && await networkInfo.isConnected) {
        try {
          return await networkOperation();
        } catch (networkError) {
          // If network also fails, throw the original local error
          throw e;
        }
      } else {
        throw e;
      }
    }
  }
}
