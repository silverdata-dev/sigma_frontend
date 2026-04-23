import '../core/framework_core.dart';
import 'local/local_database.dart';
import 'local/local_store.dart';
import 'remote/remote_provider.dart';
import 'sync/sync_queue.dart';
import 'sync/sync_engine.dart';
import 'base_repository.dart' show AppDeps, BaseRepository;

/// Generic entity wrapper for JSON payloads from the API.
class DynamicEntity implements FrameworkEntity {
  @override
  final String id;
  final Map<String, dynamic> data;

  DynamicEntity({required this.id, required this.data});

  @override
  Map<String, dynamic> toJson() => data;
}

class AppFramework {
  static final AppFramework _instance = AppFramework._internal();
  factory AppFramework() => _instance;

  final Map<String, LocalStore> _storeRegistry = {};
  final Map<String, BaseRepository> _repositories = {};
  late final Future<AppDeps> _deps;

  AppFramework._internal() {
    _deps = _initialize();
  }

  Future<AppDeps> _initialize() async {
    await LocalDatabase.instance;
    final queue = await SyncQueue.create();
    final remote = const RemoteProvider();
    final engine = SyncEngine.create(
      remote: remote,
      queue: queue,
      storeRegistry: _storeRegistry,
    );
    engine.start();
    return AppDeps(syncQueue: queue, syncEngine: engine, remote: remote);
  }

  /// Returns a [BaseRepository] for the given endpoint. Synchronous — init happens lazily.
  BaseRepository getRepository(String endpoint) {
    return _repositories.putIfAbsent(
      endpoint,
      () => BaseRepository.create(
        endpoint: endpoint,
        deps: _deps,
        storeRegistry: _storeRegistry,
      ),
    );
  }
}
