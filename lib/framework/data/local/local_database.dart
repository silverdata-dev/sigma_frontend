import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart';

class LocalDatabase {
  static LocalDatabase? _instance;
  Database? _db;

  LocalDatabase._();

  static Future<LocalDatabase> get instance async {
    if (_instance == null) {
      _instance = LocalDatabase._();
      await _instance!._init();
    }
    return _instance!;
  }

  Future<void> _init() async {
    final path = join(await getDatabasesPath(), 'sigma_local.db');
    _db = await openDatabase(
      path,
      version: 1,
      onCreate: (db, _) async {
        await db.execute('''
          CREATE TABLE sync_queue (
            id            INTEGER PRIMARY KEY AUTOINCREMENT,
            method        TEXT    NOT NULL,
            entity        TEXT    NOT NULL,
            local_id      TEXT    NOT NULL,
            payload       TEXT,
            timestamp     INTEGER NOT NULL,
            status        TEXT    NOT NULL DEFAULT 'pending',
            retry_count   INTEGER NOT NULL DEFAULT 0,
            next_retry_at INTEGER,
            error_message TEXT
          )
        ''');
      },
    );
  }

  Database get db => _db!;

  Future<void> ensureEntityTable(String entity) async {
    final table = 'tbl_${entity.replaceAll(RegExp(r'[^a-zA-Z0-9_]'), '_')}';
    await db.execute('''
      CREATE TABLE IF NOT EXISTS $table (
        id         TEXT    PRIMARY KEY,
        data       TEXT    NOT NULL,
        updated_at INTEGER NOT NULL
      )
    ''');
  }
}
