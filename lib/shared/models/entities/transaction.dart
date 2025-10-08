import 'dart:convert';
import 'package:equatable/equatable.dart';

class Transaction extends Equatable {
  final String id;
  final String tenantId;
  final String locationId;
  final String userId;
  final String? receiptNumber;
  final double subtotal;
  final double discount;
  final double tax;
  final double total;
  final String? paymentMethod;
  final Map<String, dynamic> paymentDetails;
  final double? amountPaid;
  final double? changeAmount;
  final String status;
  final String? notes;
  final String? customerName;
  final String? customerPhone;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? voidedAt;
  final String? voidedBy;
  final String? voidReason;
  final String syncStatus;
  final DateTime? lastSyncedAt;

  const Transaction({
    required this.id,
    required this.tenantId,
    required this.locationId,
    required this.userId,
    this.receiptNumber,
    required this.subtotal,
    this.discount = 0.0,
    this.tax = 0.0,
    required this.total,
    this.paymentMethod,
    this.paymentDetails = const {},
    this.amountPaid,
    this.changeAmount,
    this.status = 'completed',
    this.notes,
    this.customerName,
    this.customerPhone,
    required this.createdAt,
    required this.updatedAt,
    this.voidedAt,
    this.voidedBy,
    this.voidReason,
    this.syncStatus = 'synced',
    this.lastSyncedAt,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'] as String,
      tenantId: json['tenant_id'] as String,
      locationId: json['location_id'] as String,
      userId: json['user_id'] as String,
      receiptNumber: json['receipt_number'] as String?,
      subtotal: (json['subtotal'] as num).toDouble(),
      discount: (json['discount'] as num?)?.toDouble() ?? 0.0,
      tax: (json['tax'] as num?)?.toDouble() ?? 0.0,
      total: (json['total'] as num).toDouble(),
      paymentMethod: json['payment_method'] as String?,
      paymentDetails: json['payment_details'] != null
          ? (json['payment_details'] is String 
              ? Map<String, dynamic>.from(jsonDecode(json['payment_details'] as String))
              : Map<String, dynamic>.from(json['payment_details'] as Map))
          : {},
      amountPaid: (json['amount_paid'] as num?)?.toDouble(),
      changeAmount: (json['change_amount'] as num?)?.toDouble(),
      status: json['status'] as String? ?? 'completed',
      notes: json['notes'] as String?,
      customerName: json['customer_name'] as String?,
      customerPhone: json['customer_phone'] as String?,
      createdAt: DateTime.fromMillisecondsSinceEpoch(json['created_at'] as int),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(json['updated_at'] as int),
      voidedAt: json['voided_at'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['voided_at'] as int)
          : null,
      voidedBy: json['voided_by'] as String?,
      voidReason: json['void_reason'] as String?,
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
      'location_id': locationId,
      'user_id': userId,
      'receipt_number': receiptNumber,
      'subtotal': subtotal,
      'discount': discount,
      'tax': tax,
      'total': total,
      'payment_method': paymentMethod,
      'payment_details': jsonEncode(paymentDetails), // Convert Map to JSON string for SQLite
      'amount_paid': amountPaid,
      'change_amount': changeAmount,
      'status': status,
      'notes': notes,
      'customer_name': customerName,
      'customer_phone': customerPhone,
      'created_at': createdAt.millisecondsSinceEpoch,
      'updated_at': updatedAt.millisecondsSinceEpoch,
      'voided_at': voidedAt?.millisecondsSinceEpoch,
      'voided_by': voidedBy,
      'void_reason': voidReason,
      'sync_status': syncStatus,
      'last_synced_at': lastSyncedAt?.millisecondsSinceEpoch,
    };
  }

  Transaction copyWith({
    String? id,
    String? tenantId,
    String? locationId,
    String? userId,
    String? receiptNumber,
    double? subtotal,
    double? discount,
    double? tax,
    double? total,
    String? paymentMethod,
    Map<String, dynamic>? paymentDetails,
    double? amountPaid,
    double? changeAmount,
    String? status,
    String? notes,
    String? customerName,
    String? customerPhone,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? voidedAt,
    String? voidedBy,
    String? voidReason,
    String? syncStatus,
    DateTime? lastSyncedAt,
  }) {
    return Transaction(
      id: id ?? this.id,
      tenantId: tenantId ?? this.tenantId,
      locationId: locationId ?? this.locationId,
      userId: userId ?? this.userId,
      receiptNumber: receiptNumber ?? this.receiptNumber,
      subtotal: subtotal ?? this.subtotal,
      discount: discount ?? this.discount,
      tax: tax ?? this.tax,
      total: total ?? this.total,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      paymentDetails: paymentDetails ?? this.paymentDetails,
      amountPaid: amountPaid ?? this.amountPaid,
      changeAmount: changeAmount ?? this.changeAmount,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      customerName: customerName ?? this.customerName,
      customerPhone: customerPhone ?? this.customerPhone,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      voidedAt: voidedAt ?? this.voidedAt,
      voidedBy: voidedBy ?? this.voidedBy,
      voidReason: voidReason ?? this.voidReason,
      syncStatus: syncStatus ?? this.syncStatus,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
    );
  }

  bool get isCompleted => status == 'completed';
  bool get isDraft => status == 'draft';
  bool get isVoided => status == 'voided';
  bool get isRefunded => status == 'refunded';
  bool get isPartialRefunded => status == 'partial_refunded';
  bool get isPaid => amountPaid != null && amountPaid! >= total;
  bool get hasCustomer => customerName != null && customerName!.isNotEmpty;

  @override
  List<Object?> get props => [
        id,
        tenantId,
        locationId,
        userId,
        receiptNumber,
        subtotal,
        discount,
        tax,
        total,
        paymentMethod,
        paymentDetails,
        amountPaid,
        changeAmount,
        status,
        notes,
        customerName,
        customerPhone,
        createdAt,
        updatedAt,
        voidedAt,
        voidedBy,
        voidReason,
        syncStatus,
        lastSyncedAt,
      ];
}
