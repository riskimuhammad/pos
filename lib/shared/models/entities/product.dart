import 'package:equatable/equatable.dart';
import 'dart:convert';

class Product extends Equatable {
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
  final String sku;
  final String name;
  final String? categoryId;
  final String? description;
  final String unit;
  final double priceBuy;
  final double priceSell;
  final double? weight;
  final bool hasBarcode;
  final String? barcode;
  final bool isExpirable;
  final bool isActive;
  final int minStock;
  final List<String> photos;
  final Map<String, dynamic> attributes;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final String syncStatus;
  final DateTime? lastSyncedAt;

  const Product({
    required this.id,
    required this.tenantId,
    required this.sku,
    required this.name,
    this.categoryId,
    this.description,
    this.unit = 'pcs',
    this.priceBuy = 0.0,
    required this.priceSell,
    this.weight,
    this.hasBarcode = false,
    this.barcode,
    this.isExpirable = false,
    this.isActive = true,
    this.minStock = 0,
    this.photos = const [],
    this.attributes = const {},
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    this.syncStatus = 'synced',
    this.lastSyncedAt,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] as String,
      tenantId: json['tenant_id'] as String,
      sku: json['sku'] as String,
      name: json['name'] as String,
      categoryId: json['category_id'] as String?,
      description: json['description'] as String?,
      unit: json['uom'] as String? ?? 'pcs',
      priceBuy: (json['price_buy'] as num?)?.toDouble() ?? 0.0,
      priceSell: (json['price_sell'] as num).toDouble(),
      weight: (json['weight'] as num?)?.toDouble(),
      hasBarcode: _parseBoolean(json['has_barcode'], false),
      barcode: json['barcode'] as String?,
      isExpirable: _parseBoolean(json['is_expirable'], false),
      isActive: _parseBoolean(json['is_active'], true),
      minStock: json['min_stock'] as int? ?? 0,
      photos: json['photos'] != null
          ? (json['photos'] is String 
              ? List<String>.from(jsonDecode(json['photos'] as String))
              : List<String>.from(json['photos'] as List))
          : [],
      attributes: json['attributes'] != null
          ? (json['attributes'] is String
              ? Map<String, dynamic>.from(jsonDecode(json['attributes'] as String))
              : Map<String, dynamic>.from(json['attributes'] as Map))
          : {},
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
      'sku': sku,
      'name': name,
      'category_id': categoryId,
      'description': description,
      'uom': unit,
      'price_buy': priceBuy,
      'price_sell': priceSell,
      'weight': weight,
      'has_barcode': hasBarcode ? 1 : 0,
      'barcode': barcode,
      'is_expirable': isExpirable ? 1 : 0,
      'is_active': isActive ? 1 : 0,
      'min_stock': minStock,
      'photos': jsonEncode(photos),
      'attributes': jsonEncode(attributes),
      'created_at': createdAt.millisecondsSinceEpoch,
      'updated_at': updatedAt.millisecondsSinceEpoch,
      'deleted_at': deletedAt?.millisecondsSinceEpoch,
      'sync_status': syncStatus,
      'last_synced_at': lastSyncedAt?.millisecondsSinceEpoch,
    };
  }

  Product copyWith({
    String? id,
    String? tenantId,
    String? sku,
    String? name,
    String? categoryId,
    String? description,
    String? unit,
    double? priceBuy,
    double? priceSell,
    double? weight,
    bool? hasBarcode,
    String? barcode,
    bool? isExpirable,
    bool? isActive,
    int? minStock,
    List<String>? photos,
    Map<String, dynamic>? attributes,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
    String? syncStatus,
    DateTime? lastSyncedAt,
  }) {
    return Product(
      id: id ?? this.id,
      tenantId: tenantId ?? this.tenantId,
      sku: sku ?? this.sku,
      name: name ?? this.name,
      categoryId: categoryId ?? this.categoryId,
      description: description ?? this.description,
      unit: unit ?? this.unit,
      priceBuy: priceBuy ?? this.priceBuy,
      priceSell: priceSell ?? this.priceSell,
      weight: weight ?? this.weight,
      hasBarcode: hasBarcode ?? this.hasBarcode,
      barcode: barcode ?? this.barcode,
      isExpirable: isExpirable ?? this.isExpirable,
      isActive: isActive ?? this.isActive,
      minStock: minStock ?? this.minStock,
      photos: photos ?? this.photos,
      attributes: attributes ?? this.attributes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      syncStatus: syncStatus ?? this.syncStatus,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
    );
  }

  double get profitMargin => priceSell - priceBuy;
  double get profitMarginPercentage => priceBuy > 0 ? (profitMargin / priceBuy) * 100 : 0;
  bool get hasPhotos => photos.isNotEmpty;
  String? get firstPhoto => photos.isNotEmpty ? photos.first : null;

  @override
  List<Object?> get props => [
        id,
        tenantId,
        sku,
        name,
        categoryId,
        description,
        unit,
        priceBuy,
        priceSell,
        weight,
        hasBarcode,
        barcode,
        isExpirable,
        isActive,
        minStock,
        photos,
        attributes,
        createdAt,
        updatedAt,
        deletedAt,
        syncStatus,
        lastSyncedAt,
      ];
}
