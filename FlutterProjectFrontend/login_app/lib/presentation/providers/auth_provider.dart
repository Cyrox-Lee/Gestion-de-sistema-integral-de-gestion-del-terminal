import 'package:flutter/foundation.dart';
import 'package:login_app/data/models/user_model.dart';
import 'package:login_app/data/repositories/auth_repository.dart';
import 'package:login_app/data/services/auth_service.dart';

/// Estados posibles del proveedor de autenticación
enum AuthState {
  initial,
  loading,
  authenticated,
  unauthenticated,
  error,
}

/// Provider para gestionar autenticación
/// Maneja login, logout y persistencia del usuario autenticado
class AuthProvider extends ChangeNotifier {
  // Dependencias
  final AuthRepository _repository;

  // Estado
  AuthState _state = AuthState.initial;
  UserModel? _currentUser;
  String? _errorMessage;

  // Getters
  AuthState get state => _state;
  UserModel? get currentUser => _currentUser;
  bool get isAuthenticated => _state == AuthState.authenticated;
  bool get isLoading => _state == AuthState.loading;
  bool get hasError => _state == AuthState.error;
  String? get errorMessage => _errorMessage;

  AuthProvider({AuthRepository? repository})
      : _repository = repository ??
            AuthRepository(authService: AuthService());

  /// Inicia sesión con usuario y contraseña
  Future<bool> login(String username, String password) async {
    try {
      _setState(AuthState.loading);
      _clearError();

      final user = await _repository.login(
        username: username,
        password: password,
      );

      _currentUser = user;
      _setState(AuthState.authenticated);
      return true;
    } catch (e) {
      _handleError('Error en login: ${e.toString()}');
      return false;
    }
  }

  /// Cierra la sesión del usuario actual
  Future<bool> logout() async {
    try {
      _setState(AuthState.loading);
      final success = await _repository.logout();

      if (success) {
        _currentUser = null;
        _setState(AuthState.unauthenticated);
        return true;
      } else {
        _handleError('Error al cerrar sesión');
        return false;
      }
    } catch (e) {
      _handleError('Error en logout: ${e.toString()}');
      return false;
    }
  }

  /// Registra un nuevo usuario
  Future<bool> register({
    required String name,
    required String email,
    required String username,
    required String password,
    required String phone,
  }) async {
    try {
      _setState(AuthState.loading);
      _clearError();

      final user = await _repository.register(
        name: name,
        email: email,
        username: username,
        password: password,
        phone: phone,
      );

      _currentUser = user;
      _setState(AuthState.authenticated);
      return true;
    } catch (e) {
      _handleError('Error en registro: ${e.toString()}');
      return false;
    }
  }

  // Métodos privados
  void _setState(AuthState newState) {
    _state = newState;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
  }

  void _handleError(String message) {
    _errorMessage = message;
    _setState(AuthState.error);
  }
}
