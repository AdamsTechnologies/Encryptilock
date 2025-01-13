import 'package:flutter_test/flutter_test.dart';
import 'package:passguard/backend/databaseManager/sqlite_controller.dart';

void main() {
  group('SQLiteController Tests', () {
    late SQLiteController controller;

    setUp(() {
      controller = SQLiteController(dbFile: ':memory:', verboseLogging: true);
    });

    tearDown(() {
      controller.database.close();
    });

    test('Convert Schema', () async {
      final schema = {
        'id': 'int PRIMARY KEY',
        'name': 'nvarchar(100) NOT NULL',
        'email': 'varchar(200) UNIQUE',
        'created_at': 'datetime'
      };

      final convertedSchema = await controller.convertSchema(schema);

      expect(convertedSchema, {
        'id': 'INTEGER PRIMARY KEY',
        'name': 'TEXT NOT NULL',
        'email': 'TEXT UNIQUE',
        'created_at': 'TEXT'
      });
    });

    test('Create Table If Not Exists', () async {
      final schema = {
        'id': 'int PRIMARY KEY',
        'name': 'nvarchar(100)',
        'age': 'int'
      };

      await controller.createTableIfNotExists('users', schema);

      final result = controller.database.query(
        "SELECT name FROM sqlite_master WHERE type=? AND name=?;",
        ['table', 'users']
      );
      expect(result.isNotEmpty, true);
    });

    test('Append Data', () async {
      final schema = {
        'id': 'int PRIMARY KEY',
        'name': 'nvarchar(100)',
        'age': 'int'
      };

      await controller.createTableIfNotExists('users', schema);

      await controller.appendData('users', [
        {'id': 1, 'name': 'Alice', 'age': 30},
        {'id': 2, 'name': 'Bob', 'age': 25},
      ]);

      final result = await controller.getAllItems('users');
      expect(result.length, 2);
      expect(result.first['name'], 'Alice');
    });

    test('Upsert Data', () async {
      final schema = {
        'id': 'int PRIMARY KEY',
        'name': 'nvarchar(100)',
        'age': 'int'
      };

      await controller.createTableIfNotExists('users', schema);

      // Insert new data
      await controller.upsertData('users', [
        {'id': 1, 'name': 'Alice', 'age': 30},
      ], ['id']);

      // Update existing data
      await controller.upsertData('users', [
        {'id': 1, 'name': 'Alice Updated', 'age': 31},
      ], ['id']);

      final result = await controller.getAllItems('users');
      expect(result.length, 1);
      expect(result.first['name'], 'Alice Updated');
      expect(result.first['age'], 31);
    });

    test('Get All Items', () async {
      final schema = {
        'id': 'int PRIMARY KEY',
        'name': 'nvarchar(100)',
        'age': 'int'
      };

      await controller.createTableIfNotExists('users', schema);

      await controller.appendData('users', [
        {'id': 1, 'name': 'Alice', 'age': 30},
        {'id': 2, 'name': 'Bob', 'age': 25},
      ]);

      final result = await controller.getAllItems('users');
      expect(result.length, 2);
    });

    test('Get Batch Number', () async {
      final schema = {
        'id': 'int PRIMARY KEY',
        'batch_no': 'int',
        'name': 'nvarchar(100)'
      };

      await controller.createTableIfNotExists('items', schema);

      await controller.appendData('items', [
        {'id': 1, 'batch_no': 1, 'name': 'Item 1'},
        {'id': 2, 'batch_no': 1, 'name': 'Item 2'},
      ]);

      final batchNo = await controller.getBatchNo('items', 'batch_no');
      expect(batchNo, 2);
    });
  });
}
