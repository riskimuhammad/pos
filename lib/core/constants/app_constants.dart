class AppConstants {
  // App Info
  static const String appName = 'POS UMKM';
  static const String appVersion = '1.0.0';
  
  // Database
  static const String databaseName = 'pos_umkm.db';
  static const int databaseVersion = 1;
  static const String databasePassword = 'pos_umkm_2024';
  
  // API
  static const String baseUrl = 'https://api.pos-umkm.com';
  static const String apiVersion = '/v1';
  static const Duration apiTimeout = Duration(seconds: 30);
  
  // Storage Keys
  static const String tokenKey = 'auth_token';
  static const String userKey = 'user_data';
  static const String tenantKey = 'tenant_data';
  static const String settingsKey = 'app_settings';
  
  // Sync
  static const Duration syncInterval = Duration(minutes: 5);
  static const int maxRetryAttempts = 3;
  
  // UI
  static const double defaultPadding = 16.0;
  static const double defaultRadius = 8.0;
  static const double defaultElevation = 2.0;
  
  // Business Rules
  static const int maxParkedTransactions = 10;
  static const int maxLoginAttempts = 5;
  static const Duration lockoutDuration = Duration(minutes: 15);
  
  // Receipt
  static const int receiptWidth = 58; // mm
  static const String receiptFont = 'monospace';
  
  // ML
  static const String modelPath = 'assets/models/product_detection.tflite';
  static const double minConfidenceThreshold = 0.7;
  
  // Pagination
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;
}
