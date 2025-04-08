import 'package:flutter_test/flutter_test.dart';
import 'package:encryptilock/backend/helpers/support_functs.dart';

void main() {
  group('applyCasing Tests', () {
    test('Handles empty string', () {
      expect(applyCasing('', Casing.upper), '');
      expect(applyCasing('', Casing.lower), '');
      expect(applyCasing('', Casing.title), '');
      expect(applyCasing('', Casing.capitalize), '');
      expect(applyCasing('', Casing.none), '');
    });

    test('Converts to uppercase', () {
      expect(applyCasing('hello world', Casing.upper), 'HELLO WORLD');
    });

    test('Converts to lowercase', () {
      expect(applyCasing('HELLO WORLD', Casing.lower), 'hello world');
    });

    test('Converts to title case', () {
      expect(applyCasing('hello world', Casing.title), 'Hello World');
      expect(applyCasing('HELLO world', Casing.title), 'Hello World');
      expect(applyCasing('  hello   world  ', Casing.title), '  Hello   World  '); // Preserves extra spaces
    });

    test('Capitalizes the first letter', () {
      expect(applyCasing('hello world', Casing.capitalize), 'Hello world');
      expect(applyCasing('HELLO WORLD', Casing.capitalize), 'Hello world');
    });

    test('Returns original string for none', () {
      expect(applyCasing('heLlo wOrld', Casing.none), 'heLlo wOrld');
    });
  });
}
