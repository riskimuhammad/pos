import 'package:dartz/dartz.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/sync_queue.dart';
import '../../domain/entities/sync_status.dart';
import '../../domain/repositories/sync_repository.dart';
import '../datasources/sync_local_datasource.dart';
import '../datasources/sync_remote_datasource.dart';

class SyncRepositoryImpl implements SyncRepository {
  final SyncLocalDataSource localDataSource;
  final SyncRemoteDataSource remoteDataSource;
  final Connectivity connectivity;

  SyncRepositoryImpl({
    required this.localDataSource,
    required this.remoteDataSource,
    required this.connectivity,
  });

  @override
  Future<Either<Failure, void>> addToSyncQueue({
    required String tableName,
    required String operation,
    required Map<String, dynamic> data,
  }) async {
    try {
      final syncItem = SyncQueue(
        id: const Uuid().v4(),
        tableName: tableName,
        operation: operation,
        data: data,
        timestamp: DateTime.now(),
      );

      await localDataSource.insertSyncQueue(syncItem);
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> performSync() async {
    try {
      final isOnlineResult = await isOnline();
      if (isOnlineResult.isLeft()) {
        return const Left(NetworkFailure(message: 'No internet connection'));
      }

      final pendingItems = await localDataSource.getPendingSyncItems();
      if (pendingItems.isEmpty) {
        return const Right(null);
      }

      // Group items by table name
      final groupedItems = <String, List<SyncQueue>>{};
      for (final item in pendingItems) {
        groupedItems.putIfAbsent(item.tableName, () => []).add(item);
      }

      // Sync each table
      for (final entry in groupedItems.entries) {
        await _syncTable(entry.key, entry.value);
      }

      // Update sync status
      final syncStatus = await localDataSource.getSyncStatus();
      await localDataSource.updateSyncStatus(
        syncStatus.copyWith(
          lastSyncTimestamp: DateTime.now(),
          pendingItemsCount: 0,
        ),
      );

      return const Right(null);
    } catch (e) {
      return Left(SyncFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> performManualSync() async {
    try {
      final result = await performSync();
      if (result.isLeft()) {
        return result;
      }

      // Clear old synced items
      await localDataSource.clearSyncedItems();
      return const Right(null);
    } catch (e) {
      return Left(SyncFailure(message: e.toString()));
    }
  }

  Future<void> _syncTable(String tableName, List<SyncQueue> items) async {
    try {
      final data = items.map((item) => item.data).toList();
      final lastSync = DateTime.now().subtract(Duration(days: 1)).toIso8601String();

      Map<String, dynamic> response;
      switch (tableName) {
        case 'products':
          response = await remoteDataSource.syncProducts(data, lastSync);
          break;
        case 'transactions':
          response = await remoteDataSource.syncTransactions(data, lastSync);
          break;
        case 'categories':
          response = await remoteDataSource.syncCategories(data, lastSync);
          break;
        default:
          response = await remoteDataSource.uploadSyncQueue(items);
      }

      if (response['success'] == true) {
        // Mark items as synced
        for (final item in items) {
          await localDataSource.markSyncItemAsSynced(item.id);
        }
      } else {
        // Handle failed items
        final failedItems = response['failed_items'] as List<dynamic>? ?? [];
        for (final item in items) {
          if (failedItems.contains(item.id)) {
            await localDataSource.updateSyncItemError(
              item.id,
              response['message'] ?? 'Sync failed',
              item.retryCount + 1,
            );
          } else {
            await localDataSource.markSyncItemAsSynced(item.id);
          }
        }
      }
    } catch (e) {
      // Mark all items as failed
      for (final item in items) {
        await localDataSource.updateSyncItemError(
          item.id,
          e.toString(),
          item.retryCount + 1,
        );
      }
      rethrow;
    }
  }

  @override
  Future<Either<Failure, SyncStatus>> getSyncStatus() async {
    try {
      final status = await localDataSource.getSyncStatus();
      final pendingItems = await localDataSource.getPendingSyncItems();
      final isOnlineResult = await isOnline();
      
      return Right(status.copyWith(
        isOnline: isOnlineResult.getOrElse(() => false),
        pendingItemsCount: pendingItems.length,
      ));
    } catch (e) {
      return Left(DatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<SyncQueue>>> getPendingSyncItems() async {
    try {
      final items = await localDataSource.getPendingSyncItems();
      return Right(items);
    } catch (e) {
      return Left(DatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> clearSyncedItems() async {
    try {
      await localDataSource.clearSyncedItems();
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> isOnline() async {
    try {
      final connectivityResult = await connectivity.checkConnectivity();
      return Right(connectivityResult != ConnectivityResult.none);
    } catch (e) {
      return Left(NetworkFailure(message: e.toString()));
    }
  }

  @override
  Stream<bool> get connectivityStream {
    return connectivity.onConnectivityChanged.map((result) => result != ConnectivityResult.none);
  }
}
