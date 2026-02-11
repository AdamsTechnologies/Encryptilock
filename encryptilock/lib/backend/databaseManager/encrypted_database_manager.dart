import 'dart:io';
import 'dart:math';
import 'package:path/path.dart' as p;
import 'package:encryptilock/backend/devsec/encrypto.dart';
import 'package:encryptilock/backend/devsec/key_generator.dart';
import 'package:encryptilock/backend/databaseManager/dart_sqlite.dart';
import 'package:encryptilock/backend/databaseManager/desktop_encryptilock_database.dart';
import 'package:encryptilock/backend/databaseManager/mobile_encryptilock_database.dart';
import 'package:encryptilock/backend/databaseManager/database_abstraction.dart';
import 'package:sqlite3/sqlite3.dart';
import 'package:path_provider/path_provider.dart';

class EncryptedDatabaseManager {
  final String dbPath;
  final String password;
  final String? providedSalt;

  late Encrypto _encrypto;
  late String _currentSalt;
  EncryptilockDatabase? _activeDb;

  EncryptedDatabaseManager({
    required this.dbPath,
    required this.password,
    this.providedSalt,
  });

  /// Opens the encrypted DB and returns the platform-specific implementation.
  Future<EncryptilockDatabase> open() async {
    final keyResult = await generateKey(password, providedSalt);
    final derivedKey = keyResult['key']!;
    _currentSalt = keyResult['salt']!;
    _encrypto = Encrypto(derivedKey);

    if (Platform.isAndroid || Platform.isIOS) {
      final tempDir = await getTemporaryDirectory();
      final tempPath = p.join(tempDir.path, 'session.db');

      if (await File(dbPath).exists()) {
        final encryptedBytes = await File(dbPath).readAsBytes();
        final decryptedBytes = await _encrypto.decrypt(encryptedBytes);
        await File(tempPath).writeAsBytes(decryptedBytes);
      }

      final db = MobileEncryptilockDatabase(dbFile: tempPath);
      await db.open();
      _activeDb = db;
      return db;
    } else {
      final tempPath = _generateTempFilePath();
      final file = File(dbPath);
      final inMemoryDb = DartSqlite(dbFile: ':memory:');
      inMemoryDb.open();

      if (file.existsSync()) {
        final encryptedBytes = await file.readAsBytes();
        final decryptedBytes = await _encrypto.decrypt(encryptedBytes);

        final tempFile = File(tempPath);
        await tempFile.writeAsBytes(decryptedBytes);

        final fileDb = sqlite3.open(tempPath);
        await fileDb.backup(inMemoryDb.database).drain();
        fileDb.dispose();
        await tempFile.delete();
      }

      final db = DesktopEncryptilockDatabase(inMemoryDb);
      _activeDb = db;
      return db;
    }
  }

  Future<void> close() async {
    if (_activeDb == null) return;

    if (Platform.isAndroid || Platform.isIOS) {
      final db = _activeDb as MobileEncryptilockDatabase;
      final path = db.dbFile;
      await db.close();

      final tempFile = File(path);
      if (await tempFile.exists()) {
        final rawBytes = await tempFile.readAsBytes();
        final encryptedBytes = await _encrypto.encrypt(rawBytes);
        await File(dbPath).writeAsBytes(encryptedBytes);
        await tempFile.delete();
      }
    } else {
      final db = (_activeDb as DesktopEncryptilockDatabase).database;
      final tempPath = _generateTempFilePath();
      final tempFile = File(tempPath);

      final fileDb = sqlite3.open(tempPath);
      await db.database.backup(fileDb).drain();
      fileDb.dispose();

      final rawBytes = await tempFile.readAsBytes();
      final encryptedBytes = await _encrypto.encrypt(rawBytes);
      await File(dbPath).writeAsBytes(encryptedBytes);

      db.close();
      await tempFile.delete();
    }

    _activeDb = null;
  }

  /// Returns the current encryption salt used after `open()`.
  String get currentSalt => _currentSalt;

  /// Returns the encryption engine (keyed after open()).
  Encrypto get encrypto => _encrypto;

  /// Generates a random temporary path.
  String _generateTempFilePath() {
    final tmpDir = Directory.systemTemp;
    final randomName = "${_randomString(10)}.db";
    return p.join(tmpDir.path, randomName);
  }

  /// Generates a random alphanumeric string.
  String _randomString(int length) {
    const chars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final rand = Random.secure();
    return List.generate(length, (_) => chars[rand.nextInt(chars.length)]).join();
  }
}
