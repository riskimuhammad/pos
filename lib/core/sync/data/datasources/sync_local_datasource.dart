import 'package:sqflite_sqlcipher/sqflite.dart';
import '../../domain/entities/sync_queue.dart';
import '../../domain/entities/sync_status.dart';

abstract class SyncLocalDataSource {
  Future<void> insertSyncQueue(SyncQueue syncItem);
  Future<List<SyncQueue>> getPendingSyncItems();
  Future<void> markSyncItemAsSynced(String id);
  Future<void> updateSyncItemError(String id, String error, int retryCount);
  Future<void> deleteSyncItem(String id);
  Future<SyncStatus> getSyncStatus();
  Future<void> updateSyncStatus(SyncStatus status);
  Future<void> clearSyncedItems();
}

class SyncLocalDataSourceImpl implements SyncLocalDataSource {
  final Database database;

  SyncLocalDataSourceImpl({required this.database});

  @override
  Future<void> insertSyncQueue(SyncQueue syncItem) async {
    await database.insert(
      'sync_queue',
      syncItem.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<List<SyncQueue>> getPendingSyncItems() async {
    final List<Map<String, dynamic>> maps = await database.query(
      'sync_queue',
      where: 'is_synced = ?',
      whereArgs: [0],
      orderBy: 'timestamp ASC',
    );

    return maps.map((map) => SyncQueue.fromJson(map)).toList();
  }

  @override
  Future<void> markSyncItemAsSynced(String id) async {
    await database.update(
      'sync_queue',
      {'is_synced': 1},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  @override
  Future<void> updateSyncItemError(String id, String error, int retryCount) async {
    await database.update(
      'sync_queue',
      {
        'error_message': error,
        'retry_count': retryCount,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  @override
  Future<void> deleteSyncItem(String id) async {
    await database.delete(
      'sync_queue',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  @override
  Future<SyncStatus> getSyncStatus() async {
    final List<Map<String, dynamic>> maps = await database.query(
      'sync_status',
      limit: 1,
    );

    if (maps.isEmpty) {
      // Create default sync status
      final defaultStatus = SyncStatus(
        id: 'default',
        lastSyncTimestamp: DateTime.now(),
        syncVersion: '1.0.0',
      );
      await updateSyncStatus(defaultStatus);
      return defaultStatus;
    }

    return SyncStatus.fromJson(maps.first);
  }

  @override
  Future<void> updateSyncStatus(SyncStatus status) async {
    await database.insert(
      'sync_status',
      status.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<void> clearSyncedItems() async {
    await database.delete(
      'sync_queue',
      where: 'is_synced = ?',
      whereArgs: [1],
    );
  }
}
