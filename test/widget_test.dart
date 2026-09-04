import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:money_tracker_personal/core/constants/app_constants.dart';
import 'package:money_tracker_personal/core/utils/budget_warning_helper.dart';
import 'package:money_tracker_personal/core/utils/currency_formatter.dart';
import 'package:money_tracker_personal/core/utils/pin_hasher.dart';
import 'package:money_tracker_personal/database/tables/recurring_transactions.dart';
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

    test('formatWithoutSymbol memakai titik ribuan', () {
      expect(CurrencyFormatter.formatWithoutSymbol(700000), '700.000');
    });
  });

  group('Budget threshold 80% (PRD §8.6)', () {    test('threshold terkunci 0.8', () {
      expect(AppConstants.budgetWarningThreshold, 0.8);
    });

    test('shouldWarn false di bawah 0.8, true di 0.8 ke atas', () {
      expect(BudgetWarningHelper.shouldWarn(0.79), isFalse);
      expect(BudgetWarningHelper.shouldWarn(0.8), isTrue);
      expect(BudgetWarningHelper.shouldWarn(1.2), isTrue);
    });
  });

  group('Transaksi berulang nextRecurrence (v1.1)', () {
    test('mingguan +7 hari', () {
      expect(nextRecurrence(DateTime(2026, 9, 3), 'weekly'), DateTime(2026, 9, 10));
    });

    test('bulanan tanggal sama', () {
      expect(nextRecurrence(DateTime(2026, 9, 15), 'monthly'), DateTime(2026, 10, 15));
    });

    test('bulanan ganti tahun Des -> Jan', () {
      expect(nextRecurrence(DateTime(2026, 12, 5), 'monthly'), DateTime(2027, 1, 5));
    });

    test('bulanan 31 Jan dijepit ke 28 Feb (non-kabisat)', () {
      expect(nextRecurrence(DateTime(2026, 1, 31), 'monthly'), DateTime(2026, 2, 28));
    });

    test('bulanan 31 Jan dijepit ke 29 Feb (kabisat 2028)', () {
      expect(nextRecurrence(DateTime(2028, 1, 31), 'monthly'), DateTime(2028, 2, 29));
    });
  });

  group('PinHasher kunci layar (v1.1)', () {
    test('hash deterministik & verify benar/salah', () {
      const salt = 'abc123';
      final h1 = PinHasher.hash('123456', salt);
      expect(h1, PinHasher.hash('123456', salt));
      expect(PinHasher.verify('123456', h1, salt), isTrue);
      expect(PinHasher.verify('654321', h1, salt), isFalse);
      expect(PinHasher.verify('123456', '', salt), isFalse);
    });

    test('salt berbeda -> hash berbeda', () {
      expect(PinHasher.hash('123456', 's1'), isNot(PinHasher.hash('123456', 's2')));
      expect(PinHasher.generateSalt().length, 32);
    });

    test('format hanya 6 digit angka', () {
      expect(PinHasher.isValidFormat('123456'), isTrue);
      expect(PinHasher.isValidFormat('12345'), isFalse);
      expect(PinHasher.isValidFormat('abcdef'), isFalse);
    });
  });

  testWidgets('BalanceCard tampil label dan saldo terformat', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: BalanceCard(balance: 4250750, income: 7350000, expense: 3099250),
          ),
        ),
      ),
    );
    expect(find.text('Saldo Saat Ini'), findsOneWidget);
    expect(find.text(CurrencyFormatter.format(4250750)), findsOneWidget);
    expect(find.byIcon(Icons.visibility), findsOneWidget);
    // Ketuk mata -> nominal disensor
    await tester.tap(find.byIcon(Icons.visibility));
    await tester.pump();
    expect(find.text('Rp ••••••'), findsNWidgets(3));
    expect(find.byIcon(Icons.visibility_off), findsOneWidget);
  });
}
