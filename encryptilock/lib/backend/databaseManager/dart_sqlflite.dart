import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class SqfliteSqlite {
  final String dbFile; // just the filename, e.g. 's1.db'
  Database? _db;

  SqfliteSqlite({required this.dbFile});

  Future<void> open() async {
    if (_db != null) return;
    final docs = await getApplicationDocumentsDirectory();
    final path = join(docs.path, dbFile);
    _db = await openDatabase(path, version: 1);
  }

  Future<void> close() async {
    if (_db != null) {
      await _db!.close();
      _db = null;
    }
  }

  void _checkOpen() {
    if (_db == null) throw Exception('Database not opened');
  }

  Future<void> createTableIfNotExists(String table, Map<String, String> schema) async {
    _checkOpen();
    final columns = schema.entries.map((e) => '${e.key} ${e.value}').join(', ');
    final sql = 'CREATE TABLE IF NOT EXISTS $table ($columns)';
    await _db!.execute(sql);
  }

  Future<void> insert(String table, Map<String, dynamic> values) async {
    _checkOpen();
    await _db!.insert(table, values);
  }

  Future<void> batchInsert(String table, List<Map<String, dynamic>> rows) async {
    _checkOpen();
    final batch = _db!.batch();
    for (final row in rows) {
      batch.insert(table, row);
    }
    await batch.commit(noResult: true);
  }

  Future<void> update(
    String table,
    Map<String, dynamic> values, {
    required String whereClause,
    required List<Object?> whereArgs,
  }) async {
    _checkOpen();
    await _db!.update(table, values, where: whereClause, whereArgs: whereArgs);
  }

  Future<List<Map<String, dynamic>>> query(String sql, [List<Object?> params = const []]) async {
    _checkOpen();
    return await _db!.rawQuery(sql, params);
  }

  Future<void> executeCommand(String sql, [List<Object?> params = const []]) async {
    _checkOpen();
    if (params.isEmpty) {
      await _db!.execute(sql);
    } else {
      await _db!.rawQuery(sql, params);
    }
  }

  Future<void> delete(String table, String whereClause, List<Object?> whereArgs) async {
    _checkOpen();
    await _db!.delete(table, where: whereClause, whereArgs: whereArgs);
  }

  Future<void> upsert(String table, Map<String, dynamic> values, List<String> conflictColumns) async {
    _checkOpen();
    await _db!.insert(
      table,
      values,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> batchUpsert(String table, List<Map<String, dynamic>> rows, List<String> conflictColumns) async {
    _checkOpen();
    final batch = _db!.batch();
    for (final row in rows) {
      batch.insert(table, row, conflictAlgorithm: ConflictAlgorithm.replace);
    }
    await batch.commit(noResult: true);
  }

  Future<int?> getBatchNo(String table, String field) async {
    _checkOpen();
    final result = await query('SELECT COALESCE(MAX($field), 0) + 1 AS max_batch_no FROM $table');
    if (result.isNotEmpty) {
      return result.first['max_batch_no'] as int?;
    }
    return 1;
  }

  Database get database {
    _checkOpen();
    return _db!;
  }
}
