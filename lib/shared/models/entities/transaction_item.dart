import 'package:equatable/equatable.dart';

class TransactionItem extends Equatable {
  final String id;
  final String transactionId;
  final String productId;
  final String productName;
  final String? sku;
  final int quantity;
  final double unitPrice;
  final double discount;
  final double subtotal;
  final String? notes;
  final DateTime createdAt;

  const TransactionItem({
    required this.id,
    required this.transactionId,
    required this.productId,
    required this.productName,
    this.sku,
    required this.quantity,
    required this.unitPrice,
    this.discount = 0.0,
    required this.subtotal,
    this.notes,
    required this.createdAt,
  });

  factory TransactionItem.fromJson(Map<String, dynamic> json) {
    return TransactionItem(
      id: json['id'] as String,
      transactionId: json['transaction_id'] as String,
      productId: json['product_id'] as String,
      productName: json['product_name'] as String,
      sku: json['sku'] as String?,
      quantity: json['quantity'] as int,
      unitPrice: (json['unit_price'] as num).toDouble(),
      discount: (json['discount'] as num?)?.toDouble() ?? 0.0,
      subtotal: (json['subtotal'] as num).toDouble(),
      notes: json['notes'] as String?,
      createdAt: DateTime.fromMillisecondsSinceEpoch(json['created_at'] as int),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'transaction_id': transactionId,
      'product_id': productId,
      'product_name': productName,
      'sku': sku,
      'quantity': quantity,
      'unit_price': unitPrice,
      'discount': discount,
      'subtotal': subtotal,
      'notes': notes,
      'created_at': createdAt.millisecondsSinceEpoch,
    };
  }

  TransactionItem copyWith({
    String? id,
    String? transactionId,
    String? productId,
    String? productName,
    String? sku,
    int? quantity,
    double? unitPrice,
    double? discount,
    double? subtotal,
    String? notes,
    DateTime? createdAt,
  }) {
    return TransactionItem(
      id: id ?? this.id,
      transactionId: transactionId ?? this.transactionId,
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      sku: sku ?? this.sku,
      quantity: quantity ?? this.quantity,
      unitPrice: unitPrice ?? this.unitPrice,
      discount: discount ?? this.discount,
      subtotal: subtotal ?? this.subtotal,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  double get totalPrice => quantity * unitPrice;
  double get finalPrice => totalPrice - discount;
  bool get hasDiscount => discount > 0;

  @override
  List<Object?> get props => [
        id,
        transactionId,
        productId,
        productName,
        sku,
        quantity,
        unitPrice,
        discount,
        subtotal,
        notes,
        createdAt,
      ];
}
