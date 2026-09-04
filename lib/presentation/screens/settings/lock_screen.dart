import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/utils/pin_hasher.dart';
import '../../../services/biometric_auth.dart';
import '../../providers/lock_provider.dart';
import '../../providers/settings_provider.dart';

/// Layar kunci PIN 6 digit (v1.1). Ditampilkan oleh `MoneyTrackerApp`
/// bila settings `pinHash` terisi dan `appLockedProvider == true`.
class LockScreen extends ConsumerStatefulWidget {
  final String pinHash;
  final String pinSalt;
  final bool biometricEnabled;
  final VoidCallback onUnlocked;
  const LockScreen({super.key, required this.pinHash, this.pinSalt = '', this.biometricEnabled = true, required this.onUnlocked});

  @override
  ConsumerState<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends ConsumerState<LockScreen> {
  String _pin = '';
  String? _error;

  Future<void> _unlockBio() async {
    final res = await BiometricAuth.authenticate();
    if (!mounted) return;
    if (res.ok) {
      ref.read(appLockedProvider.notifier).state = false;
      widget.onUnlocked();
    } else if (res.code != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(BiometricAuth.friendlyMessage(res.code)), duration: const Duration(seconds: 4)),
      );
    }
  }

  void _press(String d) {
    if (_pin.length >= PinHasher.pinLength) return;
    setState(() {
      _pin += d;
      _error = null;
    });
    if (_pin.length == PinHasher.pinLength) {
      Future.delayed(const Duration(milliseconds: 150), _submit);
    }
  }

  void _backspace() {
    if (_pin.isEmpty) return;
    setState(() {
      _pin = _pin.substring(0, _pin.length - 1);
      _error = null;
    });
  }

  void _submit() async {
    if (!mounted) return;
    final pin = _pin;
    if (PinHasher.verify(pin, widget.pinHash, widget.pinSalt)) {
      _unlock();
    } else if (PinHasher.verifyLegacy(pin, widget.pinHash, widget.pinSalt)) {
      // PIN lama (salt statis): upgrade ke salt acak tanpa ganggu user
      try {
        await ref.read(settingsNotifierProvider).setPin(pin);
      } catch (_) {}
      if (!mounted) return;
      _unlock();
    } else {
      setState(() {
        _error = 'PIN salah, coba lagi';
        _pin = '';
      });
    }
  }

  void _unlock() {
    ref.read(appLockedProvider.notifier).state = false;
    widget.onUnlocked();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: scheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: scheme.primary, shape: BoxShape.circle),
              child: const Icon(Icons.lock, color: Colors.white, size: 32),
            ),
            const SizedBox(height: 16),
            const Text('Money Tracker Terkunci', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
            const SizedBox(height: 4),
            Text('Masukkan PIN 6 digit', style: TextStyle(fontSize: 13, color: scheme.onSurfaceVariant)),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (var i = 0; i < PinHasher.pinLength; i++)
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 6),
                    width: 14,
                    height: 14,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: i < _pin.length ? scheme.primary : scheme.surfaceContainerHighest,
                      border: Border.all(color: scheme.outlineVariant),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 20,
              child: _error == null
                  ? null
                  : Text(_error!, style: TextStyle(fontSize: 12, color: scheme.error, fontWeight: FontWeight.w600)),
            ),
            const Spacer(),
            if (widget.biometricEnabled) ...[
              FilledButton.tonalIcon(
                onPressed: _unlockBio,
                icon: const Icon(Icons.fingerprint, size: 28),
                label: const Text('Buka dengan sidik jari'),
              ),
              const SizedBox(height: 8),
              Text('atau PIN', style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant)),
              const SizedBox(height: 8),
            ],
            for (final row in [
              ['1', '2', '3'],
              ['4', '5', '6'],
              ['7', '8', '9'],
              ['', '0', 'back'],
            ])
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    for (final k in row)
                      SizedBox(
                        width: 72,
                        height: 56,
                        child: k.isEmpty
                            ? const SizedBox.shrink()
                            : k == 'back'
                                ? IconButton(onPressed: _backspace, icon: const Icon(Icons.backspace_outlined))
                                : FilledButton.tonal(
                                    onPressed: () => _press(k),
                                    style: FilledButton.styleFrom(shape: const CircleBorder()),
                                    child: Text(k, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w600)),
                                  ),
                      ),
                  ],
                ),
              ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
