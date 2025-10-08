class Product {
  final String id;
  final String name;
  final String sku;
  final String category;
  final double price;
  final String? imageUrl;
  final String? description;
  final int stock;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? brand;
  final String? variant;
  final String? packSize;
  final String? uom;
  final int? reorderPoint;
  final int? reorderQty;

  const Product({
    required this.id,
    required this.name,
    required this.sku,
    required this.category,
    required this.price,
    this.imageUrl,
    this.description,
    required this.stock,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
    this.brand,
    this.variant,
    this.packSize,
    this.uom,
    this.reorderPoint,
    this.reorderQty,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] as String,
      name: json['name'] as String,
      sku: json['sku'] as String,
      category: json['category'] as String,
      price: (json['price'] as num).toDouble(),
      imageUrl: json['image_url'] as String?,
      description: json['description'] as String?,
      stock: json['stock'] as int? ?? 0,
      isActive: json['is_active'] as bool? ?? true,
      createdAt: DateTime.fromMillisecondsSinceEpoch(json['created_at'] as int),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(json['updated_at'] as int),
      brand: json['brand'] as String?,
      variant: json['variant'] as String?,
      packSize: json['pack_size'] as String?,
      uom: json['uom'] as String?,
      reorderPoint: json['reorder_point'] as int?,
      reorderQty: json['reorder_qty'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'sku': sku,
      'category': category,
      'price': price,
      'image_url': imageUrl,
      'description': description,
      'stock': stock,
      'is_active': isActive,
      'created_at': createdAt.millisecondsSinceEpoch,
      'updated_at': updatedAt.millisecondsSinceEpoch,
      'brand': brand,
      'variant': variant,
      'pack_size': packSize,
      'uom': uom,
      'reorder_point': reorderPoint,
      'reorder_qty': reorderQty,
    };
  }

  Product copyWith({
    String? id,
    String? name,
    String? sku,
    String? category,
    double? price,
    String? imageUrl,
    String? description,
    int? stock,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? brand,
    String? variant,
    String? packSize,
    String? uom,
    int? reorderPoint,
    int? reorderQty,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      sku: sku ?? this.sku,
      category: category ?? this.category,
      price: price ?? this.price,
      imageUrl: imageUrl ?? this.imageUrl,
      description: description ?? this.description,
      stock: stock ?? this.stock,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      brand: brand ?? this.brand,
      variant: variant ?? this.variant,
      packSize: packSize ?? this.packSize,
      uom: uom ?? this.uom,
      reorderPoint: reorderPoint ?? this.reorderPoint,
      reorderQty: reorderQty ?? this.reorderQty,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Product && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Product(id: $id, name: $name, sku: $sku, category: $category, price: $price)';
  }
}
