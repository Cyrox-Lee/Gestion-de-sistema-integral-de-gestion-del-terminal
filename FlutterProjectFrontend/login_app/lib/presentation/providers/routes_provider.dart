import 'package:flutter/foundation.dart';
import 'package:login_app/core/exceptions/app_exception.dart';
import 'package:login_app/data/models/route_model.dart';
import 'package:login_app/data/repositories/route_repository.dart';
import 'package:login_app/data/services/route_service.dart';

/// Estados posibles del provider
enum RoutesState {
  initial,
  loading,
  success,
  error,
}

/// Provider para gestionar rutas
/// Maneja el estado y notifica a los listeners cuando cambia
class RoutesProvider extends ChangeNotifier {
  // Dependencias
  final RouteRepository _repository = RouteRepository(
    routeService: RouteService(),
  );

  // Estado
  RoutesState _state = RoutesState.initial;
  List<RouteModel> _routes = [];
  String? _errorMessage;
  String? _successMessage;
  AppException? _exception;

  // Getters
  RoutesState get state => _state;
  List<RouteModel> get routes => _routes;
  bool get isLoading => _state == RoutesState.loading;
  bool get hasError => _state == RoutesState.error;
  bool get isEmpty => _routes.isEmpty;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;
  AppException? get exception => _exception;

  /// Carga todas las rutas desde el repositorio
  ///
  /// Emite estados: loading -> success/error
  Future<void> fetchRoutes() async {
    try {
      _setState(RoutesState.loading);
      _clearMessages();

      _routes = await _repository.getAll();

      _setState(RoutesState.success);
      _successMessage = 'Routes loaded successfully';
    } on AppException catch (e) {
      _handleError(e);
    } catch (e, stackTrace) {
      _handleError(
        ApplicationException(
          message: 'Unexpected error: ${e.toString()}',
          code: 'UNKNOWN_ERROR',
          originalException: e as Exception?,
          stackTrace: stackTrace,
        ),
      );
    }
  }

  /// Obtiene una ruta específica por ID
  ///
  /// Retorna null si no la encuentra o hay error
  Future<RouteModel?> getRouteById(String id) async {
    try {
      _clearMessages();
      return await _repository.getById(id);
    } on AppException catch (e) {
      _errorMessage = e.message;
      _exception = e;
      notifyListeners();
      return null;
    } catch (e) {
      _errorMessage = 'Error fetching route: ${e.toString()}';
      notifyListeners();
      return null;
    }
  }

  /// Crea una nueva ruta
  ///
  /// Emite estados: loading -> success/error
  /// Retorna true si fue exitoso
  Future<bool> createRoute({
    required String routeName,
    required String routeNumber,
    required String startPoint,
    required String endPoint,
    required double fare,
    required int estimatedDuration,
    String? description,
  }) async {
    try {
      _setState(RoutesState.loading);
      _clearMessages();

      final newRoute = RouteModel(
        id: '${DateTime.now().millisecondsSinceEpoch}',
        routeName: routeName,
        routeNumber: routeNumber,
        startPoint: startPoint,
        endPoint: endPoint,
        fare: fare,
        estimatedDuration: estimatedDuration,
        description: description,
        createdAt: DateTime.now(),
        isActive: true,
      );

      final createdRoute = await _repository.create(newRoute);
      _routes = [..._routes, createdRoute];

      _setState(RoutesState.success);
      _successMessage = 'Route created successfully';
      return true;
    } on ValidationException catch (e) {
      _handleValidationError(e);
      return false;
    } on AppException catch (e) {
      _handleError(e);
      return false;
    } catch (e, stackTrace) {
      _handleError(
        ApplicationException(
          message: 'Error creating route: ${e.toString()}',
          code: 'CREATE_ROUTE_ERROR',
          originalException: e as Exception?,
          stackTrace: stackTrace,
        ),
      );
      return false;
    }
  }

  /// Actualiza una ruta existente
  ///
  /// Emite estados: loading -> success/error
  /// Retorna true si fue exitoso
  Future<bool> updateRoute({
    required String id,
    required String routeName,
    required String routeNumber,
    required String startPoint,
    required String endPoint,
    required double fare,
    required int estimatedDuration,
    String? description,
    bool? isActive,
  }) async {
    try {
      _setState(RoutesState.loading);
      _clearMessages();

      final updatedRoute = RouteModel(
        id: id,
        routeName: routeName,
        routeNumber: routeNumber,
        startPoint: startPoint,
        endPoint: endPoint,
        fare: fare,
        estimatedDuration: estimatedDuration,
        description: description,
        createdAt: DateTime.now(),
        isActive: isActive ?? true,
      );

      final result = await _repository.update(id, updatedRoute);

      final index = _routes.indexWhere((r) => r.id == id);
      if (index != -1) {
        _routes[index] = result;
      }

      _setState(RoutesState.success);
      _successMessage = 'Route updated successfully';
      return true;
    } on ValidationException catch (e) {
      _handleValidationError(e);
      return false;
    } on AppException catch (e) {
      _handleError(e);
      return false;
    } catch (e, stackTrace) {
      _handleError(
        ApplicationException(
          message: 'Error updating route: ${e.toString()}',
          code: 'UPDATE_ROUTE_ERROR',
          originalException: e as Exception?,
          stackTrace: stackTrace,
        ),
      );
      return false;
    }
  }

  /// Elimina una ruta
  ///
  /// Emite estados: loading -> success/error
  /// Retorna true si fue exitoso
  Future<bool> deleteRoute(String id) async {
    try {
      _setState(RoutesState.loading);
      _clearMessages();

      await _repository.delete(id);
      _routes = _routes.where((r) => r.id != id).toList();

      _setState(RoutesState.success);
      _successMessage = 'Route deleted successfully';
      return true;
    } on AppException catch (e) {
      _handleError(e);
      return false;
    } catch (e, stackTrace) {
      _handleError(
        ApplicationException(
          message: 'Error deleting route: ${e.toString()}',
          code: 'DELETE_ROUTE_ERROR',
          originalException: e as Exception?,
          stackTrace: stackTrace,
        ),
      );
      return false;
    }
  }

  /// Busca rutas por criterios
  ///
  /// Emite estados: loading -> success/error
  Future<bool> searchRoutes(String query) async {
    try {
      _setState(RoutesState.loading);
      _clearMessages();

      _routes = await _repository.search(query: query);

      _setState(RoutesState.success);
      if (_routes.isEmpty) {
        _successMessage = 'No routes found matching "$query"';
      } else {
        _successMessage = 'Found ${_routes.length} route(s)';
      }
      return true;
    } on ValidationException catch (e) {
      _handleValidationError(e);
      return false;
    } on AppException catch (e) {
      _handleError(e);
      return false;
    } catch (e, stackTrace) {
      _handleError(
        ApplicationException(
          message: 'Error searching routes: ${e.toString()}',
          code: 'SEARCH_ROUTES_ERROR',
          originalException: e as Exception?,
          stackTrace: stackTrace,
        ),
      );
      return false;
    }
  }

  /// Filtra rutas por estado
  ///
  /// Emite estados: loading -> success/error
  Future<bool> filterByStatus(String status) async {
    try {
      _setState(RoutesState.loading);
      _clearMessages();

      _routes = await _repository.filterByStatus(status);

      _setState(RoutesState.success);
      _successMessage = 'Routes filtered by status: $status';
      return true;
    } on AppException catch (e) {
      _handleError(e);
      return false;
    } catch (e, stackTrace) {
      _handleError(
        ApplicationException(
          message: 'Error filtering routes: ${e.toString()}',
          code: 'FILTER_ROUTES_ERROR',
          originalException: e as Exception?,
          stackTrace: stackTrace,
        ),
      );
      return false;
    }
  }

  /// Ordena las rutas actualmente cargadas
  ///
  /// No afecta el servidor, solo el estado local
  /// Parámetros:
  /// - orderBy: campo por el cual ordenar (name, fare, duration, date)
  /// - descending: si debe ser orden descendente
  void sortRoutes({
    required String orderBy,
    bool descending = false,
  }) {
    try {
      _clearMessages();

      final sortedRoutes = List<RouteModel>.from(_routes);

      switch (orderBy.toLowerCase()) {
        case 'name':
          sortedRoutes.sort((a, b) => descending
              ? b.routeName.compareTo(a.routeName)
              : a.routeName.compareTo(b.routeName));
          break;
        case 'fare':
          sortedRoutes.sort((a, b) => descending
              ? b.fare.compareTo(a.fare)
              : a.fare.compareTo(b.fare));
          break;
        case 'duration':
          sortedRoutes.sort((a, b) => descending
              ? b.estimatedDuration.compareTo(a.estimatedDuration)
              : a.estimatedDuration.compareTo(b.estimatedDuration));
          break;
        case 'date':
          sortedRoutes.sort((a, b) => descending
              ? b.createdAt.compareTo(a.createdAt)
              : a.createdAt.compareTo(b.createdAt));
          break;
        default:
          _errorMessage = 'Invalid sort field: $orderBy';
          notifyListeners();
          return;
      }

      _routes = sortedRoutes;
      _successMessage = 'Routes sorted by $orderBy';
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Error sorting routes: ${e.toString()}';
      notifyListeners();
    }
  }

  /// Limpia los mensajes de éxito/error
  void clearMessages() {
    _clearMessages();
  }

  // Métodos privados

  void _setState(RoutesState newState) {
    _state = newState;
    notifyListeners();
  }

  void _clearMessages() {
    _errorMessage = null;
    _successMessage = null;
    _exception = null;
  }

  void _handleError(AppException exception) {
    _exception = exception;
    _errorMessage = exception.message;
    _state = RoutesState.error;
    notifyListeners();
  }

  void _handleValidationError(ValidationException exception) {
    _exception = exception;
    _errorMessage = exception.errors.join(', ');
    _state = RoutesState.error;
    notifyListeners();
  }
}
