import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:money_tracker_personal/core/constants/app_constants.dart';
import 'package:money_tracker_personal/core/utils/budget_warning_helper.dart';
import 'package:money_tracker_personal/core/utils/currency_formatter.dart';
import 'package:money_tracker_personal/presentation/widgets/balance_card.dart';

// Catatan: full-app pump sengaja TIDAK dipakai di sini karena dua alasan
// yang terdokumentasi saat perbaikan ERROR.md Fase 5:
//  1. AppDatabase native membuka sqlite file (Timer pending di fake_async).
//  2. AppTheme pakai google_fonts runtime fetch (butuh network/aset font).
// Smoke test memakai widget + unit test hermetis di bawah ini.

void main() {
  setUpAll(() async {
    await initializeDateFormatting('id_ID');
  });

  group('CurrencyFormatter (IDR, id_ID)', () {
    test('format memakai simbol Rp dan pemisah ribuan titik', () {
      final formatted = CurrencyFormatter.format(4250750);
      expect(formatted.startsWith('Rp'), isTrue);
      expect(formatted.contains('4.250.750'), isTrue);
    });

    test('parse membersihkan prefix Rp dan titik ribuan', () {
      expect(CurrencyFormatter.parse('Rp4.250.750'), 4250750);
      expect(CurrencyFormatter.parse(''), 0);
      expect(CurrencyFormatter.parse('Rp 0'), 0);
    });

    test('formatCompact menyingkat jt/M', () {
      expect(CurrencyFormatter.formatCompact(2500000).contains('jt'), isTrue);
      expect(CurrencyFormatter.formatCompact(1500000000).contains('M'), isTrue);
    });
  });

  group('Budget threshold 80% (PRD §8.6)', () {
    test('threshold terkunci 0.8', () {
      expect(AppConstants.budgetWarningThreshold, 0.8);
    });

    test('shouldWarn false di bawah 0.8, true di 0.8 ke atas', () {
      expect(BudgetWarningHelper.shouldWarn(0.79), isFalse);
      expect(BudgetWarningHelper.shouldWarn(0.8), isTrue);
      expect(BudgetWarningHelper.shouldWarn(1.2), isTrue);
    });
  });

  testWidgets('BalanceCard tampil label dan saldo terformat', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: BalanceCard(balance: 4250750, income: 7350000, expense: 3099250),
        ),
      ),
    );
    expect(find.text('Saldo Saat Ini'), findsOneWidget);
    expect(find.text(CurrencyFormatter.format(4250750)), findsOneWidget);
  });
}
