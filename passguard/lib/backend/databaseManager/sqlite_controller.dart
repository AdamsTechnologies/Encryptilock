import 'dart:async';
import 'package:passguard/backend/databaseManager/sqlite_db.dart';

class SQLiteController {
  late DartSqlite database;
  Map<String, String>? schema;
  List<String>? upsertKeys;
  String? tableName;
  int? batchId;
  bool verboseLogging;
  void Function(String)? logger;

  final Map<String, String> typeMapping = {
    'nvarchar': 'TEXT',
    'varchar': 'TEXT',
    'char': 'TEXT',
    'bit': 'INTEGER',
    'datetime': 'TEXT',
    'int': 'INTEGER',
    'bigint': 'INTEGER',
    'float': 'REAL',
    'decimal': 'REAL',
    'money': 'REAL',
    'uniqueidentifier': 'TEXT',
    'binary': 'BLOB',
    'varbinary': 'BLOB',
  };

  SQLiteController({
    required String dbFile,
    DartSqlite? db,
    this.verboseLogging = true,
    this.logger,
    this.schema,
    this.tableName,
    this.upsertKeys,
  }) {
    database = db ?? _establishConnection(dbFile);
  }

  /// Establishes a new DartSqlite connection
  DartSqlite _establishConnection(String dbFile) {
    final db = DartSqlite(dbFile: dbFile);
    db.open();
    return db;
  }

  /// Converts SQL92 schema to SQLite-compatible schema
  Future<Map<String, String>> convertSchema(Map<String, String>? inputSchema) async {
    final activeSchema = inputSchema ?? schema ?? {};
    final convertedSchema = <String, String>{};

    for (var entry in activeSchema.entries) {
      String columnName = entry.key;
      String columnType = entry.value;
      final addons = <String>[];

      if (columnType.contains('NOT NULL')) {
        columnType = columnType.replaceAll('NOT NULL', '').trim();
        addons.add('NOT NULL');
      }
      if (columnType.contains('UNIQUE')) {
        columnType = columnType.replaceAll('UNIQUE', '').trim();
        addons.add('UNIQUE');
      }
      if (columnType.contains('PRIMARY KEY')) {
        columnType = columnType.replaceAll('PRIMARY KEY', '').trim();
        addons.add('PRIMARY KEY');
      }

      final sqliteType = typeMapping[columnType.split('(')[0].trim()] ?? 'TEXT';
      convertedSchema[columnName] = '$sqliteType ${addons.join(' ')}'.trim();
    }

    schema = convertedSchema;
    return convertedSchema;
  }

  /// Creates a table if it doesn't already exist
  Future<void> createTableIfNotExists(String tableName, Map<String, String> schema) async {
    final convertedSchema = await convertSchema(schema);
    database.createTableIfNotExists(tableName, convertedSchema);
    _logMessage('Table $tableName created successfully.');
  }

  /// Appends data in batches
  Future<void> appendData(String tableName, List<Map<String, dynamic>> data,
      {String? incrField, int batchSize = 1000}) async {
    if (data.isEmpty) {
      _logMessage('No data provided for processing.');
      return;
    }

    if (incrField != null) {
      final batchNo = await getBatchNo(tableName, incrField);
      data = data.map((row) => {...row, incrField: batchNo}).toList();
    }

    for (int i = 0; i < data.length; i += batchSize) {
      final batchData = data.sublist(i, i + batchSize > data.length ? data.length : i + batchSize);
      database.batchInsert(tableName, batchData);
    }

    _logMessage('Appended ${data.length} rows to $tableName.');
  }

  /// Upserts data into the table
  Future<void> upsertData(
      String tableName, List<Map<String, dynamic>> data, List<String> uniqueKeys,
      {String? incrField}) async {
    if (data.isEmpty) {
      _logMessage('No data provided for upserting.');
      return;
    }

    if (incrField != null) {
      final batchNo = await getBatchNo(tableName, incrField);
      data = data.map((row) => {...row, incrField: batchNo}).toList();
    }

    for (final row in data) {
      database.upsert(tableName, row, uniqueKeys);
    }

    _logMessage('Upserted ${data.length} rows to $tableName.');
  }

  /// Retrieves all items from the table
  Future<List<Map<String, dynamic>>> getAllItems(String tableName) async {
    return database.query('SELECT * FROM $tableName');
  }

  /// Logs a message
  void _logMessage(String message) {
    if (verboseLogging) {
      if (logger != null) {
        logger!(message);
      } else {
        print(message);
      }
    }
  }

  /// Retrieves the next batch number for a table
  Future<int?> getBatchNo(String tableName, String incrField) async {
    try {
      final result = database.query(
        'SELECT COALESCE(MAX($incrField), 0) + 1 AS max_batch_no FROM $tableName',
      );
      return result.isNotEmpty ? result.first['max_batch_no'] as int? : 1;
    } catch (e) {
      _logMessage('Error getting batch number: $e');
      return null;
    }
  }

  /// Closes the database connection
  void close() {
    database.close();
    _logMessage('Database connection closed.');
  }
}
