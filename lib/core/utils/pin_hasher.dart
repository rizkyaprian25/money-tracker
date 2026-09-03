import 'dart:convert';
import 'package:crypto/crypto.dart';

/// Hash PIN kunci layar (v1.1). SHA-256 + salt statis agar PIN mentah
/// tidak tersimpan di database. Pure Dart (paket `crypto`), unit-testable.
class PinHasher {
  static const int pinLength = 6;
  static const String _salt = 'moneytracker-pin-v1';

  static String hash(String pin) {
    final bytes = utf8.encode('$_salt|$pin');
    return sha256.convert(bytes).toString();
  }

  static bool verify(String pin, String hash) => hash.isNotEmpty && hash == PinHasher.hash(pin);

  static bool isValidFormat(String pin) => RegExp(r'^\d{6}$').hasMatch(pin);
}
