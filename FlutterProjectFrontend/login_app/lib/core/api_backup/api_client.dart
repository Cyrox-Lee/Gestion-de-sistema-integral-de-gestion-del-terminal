import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:login_app/core/exceptions/app_exception.dart';

/// Cliente HTTP centralizado para comunicación con Django API
/// 
/// Configuración:
/// - Base URL: http://127.0.0.1:8000
/// - Endpoints disponibles: /api/routes/, /api/buses/, /api/drivers/, /api/schedules/
/// 
/// Métodos:
/// - GET: obtener datos
/// - POST: crear datos
/// - PUT: actualizar datos
/// - DELETE: eliminar datos
class ApiClient {
  static const String _baseUrl = 'http://127.0.0.1:8000';
  
  static final http.Client _httpClient = http.Client();

  /// Headers por defecto para todas las peticiones
  static Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  /// GET - Obtener datos
  /// 
  /// Parámetros:
  /// - endpoint: ruta del endpoint (ej: '/api/routes/')
  /// 
  /// Retorna: Lista de maps JSON o un map JSON único
  /// Lanza: [NetworkException] si hay error
  static Future<dynamic> get(String endpoint) async {
    try {
      final url = Uri.parse('$_baseUrl$endpoint');
      final response = await _httpClient.get(
        url,
        headers: _headers,
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () => throw NetworkException(
          message: 'Request timeout',
          code: 'TIMEOUT',
        ),
      );

      return _handleResponse(response);
    } catch (e, stackTrace) {
      if (e is AppException) rethrow;
      throw NetworkException(
        message: 'GET request failed: $endpoint',
        code: 'GET_ERROR',
        originalException: e as Exception?,
        stackTrace: stackTrace,
      );
    }
  }

  /// POST - Crear datos
  /// 
  /// Parámetros:
  /// - endpoint: ruta del endpoint (ej: '/api/routes/')
  /// - body: datos a enviar como Map
  /// 
  /// Retorna: Respuesta JSON del servidor
  /// Lanza: [NetworkException] si hay error
  static Future<dynamic> post(String endpoint, Map<String, dynamic> body) async {
    try {
      final url = Uri.parse('$_baseUrl$endpoint');
      final response = await _httpClient.post(
        url,
        headers: _headers,
        body: jsonEncode(body),
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () => throw NetworkException(
          message: 'Request timeout',
          code: 'TIMEOUT',
        ),
      );

      return _handleResponse(response);
    } catch (e, stackTrace) {
      if (e is AppException) rethrow;
      throw NetworkException(
        message: 'POST request failed: $endpoint',
        code: 'POST_ERROR',
        originalException: e as Exception?,
        stackTrace: stackTrace,
      );
    }
  }

  /// PUT - Actualizar datos
  /// 
  /// Parámetros:
  /// - endpoint: ruta del endpoint (ej: '/api/routes/1/')
  /// - body: datos actualizados como Map
  /// 
  /// Retorna: Respuesta JSON del servidor
  /// Lanza: [NetworkException] si hay error
  static Future<dynamic> put(String endpoint, Map<String, dynamic> body) async {
    try {
      final url = Uri.parse('$_baseUrl$endpoint');
      final response = await _httpClient.put(
        url,
        headers: _headers,
        body: jsonEncode(body),
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () => throw NetworkException(
          message: 'Request timeout',
          code: 'TIMEOUT',
        ),
      );

      return _handleResponse(response);
    } catch (e, stackTrace) {
      if (e is AppException) rethrow;
      throw NetworkException(
        message: 'PUT request failed: $endpoint',
        code: 'PUT_ERROR',
        originalException: e as Exception?,
        stackTrace: stackTrace,
      );
    }
  }

  /// DELETE - Eliminar datos
  /// 
  /// Parámetros:
  /// - endpoint: ruta del endpoint (ej: '/api/routes/1/')
  /// 
  /// Retorna: true si se eliminó exitosamente
  /// Lanza: [NetworkException] si hay error
  static Future<bool> delete(String endpoint) async {
    try {
      final url = Uri.parse('$_baseUrl$endpoint');
      final response = await _httpClient.delete(
        url,
        headers: _headers,
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () => throw NetworkException(
          message: 'Request timeout',
          code: 'TIMEOUT',
        ),
      );

      if (response.statusCode == 204) {
        return true; // No content - eliminado exitosamente
      }

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return true;
      }

      throw NetworkException.badResponse(
        response.statusCode,
        response.body,
      );
    } catch (e, stackTrace) {
      if (e is AppException) rethrow;
      throw NetworkException(
        message: 'DELETE request failed: $endpoint',
        code: 'DELETE_ERROR',
        originalException: e as Exception?,
        stackTrace: stackTrace,
      );
    }
  }

  /// Maneja respuestas HTTP
  /// 
  /// Retorna: JSON decodificado o lanza excepción
  static dynamic _handleResponse(http.Response response) {
    // Códigos de éxito: 200-299
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) {
        return {}; // Respuesta vacía (ej: DELETE sin body)
      }
      return jsonDecode(response.body);
    }

    // Error 400-500
    String errorMessage = 'HTTP ${response.statusCode}';
    try {
      final error = jsonDecode(response.body);
      errorMessage = error['detail'] ?? 
                     error['message'] ?? 
                     error['error'] ?? 
                     errorMessage;
    } catch (_) {
      // Si no es JSON válido, usar el mensaje HTTP
    }

    throw NetworkException.badResponse(
      response.statusCode,
      errorMessage,
    );
  }

  /// Cierra las conexiones (opcional)
  static void close() {
    _httpClient.close();
  }
}

/// Extensión de NetworkException para respuestas HTTP
extension NetworkExceptionFactory on NetworkException {
  static NetworkException badResponse(int statusCode, String body) {
    return NetworkException(
      message: body,
      code: 'HTTP_ERROR_$statusCode',
    );
  }
}
