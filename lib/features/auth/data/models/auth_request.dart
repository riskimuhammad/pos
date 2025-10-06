import 'package:equatable/equatable.dart';

class AuthRequest extends Equatable {
  final String username;
  final String password;
  final String? deviceId;
  final String? deviceName;
  final String? osVersion;
  final String? appVersion;

  const AuthRequest({
    required this.username,
    required this.password,
    this.deviceId,
    this.deviceName,
    this.osVersion,
    this.appVersion,
  });

  @override
  List<Object?> get props => [
        username,
        password,
        deviceId,
        deviceName,
        osVersion,
        appVersion,
      ];

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'password': password,
      'device_info': {
        'device_id': deviceId,
        'device_name': deviceName,
        'os_version': osVersion,
        'app_version': appVersion,
      },
    };
  }

  factory AuthRequest.fromJson(Map<String, dynamic> json) {
    final deviceInfo = json['device_info'] as Map<String, dynamic>?;
    return AuthRequest(
      username: json['username'] as String,
      password: json['password'] as String,
      deviceId: deviceInfo?['device_id'] as String?,
      deviceName: deviceInfo?['device_name'] as String?,
      osVersion: deviceInfo?['os_version'] as String?,
      appVersion: deviceInfo?['app_version'] as String?,
    );
  }
}
