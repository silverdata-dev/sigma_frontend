import 'dart:async';

/// Interfaz base para todas las entidades del framework.
abstract class FrameworkEntity {
  String get id;

  Map<String, dynamic> toJson();
}

/// Proveedor de datos genérico para operaciones CRUD.
abstract class DataProvider<T extends FrameworkEntity> {
  Future<T?> getById(String id);
  Future<List<T>> getAll();
  Future<void> create(T entity);
  Future<void> update(T entity);
  Future<void> delete(String id);

  /// Stream reactivo para cambios en la colección.
  Stream<List<Map<String, dynamic>>> get dataStream;
}

/// Representa una operación en el Transaction Log para sincronización.
enum OperationType { create, update, delete, link }

class SyncOperation {
  final String id;
  final String entityType;
  final OperationType type;
  final Map<String, dynamic> payload;
  final DateTime timestamp;

  SyncOperation({
    required this.id,
    required this.entityType,
    required this.type,
    required this.payload,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  Map<String, dynamic> toJson() => {
    'id': id,
    'entityType': entityType,
    'type': type.name,
    'payload': payload,
    'timestamp': timestamp.toIso8601String(),
  };
}
