import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';

/// Wrapper sidik jari/biometrik (v1.1). Web: selalu tidak tersedia.
class BiometricAuth {
  static final LocalAuthentication _auth = LocalAuthentication();

  /// True bila perangkat punya hardware biometrik + terdaftar.
  /// Catatan: HANYA untuk visibilitas tombol. Keputusan akhir selalu dari
  /// hasil `authenticate()` (gate ini bisa false-negative di sebagian HP).
  static Future<bool> get isAvailable async {
    if (kIsWeb) return false;
    try {
      final supported = await _auth.isDeviceSupported();
      if (!supported) return false;
      final enrolled = await _auth.getAvailableBiometrics();
      return enrolled.isNotEmpty;
    } on PlatformException {
      return false;
    } catch (_) {
      return false;
    }
  }

  /// Minta autentikasi biometrik. Selalu panggil langsung (tanpa gate
  /// `isAvailable`) — dialog sistem sendiri yang menangani semua kasus
  /// (belum daftar, terkunci, dibatalkan) via kode error.
  static Future<BiometricResult> authenticate() async {
    try {
      final ok = await _auth.authenticate(
        localizedReason: 'Buka kunci Money Tracker',
        options: const AuthenticationOptions(biometricOnly: true, stickyAuth: true),
      );
      return BiometricResult(ok: ok);
    } on PlatformException catch (e) {
      return BiometricResult(ok: false, code: e.code, message: e.message);
    } catch (_) {
      return BiometricResult(ok: false, code: 'unknown');
    }
  }

  /// Pesanramah untuk kode error local_auth agar user tahu penyebabnya.
  static String friendlyMessage(String? code) {
    switch (code) {
      case 'NotAvailable':
        return 'HP ini tidak mendukung sidik jari.';
      case 'NotEnrolled':
      case 'PasscodeNotSet':
        return 'Belum ada sidik jari terdaftar. Daftarkan dulu di Pengaturan HP → Keamanan → Sidik jari.';
      case 'LockedOut':
      case 'TemporarilyLockedOut':
        return 'Terkunci sementara (terlalu banyak gagal). Tunggu sebentar lalu coba lagi.';
      case 'PermanentlyLockedOut':
        return 'Terkunci — buka HP dengan PIN sekali, lalu coba lagi.';
      case 'unknown':
        return 'Sidik jari gagal. Coba lagi.';
      default:
        return 'Sidik jari gagal ($code). Coba lagi.';
    }
  }
}

/// Hasil autentikasi biometrik. `code == null` + `ok == false`
/// artinya user membatalkan sendiri (jangan tampilkan error).
class BiometricResult {
  final bool ok;
  final String? code;
  final String? message;
  const BiometricResult({required this.ok, this.code, this.message});
}
