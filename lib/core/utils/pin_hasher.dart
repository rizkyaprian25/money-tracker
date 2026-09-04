import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';

/// Hash PIN kunci layar (v1.1). SHA-256 + salt ACAK per-install
/// (pentest 2026-09-04: sebelumnya salt statis app-wide). Pure Dart,
/// unit-testable.
class PinHasher {
  static const int pinLength = 6;
  // Salt lama (v4): statis app-wide. Dipertahankan HANYA untuk verifikasi
  // PIN yang dibuat sebelum pentest 2026-09-04, lalu di-upgrade otomatis.
  static const String _legacySalt = 'moneytracker-pin-v1';

  /// Salt hex 16 byte dari RNG aman.
  static String generateSalt() {
    final rand = Random.secure();
    final bytes = List<int>.generate(16, (_) => rand.nextInt(256));
    return bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
  }

  static String hash(String pin, String salt) {
    final bytes = utf8.encode('$salt|$pin');
    return sha256.convert(bytes).toString();
  }

  static bool verify(String pin, String hash, String salt) =>
      hash.isNotEmpty && hash == PinHasher.hash(pin, salt);

  /// Cocokkan PIN lama (salt statis). True -> panggil `setPin` untuk upgrade.
  static bool verifyLegacy(String pin, String hash, String salt) =>
      salt.isEmpty && hash.isNotEmpty && hash == PinHasher.hash(pin, _legacySalt);

  static bool isValidFormat(String pin) => RegExp(r'^\d{6}$').hasMatch(pin);
}
