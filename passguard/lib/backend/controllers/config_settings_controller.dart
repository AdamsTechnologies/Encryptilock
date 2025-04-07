import 'package:Encryptilock/backend/databaseManager/dart_sqlite.dart';
import 'package:Encryptilock/backend/devsec/obfuscation_util.dart';

class ConfigSettingsController {
  final DartSqlite db;
  String? _xorKey;

  ConfigSettingsController(this.db) {
    db.createTableIfNotExists('settings', {
      'key': 'TEXT PRIMARY KEY',
      'value': 'TEXT',
    });
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
}

// import 'package:Encryptilock/backend/databaseManager/dart_sqlite.dart';
// import 'package:Encryptilock/backend/devsec/obfuscation_util.dart';

// class ConfigSettingsController {
//   final DartSqlite db;
//   String? _xorKey;

//   ConfigSettingsController(this.db) {
//     db.createTableIfNotExists('settings', {
//       'key': 'TEXT PRIMARY KEY',
//       'value': 'TEXT',
//     });
//   }

//   /// Call this after login with the user's derived salt or chosen XOR key
//   void setXorKey(String key) {
//     _xorKey = key;
//   }

//   /// Internally obfuscates the key if XOR is set
//   String _obfuscateKey(String key) {
//     return _xorKey != null ? ObfuscationUtil.xorCipher(key, _xorKey!) : key;
//   }

//   /// Fetches a setting by key. XOR-decodes value, and uses obfuscated key
//   Future<String?> getSetting(String key) async {
//     final obfuscatedKey = _obfuscateKey(key);
//     final result = db.query('SELECT value FROM settings WHERE key = ?', [
//       obfuscatedKey
//     ]);

//     if (result.isEmpty) return null;

//     final encoded = result.first['value'] as String;
//     if (_xorKey == null) return encoded;

//     try {
//       return ObfuscationUtil.xorDecipher(encoded, _xorKey!);
//     } catch (_) {
//       return encoded;
//     }
//   }

//   /// Saves or updates a setting. XOR-encodes both key and value
//   Future<void> setSetting(String key, String value) async {
//     final obfuscatedKey = _obfuscateKey(key);
//     final encodedValue = _xorKey != null ? ObfuscationUtil.xorCipher(value, _xorKey!) : value;

//     db.upsert('settings', {
//       'key': obfuscatedKey,
//       'value': encodedValue,
//     }, [
//       'key'
//     ]);
//   }
// }
