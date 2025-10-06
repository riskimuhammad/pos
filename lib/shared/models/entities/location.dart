import 'package:equatable/equatable.dart';

class Location extends Equatable {
  // Helper function to parse boolean from various types
  static bool _parseBoolean(dynamic value, bool defaultValue) {
    if (value == null) return defaultValue;
    if (value is bool) return value;
    if (value is int) return value == 1;
    if (value is String) return value.toLowerCase() == 'true' || value == '1';
    return defaultValue;
  }
  final String id;
  final String tenantId;
  final String name;
  final String type;
  final String? address;
  final bool isPrimary;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final String syncStatus;
  final DateTime? lastSyncedAt;

  const Location({
    required this.id,
    required this.tenantId,
    required this.name,
    this.type = 'store',
    this.address,
    this.isPrimary = false,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    this.syncStatus = 'synced',
    this.lastSyncedAt,
  });

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      id: json['id'] as String,
      tenantId: json['tenant_id'] as String,
      name: json['name'] as String,
      type: json['type'] as String? ?? 'store',
      address: json['address'] as String?,
      isPrimary: _parseBoolean(json['is_primary'], false),
      isActive: _parseBoolean(json['is_active'], true),
      createdAt: DateTime.fromMillisecondsSinceEpoch(json['created_at'] as int),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(json['updated_at'] as int),
      deletedAt: json['deleted_at'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['deleted_at'] as int)
          : null,
      syncStatus: json['sync_status'] as String? ?? 'synced',
      lastSyncedAt: json['last_synced_at'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['last_synced_at'] as int)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tenant_id': tenantId,
      'name': name,
      'type': type,
      'address': address,
      'is_primary': isPrimary ? 1 : 0,
      'is_active': isActive ? 1 : 0,
      'created_at': createdAt.millisecondsSinceEpoch,
      'updated_at': updatedAt.millisecondsSinceEpoch,
      'deleted_at': deletedAt?.millisecondsSinceEpoch,
      'sync_status': syncStatus,
      'last_synced_at': lastSyncedAt?.millisecondsSinceEpoch,
    };
  }

  Location copyWith({
    String? id,
    String? tenantId,
    String? name,
    String? type,
    String? address,
    bool? isPrimary,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
    String? syncStatus,
    DateTime? lastSyncedAt,
  }) {
    return Location(
      id: id ?? this.id,
      tenantId: tenantId ?? this.tenantId,
      name: name ?? this.name,
      type: type ?? this.type,
      address: address ?? this.address,
      isPrimary: isPrimary ?? this.isPrimary,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      syncStatus: syncStatus ?? this.syncStatus,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
    );
  }

  bool get isStore => type == 'store';
  bool get isWarehouse => type == 'warehouse';

  @override
  List<Object?> get props => [
        id,
        tenantId,
        name,
        type,
        address,
        isPrimary,
        isActive,
        createdAt,
        updatedAt,
        deletedAt,
        syncStatus,
        lastSyncedAt,
      ];
}
