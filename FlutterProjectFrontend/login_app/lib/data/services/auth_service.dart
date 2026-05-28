import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:login_app/data/services/token_storage.dart';

class AuthService {
  static const String baseUrl = 'http://127.0.0.1:8000/api';

  /// Registrar nuevo usuario
  Future<Map<String, dynamic>> register({
    required String username,
    required String email,
    required String firstName,
    required String lastName,
    required String phone,
    required String password,
    required String password2,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/register/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': username,
          'email': email,
          'first_name': firstName,
          'last_name': lastName,
          'phone': phone,
          'password': password,
          'password2': password2,
          'role': 'visitor',
        }),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return {'success': true, 'data': data};
      } else {
        final error = jsonDecode(response.body);
        String errorMessage = 'Error en registro';
        
        if (error is Map) {
          if (error.containsKey('username') && error['username'] is List) {
            errorMessage = error['username'].first;
          } else if (error.containsKey('email') && error['email'] is List) {
            errorMessage = error['email'].first;
          }
        }
        
        return {
          'success': false,
          'error': errorMessage
        };
      }
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  /// Login con usuario y contraseña
  Future<Map<String, dynamic>> login({
    required String username,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/token/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': username,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        // Guardar tokens
        await TokenStorage.saveAccessToken(data['access']);
        if (data['refresh'] != null) {
          await TokenStorage.saveRefreshToken(data['refresh']);
        }

        // Obtener perfil del usuario
        final profileResponse = await getProfile(data['access']);
        if (profileResponse['success']) {
          final user = profileResponse['data'];
          await TokenStorage.saveUserInfo(
            userId: user['id'].toString(),
            username: user['username'],
            userRole: user['role'],
          );
          return {
            'success': true,
            'user': user,
            'token': data['access'],
          };
        }

        return {'success': true, 'token': data['access']};
      } else {
        return {
          'success': false,
          'error': 'Usuario o contraseña incorrectos'
        };
      }
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  /// Obtener perfil del usuario autenticado
  Future<Map<String, dynamic>> getProfile(String accessToken) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/auth/profile/'),
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {'success': true, 'data': data};
      } else {
        return {'success': false, 'error': 'No se pudo obtener el perfil'};
      }
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  /// Logout
  Future<bool> logout() async {
    try {
      await TokenStorage.clearAll();
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Verificar si existe sesión activa
  Future<Map<String, dynamic>> checkSession() async {
    try {
      final token = await TokenStorage.getAccessToken();
      if (token == null) {
        return {'authenticated': false};
      }

      final profileResponse = await getProfile(token);
      if (profileResponse['success']) {
        return {
          'authenticated': true,
          'user': profileResponse['data'],
        };
      } else {
        await TokenStorage.clearAll();
        return {'authenticated': false};
      }
    } catch (e) {
      return {'authenticated': false, 'error': e.toString()};
    }
  }

  /// Refrescar token de acceso
  Future<Map<String, dynamic>> refreshAccessToken() async {
    try {
      final refreshToken = await TokenStorage.getRefreshToken();
      if (refreshToken == null) {
        return {'success': false, 'error': 'No refresh token available'};
      }

      final response = await http.post(
        Uri.parse('$baseUrl/auth/token/refresh/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'refresh': refreshToken}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        await TokenStorage.saveAccessToken(data['access']);
        return {'success': true, 'token': data['access']};
      } else {
        await TokenStorage.clearAll();
        return {'success': false, 'error': 'Token refresh failed'};
      }
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }
}
