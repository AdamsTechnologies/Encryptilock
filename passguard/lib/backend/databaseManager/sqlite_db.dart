import 'dart:ffi'; // For FFI (this is typically needed by sqlite3)
import 'dart:io';

import 'package:sqlite3/sqlite3.dart';

/// A high-level SQLite class that wraps the [sqlite3] library.
/// It supports opening a database (file-based or in-memory),
/// executing queries/commands, and doing common CRUD operations.
class DartSqlite {
  final String dbFile;        // Path to the DB file; use ':memory:' for in-memory
  Database? db;              // The underlying sqlite3 Database
  bool _isOpen = false;

  /// [dbFile]: Pass a valid path to open or create a file-based database.
  ///           If you want an in-memory DB, pass `':memory:'`.
  DartSqlite({required this.dbFile});

  /// Opens the connection if not already open.
  void open() {
    if (_isOpen) return;

    // If dbFile == ':memory:', it opens an in-memory DB.
    // Otherwise, it opens or creates a file-based DB.
    db = sqlite3.open(dbFile);
    _isOpen = true;
  }

  /// Closes the connection if open.
  void close() {
    if (!_isOpen) return;
    db?.dispose();
    _isOpen = false;
  }

  /// Ensures the DB is open before any operation.
  void _checkOpen() {
    if (!_isOpen || db == null) {
      throw StateError('Database is not open. Call open() before usage.');
    }
  }

  // ---------------------------------------------------------------------------
  //    Basic Execution Methods
  // ---------------------------------------------------------------------------

  /// Executes a SQL command that doesn't return rows (e.g., CREATE TABLE, DROP, etc.).
  /// [sql] can contain '?' placeholders. [params] is a list of values to bind.
  void executeCommand(String sql, [List<Object?> params = const []]) {
    _checkOpen();
    if (params.isEmpty) {
      db!.execute(sql);
    } else {
      final stmt = db!.prepare(sql);
      try {
        stmt.execute(params);
      } finally {
        stmt.dispose();
      }
    }
  }

  /// Executes a SELECT or other query that returns rows.
  /// Returns a List of Maps for convenience, akin to how Python might return a list of dicts.
  List<Map<String, dynamic>> query(String sql, [List<Object?> params = const []]) {
    _checkOpen();
    final stmt = db!.prepare(sql);
    try {
      final result = stmt.select(params);
      return _resultToMaps(result);
    } finally {
      stmt.dispose();
    }
  }

  // ---------------------------------------------------------------------------
  //    Create Table if not exists
  // ---------------------------------------------------------------------------

  /// Creates a table if it doesn't exist, using the provided [schema].
  /// Example:
  ///   schema = {
  ///     'id': 'INTEGER PRIMARY KEY',
  ///     'name': 'TEXT NOT NULL'
  ///   }
  /// => CREATE TABLE IF NOT EXISTS tableName (id INTEGER PRIMARY KEY, name TEXT NOT NULL)
  void createTableIfNotExists(String tableName, Map<String, String> schema) {
    _checkOpen();
    final columns = schema.entries.map((e) => '${e.key} ${e.value}').join(', ');
    final sql = 'CREATE TABLE IF NOT EXISTS $tableName ($columns)';
    db!.execute(sql);
  }

  // ---------------------------------------------------------------------------
  //    INSERT
  // ---------------------------------------------------------------------------

  /// Inserts a single row into [table]. Returns nothing, but you can query `lastInsertRowId` after if needed.
  /// [values] is a columnName -> value map.
  void insert(String table, Map<String, dynamic> values) {
    _checkOpen();

    final columns = values.keys.toList();
    final placeholders = List.filled(columns.length, '?').join(', ');
    final sql = 'INSERT INTO $table (${columns.join(', ')}) VALUES ($placeholders)';

    final stmt = db!.prepare(sql);
    try {
      stmt.execute(values.values.toList());
    } finally {
      stmt.dispose();
    }
  }

  /// Batch insert multiple rows in a single transaction for efficiency.
  /// The [rows] list must not be empty. Each map must have the same columns.
  void batchInsert(String table, List<Map<String, dynamic>> rows) {
    if (rows.isEmpty) return;

    _checkOpen();
    final columns = rows.first.keys.toList();
    final placeholders = List.filled(columns.length, '?').join(', ');
    final sql = 'INSERT INTO $table (${columns.join(', ')}) VALUES ($placeholders)';

    // We'll do this in a manual transaction for speed.
    db!.execute('BEGIN');
    final stmt = db!.prepare(sql);
    try {
      for (final row in rows) {
        stmt.execute(row.values.toList());
      }
      stmt.dispose();
      db!.execute('COMMIT');
    } catch (e) {
      db!.execute('ROLLBACK');
      rethrow;
    }
  }

  // ---------------------------------------------------------------------------
  //    UPDATE
  // ---------------------------------------------------------------------------

  /// Updates rows in [table] according to [whereClause].
  /// e.g. update('users', {'name': 'Bob'}, 'id = ?', [123]);
  /// => UPDATE users SET name=? WHERE id=?
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

    final params = [...values.values, ...whereArgs];
    final stmt = db!.prepare(sql);
    try {
      stmt.execute(params);
    } finally {
      stmt.dispose();
    }
  }

  /// Batch update multiple rows in a single transaction.
  /// Each row's data must match an entry in [whereArgsList].
  /// e.g., batchUpdate('users',
  ///   [
  ///     {'name': 'Alice'},
  ///     {'name': 'Bob'},
  ///   ],
  ///   whereClause: 'id = ?',
  ///   whereArgsList: [
  ///     [1],
  ///     [2],
  ///   ]
  /// )
  void batchUpdate(
    String table,
    List<Map<String, dynamic>> rows, {
    required String whereClause,
    required List<List<Object?>> whereArgsList,
  }) {
    _checkOpen();

    if (rows.isEmpty) return;
    if (rows.length != whereArgsList.length) {
      throw ArgumentError('rows.length must match whereArgsList.length');
    }

    // We'll assume each row has the same columns
    final columns = rows.first.keys.toList();
    final setClause = columns.map((col) => '$col = ?').join(', ');

    final sql = 'UPDATE $table SET $setClause WHERE $whereClause';
    db!.execute('BEGIN');
    final stmt = db!.prepare(sql);
    try {
      for (int i = 0; i < rows.length; i++) {
        final rowValues = rows[i].values.toList();
        final params = [...rowValues, ...whereArgsList[i]];
        stmt.execute(params);
      }
      stmt.dispose();
      db!.execute('COMMIT');
    } catch (e) {
      db!.execute('ROLLBACK');
      rethrow;
    }
  }

  // ---------------------------------------------------------------------------
  //    UPSERT
  // ---------------------------------------------------------------------------

  /// Performs an "INSERT ... ON CONFLICT(columns) DO UPDATE SET ..."
  /// This requires that [conflictColumns] is a unique index or PK in your table schema.
  /// e.g. upsert('users', {'id': 123, 'name': 'Alice'}, ['id']);
  /// => INSERT INTO users (id,name) VALUES (?,?)
  ///    ON CONFLICT(id) DO UPDATE SET name=excluded.name
  void upsert(String table, Map<String, dynamic> values, List<String> conflictColumns) {
    _checkOpen();
    if (values.isEmpty) return;

    final columns = values.keys.toList();
    final placeholders = List.filled(columns.length, '?').join(', ');
    final conflictClause = conflictColumns.join(', ');

    // We skip conflict columns from the update if we don't want to override them,
    // but typically you'd skip them anyway.
    final updateCols = columns.where((c) => !conflictColumns.contains(c)).toList();
    final updateAssignments = updateCols.map((c) => '$c = excluded.$c').join(', ');

    // If there's nothing to update, we can do "DO NOTHING"
    final doUpdateOrNothing = updateAssignments.isNotEmpty
        ? 'DO UPDATE SET $updateAssignments'
        : 'DO NOTHING';

    final sql = '''
      INSERT INTO $table (${columns.join(', ')})
      VALUES ($placeholders)
      ON CONFLICT($conflictClause)
      $doUpdateOrNothing
    ''';

    final stmt = db!.prepare(sql);
    try {
      stmt.execute(values.values.toList());
    } finally {
      stmt.dispose();
    }
  }

  // ---------------------------------------------------------------------------
  //    DELETE
  // ---------------------------------------------------------------------------

  /// Deletes rows matching [whereClause]. e.g. delete('users', 'id = ?', [123])
  void delete(String table, String whereClause, List<Object?> whereArgs) {
    _checkOpen();
    final sql = 'DELETE FROM $table WHERE $whereClause';
    final stmt = db!.prepare(sql);
    try {
      stmt.execute(whereArgs);
    } finally {
      stmt.dispose();
    }
  }

  /// Batch delete multiple rows in one transaction.
  /// e.g. batchDelete('users', 'id = ?', [[1], [2], [3]]);
  void batchDelete(String table, String whereClause, List<List<Object?>> argsList) {
    if (argsList.isEmpty) return;
    _checkOpen();

    final sql = 'DELETE FROM $table WHERE $whereClause';

    db!.execute('BEGIN');
    final stmt = db!.prepare(sql);
    try {
      for (final args in argsList) {
        stmt.execute(args);
      }
      stmt.dispose();
      db!.execute('COMMIT');
    } catch (e) {
      db!.execute('ROLLBACK');
      rethrow;
    }
  }

  // ---------------------------------------------------------------------------
  //    Private Helpers
  // ---------------------------------------------------------------------------

  /// Converts a [ResultSet] from sqlite3 to a List<Map<String, dynamic>>
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
}
