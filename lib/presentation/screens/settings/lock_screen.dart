import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/utils/pin_hasher.dart';
import '../../providers/lock_provider.dart';

/// Layar kunci PIN 6 digit (v1.1). Ditampilkan oleh `MoneyTrackerApp`
/// bila settings `pinHash` terisi dan `appLockedProvider == true`.
class LockScreen extends ConsumerStatefulWidget {
  final String pinHash;
  final VoidCallback onUnlocked;
  const LockScreen({super.key, required this.pinHash, required this.onUnlocked});

  @override
  ConsumerState<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends ConsumerState<LockScreen> {
  String _pin = '';
  String? _error;

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

  void _submit() {
    if (!mounted) return;
    if (PinHasher.verify(_pin, widget.pinHash)) {
      ref.read(appLockedProvider.notifier).state = false;
      widget.onUnlocked();
    } else {
      setState(() {
        _error = 'PIN salah, coba lagi';
        _pin = '';
      });
    }
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
