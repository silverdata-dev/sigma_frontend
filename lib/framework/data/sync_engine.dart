import '../core/framework_core.dart';
import 'dart:async';

/// Motor de sincronización con soporte para Transaction Log y Re-mapping de IDs.
class SyncEngine {
  final List<SyncOperation> _transactionLog = [];
  final StreamController<List<SyncOperation>> _logController = StreamController.broadcast();

  Stream<List<SyncOperation>> get logStream => _logController.stream;

  /// Añade una operación al log.
  void addOperation(SyncOperation op) {
    _transactionLog.add(op);
    _logController.add(List.unmodifiable(_transactionLog));
  }

  /// Reemplaza IDs temporales por IDs reales en todo el log de transacciones.
  /// Esto es vital para mantener la integridad referencial tras una creación exitosa en el servidor.
  void remapIds(String tempId, String realId) {
    for (var i = 0; i < _transactionLog.length; i++) {
      final op = _transactionLog[i];
      
      // 1. Reemplazar en el ID de la operación si coincide.
      final newOpId = op.id == tempId ? realId : op.id;

      // 2. Escanear recursivamente el payload para reemplazar referencias.
      final newPayload = _recursiveRemap(op.payload, tempId, realId);

      _transactionLog[i] = SyncOperation(
        id: newOpId,
        entityType: op.entityType,
        type: op.type,
        payload: newPayload,
        timestamp: op.timestamp,
      );
    }
    _logController.add(List.unmodifiable(_transactionLog));
  }

  dynamic _recursiveRemap(dynamic data, String tempId, String realId) {
    if (data is String) {
      return data == tempId ? realId : data;
    } else if (data is Map<String, dynamic>) {
      return data.map((key, value) => MapEntry(key, _recursiveRemap(value, tempId, realId)));
    } else if (data is List) {
      return data.map((item) => _recursiveRemap(item, tempId, realId)).toList();
    }
    return data;
  }

  List<SyncOperation> get pendingOperations => List.unmodifiable(_transactionLog);

  void clearLog() {
    _transactionLog.clear();
    _logController.add([]);
  }
}

/// Orquestador que coordina la persistencia local y remota.
class DataOrchestrator {
  final DataProvider localProvider;
  final DataProvider remoteProvider;
  final SyncEngine syncEngine;

  DataOrchestrator({
    required this.localProvider,
    required this.remoteProvider,
    required this.syncEngine,
  });

  /// Ejecuta una operación guardando localmente primero (Offline-First).
  Future<void> save(FrameworkEntity entity, {bool isNew = false}) async {
    // 1. Guardar localmente inmediatamente.
    if (isNew) {
      await localProvider.create(entity);
    } else {
      await localProvider.update(entity);
    }

    // 2. Registrar en el log de sincronización.
    syncEngine.addOperation(SyncOperation(
      id: entity.id,
      entityType: entity.runtimeType.toString(),
      type: isNew ? OperationType.create : OperationType.update,
      payload: entity.toJson(),
    ));

    // 3. Intentar sincronización en segundo plano (simplificado para este ejemplo).
    _processSync();
  }

  Future<void> _processSync() async {
    // Aquí iría la lógica de reintento, manejo de errores de red, etc.
  }
}
