import 'dart:convert';
import '../local/local_database.dart';

enum SyncMethod { create, update, delete }

enum SyncStatus { pending, processing, done, failed }

class SyncOperation {
  final int id;
  final SyncMethod method;
  final String entity;
  final String localId;
  final Map<String, dynamic>? payload;
  final DateTime timestamp;
  final SyncStatus status;
  final int retryCount;
  final DateTime? nextRetryAt;
  final String? errorMessage;

  const SyncOperation({
    required this.id,
    required this.method,
    required this.entity,
    required this.localId,
    this.payload,
    required this.timestamp,
    required this.status,
    required this.retryCount,
    this.nextRetryAt,
    this.errorMessage,
  });

  factory SyncOperation.fromRow(Map<String, dynamic> row) => SyncOperation(
        id: row['id'] as int,
        method: SyncMethod.values.byName(row['method'] as String),
        entity: row['entity'] as String,
        localId: row['local_id'] as String,
        payload: row['payload'] != null
            ? json.decode(row['payload'] as String) as Map<String, dynamic>
            : null,
        timestamp:
            DateTime.fromMillisecondsSinceEpoch(row['timestamp'] as int),
        status: SyncStatus.values.byName(row['status'] as String),
        retryCount: row['retry_count'] as int,
        nextRetryAt: row['next_retry_at'] != null
            ? DateTime.fromMillisecondsSinceEpoch(
                row['next_retry_at'] as int)
            : null,
        errorMessage: row['error_message'] as String?,
      );
}

class SyncQueue {
  final LocalDatabase _db;

  SyncQueue._(this._db);

  static Future<SyncQueue> create() async {
    final db = await LocalDatabase.instance;
    return SyncQueue._(db);
  }

  Future<void> enqueue({
    required SyncMethod method,
    required String entity,
    required String localId,
    Map<String, dynamic>? payload,
  }) async {
    await _db.db.insert('sync_queue', {
      'method': method.name,
      'entity': entity,
      'local_id': localId,
      'payload': payload != null ? json.encode(payload) : null,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
      'status': SyncStatus.pending.name,
      'retry_count': 0,
    });
  }

  /// Returns the next PENDING operation eligible for processing (respects backoff delay).
  Future<SyncOperation?> nextPending() async {
    final now = DateTime.now().millisecondsSinceEpoch;
    final rows = await _db.db.query(
      'sync_queue',
      where: "status = ? AND (next_retry_at IS NULL OR next_retry_at <= ?)",
      whereArgs: [SyncStatus.pending.name, now],
      orderBy: 'timestamp ASC',
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return SyncOperation.fromRow(rows.first);
  }

  Future<void> markProcessing(int id) => _db.db.update(
        'sync_queue',
        {'status': SyncStatus.processing.name},
        where: 'id = ?',
        whereArgs: [id],
      );

  Future<void> markDone(int id) =>
      _db.db.delete('sync_queue', where: 'id = ?', whereArgs: [id]);

  Future<void> markFailed(int id, String error, DateTime nextRetry) async {
    final rows = await _db.db.query(
      'sync_queue',
      columns: ['retry_count'],
      where: 'id = ?',
      whereArgs: [id],
    );
    if (rows.isEmpty) return;
    await _db.db.update(
      'sync_queue',
      {
        'status': SyncStatus.pending.name,
        'retry_count': (rows.first['retry_count'] as int) + 1,
        'next_retry_at': nextRetry.millisecondsSinceEpoch,
        'error_message': error,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Replaces all [tempId] references in pending payloads with [realId].
  /// Uses string substitution on the serialized JSON to avoid full deserialization.
  Future<void> remapLocalId(String tempId, String realId) async {
    final rows = await _db.db.query(
      'sync_queue',
      where: "status = ? AND local_id = ?",
      whereArgs: [SyncStatus.pending.name, tempId],
    );
    for (final row in rows) {
      final raw = row['payload'] as String?;
      await _db.db.update(
        'sync_queue',
        {
          'local_id': realId,
          if (raw != null) 'payload': raw.replaceAll('"$tempId"', '"$realId"'),
        },
        where: 'id = ?',
        whereArgs: [row['id']],
      );
    }
  }

  Future<int> pendingCount() async {
    final result = await _db.db.rawQuery(
      "SELECT COUNT(*) as cnt FROM sync_queue WHERE status = ?",
      [SyncStatus.pending.name],
    );
    return result.first['cnt'] as int;
  }
}
