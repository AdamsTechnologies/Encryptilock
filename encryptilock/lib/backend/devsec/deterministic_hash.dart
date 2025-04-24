import 'dart:convert';
import 'package:crypto/crypto.dart';

/// Deterministically hashes an object using SHA-256.
/// used to mask inputs that don't require encryption and need a deterministic value.
String hashObject(dynamic obj, [String salt = ""]) {
  try {
    // Convert the object to a JSON string (sorted keys for determinism)
    final jsonString = jsonEncode(obj);
    // Combine salt and JSON string, then encode to bytes
    final data = utf8.encode(salt + jsonString);
    // Compute the SHA-256 digest and return it as a hex string
    final digest = sha256.convert(data).toString();
    return digest;
  } catch (e) {
    throw ArgumentError("The object must be JSON-serializable.");
  }
}
