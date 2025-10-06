class ServerException implements Exception {
  final String message;
  final int? code;
  
  const ServerException({
    required this.message,
    this.code,
  });
  
  @override
  String toString() => 'ServerException: $message (Code: $code)';
}

class NetworkException implements Exception {
  final String message;
  
  const NetworkException({required this.message});
  
  @override
  String toString() => 'NetworkException: $message';
}

class CacheException implements Exception {
  final String message;
  
  const CacheException({required this.message});
  
  @override
  String toString() => 'CacheException: $message';
}

class DatabaseException implements Exception {
  final String message;
  
  const DatabaseException({required this.message});
  
  @override
  String toString() => 'DatabaseException: $message';
}

class AuthenticationException implements Exception {
  final String message;
  
  const AuthenticationException({required this.message});
  
  @override
  String toString() => 'AuthenticationException: $message';
}

class ValidationException implements Exception {
  final String message;
  
  const ValidationException({required this.message});
  
  @override
  String toString() => 'ValidationException: $message';
}

class BusinessLogicException implements Exception {
  final String message;
  
  const BusinessLogicException({required this.message});
  
  @override
  String toString() => 'BusinessLogicException: $message';
}

class PrinterException implements Exception {
  final String message;
  
  const PrinterException({required this.message});
  
  @override
  String toString() => 'PrinterException: $message';
}

class ScannerException implements Exception {
  final String message;
  
  const ScannerException({required this.message});
  
  @override
  String toString() => 'ScannerException: $message';
}

class SyncException implements Exception {
  final String message;
  
  const SyncException({required this.message});
  
  @override
  String toString() => 'SyncException: $message';
}
