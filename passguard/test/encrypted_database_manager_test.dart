import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:encryptilock/backend/databaseManager/encrypted_database_manager.dart';
import 'package:path/path.dart' as p;

void main() {
  group('EncryptedDatabaseManager Tests', () {
    late EncryptedDatabaseManager manager;
    late String dbPath;
    const password = 'securepassword';

    setUp(() async {
      // Create a unique test database path
      final testDir = Directory.systemTemp.createTempSync();
      dbPath = p.join(testDir.path, 'test.db');
    });

    tearDown(() async {
      // Delete the test database if it exists
      final file = File(dbPath);
      if (await file.exists()) {
        await file.delete();
      }
    });

    test('Opens and initializes a new in-memory database', () async {
      manager = EncryptedDatabaseManager(dbPath: dbPath, password: password);

      // Open the database
      final db = await manager.open();

      // Verify the current salt is set
      expect(manager.currentSalt, isA<String>());
      expect(manager.currentSalt.isNotEmpty, true);

      // Write to the database
      // final db = manager.database;
      db.executeCommand('CREATE TABLE IF NOT EXISTS test (id INTEGER PRIMARY KEY, value TEXT)');
      db.insert('test', {
        'value': 'Hello, Encrypted World!'
      });

      // Verify data can be read back
      final result = db.query('SELECT * FROM test');
      expect(result.length, 1);
      expect(result.first['value'], 'Hello, Encrypted World!');

      // Close the database
      await manager.close(db);
    });

    test('Encrypts and decrypts an existing database', () async {
      manager = EncryptedDatabaseManager(dbPath: dbPath, password: password);
      final db = await manager.open();
      String salt = manager.currentSalt;
      db.executeCommand('CREATE TABLE IF NOT EXISTS test (id INTEGER PRIMARY KEY, value TEXT)');
      db.insert('test', {
        'value': 'Persisted data!'
      });
      await manager.close(db);

      final encryptedFile = File(dbPath);
      expect(await encryptedFile.exists(), true);

      final reopenedManager = EncryptedDatabaseManager(dbPath: dbPath, password: password, providedSalt: salt);
      final reopenedDb = await reopenedManager.open();
      final result = reopenedDb.query('SELECT * FROM test');
      expect(result.length, 1);
      expect(result.first['value'], 'Persisted data!');
      await reopenedManager.close(reopenedDb);
    });

    test('Handles temporary file cleanup correctly', () async {
      manager = EncryptedDatabaseManager(dbPath: dbPath, password: password);

      // Open the database
      final db = await manager.open();

      // Validate that no temp files are left behind after closing
      final tempDir = Directory.systemTemp;
      final tempFilesBefore = tempDir.listSync().whereType<File>().length;

      await manager.close(db);

      final tempFilesAfter = tempDir.listSync().whereType<File>().length;
      expect(tempFilesAfter, tempFilesBefore);
    });

    test('Generates a new salt when none is provided', () async {
      manager = EncryptedDatabaseManager(dbPath: dbPath, password: password);

      final db = await manager.open();

      // Verify that a new salt was generated
      expect(manager.currentSalt, isNotEmpty);
      expect(manager.currentSalt, isA<String>());

      await manager.close(db);
    });

    test('Uses the provided salt', () async {
      const testSalt = 'MTIzNDU2Nzg5MDEyMzQ1Ng=='; // Base64 encoded "1234567890123456"
      manager = EncryptedDatabaseManager(dbPath: dbPath, password: password, providedSalt: testSalt);

      final db = await manager.open();

      // Verify that the provided salt is used
      expect(manager.currentSalt, testSalt);

      await manager.close(db);
    });

    test('Throws an error when trying to decrypt with the wrong password', () async {
      // Create an encrypted database
      manager = EncryptedDatabaseManager(dbPath: dbPath, password: password);
      final db = await manager.open();
      db.executeCommand('CREATE TABLE IF NOT EXISTS test (id INTEGER PRIMARY KEY, value TEXT)');
      db.insert('test', {
        'value': 'Secure data!'
      });
      await manager.close(db);

      // Attempt to reopen with the wrong password
      final incorrectPasswordManager = EncryptedDatabaseManager(dbPath: dbPath, password: 'wrongpassword');

      expect(() async => await incorrectPasswordManager.open(), throwsException);
    });
  });
}
