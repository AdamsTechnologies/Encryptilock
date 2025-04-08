import 'dart:io';
import 'dart:math';
import 'package:path/path.dart' as p;
import 'package:sqlite3/sqlite3.dart';
import 'package:encryptilock/backend/devsec/encrypto.dart';
import 'package:encryptilock/backend/devsec/key_generator.dart';
import 'package:encryptilock/backend/databaseManager/dart_sqlite.dart';

class EncryptedDatabaseManager {
  final String dbPath; // Path to the encrypted DB on disk
  final String password; // Password used for deriving encryption key
  final String? providedSalt; // Optional salt, base64-encoded or similar

  late Encrypto _encrypto;
  late String _currentSalt;

  EncryptedDatabaseManager({
    required this.dbPath,
    required this.password,
    this.providedSalt,
  });

  /// Opens the database:
  /// 1) Decrypts the on-disk database if it exists.
  /// 2) Loads it into a DartSqlite instance backed by in-memory SQLite.
  /// 3) Returns the DartSqlite object for use.
  Future<DartSqlite> open() async {
    final keyResult = await generateKey(
      password,
      providedSalt,
    );
    final derivedKey = keyResult['key']!;
    _currentSalt = keyResult['salt']!;
    _encrypto = Encrypto(derivedKey);

    // Prepare temp path for decryption
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
    return inMemoryDb;
  }

  /// Closes the database:
  /// 1) Backs up the in-memory DB to a temporary file.
  /// 2) Encrypts the temporary file.
  /// 3) Writes the encrypted data back to the original on-disk location.
  /// 4) Cleans up temporary artifacts.
  Future<void> close(DartSqlite inMemoryDb) async {
    final tempPath = _generateTempFilePath();
    final tempFile = File(tempPath);

    try {
      final fileDb = sqlite3.open(tempPath); // create a blank db in tempPath.
      await inMemoryDb.database.backup(fileDb).drain(); // back-up inMemoryDb to tempPath
      fileDb.dispose(); // close connection

      final rawBytes = await tempFile.readAsBytes();
      final encryptedBytes = await _encrypto.encrypt(rawBytes);

      await File(dbPath).writeAsBytes(encryptedBytes);
    } finally {
      inMemoryDb.close();
      if (await tempFile.exists()) {
        await tempFile.delete();
      }
    }
  }

  /// Generates a random file path for temporary files.
  String _generateTempFilePath() {
    final tmpDir = Directory.systemTemp;
    final randomName = "${_randomString(10)}.db";
    return p.join(tmpDir.path, randomName);
  }

  /// Generates a random alphanumeric string of [length].
  String _randomString(int length) {
    const chars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final rand = Random.secure();
    return List.generate(length, (_) => chars[rand.nextInt(chars.length)]).join();
  }

  /// Getter to access the current salt used in the encryption key.
  String get currentSalt => _currentSalt;
  Encrypto get encrypto => _encrypto;
}
