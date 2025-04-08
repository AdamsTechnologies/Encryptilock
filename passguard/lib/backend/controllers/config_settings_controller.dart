import 'package:encryptilock/backend/databaseManager/dart_sqlite.dart';
import 'package:encryptilock/backend/devsec/obfuscation_util.dart';

class ConfigSettingsController {
  final DartSqlite db;
  String? _xorKey;
  String? get xorKey => _xorKey;

  ConfigSettingsController._(this.db);

  static Future<ConfigSettingsController> init(DartSqlite db) async {
    db.createTableIfNotExists('settings', {
      'key': 'TEXT PRIMARY KEY',
      'value': 'TEXT',
    });

    final controller = ConfigSettingsController._(db);
    final salt = await controller.getHashedSetting('session_ref');
    if (salt != null) controller.setXorKey(salt);
    return controller;
  }

  void setXorKey(String key) {
    _xorKey = key;
  }

  String _obfuscateKey(String key) {
    return _xorKey != null ? ObfuscationUtil.xorCipher(key, _xorKey!) : key;
  }

  Future<String?> getSetting(String key, {bool plaintextValue = false}) async {
    final obfuscatedKey = _obfuscateKey(key);
    final result = db.query('SELECT value FROM settings WHERE key = ?', [
      obfuscatedKey
    ]);
    if (result.isEmpty) return null;

    final encoded = result.first['value'] as String;

    if (_xorKey == null || plaintextValue) return encoded;

    try {
      return ObfuscationUtil.xorDecipher(encoded, _xorKey!);
    } catch (_) {
      return encoded;
    }
  }

  Future<void> setSetting(String key, String value, {bool plaintextValue = false}) async {
    final obfuscatedKey = _obfuscateKey(key);
    final encodedValue = plaintextValue ? value : (_xorKey != null ? ObfuscationUtil.xorCipher(value, _xorKey!) : value);

    db.upsert('settings', {
      'key': obfuscatedKey,
      'value': encodedValue,
    }, [
      'key'
    ]);
  }

  Future<String?> getHashedSetting(String key) async {
    final hashedKey = ObfuscationUtil.hashObject(key);
    final result = db.query('SELECT value FROM settings WHERE key = ?', [
      hashedKey
    ]);
    if (result.isEmpty) return null;

    try {
      return ObfuscationUtil.decodeBase64(result.first['value'] as String);
    } catch (_) {
      return null;
    }
  }

  Future<void> setHashedSetting(String key, String value) async {
    final hashedKey = ObfuscationUtil.hashObject(key);
    final encodedValue = ObfuscationUtil.encodeBase64(value);
    db.upsert('settings', {
      'key': hashedKey,
      'value': encodedValue,
    }, [
      'key'
    ]);
  }

  void close() async {
    db.close();
  }
}
