import 'package:equatable/equatable.dart';
import '../../../../shared/models/entities/entities.dart';

class AuthResponse extends Equatable {
  final User user;
  final Tenant tenant;
  final String token;
  final String refreshToken;
  final DateTime expiresAt;

  const AuthResponse({
    required this.user,
    required this.tenant,
    required this.token,
    required this.refreshToken,
    required this.expiresAt,
  });

  @override
  List<Object> get props => [user, tenant, token, refreshToken, expiresAt];

  Map<String, dynamic> toJson() {
    return {
      'user': user.toJson(),
      'tenant': tenant.toJson(),
      'token': token,
      'refresh_token': refreshToken,
      'expires_at': expiresAt.millisecondsSinceEpoch,
    };
  }

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      user: User.fromJson(json['user'] as Map<String, dynamic>),
      tenant: Tenant.fromJson(json['tenant'] as Map<String, dynamic>),
      token: json['token'] as String,
      refreshToken: json['refresh_token'] as String,
      expiresAt: DateTime.fromMillisecondsSinceEpoch(json['expires_at'] as int),
    );
  }
}
