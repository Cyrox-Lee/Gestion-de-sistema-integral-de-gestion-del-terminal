import 'package:login_app/core/exceptions/app_exception.dart';
import 'package:login_app/data/models/user_model.dart';
import 'package:login_app/data/services/auth_service.dart';

/// Repositorio de Autenticación
/// Maneja toda la lógica de autenticación y autorización
class AuthRepository {
  final AuthService _authService;

  AuthRepository({required AuthService authService}) : _authService = authService;

  /// Inicia sesión con credenciales
  Future<UserModel> login({
    required String username,
    required String password,
  }) async {
    try {
      _validateCredentials(username, password);

      final response = await _authService.login(
        username: username,
        password: password,
      );

      if (!response['success']) {
        throw AuthException.invalidCredentials();
      }

      final userData = response['user'] ?? {};
      return UserModel(
        id: userData['id'].toString(),
        name: '${userData['first_name']} ${userData['last_name']}'.trim(),
        email: userData['email'] ?? '',
        username: userData['username'] ?? '',
        phone: userData['phone'] ?? '',
        role: userData['role'] ?? 'visitor',
        createdAt: DateTime.tryParse(userData['created_at'] ?? '') ?? DateTime.now(),
      );
    } on AppException {
      rethrow;
    } catch (e) {
      throw ApplicationException(
        message: 'Login failed: ${e.toString()}',
        code: 'LOGIN_ERROR',
      );
    }
  }

  /// Registra un nuevo usuario
  Future<UserModel> register({
    required String name,
    required String email,
    required String username,
    required String password,
    required String phone,
  }) async {
    try {
      _validateRegistrationData(name, email, username, password);

      final nameParts = name.split(' ');
      final firstName = nameParts.first;
      final lastName = nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '';

      final response = await _authService.register(
        username: username,
        email: email,
        firstName: firstName,
        lastName: lastName,
        phone: phone,
        password: password,
        password2: password,
      );

      if (!response['success']) {
        throw ApplicationException(
          message: response['error'] ?? 'Registration failed',
          code: 'REGISTRATION_ERROR',
        );
      }

      final userData = response['data']['user'] ?? response['data'] ?? {};
      return UserModel(
        id: userData['id'].toString(),
        name: name,
        email: email,
        username: username,
        phone: phone,
        role: 'visitor',
        createdAt: DateTime.now(),
      );
    } on AppException {
      rethrow;
    } catch (e) {
      throw ApplicationException(
        message: 'Registration failed: ${e.toString()}',
        code: 'REGISTRATION_ERROR',
      );
    }
  }

  /// Cierra la sesión del usuario actual
  Future<bool> logout() async {
    try {
      final success = await _authService.logout();
      if (!success) {
        throw ApplicationException(
          message: 'Failed to logout',
          code: 'LOGOUT_FAILED',
        );
      }
      return true;
    } on AppException {
      rethrow;
    } catch (e) {
      throw ApplicationException(
        message: 'Logout failed: ${e.toString()}',
        code: 'LOGOUT_ERROR',
      );
    }
  }

  /// Obtiene el usuario autenticado actualmente
  Future<UserModel?> getCurrentUser() async {
    try {
      final response = await _authService.checkSession();
      
      if (!response['authenticated']) {
        return null;
      }

      final userData = response['user'] ?? {};
      return UserModel(
        id: userData['id'].toString(),
        name: '${userData['first_name']} ${userData['last_name']}'.trim(),
        email: userData['email'] ?? '',
        username: userData['username'] ?? '',
        phone: userData['phone'] ?? '',
        role: userData['role'] ?? 'visitor',
        createdAt: DateTime.tryParse(userData['created_at'] ?? '') ?? DateTime.now(),
      );
    } catch (e) {
      throw ApplicationException(
        message: 'Failed to fetch current user: ${e.toString()}',
        code: 'GET_USER_ERROR',
      );
    }
  }

  /// Envía email de recuperación de contraseña
  Future<bool> resetPassword(String email) async {
    try {
      if (email.isEmpty) {
        throw ValidationException.empty('Email');
      }
      if (!_isValidEmail(email)) {
        throw ValidationException.invalid('Email', 'Invalid format');
      }
      // TODO: Implementar endpoint de reseteo de contraseña
      return true;
    } on AppException {
      rethrow;
    } catch (e) {
      throw ApplicationException(
        message: 'Password reset failed: ${e.toString()}',
        code: 'RESET_PASSWORD_ERROR',
      );
    }
  }

  /// Cambia la contraseña del usuario autenticado
  Future<bool> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    try {
      if (oldPassword.isEmpty) {
        throw ValidationException.empty('Old password');
      }
      _validatePassword(newPassword);
      // TODO: Implementar endpoint de cambio de contraseña
      return true;
    } on AppException {
      rethrow;
    } catch (e) {
      throw ApplicationException(
        message: 'Change password failed: ${e.toString()}',
        code: 'CHANGE_PASSWORD_ERROR',
      );
    }
  }

  // Validaciones privadas
  void _validateCredentials(String username, String password) {
    final errors = <String>[];
    if (username.isEmpty) errors.add('Username is required');
    if (password.isEmpty) errors.add('Password is required');
    if (errors.isNotEmpty) {
      throw ValidationException.multiple(errors);
    }
  }

  void _validateRegistrationData(
    String name,
    String email,
    String username,
    String password,
  ) {
    final errors = <String>[];
    if (name.isEmpty) errors.add('Name is required');
    if (name.length < 3) errors.add('Name must be at least 3 characters');
    if (email.isEmpty) errors.add('Email is required');
    if (!_isValidEmail(email)) errors.add('Invalid email format');
    if (username.isEmpty) errors.add('Username is required');
    if (username.length < 3) errors.add('Username must be at least 3 characters');
    errors.addAll(_getPasswordErrors(password));
    if (errors.isNotEmpty) {
      throw ValidationException.multiple(errors);
    }
  }

  List<String> _getPasswordErrors(String password) {
    final errors = <String>[];
    if (password.isEmpty) errors.add('Password is required');
    if (password.length < 8) errors.add('Password must be at least 8 characters');
    if (!RegExp(r'[A-Z]').hasMatch(password)) {
      errors.add('Password must contain at least one uppercase letter');
    }
    if (!RegExp(r'[a-z]').hasMatch(password)) {
      errors.add('Password must contain at least one lowercase letter');
    }
    if (!RegExp(r'[0-9]').hasMatch(password)) {
      errors.add('Password must contain at least one number');
    }
    return errors;
  }

  void _validatePassword(String password) {
    final errors = _getPasswordErrors(password);
    if (errors.isNotEmpty) {
      throw ValidationException.multiple(errors);
    }
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }
}