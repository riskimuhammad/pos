import 'package:equatable/equatable.dart';

class User extends Equatable {
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
  final String username;
  final String? email;
  final String passwordHash;
  final String? fullName;
  final String role;
  final List<String> permissions;
  final bool isActive;
  final DateTime? lastLoginAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final String syncStatus;
  final DateTime? lastSyncedAt;

  const User({
    required this.id,
    required this.tenantId,
    required this.username,
    this.email,
    required this.passwordHash,
    this.fullName,
    required this.role,
    this.permissions = const [],
    this.isActive = true,
    this.lastLoginAt,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    this.syncStatus = 'synced',
    this.lastSyncedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      tenantId: json['tenant_id'] as String,
      username: json['username'] as String,
      email: json['email'] as String?,
      passwordHash: json['password_hash'] as String,
      fullName: json['full_name'] as String?,
      role: json['role'] as String,
      permissions: json['permissions'] != null
          ? List<String>.from(json['permissions'] as List)
          : [],
      isActive: _parseBoolean(json['is_active'], true),
      lastLoginAt: json['last_login_at'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['last_login_at'] as int)
          : null,
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
      'username': username,
      'email': email,
      'password_hash': passwordHash,
      'full_name': fullName,
      'role': role,
      'permissions': permissions,
      'is_active': isActive ? 1 : 0,
      'last_login_at': lastLoginAt?.millisecondsSinceEpoch,
      'created_at': createdAt.millisecondsSinceEpoch,
      'updated_at': updatedAt.millisecondsSinceEpoch,
      'deleted_at': deletedAt?.millisecondsSinceEpoch,
      'sync_status': syncStatus,
      'last_synced_at': lastSyncedAt?.millisecondsSinceEpoch,
    };
  }

  User copyWith({
    String? id,
    String? tenantId,
    String? username,
    String? email,
    String? passwordHash,
    String? fullName,
    String? role,
    List<String>? permissions,
    bool? isActive,
    DateTime? lastLoginAt,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
    String? syncStatus,
    DateTime? lastSyncedAt,
  }) {
    return User(
      id: id ?? this.id,
      tenantId: tenantId ?? this.tenantId,
      username: username ?? this.username,
      email: email ?? this.email,
      passwordHash: passwordHash ?? this.passwordHash,
      fullName: fullName ?? this.fullName,
      role: role ?? this.role,
      permissions: permissions ?? this.permissions,
      isActive: isActive ?? this.isActive,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      syncStatus: syncStatus ?? this.syncStatus,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
    );
  }

  bool hasPermission(String permission) {
    return permissions.contains(permission);
  }

  bool isOwner() => role == 'owner';
  bool isManager() => role == 'manager';
  bool isCashier() => role == 'cashier';
  bool isAdmin() => role == 'admin';

  @override
  List<Object?> get props => [
        id,
        tenantId,
        username,
        email,
        passwordHash,
        fullName,
        role,
        permissions,
        isActive,
        lastLoginAt,
        createdAt,
        updatedAt,
        deletedAt,
        syncStatus,
        lastSyncedAt,
      ];
}
