/// Excepción base para toda la aplicación
/// Centraliza el manejo de errores en toda la arquitectura
abstract class AppException implements Exception {
  final String message;
  final String? code;
  final Exception? originalException;
  final StackTrace? stackTrace;

  AppException({
    required this.message,
    this.code,
    this.originalException,
    this.stackTrace,
  });

  @override
  String toString() => '$runtimeType: $message';
}

/// Errores relacionados con la red/conexión
class NetworkException extends AppException {
  NetworkException({
    required String message,
    String? code,
    Exception? originalException,
    StackTrace? stackTrace,
  }) : super(
    message: message,
    code: code ?? 'NETWORK_ERROR',
    originalException: originalException,
    stackTrace: stackTrace,
  );

  factory NetworkException.noConnection() => NetworkException(
    message: 'No internet connection',
    code: 'NO_CONNECTION',
  );

  factory NetworkException.timeout() => NetworkException(
    message: 'Request timeout',
    code: 'TIMEOUT',
  );

  factory NetworkException.badResponse(int statusCode, String body) =>
      NetworkException(
        message: 'Bad response: $statusCode - $body',
        code: 'BAD_RESPONSE_$statusCode',
      );
}

/// Errores de autenticación/autorización
class AuthException extends AppException {
  AuthException({
    required String message,
    String? code,
    Exception? originalException,
    StackTrace? stackTrace,
  }) : super(
    message: message,
    code: code ?? 'AUTH_ERROR',
    originalException: originalException,
    stackTrace: stackTrace,
  );

  factory AuthException.unauthorized() => AuthException(
    message: 'Unauthorized access',
    code: 'UNAUTHORIZED',
  );

  factory AuthException.tokenExpired() => AuthException(
    message: 'Token has expired',
    code: 'TOKEN_EXPIRED',
  );

  factory AuthException.invalidCredentials() => AuthException(
    message: 'Invalid credentials',
    code: 'INVALID_CREDENTIALS',
  );
}

/// Errores de validación de datos
class ValidationException extends AppException {
  final List<String> errors;

  ValidationException({
    required String message,
    required this.errors,
    String? code,
    Exception? originalException,
    StackTrace? stackTrace,
  }) : super(
    message: message,
    code: code ?? 'VALIDATION_ERROR',
    originalException: originalException,
    stackTrace: stackTrace,
  );

  factory ValidationException.empty(String fieldName) => ValidationException(
    message: '$fieldName cannot be empty',
    errors: ['$fieldName is required'],
    code: 'EMPTY_FIELD',
  );

  factory ValidationException.invalid(String fieldName, String reason) =>
      ValidationException(
        message: 'Invalid $fieldName: $reason',
        errors: ['$fieldName is invalid: $reason'],
        code: 'INVALID_FIELD',
      );

  factory ValidationException.multiple(List<String> errorList) =>
      ValidationException(
        message: 'Validation failed with ${errorList.length} error(s)',
        errors: errorList,
        code: 'MULTIPLE_ERRORS',
      );
}

/// Errores de base de datos/persistencia
class DatabaseException extends AppException {
  DatabaseException({
    required String message,
    String? code,
    Exception? originalException,
    StackTrace? stackTrace,
  }) : super(
    message: message,
    code: code ?? 'DATABASE_ERROR',
    originalException: originalException,
    stackTrace: stackTrace,
  );

  factory DatabaseException.notFound(String entity) => DatabaseException(
    message: '$entity not found',
    code: 'NOT_FOUND',
  );

  factory DatabaseException.alreadyExists(String entity) => DatabaseException(
    message: '$entity already exists',
    code: 'ALREADY_EXISTS',
  );
}

/// Errores genéricos de la aplicación
class ApplicationException extends AppException {
  ApplicationException({
    required String message,
    String? code,
    Exception? originalException,
    StackTrace? stackTrace,
  }) : super(
    message: message,
    code: code ?? 'APPLICATION_ERROR',
    originalException: originalException,
    stackTrace: stackTrace,
  );
}
