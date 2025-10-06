import 'package:equatable/equatable.dart';

class SyncQueue extends Equatable {
  final String id;
  final String tableName;
  final String operation; // CREATE, UPDATE, DELETE
  final Map<String, dynamic> data;
  final DateTime timestamp;
  final bool isSynced;
  final int retryCount;
  final String? errorMessage;

  const SyncQueue({
    required this.id,
    required this.tableName,
    required this.operation,
    required this.data,
    required this.timestamp,
    this.isSynced = false,
    this.retryCount = 0,
    this.errorMessage,
  });

  SyncQueue copyWith({
    String? id,
    String? tableName,
    String? operation,
    Map<String, dynamic>? data,
    DateTime? timestamp,
    bool? isSynced,
    int? retryCount,
    String? errorMessage,
  }) {
    return SyncQueue(
      id: id ?? this.id,
      tableName: tableName ?? this.tableName,
      operation: operation ?? this.operation,
      data: data ?? this.data,
      timestamp: timestamp ?? this.timestamp,
      isSynced: isSynced ?? this.isSynced,
      retryCount: retryCount ?? this.retryCount,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'table_name': tableName,
      'operation': operation,
      'data': data,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'is_synced': isSynced ? 1 : 0,
      'retry_count': retryCount,
      'error_message': errorMessage,
    };
  }

  factory SyncQueue.fromJson(Map<String, dynamic> json) {
    return SyncQueue(
      id: json['id'],
      tableName: json['table_name'],
      operation: json['operation'],
      data: Map<String, dynamic>.from(json['data']),
      timestamp: DateTime.fromMillisecondsSinceEpoch(json['timestamp']),
      isSynced: json['is_synced'] == 1,
      retryCount: json['retry_count'] ?? 0,
      errorMessage: json['error_message'],
    );
  }

  @override
  List<Object?> get props => [
        id,
        tableName,
        operation,
        data,
        timestamp,
        isSynced,
        retryCount,
        errorMessage,
      ];
}

class SyncStatus extends Equatable {
  final String id;
  final DateTime lastSyncTimestamp;
  final String syncVersion;
  final bool isOnline;
  final int pendingItemsCount;

  const SyncStatus({
    required this.id,
    required this.lastSyncTimestamp,
    required this.syncVersion,
    this.isOnline = false,
    this.pendingItemsCount = 0,
  });

  SyncStatus copyWith({
    String? id,
    DateTime? lastSyncTimestamp,
    String? syncVersion,
    bool? isOnline,
    int? pendingItemsCount,
  }) {
    return SyncStatus(
      id: id ?? this.id,
      lastSyncTimestamp: lastSyncTimestamp ?? this.lastSyncTimestamp,
      syncVersion: syncVersion ?? this.syncVersion,
      isOnline: isOnline ?? this.isOnline,
      pendingItemsCount: pendingItemsCount ?? this.pendingItemsCount,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'last_sync_timestamp': lastSyncTimestamp.millisecondsSinceEpoch,
      'sync_version': syncVersion,
      'is_online': isOnline ? 1 : 0,
      'pending_items_count': pendingItemsCount,
    };
  }

  factory SyncStatus.fromJson(Map<String, dynamic> json) {
    return SyncStatus(
      id: json['id'],
      lastSyncTimestamp: DateTime.fromMillisecondsSinceEpoch(json['last_sync_timestamp']),
      syncVersion: json['sync_version'],
      isOnline: json['is_online'] == 1,
      pendingItemsCount: json['pending_items_count'] ?? 0,
    );
  }

  @override
  List<Object?> get props => [
        id,
        lastSyncTimestamp,
        syncVersion,
        isOnline,
        pendingItemsCount,
      ];
}
