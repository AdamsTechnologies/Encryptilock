import 'package:flutter_test/flutter_test.dart';
import 'dart:math';
import 'dart:convert';
import 'package:encryptilock/backend/databaseManager/dart_sqlite.dart';
import 'package:encryptilock/backend/devsec/encrypto.dart';
import 'package:encryptilock/backend/controllers/password_controller.dart';

void main() {
  group('PasswordController Tests', () {
    late DartSqlite db;
    late PasswordController passwordController;

    setUp(() async {
      // 1) Create an in-memory DB
      db = DartSqlite(dbFile: ':memory:');
      db.open();

      // 2) Define a schema for the "pm" table
      final schema = {
        'id': 'TEXT PRIMARY KEY',
        'username': 'TEXT',
        'password': 'TEXT',
        'service': 'TEXT',
        'servicetype': 'TEXT',
        'isactive': 'INTEGER',
        'url': 'TEXT',
        'dt': 'TEXT',
      };

      // 3) Create our mock encrypto
      final random = Random.secure();
      final keyBytes = List<int>.generate(32, (_) => random.nextInt(256));
      final base64Key = base64Url.encode(keyBytes);
      final realEncrypto = Encrypto(base64Key);

      // 4) Initialize PasswordController
      passwordController = PasswordController(
        dbController: db,
        encrypto: realEncrypto,
        tableName: 'pm',
        uniqueKeys: ['id'],
        schema: schema, // We want it to create the table if not exists
      );

      // 5) Call init() to create the table
      await passwordController.init();
    });

    tearDown(() {
      db.close();
    });

    test('Upsert a single record and retrieve it decrypted.', () async {
      // upsert one record
      await passwordController.upsertRecord(
        id: 'abc',
        username: 'alice',
        password: 'helloWorld',
        service: 'testService',
      );

      // retrieve record with decryption
      final record = await passwordController.getRecord('abc', decryptFields: ['password']);
      expect(record, isNotNull);
      expect(record!['id'], 'abc');
      expect(record['username'], 'alice');

      expect(record['password'], equals('helloWorld'));
    });

    test('getPassword returns the decrypted password if requested', () async {
      await passwordController.upsertRecord(
        id: 'xyz',
        username: 'bob',
        password: 'secretPass',
        service: 'someService',
      );

      // get the password un-decrypted
      final stored = await passwordController.getPassword('xyz', decrypt: false);
      expect(stored, isNot(equals('secretPass')));

      // get it decrypted
      final decrypted = await passwordController.getPassword('xyz', decrypt: true);
      expect(decrypted, equals('secretPass'));
    });

    test('getAllRecords with decrypt fields', () async {
      // Insert multiple
      await passwordController.upsertRecord(
        id: 'id1',
        username: 'alpha',
        password: 'pwAlpha',
      );
      await passwordController.upsertRecord(
        id: 'id2',
        username: 'beta',
        password: 'pwBeta',
      );

      // Retrieve all, decrypt the 'password' field
      final all = await passwordController.getAllRecords(decryptFields: ['password']);
      expect(all.length, 2);

      final rec1 = all.firstWhere((r) => r['id'] == 'id1');
      final rec2 = all.firstWhere((r) => r['id'] == 'id2');

      // Check the "password" field is "decrypted-encrypted-..."
      expect(rec1['password'], equals('pwAlpha'));
      expect(rec2['password'], equals('pwBeta'));
    });

    test('Upsert multiple records in one go', () async {
      final data = [
        {
          'id': 'r1',
          'username': 'u1',
          'password': 'p1',
        },
        {
          'id': 'r2',
          'username': 'u2',
          'password': 'p2',
        }
      ];
      await passwordController.upsertMultipleRecords(data);

      // Check them
      final rec1 = await passwordController.getRecord('r1', decryptFields: ['password']);
      final rec2 = await passwordController.getRecord('r2', decryptFields: ['password']);

      expect(rec1!['username'], equals('u1'));
      expect(rec1['password'], equals('p1'));
      expect(rec2!['username'], equals('u2'));
      expect(rec2['password'], equals('p2'));
    });

    test('removeRecord deletes the record', () async {
      await passwordController.upsertRecord(
        id: 'del1',
        username: 'removeme',
        password: 'gone',
      );

      // ensure it exists
      final before = await passwordController.getRecord('del1');
      expect(before, isNotNull);

      // remove
      await passwordController.removeRecord('del1');

      // now it should be gone
      final after = await passwordController.getRecord('del1');
      expect(after, isNull);
    });

    test('getRecord returns null if record does not exist', () async {
      // no records upserted
      final rec = await passwordController.getRecord('nope');
      expect(rec, isNull);
    });

    test('getPassword throws if record not found', () async {
      expect(
        () => passwordController.getPassword('noSuchId'),
        throwsA(isA<Exception>()),
      );
    });
  });
}
