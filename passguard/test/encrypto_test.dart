import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:encryptilock/backend/devsec/encrypto.dart';

void main() {
  group('Encrypto Tests', () {
    late Encrypto encrypto;

    setUp(() {
      // Generate a random 32-byte key at runtime
      final random = Random.secure();
      final keyBytes = List<int>.generate(32, (_) => random.nextInt(256));
      final base64Key = base64Url.encode(keyBytes);

      encrypto = Encrypto(base64Key);
    });

    test('encrypt() & decrypt() with raw bytes', () async {
      final testPlainText = 'Hello, world!';
      final testBytes = Uint8List.fromList(utf8.encode(testPlainText));

      final encrypted = await encrypto.encrypt(testBytes);
      final decryptedBytes = await encrypto.decrypt(encrypted);

      expect(utf8.decode(decryptedBytes), testPlainText);
    });

    test('base64Encode() & base64Decode()', () {
      final testPlainText = 'Flutter is awesome!';
      final encoded = encrypto.base64Encode(Uint8List.fromList(utf8.encode(testPlainText)));
      final decoded = encrypto.base64Decode(encoded);

      expect(utf8.decode(decoded), testPlainText);
    });

    test('encrypto() & decrypto() returns original string (UTF-8)', () async {
      final testPlainText = 'PassGuard is secure!';

      final encryptedString = await encrypto.encrypto(testPlainText);
      final decrypted = await encrypto.decrypto(encryptedString);

      expect(decrypted, isA<String>());
      expect(decrypted, testPlainText);
    });

    test('encrypto() & decrypto() returns original raw bytes (non-UTF8)', () async {
      // Create some raw bytes that won't decode as valid UTF-8.
      final originalBytes = Uint8List.fromList([
        0xFF,
        0xD8,
        0x00,
        0xFE,
        0x01,
        0x02
      ]);

      final encryptedString = await encrypto.encrypto(originalBytes);
      final decrypted = await encrypto.decrypto(encryptedString);

      // Because these bytes are invalid UTF-8, decrypto() should return a Uint8List
      expect(decrypted, isA<Uint8List>());
      expect(decrypted, originalBytes);
    });

    test('Invalid key length should throw an error', () {
      // A short string that won't decode to 32 bytes
      const invalidKey = 'invalid_key';
      expect(() => Encrypto(invalidKey), throwsArgumentError);
    });

    test('Decrypt invalid data should throw an error', () async {
      // Not enough bytes for nonce + MAC
      final invalidData = Uint8List.fromList([
        1,
        2,
        3
      ]);
      await expectLater(() => encrypto.decrypt(invalidData), throwsArgumentError);
    });

    test('base64Decode() invalid input should throw FormatException', () {
      const invalidBase64 = 'not_base64!!';
      expect(() => encrypto.base64Decode(invalidBase64), throwsFormatException);
    });
  });
}
