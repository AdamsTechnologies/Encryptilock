import 'package:flutter_test/flutter_test.dart';
import 'package:Encryptilock/backend/devsec/deterministic_hash.dart';

void main() {
  test('hashObject generates deterministic SHA-256 hashes', () {
    const salt = 'salty';
    const testObject = {
      'key': 'value',
      'num': 42
    };

    final hash1 = hashObject(testObject, salt);
    final hash2 = hashObject(testObject, salt);

    // Hash should always be the same for the same input
    expect(hash1, equals(hash2));

    // Hashes for different inputs should be different
    final differentObject = {
      'key': 'differentValue',
      'num': 42
    };
    final hash3 = hashObject(differentObject, salt);
    expect(hash1, isNot(equals(hash3)));

    // Hashes for different salts should be different
    const differentSalt = 'differentSalt';
    final hash4 = hashObject(testObject, differentSalt);
    expect(hash1, isNot(equals(hash4)));

    // Hash should always be the same for the same input (string) with no Salt
    const testString = 'HelloKitty';
    final hash5 = hashObject(testString);
    final hash6 = hashObject(testString);
    expect(hash5, equals(hash6));
  });

  test('hashObject throws an error for non-JSON serializable input', () {
    final invalidObject = () => print('not serializable');
    expect(() => hashObject(invalidObject), throwsArgumentError);
  });
}
