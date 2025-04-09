import 'dart:convert';
import 'package:crypto/crypto.dart'; // For SHA-256

class ObfuscationUtil {
  // irreversably but deterministically hashes a string input.
  static String hashObject(dynamic obj, [String salt = ""]) {
    try {
      final jsonString = jsonEncode(obj);
      final data = utf8.encode(salt + jsonString);
      final digest = sha256.convert(data).toString();
      return digest;
    } catch (e) {
      throw ArgumentError("The object must be JSON-serializable.");
    }
  }

  static String xorCipher(String input, String key) {
    final inputBytes = input.codeUnits;
    final keyBytes = key.codeUnits;
    final outputBytes = List<int>.generate(
      inputBytes.length,
      (i) => inputBytes[i] ^ keyBytes[i % keyBytes.length],
    );
    return base64Encode(outputBytes);
  }

  static String xorDecipher(String encoded, String key) {
    final decodedBytes = base64Decode(encoded);
    final keyBytes = key.codeUnits;
    final outputBytes = List<int>.generate(
      decodedBytes.length,
      (i) => decodedBytes[i] ^ keyBytes[i % keyBytes.length],
    );
    return String.fromCharCodes(outputBytes);
  }

  static String encodeBase64(String input) {
    return base64Encode(utf8.encode(input));
  }

  static String decodeBase64(String encoded) {
    return utf8.decode(base64Decode(encoded));
  }
}
