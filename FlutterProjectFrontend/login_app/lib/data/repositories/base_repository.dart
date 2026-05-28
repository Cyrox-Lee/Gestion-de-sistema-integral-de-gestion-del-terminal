import 'package:login_app/core/exceptions/app_exception.dart';

/// Interfaz base para todos los repositorios
/// Define el contrato CRUD que todos los repositorios deben implementar
abstract class BaseRepository<T> {
  /// Obtiene todos los registros de tipo T
  ///
  /// Lanza [AppException] si ocurre un error
  Future<List<T>> getAll({int? skip, int? take});

  /// Obtiene un registro por ID
  ///
  /// Retorna null si no existe
  /// Lanza [AppException] si ocurre un error
  Future<T?> getById(String id);

  /// Crea un nuevo registro
  ///
  /// Lanza [ValidationException] si los datos son inválidos
  /// Lanza [AppException] si ocurre un error en la creación
  Future<T> create(T item);

  /// Actualiza un registro existente
  ///
  /// Lanza [ValidationException] si los datos son inválidos
  /// Lanza [DatabaseException] si no existe el registro
  /// Lanza [AppException] si ocurre un error en la actualización
  Future<T> update(String id, T item);

  /// Elimina un registro
  ///
  /// Lanza [DatabaseException] si no existe el registro
  /// Lanza [AppException] si ocurre un error en la eliminación
  Future<bool> delete(String id);
}
