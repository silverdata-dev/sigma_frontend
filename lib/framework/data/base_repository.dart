import 'package:uuid/uuid.dart';
import 'local/local_store.dart';
import 'remote/remote_provider.dart';
import 'sync/sync_engine.dart';
import 'sync/sync_queue.dart';

class AppDeps {
  final SyncQueue syncQueue;
  final SyncEngine syncEngine;
  final RemoteProvider remote;

  const AppDeps({
    required this.syncQueue,
    required this.syncEngine,
    required this.remote,
  });
}

class BaseRepository {
  final String endpoint;
  final Future<AppDeps> _deps;
  final Map<String, LocalStore> _storeRegistry;

  LocalStore? _store;
  DateTime? _lastPull;
  static const _pullTtl = Duration(minutes: 5);

  BaseRepository._({
    required this.endpoint,
    required Future<AppDeps> deps,
    required Map<String, LocalStore> storeRegistry,
  })  : _deps = deps,
        _storeRegistry = storeRegistry;

  static BaseRepository create({
    required String endpoint,
    required Future<AppDeps> deps,
    required Map<String, LocalStore> storeRegistry,
  }) =>
      BaseRepository._(
          endpoint: endpoint, deps: deps, storeRegistry: storeRegistry);

  /// Awaits framework initialization and creates entity table on first call.
  Future<(LocalStore, AppDeps)> _ready() async {
    final deps = await _deps;
    if (_store == null) {
      _store = _storeRegistry[endpoint] ?? await LocalStore.create(endpoint);
      _storeRegistry[endpoint] = _store!;
    }
    return (_store!, deps);
  }

  /// Stream that yields current local state on subscribe, then live updates.
  Stream<List<Map<String, dynamic>>> watchAll() async* {
    final (store, _) = await _ready();
    yield* store.watchAll();
  }

  /// Returns local data and triggers a background remote pull if TTL expired.
  Future<List<Map<String, dynamic>>> getAll() async {
    final (store, deps) = await _ready();
    _pullIfStale(store, deps.remote);
    return store.queryAll();
  }

  /// Checks local first; falls back to remote and caches the result.
  Future<Map<String, dynamic>?> findById(String id) async {
    final (store, deps) = await _ready();
    final cached = await store.queryById(id);
    if (cached != null) return cached;
    final remote = await deps.remote.getById(endpoint, id);
    if (remote != null) await store.upsert(remote['id'].toString(), remote);
    return remote;
  }

  /// Local upsert → enqueue PENDING → trigger sync. Returns the local ID.
  Future<String> save(Map<String, dynamic> data) async {
    final (store, deps) = await _ready();
    final isNew = data['id'] == null || data['id'].toString().isEmpty;
    final id = isNew ? const Uuid().v4() : data['id'].toString();
    final record = {...data, 'id': id};

    await store.upsert(id, record);
    await deps.syncQueue.enqueue(
      method: isNew ? SyncMethod.create : SyncMethod.update,
      entity: endpoint,
      localId: id,
      payload: record,
    );
    deps.syncEngine.trigger();
    return id;
  }

  Future<void> delete(String id) async {
    final (store, deps) = await _ready();
    await store.remove(id);
    await deps.syncQueue.enqueue(
      method: SyncMethod.delete,
      entity: endpoint,
      localId: id,
    );
    deps.syncEngine.trigger();
  }

  /// Explicit remote refresh; useful for pull-to-refresh.
  Future<void> pull() async {
    final (store, deps) = await _ready();
    try {
      final records = await deps.remote.getAll(endpoint);
      await store.upsertAll(records);
      _lastPull = DateTime.now();
    } catch (_) {}
  }

  void _pullIfStale(LocalStore store, RemoteProvider remote) {
    final now = DateTime.now();
    if (_lastPull == null || now.difference(_lastPull!) > _pullTtl) {
      pull();
    }
  }
}

