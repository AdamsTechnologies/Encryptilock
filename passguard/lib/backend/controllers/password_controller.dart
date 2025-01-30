import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:passguard/backend/devsec/encrypto.dart'; // Or your actual EncryptionInterface
import 'package:passguard/backend/databaseManager/dart_sqlite.dart'; // Your existing SQLiteController

/// A simple controller for storing and retrieving password records.
/// Depends on:
///  - `SQLiteController` for DB operations
///  - `EncryptionInterface` (e.g., `Encrypto`) for encryption.
class PasswordController {
  //TODO Add note field!!
  /// The underlying SQLite controller that handles queries, upserts, etc.
  final DartSqlite dbController;

  /// Provides encryption/decryption methods (`encrypt`, `decrypt`, etc.).
  final Encrypto encrypto;

  /// Table name in SQLite where password records are stored (defaults to "pm").
  final String tableName;

  /// The columns that uniquely identify a record. Usually ["id"].
  final List<String> uniqueKeys;

  /// If you want to create a table on initialization, you can store the schema here.
  /// For example:
  /// {
  ///   "id": "nvarchar(50) PRIMARY KEY",
  ///   "username": "nvarchar(256)",
  ///   "password": "nvarchar(256)",
  ///   "service": "nvarchar(1000)",
  ///   "servicetype": "nvarchar(1000)",
  ///   "isactive": "bit",
  ///   "url": "nvarchar(MAX) NULL",
  ///   "dt": "datetime"
  /// }
  final Map<String, String>? schema;

  PasswordController({
    required this.dbController,
    required this.encrypto,
    this.tableName = 'pm',
    this.uniqueKeys = const [
      'id'
    ],
    this.schema,
  });

  /// Optionally call this after constructing the controller, to ensure
  /// the table is created if it doesn't exist.
  /// e.g.:
  ///   await passwordController.init();
  Future<void> init() async {
    if (schema != null) {
      // Create table if not exists
      dbController.createTableIfNotExists(tableName, schema!);
    }
  }

  /// Retrieves a single field from the record, typically the 'password'.
  /// If [decrypt] is true, the returned field is decrypted.
  Future<String?> getPassword(String id, {bool decrypt = false}) async {
    // We'll rely on a method like "getItem" or a raw query from the dbController.
    // Adjust as needed to match your 'getItem' logic in SQLiteController
    // or a raw query approach.
    final record = await _getRecordById(id);
    if (record == null) {
      throw Exception("No record found for id=$id");
    }
    final encValue = record['password'] as String?;

    if (encValue == null) return null;
    if (decrypt == true) {
      return await encrypto.decrypto(encValue);
    } else {
      return encValue;
    }
  }

  /// Retrieves the entire record by [id]. If [decryptFields] is provided,
  /// those fields are decrypted in the returned map.
  Future<Map<String, dynamic>?> getRecord(String id, {List<String>? decryptFields}) async {
    final record = await _getRecordById(id);
    if (record == null) return null;

    if (decryptFields != null) {
      for (final field in decryptFields) {
        final value = record[field];
        if (value is String) {
          record[field] = await encrypto.decrypto(value);
        }
      }
    }
    return record;
  }

  /// Retrieves all records in the table. If [decryptFields] is provided,
  /// decrypt those fields in each record.
  Future<List<Map<String, dynamic>>> getAllRecords({List<String>? decryptFields}) async {
    final sql = "SELECT * FROM $tableName";
    final results = dbController.query(sql);
    // getAllItems presumably returns List<Map<String, dynamic>>
    if (decryptFields == null || decryptFields.isEmpty) {
      return results;
    }
    for (final record in results) {
      for (final field in decryptFields) {
        final value = record[field];
        if (value is String) {
          record[field] = await encrypto.decrypto(value);
        }
      }
    }
    return results;
  }

  /// Upserts a password record.
  /// If [id] is not provided, we generate one.
  /// The password is encrypted before storing.
  Future<String> upsertRecord({
    String? id,
    required String username,
    required String password,
    String? service,
    String? servicetype,
    String? url,
    String? notes,
    String? createdt,
    bool passwordChanged = false,
    int isactive = 1,
  }) async {
    id ??= _generateUniqueId();
    final now = DateTime.now().toUtc().toIso8601String();
    String pass;
    if (passwordChanged) {
      pass = await encrypto.encrypto(password);
    } else {
      pass = password;
    }

    print("upsertRecord encryptedPass: $pass");
    // Create the row data
    final row = <String, dynamic>{
      // TODO align schemas..
      'id': id,
      'username': username,
      'password': pass,
      'service': service,
      'servicetype': servicetype,
      'url': url,
      "notes": notes,
      'isactive': isactive,
      'createdt': createdt ?? now,
      'updatedt': now,
    };
    print("PasswordController upsertRecord: $row");
    dbController.upsert(
      tableName,
      row,
      uniqueKeys,
    );
    return id;
  }

  /// Upserts multiple password records, ignoring errors or logging them.
  Future<void> upsertMultipleRecords(List<Map<String, dynamic>> data) async {
    // We can transform each record, encrypting `password`.
    final transformedData = <Map<String, dynamic>>[];
    for (final item in data) {
      final clone = Map<String, dynamic>.from(item);
      clone['id'] ??= _generateUniqueId();
      if (clone['password'] is String) {
        // TODO check this logic.
        clone['password'] = await encrypto.encrypto(clone['password'] as String);
      }
      clone['updatedt'] = DateTime.now().toUtc().toIso8601String();
      transformedData.add(clone);
    }
    // Then pass them in one go, if we want:
    // or do a loop if we want to handle errors individually.

    dbController.batchUpsert(tableName, transformedData, uniqueKeys);
  }

  /// Removes a record by [id].
  Future<void> removeRecord(String id) async {
    print("deleting record, id: $id");
    dbController.delete(tableName, "id = ?", [
      id
    ]);
  }

  // --------------------------------------------------------------------------
  // INTERNALS
  // --------------------------------------------------------------------------

  /// Retrieves a record by [id], returning a Map<String, dynamic> or null if not found.
  Future<Map<String, dynamic>?> _getRecordById(String id) async {
    // We can do a raw query via dbController:
    final sql = "SELECT * FROM $tableName WHERE id = ?";
    final results = dbController.query(sql, [
      id
    ]);
    if (results.isEmpty) return null;
    return results.first;
  }

  /// Generates a random pseudo-unique ID.
  /// Alternatively, TODO you can store a real UUID from a library,
  /// or rely on your DB to auto-generate.
  String _generateUniqueId() {
    print("generating a new UUID");
    final random = Random.secure();
    final bytes = List<int>.generate(16, (_) => random.nextInt(256));
    return base64Url.encode(bytes).replaceAll('=', '');
  }
}
