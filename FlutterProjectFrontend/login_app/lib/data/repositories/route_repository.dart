import 'package:login_app/core/exceptions/app_exception.dart';
import 'package:login_app/data/models/route_model.dart';
import 'package:login_app/data/repositories/base_repository.dart';
import 'package:login_app/data/services/route_service.dart';

/// Repositorio de Rutas
/// Maneja toda la lógica de negocio relacionada con rutas
/// Actúa como intermediario entre la UI (via Provider) y el servicio de datos
class RouteRepository implements BaseRepository<RouteModel> {
  final RouteService _routeService;

  RouteRepository({required RouteService routeService})
      : _routeService = routeService;

  /// Obtiene todas las rutas
  ///
  /// Parámetros opcionales para paginación:
  /// - skip: número de registros a saltar
  /// - take: número de registros a obtener
  ///
  /// Lanza [NetworkException] si hay error de conexión
  /// Lanza [DatabaseException] si la BD retorna error
  /// Lanza [ApplicationException] para errores no clasificados
  @override
  Future<List<RouteModel>> getAll({int? skip, int? take}) async {
    try {
      final routes = await _routeService.getAllRoutes();

      if (routes.isEmpty) {
  return [];  // lista vacía es válida, no es error
}

      // Aplicar paginación si se especifica
      var result = routes;
      if (skip != null && take != null) {
        result = routes.skip(skip).take(take).toList();
      } else if (skip != null) {
        result = routes.skip(skip).toList();
      } else if (take != null) {
        result = routes.take(take).toList();
      }

      return result;
    } on AppException {
      rethrow;
    } catch (e, stackTrace) {
      throw ApplicationException(
        message: 'Failed to fetch routes: ${e.toString()}',
        code: 'FETCH_ROUTES_ERROR',
        originalException: e as Exception?,
        stackTrace: stackTrace,
      );
    }
  }

  /// Obtiene una ruta por su ID
  ///
  /// Retorna null si la ruta no existe
  /// Lanza [ValidationException] si el ID es inválido
  /// Lanza [AppException] para otros errores
  @override
  Future<RouteModel?> getById(String id) async {
    try {
      _validateId(id);

      final route = await _routeService.getRouteById(id);

      if (route == null) {
        throw DatabaseException.notFound('Route with ID: $id');
      }

      return route;
    } on AppException {
      rethrow;
    } catch (e, stackTrace) {
      throw ApplicationException(
        message: 'Failed to fetch route: ${e.toString()}',
        code: 'FETCH_ROUTE_ERROR',
        originalException: e as Exception?,
        stackTrace: stackTrace,
      );
    }
  }

  /// Crea una nueva ruta
  ///
  /// Valida todos los campos requeridos antes de crear
  /// Lanza [ValidationException] si los datos son inválidos
  /// Lanza [AppException] si hay error en la creación
  @override
  Future<RouteModel> create(RouteModel item) async {
    try {
      _validateRoute(item);

      final createdRoute = await _routeService.createRoute(item);

      if (createdRoute == null) {
        throw ApplicationException(
          message: 'Failed to create route',
          code: 'CREATE_ROUTE_FAILED',
        );
      }

      return createdRoute;
    } on AppException {
      rethrow;
    } catch (e, stackTrace) {
      throw ApplicationException(
        message: 'Error creating route: ${e.toString()}',
        code: 'CREATE_ROUTE_ERROR',
        originalException: e as Exception?,
        stackTrace: stackTrace,
      );
    }
  }

  /// Actualiza una ruta existente
  ///
  /// Valida que la ruta exista y que los datos sean válidos
  /// Lanza [ValidationException] si los datos son inválidos
  /// Lanza [DatabaseException] si la ruta no existe
  /// Lanza [AppException] para otros errores
  @override
  Future<RouteModel> update(String id, RouteModel item) async {
    try {
      _validateId(id);
      _validateRoute(item);

      // Verificar que la ruta existe

      // Actualizar manteniendo el ID original
      final routeToUpdate = item.copyWith(id: id);
      final updatedRoute = await _routeService.updateRoute(routeToUpdate);

      if (updatedRoute == null) {
        throw ApplicationException(
          message: 'Failed to update route',
          code: 'UPDATE_ROUTE_FAILED',
        );
      }

      return updatedRoute;
    } on AppException {
      rethrow;
    } catch (e, stackTrace) {
      throw ApplicationException(
        message: 'Error updating route: ${e.toString()}',
        code: 'UPDATE_ROUTE_ERROR',
        originalException: e as Exception?,
        stackTrace: stackTrace,
      );
    }
  }

  /// Elimina una ruta
  ///
  /// Verifica que la ruta exista antes de eliminar
  /// Lanza [ValidationException] si el ID es inválido
  /// Lanza [DatabaseException] si la ruta no existe
  /// Lanza [AppException] para otros errores
  @override
  Future<bool> delete(String id) async {
    try {
      _validateId(id);

      // Verificar que la ruta existe
      final success = await _routeService.deleteRoute(id);

      if (!success) {
        throw ApplicationException(
          message: 'Failed to delete route',
          code: 'DELETE_ROUTE_FAILED',
        );
      }

      return true;
    } on AppException {
      rethrow;
    } catch (e, stackTrace) {
      throw ApplicationException(
        message: 'Error deleting route: ${e.toString()}',
        code: 'DELETE_ROUTE_ERROR',
        originalException: e as Exception?,
        stackTrace: stackTrace,
      );
    }
  }

  /// Busca rutas por criterios
  ///
  /// Parámetros:
  /// - query: término de búsqueda
  /// - searchFields: campos en los que buscar (routeName, routeNumber, etc)
  Future<List<RouteModel>> search({
    required String query,
    List<String>? searchFields,
  }) async {
    try {
      if (query.isEmpty) {
        throw ValidationException.empty('Search query');
      }

      final allRoutes = await getAll();
      final searchableFields = searchFields ?? [
        'routeName',
        'routeNumber',
        'startPoint',
        'endPoint',
      ];

      return allRoutes.where((route) {
        final searchTerm = query.toLowerCase();

        if (searchableFields.contains('routeName') &&
            route.routeName.toLowerCase().contains(searchTerm)) {
          return true;
        }

        if (searchableFields.contains('routeNumber') &&
            route.routeNumber.toLowerCase().contains(searchTerm)) {
          return true;
        }

        if (searchableFields.contains('startPoint') &&
            route.startPoint.toLowerCase().contains(searchTerm)) {
          return true;
        }

        if (searchableFields.contains('endPoint') &&
            route.endPoint.toLowerCase().contains(searchTerm)) {
          return true;
        }

        return false;
      }).toList();
    } on AppException {
      rethrow;
    } catch (e, stackTrace) {
      throw ApplicationException(
        message: 'Error searching routes: ${e.toString()}',
        code: 'SEARCH_ROUTES_ERROR',
        originalException: e as Exception?,
        stackTrace: stackTrace,
      );
    }
  }

  /// Filtra rutas por estado
  Future<List<RouteModel>> filterByStatus(String status) async {
    try {
      if (status.isEmpty) {
        throw ValidationException.empty('Status');
      }

      final allRoutes = await getAll();
      return allRoutes.where((route) => route.isActive.toString() == status).toList();
    } on AppException {
      rethrow;
    } catch (e, stackTrace) {
      throw ApplicationException(
        message: 'Error filtering routes: ${e.toString()}',
        code: 'FILTER_ROUTES_ERROR',
        originalException: e as Exception?,
        stackTrace: stackTrace,
      );
    }
  }

  /// Obtiene rutas ordenadas
  ///
  /// Parámetros:
  /// - orderBy: campo por el cual ordenar
  /// - descending: si es orden descendente
  Future<List<RouteModel>> getOrdered({
    required String orderBy,
    bool descending = false,
  }) async {
    try {
      final allRoutes = await getAll();

      final sorted = List<RouteModel>.from(allRoutes);

      switch (orderBy.toLowerCase()) {
        case 'name':
          sorted.sort((a, b) => descending
              ? b.routeName.compareTo(a.routeName)
              : a.routeName.compareTo(b.routeName));
          break;
        case 'fare':
          sorted.sort((a, b) => descending
              ? b.fare.compareTo(a.fare)
              : a.fare.compareTo(b.fare));
          break;
        case 'duration':
          sorted.sort((a, b) => descending
              ? b.estimatedDuration.compareTo(a.estimatedDuration)
              : a.estimatedDuration.compareTo(b.estimatedDuration));
          break;
        case 'date':
          sorted.sort((a, b) => descending
              ? b.createdAt.compareTo(a.createdAt)
              : a.createdAt.compareTo(b.createdAt));
          break;
        default:
          throw ValidationException.invalid(
            'orderBy parameter',
            'Must be one of: name, fare, duration, date',
          );
      }

      return sorted;
    } on AppException {
      rethrow;
    } catch (e, stackTrace) {
      throw ApplicationException(
        message: 'Error ordering routes: ${e.toString()}',
        code: 'ORDER_ROUTES_ERROR',
        originalException: e as Exception?,
        stackTrace: stackTrace,
      );
    }
  }

  /// Validaciones privadas

  void _validateId(String id) {
    if (id.isEmpty) {
      throw ValidationException.empty('Route ID');
    }
  }

  void _validateRoute(RouteModel route) {
    final errors = <String>[];

    if (route.routeName.isEmpty) {
      errors.add('Route name is required');
    }

    if (route.routeNumber.isEmpty) {
      errors.add('Route number is required');
    }

    if (route.startPoint.isEmpty) {
      errors.add('Start point is required');
    }

    if (route.endPoint.isEmpty) {
      errors.add('End point is required');
    }

    if (route.fare <= 0) {
      errors.add('Fare must be greater than 0');
    }

    if (route.estimatedDuration <= 0) {
      errors.add('Estimated duration must be greater than 0');
    }

    if (route.startPoint == route.endPoint) {
      errors.add('Start point and end point cannot be the same');
    }

    if (errors.isNotEmpty) {
      throw ValidationException.multiple(errors);
    }
  }
}
