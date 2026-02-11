/// Abstraction used so we can support desktop SQLite and Mobile SQLflite.
/// distinctions will be with how project manages the encrypted database.
/// desktops will decrypt db, read data into a in-memory db.
/// while android will write the decrypted db to a protected file (don't worry - all fields are encrypted except category and title)
abstract class EncryptilockDatabase {
  Future<void> open();
  Future<void> close();

  Future<void> createTableIfNotExists(String table, Map<String, String> schema);

  Future<void> insert(String table, Map<String, dynamic> values);
  Future<void> batchInsert(String table, List<Map<String, dynamic>> rows);

  Future<void> update(
    String table,
    Map<String, dynamic> values, {
    required String whereClause,
    required List<Object?> whereArgs,
  });

  Future<void> upsert(String table, Map<String, dynamic> values, List<String> conflictColumns);
  Future<void> batchUpsert(String table, List<Map<String, dynamic>> rows, List<String> conflictColumns);

  Future<void> delete(String table, String whereClause, List<Object?> whereArgs);
  Future<List<Map<String, dynamic>>> query(String sql, [List<Object?> params = const []]);

  Future<void> executeCommand(String sql, [List<Object?> params = const []]);
  Future<int?> getBatchNo(String tableName, String incrField);
}
