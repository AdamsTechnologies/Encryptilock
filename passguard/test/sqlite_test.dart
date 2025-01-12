import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:passguard/backend/databaseManager/sql.dart';

void main() {
  group('SQLite Class Tests', () {
    late SQLite database;

    setUp(() async {
      database = SQLite(dbFile: ':memory:', inMemory: true);
    });

    tearDown(() async {
      await database.close();
    });

    test('Create Table', () async {
      final schema = {
        'id': 'INTEGER PRIMARY KEY',
        'name': 'TEXT NOT NULL',
        'age': 'INTEGER',
        'email': 'TEXT UNIQUE',
      };

      await database.createTableIfNotExists(tableName: 'users', schema: schema);

      // Verify the table exists
      final result = await database.rawQuery(
        "SELECT name FROM sqlite_master WHERE type=? AND name=?;",['table','users']
      );
      expect(result.isNotEmpty, true);
    });

    test('Insert Data', () async {
      await database.createTableIfNotExists(
        tableName: 'users',
        schema: {
          'id': 'INTEGER PRIMARY KEY',
          'name': 'TEXT NOT NULL',
          'age': 'INTEGER',
        },
      );

      final id = await database.insert(
        table: 'users',
        values: {'id': 1, 'name': 'Alice', 'age': 25},
      );

      expect(id, 1);

      final result = await database.query('users');
      expect(result.length, 1);
      expect(result.first['name'], 'Alice');
    });

    test('Update Data', () async {
      await database.createTableIfNotExists(
        tableName: 'users',
        schema: {
          'id': 'INTEGER PRIMARY KEY',
          'name': 'TEXT NOT NULL',
          'age': 'INTEGER',
        },
      );

      await database.insert(
        table: 'users',
        values: {'id': 1, 'name': 'Alice', 'age': 25},
      );

      final updatedCount = await database.update(
        table: 'users',
        values: {'name': 'Alice Updated'},
        where: 'id = ?',
        whereArgs: [1],
      );

      expect(updatedCount, 1);

      final result = await database.query('users');
      expect(result.first['name'], 'Alice Updated');
    });

    test('Delete Data', () async {
      await database.createTableIfNotExists(
        tableName: 'users',
        schema: {
          'id': 'INTEGER PRIMARY KEY',
          'name': 'TEXT NOT NULL',
          'age': 'INTEGER',
        },
      );

      await database.insert(
        table: 'users',
        values: {'id': 1, 'name': 'Alice', 'age': 25},
      );

      final deletedCount = await database.delete(
        table: 'users',
        where: 'id = ?',
        whereArgs: [1],
      );

      expect(deletedCount, 1);

      final result = await database.query('users');
      expect(result.isEmpty, true);
    });

    test('Batch Insert', () async {
      await database.createTableIfNotExists(
        tableName: 'users',
        schema: {
          'id': 'INTEGER PRIMARY KEY',
          'name': 'TEXT NOT NULL',
          'age': 'INTEGER',
        },
      );

      await database.batchInsert(
        tableName: 'users',
        data: [
          {'id': 1, 'name': 'Alice', 'age': 25},
          {'id': 2, 'name': 'Bob', 'age': 30},
        ],
      );

      final result = await database.query('users');
      expect(result.length, 2);
    });

    test('Batch Update', () async {
      await database.createTableIfNotExists(
        tableName: 'users',
        schema: {
          'id': 'INTEGER PRIMARY KEY',
          'name': 'TEXT NOT NULL',
          'age': 'INTEGER',
        },
      );

      await database.batchInsert(
        tableName: 'users',
        data: [
          {'id': 1, 'name': 'Alice', 'age': 25},
          {'id': 2, 'name': 'Bob', 'age': 30},
        ],
      );

      await database.batchUpdate(
        tableName: 'users',
        data: [
          {'name': 'Alice Updated'},
          {'name': 'Bob Updated'},
        ],
        whereClause: 'id = ?',
        whereArgsList: [
          [1],
          [2],
        ],
      );

      final result = await database.query('users');
      expect(result[0]['name'], 'Alice Updated');
      expect(result[1]['name'], 'Bob Updated');
    });

    test('Batch Delete', () async {
      await database.createTableIfNotExists(
        tableName: 'users',
        schema: {
          'id': 'INTEGER PRIMARY KEY',
          'name': 'TEXT NOT NULL',
          'age': 'INTEGER',
        },
      );

      await database.batchInsert(
        tableName: 'users',
        data: [
          {'id': 1, 'name': 'Alice', 'age': 25},
          {'id': 2, 'name': 'Bob', 'age': 30},
        ],
      );

      await database.batchDelete(
        tableName: 'users',
        whereClauses: ['id = ?', 'id = ?'],
        whereArgsList: [
          [1],
          [2],
        ],
      );

      final result = await database.query('users');
      expect(result.isEmpty, true);
    });

    test('Upsert Data', () async {
      await database.createTableIfNotExists(
        tableName: 'users',
        schema: {
          'id': 'INTEGER PRIMARY KEY',
          'name': 'TEXT NOT NULL',
          'age': 'INTEGER',
        },
      );

      await database.upsert(
        table: 'users',
        values: {'id': 1, 'name': 'Alice', 'age': 25},
        conflictColumns: ['id'],
      );

      final result = await database.query('users');
      expect(result.length, 1);
      expect(result.first['name'], 'Alice');

      // Update using upsert
      await database.upsert(
        table: 'users',
        values: {'id': 1, 'name': 'Alice Updated', 'age': 26},
        conflictColumns: ['id'],
      );

      final updatedResult = await database.query('users');
      expect(updatedResult.first['name'], 'Alice Updated');
      expect(updatedResult.first['age'], 26);
    });
  });
}