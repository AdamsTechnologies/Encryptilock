import 'dart:io';
import 'dart:typed_data';
// import 'package:sqflite/sqflite.dart'; //TODO confirm.
import 'package:sqflite_common_ffi/sqflite_ffi.dart';


// FRESH DB EXAMPLE
// final bytes = await File('example.db').readAsBytes();
// final db = SQLite(dbFile: '', inMemory: true, dbBytes: bytes);
// Loads database into memory
// final results = await db.query('Test');

// READ DB BYTES INTO MEMORY ONLY
// final db = SQLite(dbFile: '', inMemory: true);
// Fresh in-memory database
// await db.executeCommand('CREATE TABLE Test (id INTEGER PRIMARY KEY, name TEXT)');

// READ AND WRITE STANDARD DB FILE
// final db = SQLite(dbFile: 'example.db');
// Standard file-based database
// await db.executeCommand('CREATE TABLE Test (id INTEGER PRIMARY KEY, name TEXT)');


class SQLite {
  final String dbFile; // Path to the database file (ignored if inMemory is true)
  final bool inMemory; // Whether the database is in-memory only
  final Uint8List? dbBytes; // Optional: Byte stream to initialize an in-memory database
  Database? _db;

  SQLite({
    required this.dbFile,
    this.inMemory = false,
    this.dbBytes,
  }) {
    // Initialize sqflite_common_ffi for desktop platforms
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }
  }

  /// Opens a connection to the database
  Future<void> _openConnection() async {
    if (_db != null) return;

    try {
      if (inMemory) {
        // Create an in-memory database
        _db = await openDatabase(':memory:');
        if (dbBytes != null) {
          // Load the provided byte stream into the in-memory database
          await _loadBytesToMemory(dbBytes!);
        }
      } else {
        // Open or create a physical database file
        _db = await openDatabase(dbFile, version: 1);
      }
    } catch (e) {
      throw Exception('Failed to open database: $e');
    }
  }

  /// Closes the database connection
  Future<void> close() async {
    if (_db != null) {
      await _db!.close();
      _db = null;
    }
  }

  /// Exposes the raw sqflite database object - go on, do something cool.
  Future<Database> get rawDatabase async {
    await _openConnection();
    return _db!;
  }

  /// Check if table exists, create if not.
  Future<void> createTableIfNotExists({
    required String tableName,
    required Map<String, String> schema,
  }) async {
    await _openConnection();
    // Generate the CREATE TABLE IF NOT EXISTS statement
    final columns = schema.entries
        .map((entry) => '${entry.key} ${entry.value}')
        .join(', ');

    final sql = 'CREATE TABLE IF NOT EXISTS $tableName ($columns)';
    // Execute the command
    await _db!.execute(sql);
  }

  /// -----------QUERY-----------
  Future<List<Map<String, dynamic>>> query(
    String table, {
    bool? distinct,
    List<String>? columns,
    String? where,
    List<Object?>? whereArgs,
    String? groupBy,
    String? having,
    String? orderBy,
    int? limit,
    int? offset,
  }) async {
    await _openConnection();
    try {
      return await _db!.query(
        table,
        distinct: distinct,
        columns: columns,
        where: where,
        whereArgs: whereArgs,
        groupBy: groupBy,
        having: having,
        orderBy: orderBy,
        limit: limit,
        offset: offset,
      );
    } catch (e) {
      throw Exception('Query failed: $e');
    }
  }

  /// -----------RAWQUERY-----------
  Future<List<Map<String, dynamic>>> rawQuery(String sql, [List<Object?>? arguments]) async {
    await _openConnection();
    try {
      return await _db!.rawQuery(sql, arguments);
    } catch (e) {
      throw Exception('RawQuery failed: $e');
    }
  }

  /// -----------INSERT-----------
  Future<int> insert({
    required String table,
    required Map<String, dynamic> values,
    ConflictAlgorithm conflictAlgorithm = ConflictAlgorithm.abort,
  }) async {
    await _openConnection();
    return await _db!.insert(
      table,
      values,
      conflictAlgorithm: conflictAlgorithm,
    );
  }
  /// -----------BATCH INSERT-----------
  Future<void> batchInsert({
    required String tableName,
    required List<Map<String, dynamic>> data,
    ConflictAlgorithm conflictAlgorithm = ConflictAlgorithm.abort,
  }) async {
    if (data.isEmpty) return;

    await _openConnection();
    final batch = _db!.batch();

    for (var row in data) {
      batch.insert(
        tableName,
        row,
        conflictAlgorithm: conflictAlgorithm,
      );
    }

    await batch.commit(noResult: true);
  }

  /// -----------UPDATE-----------
  Future<int> update({
    required String table,
    required Map<String, dynamic> values,
    required String where,
    required List<Object?> whereArgs,
    ConflictAlgorithm conflictAlgorithm = ConflictAlgorithm.abort,
  }) async {
    await _openConnection();
    return await _db!.update(
      table,
      values,
      where: where,
      whereArgs: whereArgs,
      conflictAlgorithm: conflictAlgorithm,
    );
  }

  /// -----------BATCH UPDATE-----------
  Future<void> batchUpdate({
    required String tableName,
    required List<Map<String, dynamic>> data,
    required String whereClause,
    required List<List<Object?>> whereArgsList,
    ConflictAlgorithm conflictAlgorithm = ConflictAlgorithm.abort,
  }) async {
    if (data.isEmpty || whereArgsList.isEmpty || data.length != whereArgsList.length) {
      throw ArgumentError('Data and whereArgsList must have the same length and cannot be empty.');
    }

    await _openConnection();
    final batch = _db!.batch();

    for (int i = 0; i < data.length; i++) {
      batch.update(
        tableName,
        data[i],
        where: whereClause,
        whereArgs: whereArgsList[i],
        conflictAlgorithm: conflictAlgorithm,
      );
    }

    await batch.commit(noResult: true);
  }
  /// -----------UPSERT-----------
  Future<void> upsert({
    required String table,
    required Map<String, dynamic> values,
    required List<String> conflictColumns,
  }) async {
    await _openConnection();

    // Generate the `ON CONFLICT` clause
    final conflictClause = conflictColumns.map((col) => col).join(', ');

    // Generate the `DO UPDATE` clause
    final updateClause = values.keys
        .where((key) => !conflictColumns.contains(key)) // Exclude conflict columns
        .map((key) => '$key = excluded.$key')
        .join(', ');

    // Prepare the SQL statement
    final sql = '''
      INSERT INTO $table (${values.keys.join(', ')})
      VALUES (${List.filled(values.length, '?').join(', ')})
      ON CONFLICT($conflictClause)
      DO UPDATE SET $updateClause;
    ''';

    // Execute the upsert operation
    await _db!.rawInsert(sql, values.values.toList());
  }

  /// -----------BATCH UPSERT-----------
  Future<void> batchUpsert({
    required String table,
    required List<Map<String, dynamic>> data,
    required List<String> conflictColumns,
  }) async {
    await _openConnection();

    final conflictClause = conflictColumns.map((col) => col).join(', ');
    final columnNames = data.first.keys.join(', ');
    final updateClause = data.first.keys
        .where((key) => !conflictColumns.contains(key))
        .map((key) => '$key = excluded.$key')
        .join(', ');

    final sql = '''
      INSERT INTO $table ($columnNames)
      VALUES (${List.filled(data.first.length, '?').join(', ')})
      ON CONFLICT($conflictClause)
      DO UPDATE SET $updateClause;
    ''';

    final batch = _db!.batch();
    for (final row in data) {
      batch.rawInsert(sql, row.values.toList());
    }

    await batch.commit(noResult: true);
  }

  /// -----------DELETE-----------
  Future<int> delete({
    required String table,
    required String where,
    required List<Object?> whereArgs,
  }) async {
    await _openConnection();
    return await _db!.delete(
      table,
      where: where,
      whereArgs: whereArgs,
    );
  }

  /// -----------DELETE-----------
  Future<void> batchDelete({
    required String tableName,
    required List<String> whereClauses,
    required List<List<Object?>> whereArgsList,
  }) async {
    if (whereClauses.isEmpty || whereArgsList.isEmpty || whereClauses.length != whereArgsList.length) {
      throw ArgumentError('WhereClauses and whereArgsList must have the same length and cannot be empty.');
    }

    await _openConnection();
    final batch = _db!.batch();

    for (int i = 0; i < whereClauses.length; i++) {
      batch.delete(
        tableName,
        where: whereClauses[i],
        whereArgs: whereArgsList[i],
      );
    }

    await batch.commit(noResult: true);
  }

  /// Executes SQL commands
  Future<void> executeCommand(String sql, [List<Object?>? arguments]) async {
    await _openConnection();
    try {
      await _db!.execute(sql, arguments);
    } catch (e) {
      throw Exception('SQL execution failed: $e');
    }
  }

  /// Executes multiple commands in a transaction
  Future<void> executeBatch(List<String> sqlCommands) async {
    await _openConnection();
    try {
      await _db!.transaction((txn) async {
        for (final sql in sqlCommands) {
          await txn.execute(sql);
        }
      });
    } catch (e) {
      throw Exception('Batch execution failed: $e');
    }
  }

  /// Loads a database byte stream into memory
  Future<void> _loadBytesToMemory(Uint8List bytes) async {
    // Temporary disk database to load the bytes
    final diskDb = await openDatabase('file:$dbFile?mode=memory&cache=shared');
    await diskDb.transaction((txn) async {
      await txn.execute('BEGIN;');
      final backup = await diskDb.query('sqlite_master');
      for (final row in backup) {
        await txn.execute(row['sql'] as String);
      }
      await txn.execute('COMMIT;');
    });
    await diskDb.close();
  }

  /// Provides a connection manager-like functionality
  Future<T> connectionManager<T>(
    Future<T> Function(Database db) operation,
  ) async {
    await _openConnection();
    try {
      return await operation(_db!);
    } catch (e) {
      throw Exception('Connection operation failed: $e');
    } finally {
      await close();
    }
  }
}