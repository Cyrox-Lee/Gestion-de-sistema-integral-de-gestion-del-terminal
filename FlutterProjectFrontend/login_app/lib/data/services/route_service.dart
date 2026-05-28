import 'package:login_app/data/models/route_model.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class RouteService {
  static const String baseUrl = 'http://127.0.0.1:8000/api';

  Future<List<RouteModel>> getAllRoutes() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/routes/'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        final List<dynamic> routes = jsonData is List ? jsonData : jsonData['results'] ?? [];
        return routes.map((r) => RouteModel.fromJson(r)).toList();
      } else {
        throw Exception('Error al obtener rutas: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  Future<RouteModel?> getRouteById(String id) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/$id/'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return RouteModel.fromJson(jsonDecode(response.body));
      } else if (response.statusCode == 404) {
        return null;
      } else {
        throw Exception('Error al obtener ruta: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  Future<RouteModel?> createRoute(RouteModel route) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(route.toCreateJson()),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 201 || response.statusCode == 200) {
        return RouteModel.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Error al crear ruta: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  Future<RouteModel?> updateRoute(RouteModel route) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/${route.id}/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(route.toUpdateJson()),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return RouteModel.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Error al actualizar ruta: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  Future<bool> deleteRoute(String id) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/$id/'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 204 || response.statusCode == 200) {
        return true;
      } else if (response.statusCode == 404) {
        return false;
      } else {
        throw Exception('Error al eliminar ruta: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }
}
