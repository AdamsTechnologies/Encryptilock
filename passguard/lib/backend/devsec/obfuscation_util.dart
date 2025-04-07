import 'dart:convert';

class ObfuscationUtil {
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
}
