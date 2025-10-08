import 'package:equatable/equatable.dart';

enum StockMovementType {
  sale,
  purchase,
  return_,
  adjustment,
  transfer,
  damage,
  expired,
}

class StockMovement extends Equatable {
  final String id;
  final String tenantId;
  final String productId;
  final String locationId;
  final StockMovementType type;
  final int quantity;
  final double? costPrice;
  final String? referenceType;
  final String? referenceId;
  final String? notes;
  final String? userId;
  final DateTime createdAt;
  final String syncStatus;
  final DateTime? lastSyncedAt;

  const StockMovement({
    required this.id,
    required this.tenantId,
    required this.productId,
    required this.locationId,
    required this.type,
    required this.quantity,
    this.costPrice,
    this.referenceType,
    this.referenceId,
    this.notes,
    this.userId,
    required this.createdAt,
    this.syncStatus = 'synced',
    this.lastSyncedAt,
  });

  factory StockMovement.fromJson(Map<String, dynamic> json) {
    return StockMovement(
      id: json['id'] as String,
      tenantId: json['tenant_id'] as String,
      productId: json['product_id'] as String,
      locationId: json['location_id'] as String,
      type: StockMovementType.values.firstWhere(
        (e) => e.name == json['type'].toString().toLowerCase(),
        orElse: () => StockMovementType.adjustment,
      ),
      quantity: json['quantity'] as int,
      costPrice: (json['cost_price'] as num?)?.toDouble(),
      referenceType: json['reference_type'] as String?,
      referenceId: json['reference_id'] as String?,
      notes: json['notes'] as String?,
      userId: json['user_id'] as String?,
      createdAt: DateTime.fromMillisecondsSinceEpoch(json['created_at'] as int),
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
      'type': type.name.toUpperCase(),
      'quantity': quantity,
      'cost_price': costPrice,
      'reference_type': referenceType,
      'reference_id': referenceId,
      'notes': notes,
      'user_id': userId,
      'created_at': createdAt.millisecondsSinceEpoch,
      'sync_status': syncStatus,
      'last_synced_at': lastSyncedAt?.millisecondsSinceEpoch,
    };
  }

  StockMovement copyWith({
    String? id,
    String? tenantId,
    String? productId,
    String? locationId,
    StockMovementType? type,
    int? quantity,
    double? costPrice,
    String? referenceType,
    String? referenceId,
    String? notes,
    String? userId,
    DateTime? createdAt,
    String? syncStatus,
    DateTime? lastSyncedAt,
  }) {
    return StockMovement(
      id: id ?? this.id,
      tenantId: tenantId ?? this.tenantId,
      productId: productId ?? this.productId,
      locationId: locationId ?? this.locationId,
      type: type ?? this.type,
      quantity: quantity ?? this.quantity,
      costPrice: costPrice ?? this.costPrice,
      referenceType: referenceType ?? this.referenceType,
      referenceId: referenceId ?? this.referenceId,
      notes: notes ?? this.notes,
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
      syncStatus: syncStatus ?? this.syncStatus,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
    );
  }

  bool get isInbound => quantity > 0;
  bool get isOutbound => quantity < 0;
  bool get isSale => type == StockMovementType.sale;
  bool get isPurchase => type == StockMovementType.purchase;
  bool get isReturn => type == StockMovementType.return_;
  bool get isAdjustment => type == StockMovementType.adjustment;
  bool get isTransfer => type == StockMovementType.transfer;
  bool get isDamage => type == StockMovementType.damage;
  bool get isExpired => type == StockMovementType.expired;

  String get typeDisplayName {
    switch (type) {
      case StockMovementType.sale:
        return 'Penjualan';
      case StockMovementType.purchase:
        return 'Pembelian';
      case StockMovementType.return_:
        return 'Retur';
      case StockMovementType.adjustment:
        return 'Penyesuaian';
      case StockMovementType.transfer:
        return 'Transfer';
      case StockMovementType.damage:
        return 'Kerusakan';
      case StockMovementType.expired:
        return 'Kadaluarsa';
    }
  }

  @override
  List<Object?> get props => [
        id,
        tenantId,
        productId,
        locationId,
        type,
        quantity,
        costPrice,
        referenceType,
        referenceId,
        notes,
        userId,
        createdAt,
        syncStatus,
        lastSyncedAt,
      ];
}
