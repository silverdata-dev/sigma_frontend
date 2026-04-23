import 'dart:async';
import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import 'local_database.dart';

class LocalStore {
  final String entity;
  final LocalDatabase _db;
  final StreamController<List<Map<String, dynamic>>> _controller =
      StreamController.broadcast();

  LocalStore._(this.entity, this._db);

  /// Sanitizes the entity name for use as a SQLite table identifier.
  /// Replaces any character outside [a-zA-Z0-9_] with underscore.
  String get _tableName =>
      'tbl_${entity.replaceAll(RegExp(r'[^a-zA-Z0-9_]'), '_')}';

  static Future<LocalStore> create(String entity) async {
    final db = await LocalDatabase.instance;
    await db.ensureEntityTable(entity);
    return LocalStore._(entity, db);
  }

  /// Emits current DB state immediately on subscribe, then live updates.
  Stream<List<Map<String, dynamic>>> watchAll() async* {
    yield await queryAll();
    await for (final data in _controller.stream) {
      yield data;
    }
  }

  Future<List<Map<String, dynamic>>> queryAll() async {
    final rows = await _db.db.query(_tableName);
    return rows
        .map((r) => json.decode(r['data'] as String) as Map<String, dynamic>)
        .toList();
  }

  Future<Map<String, dynamic>?> queryById(String id) async {
    final rows = await _db.db.query(
      _tableName,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return json.decode(rows.first['data'] as String) as Map<String, dynamic>;
  }

  Future<void> upsert(String id, Map<String, dynamic> data) async {
    await _db.db.insert(
      _tableName,
      {
        'id': id,
        'data': json.encode(data),
        'updated_at': DateTime.now().millisecondsSinceEpoch,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    await _notify();
  }

  Future<void> upsertAll(List<Map<String, dynamic>> records) async {
    if (records.isEmpty) return;
    final now = DateTime.now().millisecondsSinceEpoch;
    final batch = _db.db.batch();
    for (final record in records) {
      final id = record['id']?.toString();
      if (id == null) continue;
      batch.insert(
        _tableName,
        {'id': id, 'data': json.encode(record), 'updated_at': now},
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit(noResult: true);
    await _notify();
  }

  Future<void> remove(String id) async {
    await _db.db.delete(_tableName, where: 'id = ?', whereArgs: [id]);
    await _notify();
  }

  /// Atomically replaces a temporary ID with the server-assigned real ID.
  Future<void> replaceId(String tempId, String realId) async {
    final existing = await queryById(tempId);
    if (existing == null) return;
    final updated = {...existing, 'id': realId};
    await _db.db.transaction((txn) async {
      await txn.delete(_tableName, where: 'id = ?', whereArgs: [tempId]);
      await txn.insert(
        _tableName,
        {
          'id': realId,
          'data': json.encode(updated),
          'updated_at': DateTime.now().millisecondsSinceEpoch,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    });
    await _notify();
  }

  Future<void> _notify() async {
    if (!_controller.hasListener) return;
    _controller.add(await queryAll());
  }

  void dispose() => _controller.close();
}
