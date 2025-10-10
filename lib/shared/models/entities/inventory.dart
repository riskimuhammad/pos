import 'package:equatable/equatable.dart';

class Inventory extends Equatable {
  final String id;
  final String tenantId;
  final String productId;
  final String locationId;
  final int quantity;
  final int reserved;
  final DateTime updatedAt;
  final String syncStatus;
  final DateTime? lastSyncedAt;

  const Inventory({
    required this.id,
    required this.tenantId,
    required this.productId,
    required this.locationId,
    this.quantity = 0,
    this.reserved = 0,
    required this.updatedAt,
    this.syncStatus = 'synced',
    this.lastSyncedAt,
  });

  factory Inventory.fromJson(Map<String, dynamic> json) {
    return Inventory(
      id: json['id'] as String,
      tenantId: json['tenant_id'] as String,
      productId: json['product_id'] as String,
      locationId: json['location_id'] as String,
      quantity: json['quantity'] as int? ?? 0,
      reserved: json['reserved'] as int? ?? 0,
      updatedAt: DateTime.fromMillisecondsSinceEpoch(json['updated_at'] as int),
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
      'product_id': productId,
      'location_id': locationId,
      'quantity': quantity,
      'reserved': reserved,
      'updated_at': updatedAt.millisecondsSinceEpoch,
      'sync_status': syncStatus,
      'last_synced_at': lastSyncedAt?.millisecondsSinceEpoch,
    };
  }

  Inventory copyWith({
    String? id,
    String? tenantId,
    String? productId,
    String? locationId,
    int? quantity,
    int? reserved,
    DateTime? updatedAt,
    String? syncStatus,
    DateTime? lastSyncedAt,
  }) {
    return Inventory(
      id: id ?? this.id,
      tenantId: tenantId ?? this.tenantId,
      productId: productId ?? this.productId,
      locationId: locationId ?? this.locationId,
      quantity: quantity ?? this.quantity,
      reserved: reserved ?? this.reserved,
      updatedAt: updatedAt ?? this.updatedAt,
      syncStatus: syncStatus ?? this.syncStatus,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
    );
  }

  int get availableQuantity => quantity - reserved;
  bool get isInStock => availableQuantity > 0;
  bool get isOutOfStock => availableQuantity <= 0;
  
  // Note: isLowStock logic is handled in LocalDataSource.getLowStockProducts()
  // because it needs to compare with product.reorderPoint
  bool get isLowStock => false; // This will be overridden by proper calculation

  @override
  List<Object?> get props => [
        id,
        tenantId,
        productId,
        locationId,
        quantity,
        reserved,
        updatedAt,
        syncStatus,
        lastSyncedAt,
      ];
}
