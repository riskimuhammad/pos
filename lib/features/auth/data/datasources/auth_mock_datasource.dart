import 'package:pos/core/errors/exceptions.dart';
import '../models/auth_request.dart';
import '../models/auth_response.dart';
import '../../../../shared/models/entities/entities.dart';

class AuthMockDataSource {
  // Mock users data
  static final List<Map<String, dynamic>> _mockUsers = [
    {
      'id': 'user_001',
      'tenant_id': 'tenant_001',
      'username': 'admin',
      'email': 'admin@posumkm.com',
      'password_hash': 'admin123', // In real app, this would be hashed
      'full_name': 'Administrator',
      'role': 'owner',
      'permissions': ['all'],
      'is_active': true,
      'last_login_at': null,
      'created_at': DateTime.now().millisecondsSinceEpoch ~/ 1000,
      'updated_at': DateTime.now().millisecondsSinceEpoch ~/ 1000,
      'deleted_at': null,
      'sync_status': 'synced',
      'last_synced_at': null,
    },
    {
      'id': 'user_002',
      'tenant_id': 'tenant_001',
      'username': 'kasir1',
      'email': 'kasir1@posumkm.com',
      'password_hash': 'kasir123',
      'full_name': 'Kasir Satu',
      'role': 'cashier',
      'permissions': ['pos', 'products', 'inventory'],
      'is_active': true,
      'last_login_at': null,
      'created_at': DateTime.now().millisecondsSinceEpoch ~/ 1000,
      'updated_at': DateTime.now().millisecondsSinceEpoch ~/ 1000,
      'deleted_at': null,
      'sync_status': 'synced',
      'last_synced_at': null,
    },
    {
      'id': 'user_003',
      'tenant_id': 'tenant_001',
      'username': 'manager1',
      'email': 'manager1@posumkm.com',
      'password_hash': 'manager123',
      'full_name': 'Manager Satu',
      'role': 'manager',
      'permissions': ['pos', 'products', 'inventory', 'reports', 'users'],
      'is_active': true,
      'last_login_at': null,
      'created_at': DateTime.now().millisecondsSinceEpoch ~/ 1000,
      'updated_at': DateTime.now().millisecondsSinceEpoch ~/ 1000,
      'deleted_at': null,
      'sync_status': 'synced',
      'last_synced_at': null,
    },
  ];

  // Mock tenant data
  static final Map<String, dynamic> _mockTenant = {
    'id': 'tenant_001',
    'name': 'Toko UMKM Demo',
    'owner_name': 'Budi Santoso',
    'email': 'budi@posumkm.com',
    'phone': '+6281234567890',
    'address': 'Jl. Raya UMKM No. 123, Jakarta',
    'settings': {
      'currency': 'IDR',
      'tax_rate': 0.11,
      'receipt_footer': 'Terima kasih telah berbelanja!',
    },
    'subscription_tier': 'premium',
    'subscription_expiry': DateTime.now().add(const Duration(days: 365)).millisecondsSinceEpoch ~/ 1000,
    'is_active': true,
    'logo_url': null,
    'created_at': DateTime.now().millisecondsSinceEpoch ~/ 1000,
    'updated_at': DateTime.now().millisecondsSinceEpoch ~/ 1000,
    'deleted_at': null,
    'sync_status': 'synced',
    'last_synced_at': null,
  };

  static Future<AuthResponse> login(AuthRequest request) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));

    // Find user by username OR email
    final userData = _mockUsers.firstWhere(
      (user) => user['username'] == request.username || user['email'] == request.username,
      orElse: () => throw AuthenticationException(message: 'User not found'),
    );

    // Check password (in real app, this would be hashed comparison)
    if (userData['password_hash'] != request.password) {
      throw AuthenticationException(message: 'Invalid password');
    }

    // Check if user is active
    if (userData['is_active'] != true) {
      throw AuthenticationException(message: 'User account is disabled');
    }

    // Create user and tenant objects
    final user = User.fromJson(userData);
    final tenant = Tenant.fromJson(_mockTenant);

    // Generate mock tokens
    final token = 'mock_jwt_token_${user.id}_${DateTime.now().millisecondsSinceEpoch}';
    final refreshToken = 'mock_refresh_token_${user.id}_${DateTime.now().millisecondsSinceEpoch}';
    final expiresAt = DateTime.now().add(const Duration(hours: 24));

    return AuthResponse(
      user: user,
      tenant: tenant,
      token: token,
      refreshToken: refreshToken,
      expiresAt: expiresAt,
    );
  }

  static Future<AuthResponse> refreshToken(String refreshToken) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));

    // In real app, you would validate the refresh token
    if (!refreshToken.startsWith('mock_refresh_token_')) {
      throw AuthenticationException(message: 'Invalid refresh token');
    }

    // Extract user ID from token (mock implementation)
    final userId = refreshToken.split('_')[3];
    final userData = _mockUsers.firstWhere(
      (user) => user['id'] == userId,
      orElse: () => throw AuthenticationException(message: 'User not found'),
    );

    final user = User.fromJson(userData);
    final tenant = Tenant.fromJson(_mockTenant);

    // Generate new tokens
    final newToken = 'mock_jwt_token_${user.id}_${DateTime.now().millisecondsSinceEpoch}';
    final newRefreshToken = 'mock_refresh_token_${user.id}_${DateTime.now().millisecondsSinceEpoch}';
    final expiresAt = DateTime.now().add(const Duration(hours: 24));

    return AuthResponse(
      user: user,
      tenant: tenant,
      token: newToken,
      refreshToken: newRefreshToken,
      expiresAt: expiresAt,
    );
  }

  static Future<void> logout(String token) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 300));
    
    // In real app, you would invalidate the token on server
    // For mock, we just simulate success
    print('Mock logout successful for token: ${token.substring(0, 20)}...');
  }

  static Future<void> changePassword(String oldPassword, String newPassword) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));

    // Mock validation
    if (oldPassword.isEmpty || newPassword.isEmpty) {
      throw ValidationException(message: 'Password cannot be empty');
    }

    if (newPassword.length < 6) {
      throw ValidationException(message: 'New password must be at least 6 characters');
    }

    // In real app, you would update password on server
    print('Mock password change successful');
  }
}
