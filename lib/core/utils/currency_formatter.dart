import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class CurrencyFormatter {
  static final _formatter = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp',
    decimalDigits: 0,
  );

  static String format(double amount) {
    // Custom to match Figma: Rp4.250.750 without space handling
    final formatted = _formatter.format(amount);
    // NumberFormat gives "Rp4.250.750" - ensure correct
    return formatted.replaceAll('Rp', 'Rp');
  }

  static String formatCompact(double amount) {
    if (amount >= 1000000000) {
      return 'Rp${(amount / 1000000000).toStringAsFixed(1)}M';
    } else if (amount >= 1000000) {
      return 'Rp${(amount / 1000000).toStringAsFixed(1)}jt';
    } else if (amount >= 1000) {
      return 'Rp${(amount / 1000).toStringAsFixed(0)}rb';
    }
    return format(amount);
  }

  static String formatWithoutSymbol(double amount) {
    final f = NumberFormat('#,###', 'id_ID');
    return f.format(amount);
  }

  static double parse(String input) {
    final cleaned = input.replaceAll(RegExp(r'[^0-9]'), '');
    if (cleaned.isEmpty) return 0;
    return double.tryParse(cleaned) ?? 0;
  }
}

/// Formatter input nominal: ketik `700000` tampil `700.000` otomatis.
/// Dipakai di semua field jumlah (transaksi, anggaran, target, kontribusi).
/// `parse()` tetap bisa membaca hasilnya (non-digit dibuang).
class ThousandsSeparatorInputFormatter extends TextInputFormatter {
  final NumberFormat _f = NumberFormat('#,###', 'id_ID');

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    final digits = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.isEmpty) return const TextEditingValue(text: '');
    final n = int.tryParse(digits);
    if (n == null) return oldValue;
    final formatted = _f.format(n);
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
