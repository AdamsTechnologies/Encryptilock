import 'dart:io';
import 'package:encryptilock/backend/databaseManager/database_abstraction.dart';
import 'package:encryptilock/backend/databaseManager/dart_sqlite.dart';
import 'package:encryptilock/backend/databaseManager/desktop_encryptilock_database.dart';
import 'package:encryptilock/backend/databaseManager/mobile_encryptilock_database.dart';

Future<EncryptilockDatabase> createEncryptilockDatabase(String dbFile) async {
  if (Platform.isAndroid || Platform.isIOS) {
    final db = MobileEncryptilockDatabase(dbFile: dbFile);
    await db.open();
    return db;
  } else {
    final db = DartSqlite(dbFile: dbFile);
    final wrapper = DesktopEncryptilockDatabase(db);
    await wrapper.open();
    return wrapper;
  }
}
