import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:passguard/backend/devsec/key_generator.dart';

void main() {
  group('Key Utilities Tests', () {
    test('generateKey creates a valid key and salt', () async {
      const password = 'securepassword';

      // Test with random salt
      final result = await generateKey(password);
      print("result=$result");
      expect(result['key'], isA<String>());
      expect(result['salt'], isA<String>());
      expect(result['salt']!.length, greaterThan(0));

      // Ensure the derived key is a valid base64-encoded string
      final decodedKey = base64Url.decode(result['key']!);
      expect(decodedKey.length, 32); // Key should be 32 bytes (256 bits)

      // Test with predefined salt
      final predefinedSalt = Uint8List.fromList(List<int>.generate(16, (i) => i + 1));
      final resultWithSalt = await generateKey(password, predefinedSalt);
      expect(resultWithSalt['key'], isA<String>());
      expect(resultWithSalt['salt'], base64Url.encode(predefinedSalt));

      // Ensure the key changes when the salt changes
      expect(result['key'], isNot(resultWithSalt['key']));
    });

    test('generateKey creates the same key', () async {
      const password = 'securepassword';
      const salt = 'YDwhcjORxPWGjtwRykDmdQ==';

      // Test with existing salt
      final result = await generateKey(password, salt);
      expect(result['key'], isA<String>());
      expect(result['salt'], isA<String>());
      expect(result['salt']!.length, greaterThan(0));

      Uint8List saltList = base64Url.decode(salt);
      final resultWithUintSalt = await generateKey(password, saltList);
      expect(resultWithUintSalt['key'], equals(result['key']));
    });

    test('generateKey throws an error for empty password', () async {
      await expectLater(() => generateKey(''), throwsArgumentError);
    });
  });
}
