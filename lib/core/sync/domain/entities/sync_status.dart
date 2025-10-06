import 'package:equatable/equatable.dart';

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
