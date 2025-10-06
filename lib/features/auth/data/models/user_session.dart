import 'package:equatable/equatable.dart';
import '../../../../shared/models/entities/entities.dart';

class UserSession extends Equatable {
  // Helper function to parse boolean from various types
  static bool _parseBoolean(dynamic value, bool defaultValue) {
    if (value == null) return defaultValue;
    if (value is bool) return value;
    if (value is int) return value == 1;
    if (value is String) return value.toLowerCase() == 'true' || value == '1';
    return defaultValue;
  }
  final User user;
  final Tenant tenant;
  final String token;
  final String refreshToken;
  final DateTime expiresAt;
  final DateTime loginAt;
  final bool isActive;

  const UserSession({
    required this.user,
    required this.tenant,
    required this.token,
    required this.refreshToken,
    required this.expiresAt,
    required this.loginAt,
    this.isActive = true,
  });

  @override
  List<Object> get props => [
        user,
        tenant,
        token,
        refreshToken,
        expiresAt,
        loginAt,
        isActive,
      ];

  bool get isExpired => DateTime.now().isAfter(expiresAt);

  bool get isValid => isActive && !isExpired;

  UserSession copyWith({
    User? user,
    Tenant? tenant,
    String? token,
    String? refreshToken,
    DateTime? expiresAt,
    DateTime? loginAt,
    bool? isActive,
  }) {
    return UserSession(
      user: user ?? this.user,
      tenant: tenant ?? this.tenant,
      token: token ?? this.token,
      refreshToken: refreshToken ?? this.refreshToken,
      expiresAt: expiresAt ?? this.expiresAt,
      loginAt: loginAt ?? this.loginAt,
      isActive: isActive ?? this.isActive,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user': user.toJson(),
      'tenant': tenant.toJson(),
      'token': token,
      'refresh_token': refreshToken,
      'expires_at': expiresAt.millisecondsSinceEpoch,
      'login_at': loginAt.millisecondsSinceEpoch,
      'is_active': isActive,
    };
  }

  factory UserSession.fromJson(Map<String, dynamic> json) {
    return UserSession(
      user: User.fromJson(json['user'] as Map<String, dynamic>),
      tenant: Tenant.fromJson(json['tenant'] as Map<String, dynamic>),
      token: json['token'] as String,
      refreshToken: json['refresh_token'] as String,
      expiresAt: DateTime.fromMillisecondsSinceEpoch(json['expires_at'] as int),
      loginAt: DateTime.fromMillisecondsSinceEpoch(json['login_at'] as int),
      isActive: _parseBoolean(json['is_active'], true),
    );
  }
}
