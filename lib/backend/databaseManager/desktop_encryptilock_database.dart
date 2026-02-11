import 'package:encryptilock/backend/databaseManager/database_abstraction.dart';
import 'package:encryptilock/backend/databaseManager/dart_sqlite.dart';

class DesktopEncryptilockDatabase implements EncryptilockDatabase {
  final DartSqlite _db;

  DesktopEncryptilockDatabase(this._db);
  DartSqlite get database => _db;

  @override
  Future<void> open() async => _db.open();

  @override
  Future<void> close() async => _db.close();

  @override
  Future<void> createTableIfNotExists(String table, Map<String, String> schema) async => _db.createTableIfNotExists(table, schema);

  @override
  Future<void> insert(String table, Map<String, dynamic> values) async => _db.insert(table, values);

  @override
  Future<void> batchInsert(String table, List<Map<String, dynamic>> rows) async => _db.batchInsert(table, rows);

  @override
  Future<void> update(
    String table,
    Map<String, dynamic> values, {
    required String whereClause,
    required List<Object?> whereArgs,
  }) async =>
      _db.update(table, values, whereClause: whereClause, whereArgs: whereArgs);

  @override
  Future<void> upsert(String table, Map<String, dynamic> values, List<String> conflictColumns) async => _db.upsert(table, values, conflictColumns);

  @override
  Future<void> batchUpsert(String table, List<Map<String, dynamic>> rows, List<String> conflictColumns) async => _db.batchUpsert(table, rows, conflictColumns);

  @override
  Future<void> delete(String table, String whereClause, List<Object?> whereArgs) async => _db.delete(table, whereClause, whereArgs);

  @override
  Future<List<Map<String, dynamic>>> query(String sql, [List<Object?> params = const []]) async => _db.query(sql, params);

  @override
  Future<void> executeCommand(String sql, [List<Object?> params = const []]) async => _db.executeCommand(sql, params);

  @override
  Future<int?> getBatchNo(String tableName, String incrField) async => _db.getBatchNo(tableName, incrField);
}
