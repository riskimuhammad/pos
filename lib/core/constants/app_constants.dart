class AppConstants {
  // App Info
  static const String appName = 'POS UMKM';
  static const String appVersion = '1.0.0';
  
  // Database
  static const String databaseName = 'pos_umkm.db';
  static const int databaseVersion = 6; // Bumped to 6 for units table
  static const String databasePassword = 'pos_umkm_2024';
  
  // API Configuration
  static const String baseUrl = 'https://api.pos-umkm.com';
  static const String apiVersion = 'v1';
  static const int apiTimeout = 30000; // 30 seconds
  
  // Sync Configuration
  static const int syncIntervalMinutes = 5;
  static const int maxRetryAttempts = 3;
  static const int retryDelaySeconds = 5;
  
  // Pagination
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;
  
  // File Upload
  static const int maxImageSizeMB = 5;
  static const List<String> allowedImageTypes = ['jpg', 'jpeg', 'png', 'webp'];
  
  // Validation
  static const int minPasswordLength = 8;
  static const int maxProductNameLength = 100;
  static const int maxProductDescriptionLength = 500;
  
  // UI Configuration
  static const double defaultPadding = 16.0;
  static const double defaultBorderRadius = 8.0;
  static const double defaultElevation = 2.0;
  
  // Feature Toggles
  static const bool kEnableRemoteApi = false; // Set to true when API is ready
  static const bool kEnableSync = false;      // Set to true when sync is ready
  static const bool kEnableOfflineMode = true;
  static const bool kEnableBiometricLogin = false;
  static const bool kEnablePushNotifications = false;
  
  // AI Configuration
  static const double minConfidenceThreshold = 0.7;
  static const int maxPredictionResults = 3;
  static const int modelUpdateCheckIntervalHours = 24;
  
  // Business Rules
  static const double defaultTaxRate = 0.11; // 11% PPN
  static const double defaultServiceCharge = 0.0;
  static const int maxTransactionItems = 50;
  static const int maxHoldTransactions = 10;
  
  // Receipt Configuration
  static const int receiptWidth = 48; // characters
  static const String receiptFont = 'monospace';
  static const int receiptLineHeight = 1;
  
  // Error Messages
  static const String networkErrorMessage = 'Tidak ada koneksi internet';
  static const String serverErrorMessage = 'Terjadi kesalahan pada server';
  static const String unknownErrorMessage = 'Terjadi kesalahan yang tidak diketahui';
  
  // Success Messages
  static const String syncSuccessMessage = 'Data berhasil disinkronisasi';
  static const String saveSuccessMessage = 'Data berhasil disimpan';
  static const String deleteSuccessMessage = 'Data berhasil dihapus';
  
  // Default Values
  static const String defaultTenantId = 'default-tenant-id';
  static const String defaultLocationId = 'default-location-id';
  static const String defaultUserId = 'system';
  
  // Storage Keys
  static const String tokenKey = 'auth_token';
  static const String userKey = 'user_data';
  static const String tenantKey = 'tenant_data';
  
  // Cache Configuration
  static const int cacheExpirationMinutes = 30;
  static const int maxCacheSizeMB = 100;
  
  // Logging
  static const bool enableDebugLogging = true;
  static const bool enablePerformanceLogging = false;
  static const bool enableCrashReporting = false;
}