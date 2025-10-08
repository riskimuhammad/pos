import 'dart:convert';
import 'package:equatable/equatable.dart';

class Tenant extends Equatable {
  // Helper function to parse boolean from various types
  static bool _parseBoolean(dynamic value, bool defaultValue) {
    if (value == null) return defaultValue;
    if (value is bool) return value;
    if (value is int) return value == 1;
    if (value is String) return value.toLowerCase() == 'true' || value == '1';
    return defaultValue;
  }
  final String id;
  final String name;
  final String? ownerName;
  final String? email;
  final String? phone;
  final String? address;
  final Map<String, dynamic> settings;
  final String subscriptionTier;
  final DateTime? subscriptionExpiry;
  final bool isActive;
  final String? logoUrl;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final String syncStatus;
  final DateTime? lastSyncedAt;

  const Tenant({
    required this.id,
    required this.name,
    this.ownerName,
    this.email,
    this.phone,
    this.address,
    this.settings = const {},
    this.subscriptionTier = 'free',
    this.subscriptionExpiry,
    this.isActive = true,
    this.logoUrl,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    this.syncStatus = 'synced',
    this.lastSyncedAt,
  });

  factory Tenant.fromJson(Map<String, dynamic> json) {
    return Tenant(
      id: json['id'] as String,
      name: json['name'] as String,
      ownerName: json['owner_name'] as String?,
      email: json['email'] as String?,
      phone: json['phone'] as String?,
      address: json['address'] as String?,
      settings: json['settings'] != null 
          ? (json['settings'] is String 
              ? Map<String, dynamic>.from(jsonDecode(json['settings'] as String))
              : Map<String, dynamic>.from(json['settings'] as Map))
          : {},
      subscriptionTier: json['subscription_tier'] as String? ?? 'free',
      subscriptionExpiry: json['subscription_expiry'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['subscription_expiry'] as int)
          : null,
      isActive: _parseBoolean(json['is_active'], true),
      logoUrl: json['logo_url'] as String?,
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
      'name': name,
      'owner_name': ownerName,
      'email': email,
      'phone': phone,
      'address': address,
      'settings': jsonEncode(settings), // Convert Map to JSON string for SQLite
      'subscription_tier': subscriptionTier,
      'subscription_expiry': subscriptionExpiry?.millisecondsSinceEpoch,
      'is_active': isActive ? 1 : 0,
      'logo_url': logoUrl,
      'created_at': createdAt.millisecondsSinceEpoch,
      'updated_at': updatedAt.millisecondsSinceEpoch,
      'deleted_at': deletedAt?.millisecondsSinceEpoch,
      'sync_status': syncStatus,
      'last_synced_at': lastSyncedAt?.millisecondsSinceEpoch,
    };
  }

  Tenant copyWith({
    String? id,
    String? name,
    String? ownerName,
    String? email,
    String? phone,
    String? address,
    Map<String, dynamic>? settings,
    String? subscriptionTier,
    DateTime? subscriptionExpiry,
    bool? isActive,
    String? logoUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
    String? syncStatus,
    DateTime? lastSyncedAt,
  }) {
    return Tenant(
      id: id ?? this.id,
      name: name ?? this.name,
      ownerName: ownerName ?? this.ownerName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      settings: settings ?? this.settings,
      subscriptionTier: subscriptionTier ?? this.subscriptionTier,
      subscriptionExpiry: subscriptionExpiry ?? this.subscriptionExpiry,
      isActive: isActive ?? this.isActive,
      logoUrl: logoUrl ?? this.logoUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      syncStatus: syncStatus ?? this.syncStatus,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        ownerName,
        email,
        phone,
        address,
        settings,
        subscriptionTier,
        subscriptionExpiry,
        isActive,
        logoUrl,
        createdAt,
        updatedAt,
        deletedAt,
        syncStatus,
        lastSyncedAt,
      ];
}
