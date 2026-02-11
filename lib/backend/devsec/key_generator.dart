import 'dart:convert';
import 'dart:typed_data';
import 'dart:math';
import 'package:cryptography/cryptography.dart';

/// Generates a 256-bit key using Argon2id KDF.
Future<Map<String, dynamic>> generateKey(String password, [dynamic salt]) async {
  if (password.isEmpty) {
    throw ArgumentError("Password must be a non-empty string.");
  }

  if (salt == null) {
    salt = Uint8List.fromList(List<int>.generate(16, (_) => Random.secure().nextInt(256)));
  } else if (salt is String) {
    salt = base64Url.decode(salt);
  } else if (salt is! Uint8List) {
    throw ArgumentError("Salt must be a base64 string or Uint8List.");
  }
  final algorithm = Argon2id(
    parallelism: 1,
    memory: 20000, //19MiB
    iterations: 1,
    hashLength: 32, // 256bit
  );
  // derive the key
  final secretKey = await algorithm.deriveKeyFromPassword(password: password, nonce: salt);
  // extract bytes and encode b64
  final keyBytes = await secretKey.extractBytes();
  final base64Key = base64Url.encode(keyBytes);
  // Return the derived key as a base64 string and the salt

  return {
    "key": base64Key, // URL-safe Base64-encoded derived key
    "salt": base64Url.encode(salt), // URL-safe Base64-encoded salt
  };
}
