import 'package:passguard/backend/databaseManager/dart_sqlite.dart';

class ConfigSettingsController {
  final DartSqlite db;

  ConfigSettingsController(this.db) {
    db.createTableIfNotExists('settings', {
      'key': 'TEXT PRIMARY KEY',
      'value': 'TEXT',
    });
  }

  /// Fetches a setting by key. Returns null if not found.
  Future<String?> getSetting(String key) async {
    final result = db.query('SELECT value FROM settings WHERE key = ?', [key]);
    return result.isNotEmpty ? result.first['value'] as String : null;
  }

  /// Saves or updates a setting.
  Future<void> setSetting(String key, String value) async {
    db.upsert('settings', {'key': key, 'value': value}, ['key']);
  }

}
