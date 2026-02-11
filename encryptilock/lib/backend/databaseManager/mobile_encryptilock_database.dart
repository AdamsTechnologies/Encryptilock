import 'package:encryptilock/backend/databaseManager/database_abstraction.dart';
import 'package:encryptilock/backend/databaseManager/dart_sqlflite.dart';

class MobileEncryptilockDatabase extends SqfliteSqlite implements EncryptilockDatabase {
  MobileEncryptilockDatabase({required super.dbFile});
}
