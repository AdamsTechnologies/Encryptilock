import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:encryptilock/backend/databaseManager/dart_sqlite.dart';

void main() {
  group('DartSqlite Tests', () {
    late DartSqlite db;

    setUp(() {
      // For purely in-memory testing, you can do:
      // db = DartSqlite(dbFile: ':memory:');
      //
      // Or if you want a temporary file-based DB:
      final tempDir = Directory.systemTemp.createTempSync();
      final dbPath = '${tempDir.path}/testdb.sqlite';
      db = DartSqlite(dbFile: dbPath);

      db.open();
    });

    tearDown(() {
      db.close();
    });

    test('Opens and closes database without error', () {
      expect(() => db.open(), returnsNormally);
      expect(() => db.close(), returnsNormally);
    });

    test('createTableIfNotExists creates a table', () {
      // Define a basic schema
      final schema = {
        'id': 'TEXT PRIMARY KEY',
        'name': 'TEXT NOT NULL',
        'age': 'INTEGER',
      };

      // Create the table
      expect(() => db.createTableIfNotExists('users', schema), returnsNormally);

      // Verify table creation by querying sqlite_master
      final results = db.query("SELECT name FROM sqlite_master WHERE type='table' AND name='users'");
      expect(results.length, 1, reason: 'users table should exist.');
    });

    test('Insert and Query a single row', () {
      // Create a test table
      db.executeCommand('CREATE TABLE IF NOT EXISTS people (id TEXT PRIMARY KEY, name TEXT, age INTEGER)');

      // Insert
      db.insert('people', {
        'id': 'abc',
        'name': 'Alice',
        'age': 30
      });

      // Query
      final rows = db.query('SELECT * FROM people WHERE id=?', [
        'abc'
      ]);
      expect(rows.length, 1);
      expect(rows.first['name'], 'Alice');
      expect(rows.first['age'], 30);
    });

    test('Batch insert multiple rows', () {
      // Create a test table
      db.executeCommand('CREATE TABLE IF NOT EXISTS fruits (id TEXT PRIMARY KEY, label TEXT)');

      // Batch insert
      final data = [
        {
          'id': 'f1',
          'label': 'Apple'
        },
        {
          'id': 'f2',
          'label': 'Banana'
        },
        {
          'id': 'f3',
          'label': 'Cherry'
        },
      ];
      db.batchInsert('fruits', data);

      // Verify
      final rows = db.query('SELECT * FROM fruits');
      expect(rows.length, 3, reason: '3 rows inserted');
    });

    test('Update existing rows', () {
      // Setup table
      db.executeCommand('CREATE TABLE IF NOT EXISTS books (id TEXT PRIMARY KEY, title TEXT, author TEXT)');

      // Insert a row
      db.insert('books', {
        'id': 'b1',
        'title': 'Old Title',
        'author': 'Unknown'
      });
      // Update the row
      db.update(
        'books',
        {
          'title': 'New Title',
          'author': 'John Doe'
        },
        whereClause: 'id=?',
        whereArgs: [
          'b1'
        ],
      );

      // Verify
      final rows = db.query('SELECT title, author FROM books WHERE id=?', [
        'b1'
      ]);
      expect(rows.length, 1);
      expect(rows.first['title'], 'New Title');
      expect(rows.first['author'], 'John Doe');
    });

    test('Upsert a row (ON CONFLICT ...)', () {
      // Setup table with 'id' as unique key
      db.executeCommand('CREATE TABLE IF NOT EXISTS notes (id TEXT PRIMARY KEY, content TEXT)');

      // Insert or upsert
      db.upsert('notes', {
        'id': 'n1',
        'content': 'Hello World'
      }, [
        'id'
      ]);
      // Check inserted
      var rows = db.query('SELECT * FROM notes WHERE id=?', [
        'n1'
      ]);
      expect(rows.length, 1);
      expect(rows.first['content'], 'Hello World');

      // Upsert again with new content
      db.upsert('notes', {
        'id': 'n1',
        'content': 'Updated Content'
      }, [
        'id'
      ]);
      // Check updated
      rows = db.query('SELECT * FROM notes WHERE id=?', [
        'n1'
      ]);
      expect(rows.length, 1);
      expect(rows.first['content'], 'Updated Content');
    });

    test('Delete rows', () {
      // Setup table
      db.executeCommand('CREATE TABLE IF NOT EXISTS tasks (id TEXT PRIMARY KEY, desc TEXT)');
      db.batchInsert('tasks', [
        {
          'id': 't1',
          'desc': 'Task One'
        },
        {
          'id': 't2',
          'desc': 'Task Two'
        },
      ]);

      // Delete t1
      db.delete('tasks', 'id=?', [
        't1'
      ]);
      final rows = db.query('SELECT * FROM tasks');
      expect(rows.length, 1);
      expect(rows.first['id'], 't2');
    });

    test('getBatchNo returns next increment for a field', () {
      // Setup table
      db.executeCommand('CREATE TABLE IF NOT EXISTS logs (seq INTEGER, message TEXT)');
      // Insert a few logs with seq values
      db.batchInsert('logs', [
        {
          'seq': 1,
          'message': 'First'
        },
        {
          'seq': 2,
          'message': 'Second'
        },
      ]);

      // getBatchNo should return 3
      final nextSeq = db.getBatchNo('logs', 'seq');
      expect(nextSeq, 3);
    });
  });
}
