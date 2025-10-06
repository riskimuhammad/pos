import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/sync_queue.dart';
import '../entities/sync_status.dart';

abstract class SyncRepository {
  // Sync operations
  Future<Either<Failure, void>> addToSyncQueue({
    required String tableName,
    required String operation,
    required Map<String, dynamic> data,
  });
  
  Future<Either<Failure, void>> performSync();
  Future<Either<Failure, void>> performManualSync();
  
  // Status operations
  Future<Either<Failure, SyncStatus>> getSyncStatus();
  Future<Either<Failure, List<SyncQueue>>> getPendingSyncItems();
  Future<Either<Failure, void>> clearSyncedItems();
  
  // Connectivity
  Future<Either<Failure, bool>> isOnline();
  Stream<bool> get connectivityStream;
}
