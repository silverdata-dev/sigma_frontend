import 'dart:async';
import 'dart:math';
import '../local/local_store.dart';
import '../remote/remote_provider.dart';
import 'sync_queue.dart';

class SyncEngine {
  final RemoteProvider _remote;
  final SyncQueue _queue;
  final Map<String, LocalStore> _storeRegistry;

  Timer? _timer;
  bool _processing = false;

  SyncEngine._({
    required RemoteProvider remote,
    required SyncQueue queue,
    required Map<String, LocalStore> storeRegistry,
  })  : _remote = remote,
        _queue = queue,
        _storeRegistry = storeRegistry;

  static SyncEngine create({
    required RemoteProvider remote,
    required SyncQueue queue,
    required Map<String, LocalStore> storeRegistry,
  }) =>
      SyncEngine._(remote: remote, queue: queue, storeRegistry: storeRegistry);

  void start() {
    _timer ??= Timer.periodic(const Duration(seconds: 30), (_) => process());
    process();
  }

  void stop() {
    _timer?.cancel();
    _timer = null;
  }

  /// Triggers an immediate sync pass. Safe to call multiple times concurrently.
  void trigger() => process();

  Future<void> process() async {
    if (_processing) return;
    _processing = true;
    try {
      SyncOperation? op;
      while ((op = await _queue.nextPending()) != null) {
        await _processOperation(op!);
      }
    } finally {
      _processing = false;
    }
  }

  Future<void> _processOperation(SyncOperation op) async {
    await _queue.markProcessing(op.id);
    try {
      switch (op.method) {
        case SyncMethod.create:
          final serverData = await _remote.create(op.entity, op.payload ?? {});
          final serverId = serverData['id']?.toString();
          if (serverId != null && serverId != op.localId) {
            await _remapId(op.entity, op.localId, serverId, serverData);
          } else if (serverId != null) {
            await _storeRegistry[op.entity]?.upsert(serverId, serverData);
          }

        case SyncMethod.update:
          final id = op.payload?['id']?.toString() ?? op.localId;
          final serverData =
              await _remote.update(op.entity, id, op.payload ?? {});
          await _storeRegistry[op.entity]?.upsert(id, serverData);

        case SyncMethod.delete:
          await _remote.delete(op.entity, op.localId);
      }
      await _queue.markDone(op.id);
    } catch (e) {
      final delay = _backoff(op.retryCount);
      await _queue.markFailed(op.id, e.toString(), DateTime.now().add(delay));
    }
  }

  Future<void> _remapId(
    String entity,
    String tempId,
    String realId,
    Map<String, dynamic> serverData,
  ) async {
    final store = _storeRegistry[entity];
    if (store != null) {
      await store.replaceId(tempId, realId);
      await store.upsert(realId, serverData);
    }
    await _queue.remapLocalId(tempId, realId);
  }

  /// 2^n seconds, capped at 30 minutes.
  Duration _backoff(int retryCount) =>
      Duration(seconds: min(pow(2, retryCount).toInt(), 1800));
}
