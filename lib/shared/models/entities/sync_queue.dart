import 'package:equatable/equatable.dart';

enum SyncOperation {
  insert,
  update,
  delete,
}

enum SyncStatus {
  pending,
  processing,
  success,
  failed,
}

class SyncQueue extends Equatable {
  final String id;
  final String entityType;
  final String entityId;
  final SyncOperation operation;
  final Map<String, dynamic> payload;
  final int priority;
  final int retryCount;
  final int maxRetries;
  final SyncStatus status;
  final String? errorMessage;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? nextRetryAt;

  const SyncQueue({
    required this.id,
    required this.entityType,
    required this.entityId,
    required this.operation,
    required this.payload,
    this.priority = 5,
    this.retryCount = 0,
    this.maxRetries = 3,
    this.status = SyncStatus.pending,
    this.errorMessage,
    required this.createdAt,
    required this.updatedAt,
    this.nextRetryAt,
  });

  factory SyncQueue.fromJson(Map<String, dynamic> json) {
    return SyncQueue(
      id: json['id'] as String,
      entityType: json['entity_type'] as String,
      entityId: json['entity_id'] as String,
      operation: SyncOperation.values.firstWhere(
        (e) => e.name == json['operation'].toString().toLowerCase(),
        orElse: () => SyncOperation.insert,
      ),
      payload: Map<String, dynamic>.from(json['payload'] as Map),
      priority: json['priority'] as int? ?? 5,
      retryCount: json['retry_count'] as int? ?? 0,
      maxRetries: json['max_retries'] as int? ?? 3,
      status: SyncStatus.values.firstWhere(
        (e) => e.name == json['status'].toString().toLowerCase(),
        orElse: () => SyncStatus.pending,
      ),
      errorMessage: json['error_message'] as String?,
      createdAt: DateTime.fromMillisecondsSinceEpoch(json['created_at'] as int),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(json['updated_at'] as int),
      nextRetryAt: json['next_retry_at'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['next_retry_at'] as int)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'entity_type': entityType,
      'entity_id': entityId,
      'operation': operation.name,
      'payload': payload,
      'priority': priority,
      'retry_count': retryCount,
      'max_retries': maxRetries,
      'status': status.name,
      'error_message': errorMessage,
      'created_at': createdAt.millisecondsSinceEpoch,
      'updated_at': updatedAt.millisecondsSinceEpoch,
      'next_retry_at': nextRetryAt?.millisecondsSinceEpoch,
    };
  }

  SyncQueue copyWith({
    String? id,
    String? entityType,
    String? entityId,
    SyncOperation? operation,
    Map<String, dynamic>? payload,
    int? priority,
    int? retryCount,
    int? maxRetries,
    SyncStatus? status,
    String? errorMessage,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? nextRetryAt,
  }) {
    return SyncQueue(
      id: id ?? this.id,
      entityType: entityType ?? this.entityType,
      entityId: entityId ?? this.entityId,
      operation: operation ?? this.operation,
      payload: payload ?? this.payload,
      priority: priority ?? this.priority,
      retryCount: retryCount ?? this.retryCount,
      maxRetries: maxRetries ?? this.maxRetries,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      nextRetryAt: nextRetryAt ?? this.nextRetryAt,
    );
  }

  bool get isPending => status == SyncStatus.pending;
  bool get isProcessing => status == SyncStatus.processing;
  bool get isSuccess => status == SyncStatus.success;
  bool get isFailed => status == SyncStatus.failed;
  bool get canRetry => retryCount < maxRetries && isFailed;
  bool get isHighPriority => priority <= 3;
  bool get isLowPriority => priority >= 7;

  String get operationDisplayName {
    switch (operation) {
      case SyncOperation.insert:
        return 'Tambah';
      case SyncOperation.update:
        return 'Update';
      case SyncOperation.delete:
        return 'Hapus';
    }
  }

  String get statusDisplayName {
    switch (status) {
      case SyncStatus.pending:
        return 'Menunggu';
      case SyncStatus.processing:
        return 'Memproses';
      case SyncStatus.success:
        return 'Berhasil';
      case SyncStatus.failed:
        return 'Gagal';
    }
  }

  @override
  List<Object?> get props => [
        id,
        entityType,
        entityId,
        operation,
        payload,
        priority,
        retryCount,
        maxRetries,
        status,
        errorMessage,
        createdAt,
        updatedAt,
        nextRetryAt,
      ];
}
