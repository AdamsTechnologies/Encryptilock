import 'dart:convert';
import 'dart:typed_data';
import 'package:cryptography/cryptography.dart';

class Encrypto {
  final Uint8List key;

  Encrypto(String base64Key) : key = _parseKey(base64Key);

  /// Parses and validates the key.
  static Uint8List _parseKey(String base64Key) {
    try {
      final keyBytes = base64Url.decode(base64Key);
      if (keyBytes.length != 32) {
        throw ArgumentError('Key must be 32 bytes for AES-256.');
      }
      return Uint8List.fromList(keyBytes);
    } catch (_) {
      throw ArgumentError('Invalid key format. Must be a base64-encoded 32-byte string.');
    }
  }

  /// Encrypts data using AES-GCM.
  Future<Uint8List> encrypt(Uint8List plainText) async {
    final aesGcm = AesGcm.with256bits();
    final nonce = _generateNonce();
    final secretKey = SecretKey(key);

    final secretBox = await aesGcm.encrypt(
      plainText,
      secretKey: secretKey,
      nonce: nonce,
    );

    // Return concatenated nonce + ciphertext + MAC
    return Uint8List.fromList([
      ...nonce,
      ...secretBox.cipherText,
      ...secretBox.mac.bytes,
    ]);
  }

  /// Decrypts data using AES-GCM.
  Future<Uint8List> decrypt(Uint8List encryptedData) async {
    // Must be at least 12 bytes (nonce) + 16 bytes (MAC).
    if (encryptedData.length < 28) {
      throw ArgumentError(
          'Invalid encrypted data. Must include at least a 12-byte nonce, ciphertext, and 16-byte MAC.');
    }

    final aesGcm = AesGcm.with256bits();
    final nonce = encryptedData.sublist(0, 12);
    final cipherText = encryptedData.sublist(12, encryptedData.length - 16);
    final macBytes = encryptedData.sublist(encryptedData.length - 16);
    final secretKey = SecretKey(key);

    return Uint8List.fromList(
      await aesGcm.decrypt(
        SecretBox(cipherText, nonce: nonce, mac: Mac(macBytes)),
        secretKey: secretKey,
      ),
    );
  }

  /// Encrypts any data (String, int, List, etc.) by:
  /// 1) Converting it to a String via `toString()` if it's not already Uint8List.
  /// 2) Converting that String to UTF-8 bytes.
  /// 3) Encrypting the bytes (nonce + ciphertext + MAC).
  /// 4) Returning the result as a base64 URL-safe string.
  Future<String> encrypto(dynamic data) async {
    // Convert to bytes
    final plainTextBytes = (data is Uint8List)
        ? data
        : Uint8List.fromList(utf8.encode(data.toString()));

    final encryptedBytes = await encrypt(plainTextBytes);
    return base64Url.encode(encryptedBytes);
  }

  /// Decrypts a base64 URL-safe string. Returns either a UTF-8 decoded string
  /// (if decoding succeeds) or raw bytes if the decrypted data isn't valid UTF-8.
  Future<dynamic> decrypto(String encryptedBase64) async {
    // Decode from base64
    Uint8List encryptedBytes;
    try {
      encryptedBytes = base64Url.decode(encryptedBase64);
    } catch (e) {
      throw ArgumentError('Failed to base64-decode the input. Ensure it is valid base64url.');
    }

    // Decrypt
    final decryptedBytes = await decrypt(encryptedBytes);

    // Attempt to interpret as UTF-8 text
    try {
      final text = utf8.decode(decryptedBytes);
      // If successful, return the decoded string
      return text;
    } catch (e) {
      // If decoding fails, return raw bytes
      return decryptedBytes;
    }
  }

  /// Encodes raw bytes to a Base64 URL-safe string.
  String base64Encode(Uint8List data) {
    return base64Url.encode(data);
  }

  /// Decodes a Base64 URL-safe string to raw bytes.
  Uint8List base64Decode(String base64String) {
    return Uint8List.fromList(base64Url.decode(base64String));
  }

  /// Generates a secure random nonce (12 bytes for AES-GCM).
  Uint8List _generateNonce() {
    return Uint8List.fromList(AesGcm.with256bits().newNonce());
  }
}
