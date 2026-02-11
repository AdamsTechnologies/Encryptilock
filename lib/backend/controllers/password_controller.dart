import 'dart:convert';
import 'dart:math';
import 'package:encryptilock/backend/devsec/encrypto.dart';
import 'package:encryptilock/backend/databaseManager/database_abstraction.dart';

class PasswordController {
  final EncryptilockDatabase dbController;
  final Encrypto encrypto;
  final String tableName;
  final List<String> uniqueKeys;
  final Map<String, String>? schema;

  /// Defines which fields should be stored encrypted by default.
  /// Example usage: ['password','username','url','notes']
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

  /// Get password with option to decrypt it.
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
    // final results = dbController.query(sql);
    final results = await dbController.query(sql);

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
    // Upsert into DB
    dbController.upsert(tableName, row, uniqueKeys);
    return id;
  }

  /// Upserts multiple records in batch, always encrypting all fields for simplicity.
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

  Future<Map<String, dynamic>?> _getRecordById(String id) async {
    final sql = "SELECT * FROM $tableName WHERE id = ?";
    final results = await dbController.query(sql, [
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
