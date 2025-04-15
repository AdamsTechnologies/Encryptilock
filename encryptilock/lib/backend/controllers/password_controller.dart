import 'dart:convert';
import 'dart:math';
import 'package:encryptilock/backend/devsec/encrypto.dart';
import 'package:encryptilock/backend/databaseManager/dart_sqlite.dart';

class PasswordController {
  final DartSqlite dbController;
  final Encrypto encrypto;
  final String tableName;
  final List<String> uniqueKeys;
  final Map<String, String>? schema;

  /// Defines which fields should be stored encrypted by default.
  /// Example usage: ['password','username','service','servicetype','url','notes']
  final List<String> encryptedFields;

  PasswordController({
    required this.dbController,
    required this.encrypto,
    this.tableName = 'pm',
    this.uniqueKeys = const [
      'id'
    ],
    this.schema,
    this.encryptedFields = const [
      'password'
    ],
  });

  Future<void> init() async {
    if (schema != null) {
      dbController.createTableIfNotExists(tableName, schema!);
    }
  }

  /// Get a single field (usually 'password'), optionally decrypt it.
  Future<String?> getPassword(String id, {bool decrypt = false}) async {
    final record = await _getRecordById(id);
    if (record == null) {
      throw Exception("No record found for id=$id");
    }
    final encValue = record['password'] as String?;
    if (encValue == null) return null;
    return decrypt ? await encrypto.decrypto(encValue) : encValue;
  }

  /// Retrieves one record by ID. Decrypts [decryptFields] if specified.
  Future<Map<String, dynamic>?> getRecord(
    String id, {
    List<String>? decryptFields,
  }) async {
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

  /// Retrieves all records. Decrypts [decryptFields] if provided.
  Future<List<Map<String, dynamic>>> getAllRecords({
    List<String>? decryptFields,
  }) async {
    final sql = "SELECT * FROM $tableName";
    final results = dbController.query(sql);

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

  /// Upserts a record. Only encrypts fields if they've changed.
  ///
  /// [passwordChanged] is the original boolean for the 'password' field.
  /// [changedFields] is a map indicating if other fields have changed:
  ///   e.g. { 'username': true, 'notes': false }
  ///
  /// If a field is not in [encryptedFields], it's never encrypted.
  /// If a field has not changed, we expect its current DB value is already encrypted,
  /// so we simply pass it through as-is.
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
    Map<String, bool>? changedFields,
  }) async {
    changedFields ??= {};

    // Generate an ID if none provided
    id ??= _generateUniqueId();
    final now = DateTime.now().toUtc().toIso8601String();

    // Build the row with whatever the caller passed in
    final row = <String, dynamic>{
      'id': id,
      'username': username,
      'password': password,
      'service': service,
      'servicetype': servicetype,
      'url': url,
      'notes': notes,
      'isactive': isactive,
      'createdt': createdt ?? now,
      'updatedt': now,
    };

    // For any field in [encryptedFields], we encrypt only if:
    //   - It's the 'password' field and passwordChanged == true, OR
    //   - changedFields[field] == true (meaning user changed the field's value in plaintext)
    //
    // Otherwise, we assume the user is passing in already-encrypted data
    // or it's unchanged, so we leave it alone.
    for (final field in encryptedFields) {
      if (field == 'password') {
        // Same logic you already have
        if (passwordChanged) {
          final newPlain = row['password'];
          if (newPlain is String && newPlain.isNotEmpty) {
            row['password'] = await encrypto.encrypto(newPlain);
          }
        }
      } else {
        final fieldChanged = changedFields[field] ?? false;
        if (fieldChanged) {
          final newPlain = row[field];
          if (newPlain is String && newPlain.isNotEmpty) {
            row[field] = await encrypto.encrypto(newPlain);
          }
        }
      }
    }
    print("changedFields: $changedFields");
    print("row: $row");
    // Upsert into DB
    dbController.upsert(tableName, row, uniqueKeys);
    return id;
  }

  /// Upserts multiple records in batch, always encrypting all fields for simplicity.
  /// If you need "changed fields" logic in batch, you can adapt similarly.
  Future<void> upsertMultipleRecords(List<Map<String, dynamic>> data) async {
    final transformedData = <Map<String, dynamic>>[];

    for (final item in data) {
      final clone = Map<String, dynamic>.from(item);
      clone['id'] ??= _generateUniqueId();
      clone['updatedt'] = DateTime.now().toUtc().toIso8601String();

      // Always encrypt if the field is in encryptedFields and is a non-empty String
      for (final field in encryptedFields) {
        final val = clone[field];
        if (val is String && val.isNotEmpty) {
          clone[field] = await encrypto.encrypto(val);
        }
      }
      transformedData.add(clone);
    }

    dbController.batchUpsert(tableName, transformedData, uniqueKeys);
  }

  Future<void> removeRecord(String id) async {
    dbController.delete(tableName, "id = ?", [
      id
    ]);
  }

  // --------------------------------------------------------------------------
  // INTERNALS
  // --------------------------------------------------------------------------
  Future<Map<String, dynamic>?> _getRecordById(String id) async {
    final sql = "SELECT * FROM $tableName WHERE id = ?";
    final results = dbController.query(sql, [
      id
    ]);
    if (results.isEmpty) return null;
    return results.first;
  }

  String _generateUniqueId() {
    final random = Random.secure();
    final bytes = List<int>.generate(16, (_) => random.nextInt(256));
    return base64Url.encode(bytes).replaceAll('=', '');
  }
}

// import 'dart:convert';
// import 'dart:math';
// import 'dart:typed_data';
// import 'package:encryptilock/backend/devsec/encrypto.dart';
// import 'package:encryptilock/backend/databaseManager/dart_sqlite.dart';

// import 'dart:convert';
// import 'dart:math';
// import 'package:encryptilock/backend/devsec/encrypto.dart';
// import 'package:encryptilock/backend/databaseManager/dart_sqlite.dart';

// /// A simple controller for storing and retrieving password records.
// /// Depends on:
// ///  - `SQLiteController` for DB operations
// ///  - `EncryptionInterface` (e.g., `Encrypto`) for encryption.
// class PasswordController {
//   /// The underlying SQLite controller that handles queries, upserts, etc.
//   final DartSqlite dbController;

//   /// Provides encryption/decryption methods (`encrypt`, `decrypt`, etc.).
//   final Encrypto encrypto;

//   /// Table name in SQLite where password records are stored (defaults to "pm").
//   final String tableName;

//   /// The columns that uniquely identify a record. Usually ["id"].
//   final List<String> uniqueKeys;

//   /// If you want to create a table on initialization, you can store the schema here.
//   /// Example:
//   /// {
//   ///       'id': id,
//   ///       'username': username,
//   ///       'password': password,
//   ///       'service': service,
//   ///       'servicetype': servicetype,
//   ///       'url': url,
//   ///       'notes': notes,
//   ///       'isactive': isactive,
//   ///       'createdt': createdt ?? now,
//   ///       'updatedt': now,
//   /// };
//   final Map<String, String>? schema;

//   /// Defines which fields should be stored encrypted by default
//   /// (besides special handling for `password` with `passwordChanged`).
//   ///
//   /// Example usage:
//   ///   encryptedFields: ['password', 'username', 'url', 'notes']
//   final List<String> encryptedFields;

//   PasswordController({
//     required this.dbController,
//     required this.encrypto,
//     this.tableName = 'pm',
//     this.uniqueKeys = const [
//       'id'
//     ],
//     this.schema,
//     this.encryptedFields = const [
//       'password',
//       'username',
//       'service',
//       'servicetype',
//       'url',
//       'notes',
//       'isactive',
//       'createddt',
//       'updatedt'
//     ], // By default, everything is encrypted.
//   });

//   /// Optionally call this after constructing the controller, to ensure
//   /// the table is created if it doesn't exist.
//   ///   await passwordController.init();
//   Future<void> init() async {
//     if (schema != null) {
//       // Create table if not exists
//       dbController.createTableIfNotExists(tableName, schema!);
//     }
//   }

//   /// Retrieves a single field from the record, typically the 'password'.
//   /// If [decrypt] is true, the returned field is decrypted.
//   Future<String?> getPassword(String id, {bool decrypt = false}) async {
//     final record = await _getRecordById(id);
//     if (record == null) {
//       throw Exception("No record found for id=$id");
//     }
//     final encValue = record['password'] as String?;
//     if (encValue == null) return null;

//     if (decrypt) {
//       return await encrypto.decrypto(encValue);
//     } else {
//       return encValue;
//     }
//   }

//   /// Retrieves the entire record by [id]. If [decryptFields] is provided,
//   /// those fields are decrypted in the returned map.
//   Future<Map<String, dynamic>?> getRecord(
//     String id, {
//     List<String>? decryptFields,
//   }) async {
//     final record = await _getRecordById(id);
//     if (record == null) return null;

//     if (decryptFields != null) {
//       for (final field in decryptFields) {
//         final value = record[field];
//         if (value is String) {
//           record[field] = await encrypto.decrypto(value);
//         }
//       }
//     }
//     return record;
//   }

//   /// Retrieves all records in the table. If [decryptFields] is provided,
//   /// decrypt those fields in each record.
//   Future<List<Map<String, dynamic>>> getAllRecords({
//     List<String>? decryptFields,
//   }) async {
//     final sql = "SELECT * FROM $tableName";
//     final results = dbController.query(sql);

//     if (decryptFields == null || decryptFields.isEmpty) {
//       return results;
//     }
//     for (final record in results) {
//       for (final field in decryptFields) {
//         final value = record[field];
//         if (value is String) {
//           record[field] = await encrypto.decrypto(value);
//         }
//       }
//     }
//     return results;
//   }

//   /// Upserts a password record.
//   /// If [id] is not provided, we generate one.
//   /// The `password` field respects [passwordChanged] for encryption.
//   /// Other fields in [encryptedFields] are always encrypted if they're strings.
//   Future<String> upsertRecord({
//     String? id,
//     required String username,
//     required String password,
//     String? service,
//     String? servicetype,
//     String? url,
//     String? notes,
//     String? createdt,
//     bool passwordChanged = false,
//     int isactive = 1,
//   }) async {
//     id ??= _generateUniqueId();
//     final now = DateTime.now().toUtc().toIso8601String();

//     // We'll build this row first
//     final row = <String, dynamic>{
//       'id': id,
//       'username': username,
//       'password': password,
//       'service': service,
//       'servicetype': servicetype,
//       'url': url,
//       'notes': notes,
//       'isactive': isactive,
//       'createdt': createdt ?? now,
//       'updatedt': now,
//     };

//     // Now apply encryption rules to the listed fields
//     for (final field in encryptedFields) {
//       if (field == 'password') {
//         // Special handling for password
//         if (passwordChanged) {
//           row['password'] = await encrypto.encrypto(password);
//         }
//       } else {
//         // Encrypt any other field in [encryptedFields]
//         final value = row[field];
//         if (value is String && value.isNotEmpty) {
//           row[field] = await encrypto.encrypto(value);
//         }
//       }
//     }

//     dbController.upsert(tableName, row, uniqueKeys);
//     return id;
//   }

//   /// Upserts multiple password records, ignoring errors or logging them.
//   /// We'll encrypt fields in [encryptedFields] if they're strings.
//   Future<void> upsertMultipleRecords(List<Map<String, dynamic>> data) async {
//     final transformedData = <Map<String, dynamic>>[];

//     for (final item in data) {
//       final clone = Map<String, dynamic>.from(item);

//       clone['id'] ??= _generateUniqueId();
//       clone['updatedt'] = DateTime.now().toUtc().toIso8601String();

//       // Encrypt fields if present and are strings
//       for (final field in encryptedFields) {
//         final currentValue = clone[field];
//         if (field == 'password') {
//           // In batch scenario, we assume the password is always given in plaintext
//           // or already encrypted. There's no "passwordChanged" param here.
//           if (currentValue is String) {
//             clone[field] = await encrypto.encrypto(currentValue);
//           }
//         } else {
//           if (currentValue is String && currentValue.isNotEmpty) {
//             clone[field] = await encrypto.encrypto(currentValue);
//           }
//         }
//       }
//       transformedData.add(clone);
//     }

//     // Then pass them in one go, or you can loop individually if you need error handling
//     dbController.batchUpsert(tableName, transformedData, uniqueKeys);
//   }

//   /// Removes a record by [id].
//   Future<void> removeRecord(String id) async {
//     dbController.delete(tableName, "id = ?", [
//       id
//     ]);
//   }

//   // --------------------------------------------------------------------------
//   // INTERNALS
//   // --------------------------------------------------------------------------
//   /// Retrieves a record by [id], returning a Map<String, dynamic> or null if not found.
//   Future<Map<String, dynamic>?> _getRecordById(String id) async {
//     final sql = "SELECT * FROM $tableName WHERE id = ?";
//     final results = dbController.query(sql, [
//       id
//     ]);
//     if (results.isEmpty) return null;
//     return results.first;
//   }

//   /// Generates a random pseudo-unique ID.
//   /// Alternatively, you can store a real UUID from a library,
//   /// or rely on your DB to auto-generate.
//   String _generateUniqueId() {
//     final random = Random.secure();
//     final bytes = List<int>.generate(16, (_) => random.nextInt(256));
//     return base64Url.encode(bytes).replaceAll('=', '');
//   }
// }

//----------------------------------------------------------------------------------------------------------------------------------------------------------------------

// /// A simple controller for storing and retrieving password records.
// /// Depends on:
// ///  - `SQLiteController` for DB operations
// ///  - `EncryptionInterface` (e.g., `Encrypto`) for encryption.
// class PasswordController {
//   /// The underlying SQLite controller that handles queries, upserts, etc.
//   final DartSqlite dbController;

//   /// Provides encryption/decryption methods (`encrypt`, `decrypt`, etc.).
//   final Encrypto encrypto;

//   /// Table name in SQLite where password records are stored (defaults to "pm").
//   final String tableName;

//   /// The columns that uniquely identify a record. Usually ["id"].
//   final List<String> uniqueKeys;

//   /// If you want to create a table on initialization, you can store the schema here.
//   /// For example:
//   /// {
//   ///   "id": "nvarchar(50) PRIMARY KEY",
//   ///   "username": "nvarchar(256)",
//   ///   "password": "nvarchar(256)",
//   ///   "service": "nvarchar(1000)",
//   ///   "servicetype": "nvarchar(1000)",
//   ///   "isactive": "bit",
//   ///   "url": "nvarchar(MAX) NULL",
//   ///   "dt": "datetime"
//   /// }
//   final Map<String, String>? schema;

//   PasswordController({
//     required this.dbController,
//     required this.encrypto,
//     this.tableName = 'pm',
//     this.uniqueKeys = const [
//       'id'
//     ],
//     this.schema,
//   });

//   /// Optionally call this after constructing the controller, to ensure
//   /// the table is created if it doesn't exist.
//   /// e.g.:
//   ///   await passwordController.init();
//   Future<void> init() async {
//     if (schema != null) {
//       // Create table if not exists
//       dbController.createTableIfNotExists(tableName, schema!);
//     }
//   }

//   /// Retrieves a single field from the record, typically the 'password'.
//   /// If [decrypt] is true, the returned field is decrypted.
//   Future<String?> getPassword(String id, {bool decrypt = false}) async {
//     // We'll rely on a method like "getItem" or a raw query from the dbController.
//     // Adjust as needed to match your 'getItem' logic in SQLiteController
//     // or a raw query approach.
//     final record = await _getRecordById(id);
//     if (record == null) {
//       throw Exception("No record found for id=$id");
//     }
//     final encValue = record['password'] as String?;

//     if (encValue == null) return null;
//     if (decrypt == true) {
//       return await encrypto.decrypto(encValue);
//     } else {
//       return encValue;
//     }
//   }

//   /// Retrieves the entire record by [id]. If [decryptFields] is provided,
//   /// those fields are decrypted in the returned map.
//   Future<Map<String, dynamic>?> getRecord(String id, {List<String>? decryptFields}) async {
//     final record = await _getRecordById(id);
//     if (record == null) return null;

//     if (decryptFields != null) {
//       for (final field in decryptFields) {
//         final value = record[field];
//         if (value is String) {
//           record[field] = await encrypto.decrypto(value);
//         }
//       }
//     }
//     return record;
//   }

//   /// Retrieves all records in the table. If [decryptFields] is provided,
//   /// decrypt those fields in each record.
//   Future<List<Map<String, dynamic>>> getAllRecords({List<String>? decryptFields}) async {
//     final sql = "SELECT * FROM $tableName";
//     final results = dbController.query(sql);
//     // getAllItems presumably returns List<Map<String, dynamic>>
//     if (decryptFields == null || decryptFields.isEmpty) {
//       return results;
//     }
//     for (final record in results) {
//       for (final field in decryptFields) {
//         final value = record[field];
//         if (value is String) {
//           record[field] = await encrypto.decrypto(value);
//         }
//       }
//     }
//     return results;
//   }

//   /// Upserts a password record.
//   /// If [id] is not provided, we generate one.
//   /// The password is encrypted before storing.
//   Future<String> upsertRecord({
//     String? id,
//     required String username,
//     required String password,
//     String? service,
//     String? servicetype,
//     String? url,
//     String? notes,
//     String? createdt,
//     bool passwordChanged = false,
//     int isactive = 1,
//   }) async {
//     id ??= _generateUniqueId();
//     final now = DateTime.now().toUtc().toIso8601String();
//     String pass;
//     if (passwordChanged) {
//       pass = await encrypto.encrypto(password);
//     } else {
//       pass = password;
//     }

//     // Create the row data
//     final row = <String, dynamic>{
//       // TODO align schemas..
//       'id': id,
//       'username': username,
//       'password': pass,
//       'service': service,
//       'servicetype': servicetype,
//       'url': url,
//       "notes": notes,
//       'isactive': isactive,
//       'createdt': createdt ?? now,
//       'updatedt': now,
//     };

//     dbController.upsert(
//       tableName,
//       row,
//       uniqueKeys,
//     );
//     return id;
//   }

//   /// Upserts multiple password records, ignoring errors or logging them.
//   Future<void> upsertMultipleRecords(List<Map<String, dynamic>> data) async {
//     // We can transform each record, encrypting `password`.
//     final transformedData = <Map<String, dynamic>>[];
//     for (final item in data) {
//       final clone = Map<String, dynamic>.from(item);
//       clone['id'] ??= _generateUniqueId();
//       if (clone['password'] is String) {
//         // TODO check this logic.
//         clone['password'] = await encrypto.encrypto(clone['password'] as String);
//       }
//       clone['updatedt'] = DateTime.now().toUtc().toIso8601String();
//       transformedData.add(clone);
//     }
//     // Then pass them in one go, if we want:
//     // or do a loop if we want to handle errors individually.

//     dbController.batchUpsert(tableName, transformedData, uniqueKeys);
//   }

//   /// Removes a record by [id].
//   Future<void> removeRecord(String id) async {
//     dbController.delete(tableName, "id = ?", [
//       id
//     ]);
//   }

//   // --------------------------------------------------------------------------
//   // INTERNALS
//   // --------------------------------------------------------------------------

//   /// Retrieves a record by [id], returning a Map<String, dynamic> or null if not found.
//   Future<Map<String, dynamic>?> _getRecordById(String id) async {
//     // We can do a raw query via dbController:
//     final sql = "SELECT * FROM $tableName WHERE id = ?";
//     final results = dbController.query(sql, [
//       id
//     ]);
//     if (results.isEmpty) return null;
//     return results.first;
//   }

//   /// Generates a random pseudo-unique ID.
//   /// Alternatively, TODO you can store a real UUID from a library,
//   /// or rely on your DB to auto-generate.
//   String _generateUniqueId() {
//     final random = Random.secure();
//     final bytes = List<int>.generate(16, (_) => random.nextInt(256));
//     return base64Url.encode(bytes).replaceAll('=', '');
//   }
// }
