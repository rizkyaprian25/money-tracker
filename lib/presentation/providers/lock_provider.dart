import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Status kunci layar (v1.1). `true` = terkunci (awal tiap cold start),
/// dibuka setelah PIN benar. Tidak dipersist (kunci ulang tiap buka app).
final appLockedProvider = StateProvider<bool>((ref) => true);
