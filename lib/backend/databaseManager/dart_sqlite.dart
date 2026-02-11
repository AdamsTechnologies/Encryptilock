import 'package:sqlite3/sqlite3.dart';

/// A consolidated class that wraps [sqlite3] for easy database operations,
/// including table creation, inserts, upserts, batch operations, etc.
class DartSqlite {
  final String dbFile; // Path to the DB file; use ':memory:' for in-memory
  Database? _db; // The underlying sqlite3 Database
  bool _isOpen = false;

  DartSqlite({
    required this.dbFile,
  });

  // ---------------------------------------------------------------------------
  //   OPEN / CLOSE
  // ---------------------------------------------------------------------------

  /// Opens the connection if not already open.
  void open() {
    if (_isOpen) return;
    _db = sqlite3.open(dbFile);
    _isOpen = true;
  }

  /// Closes the connection if open.
  void close() {
    if (!_isOpen || _db == null) return;
    _db!.dispose();
    _db = null;
    _isOpen = false;
  }

  /// Ensures the DB is open before any operation.
  void _checkOpen() {
    if (!_isOpen || _db == null) {
      throw StateError('Database is not open. Call open() before usage.');
    }
  }

  // ---------------------------------------------------------------------------
  //   CREATE TABLE
  // ---------------------------------------------------------------------------

  /// Creates a table if it doesn't exist, with the given schema.
  /// Example:
  /// ```
  /// createTableIfNotExists('pm', {
  ///   'id': 'TEXT PRIMARY KEY',
  ///   'password': 'TEXT',
  ///   ...
  /// });
  /// ```
  void createTableIfNotExists(String tableName, Map<String, String> schema) {
    _checkOpen();
    final columns = schema.entries.map((e) => '${e.key} ${e.value}').join(', ');
    final sql = 'CREATE TABLE IF NOT EXISTS $tableName ($columns)';
    _db!.execute(sql);
  }

  // ---------------------------------------------------------------------------
  //   EXEC / QUERY
  // ---------------------------------------------------------------------------

  /// Executes a SQL command (no returned rows).
  /// e.g. "CREATE TABLE...", "DROP TABLE...", etc.
  void executeCommand(String sql, [List<Object?> params = const []]) {
    _checkOpen();
    if (params.isEmpty) {
      _db!.execute(sql);
    } else {
      final stmt = _db!.prepare(sql);
      try {
        stmt.execute(params);
      } finally {
        stmt.dispose();
      }
    }
  }

  /// Executes a SELECT or other query that returns rows.
  /// Returns a List of Maps for convenience.
  List<Map<String, dynamic>> query(String sql, [List<Object?> params = const []]) {
    _checkOpen();
    final stmt = _db!.prepare(sql);
    try {
      final resultSet = stmt.select(params);
      return _resultToMaps(resultSet);
    } finally {
      stmt.dispose();
    }
  }

  // ---------------------------------------------------------------------------
  //   INSERT
  // ---------------------------------------------------------------------------

  /// Inserts a single row. [values] is a map of columnName -> value.
  void insert(String table, Map<String, dynamic> values) {
    _checkOpen();
    final columns = values.keys.toList();
    final placeholders = List.filled(columns.length, '?').join(', ');
    final sql = 'INSERT INTO $table (${columns.join(', ')}) VALUES ($placeholders)';

    final stmt = _db!.prepare(sql);
    try {
      stmt.execute(values.values.toList());
    } finally {
      stmt.dispose();
    }
  }

  /// Batch insert. The [rows] list must share the same columns.
  void batchInsert(String table, List<Map<String, dynamic>> rows) {
    if (rows.isEmpty) return;
    _checkOpen();

    final columns = rows.first.keys.toList();
    final placeholders = List.filled(columns.length, '?').join(', ');
    final sql = 'INSERT INTO $table (${columns.join(', ')}) VALUES ($placeholders)';

    _db!.execute('BEGIN');
    final stmt = _db!.prepare(sql);
    try {
      for (final row in rows) {
        stmt.execute(row.values.toList());
      }
      stmt.dispose();
      _db!.execute('COMMIT');
    } catch (e) {
      _db!.execute('ROLLBACK');
      rethrow;
    }
  }

  // ---------------------------------------------------------------------------
  //   UPDATE
  // ---------------------------------------------------------------------------

  /// Update rows with a whereClause, binding [whereArgs].
  /// e.g. update('users', {'name': 'Bob'}, whereClause: 'id=?', whereArgs: [123]);
  void update(
    String table,
    Map<String, dynamic> values, {
    required String whereClause,
    required List<Object?> whereArgs,
  }) {
    _checkOpen();
    if (values.isEmpty) return;

    final setClause = values.keys.map((col) => '$col = ?').join(', ');
    final sql = 'UPDATE $table SET $setClause WHERE $whereClause';
    final params = [
      ...values.values,
      ...whereArgs
    ];

    final stmt = _db!.prepare(sql);
    try {
      stmt.execute(params);
    } finally {
      stmt.dispose();
    }
  }

  // ---------------------------------------------------------------------------
  //   UPSERT
  // ---------------------------------------------------------------------------

  /// Upsert logic using "INSERT ... ON CONFLICT(...)" approach.
  /// [values]: e.g. {'id': 'abc', 'password': 'secret'}
  /// [conflictColumns]: e.g. ['id']
  void upsert(String table, Map<String, dynamic> values, List<String> conflictColumns) {
    _checkOpen();
    if (values.isEmpty) return;

    final columns = values.keys.toList();
    final placeholders = List.filled(columns.length, '?').join(', ');
    final conflictClause = conflictColumns.join(', ');

    // columns that are not part of conflict
    final updateCols = columns.where((c) => !conflictColumns.contains(c)).toList();
    final updateAssignments = updateCols.map((c) => '$c=excluded.$c').join(', ');

    final doUpdateOrNothing = updateAssignments.isNotEmpty ? 'DO UPDATE SET $updateAssignments' : 'DO NOTHING';

    final sql = '''
      INSERT INTO $table (${columns.join(', ')})
      VALUES ($placeholders)
      ON CONFLICT($conflictClause)
      $doUpdateOrNothing
    ''';

    final stmt = _db!.prepare(sql);
    try {
      stmt.execute(values.values.toList());
    } finally {
      stmt.dispose();
    }
  }

  /// Upsert multiple rows, each with the same [conflictColumns].
  void batchUpsert(String table, List<Map<String, dynamic>> rows, List<String> conflictColumns) {
    _checkOpen();
    for (final row in rows) {
      upsert(table, row, conflictColumns);
    }
  }

  // ---------------------------------------------------------------------------
  //   DELETE
  // ---------------------------------------------------------------------------

  /// Delete rows by a whereClause.
  void delete(String table, String whereClause, List<Object?> whereArgs) {
    _checkOpen();
    final sql = 'DELETE FROM $table WHERE $whereClause';
    final stmt = _db!.prepare(sql);
    try {
      stmt.execute(whereArgs);
    } finally {
      stmt.dispose();
    }
  }

  // ---------------------------------------------------------------------------
  //   GET MAX BATCH NO
  // ---------------------------------------------------------------------------

  /// Retrieves "COALESCE(MAX($incrField),0)+1" from the table, if you have
  int? getBatchNo(String tableName, String incrField) {
    _checkOpen();
    try {
      final result = query('SELECT COALESCE(MAX($incrField), 0) + 1 AS max_batch_no FROM $tableName');
      if (result.isNotEmpty) {
        return result.first['max_batch_no'] as int?;
      }
      return 1;
    } catch (e) {
      return null;
    }
  }

  // ---------------------------------------------------------------------------
  //   Private Helpers
  // ---------------------------------------------------------------------------

  /// Convert the resultSet => a List of Maps
  List<Map<String, dynamic>> _resultToMaps(ResultSet result) {
    final columnNames = result.columnNames;
    final rows = <Map<String, dynamic>>[];
    for (final row in result) {
      final rowMap = <String, dynamic>{};
      for (int i = 0; i < columnNames.length; i++) {
        rowMap[columnNames[i]] = row[i];
      }
      rows.add(rowMap);
    }
    return rows;
  }

  Database get database {
    if (_db == null) {
      throw Exception("Database has not been initialized");
    }
    return _db!;
  }
}
