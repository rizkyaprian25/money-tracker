import 'package:drift/drift.dart';

/// Aturan transaksi berulang (gaji, cicilan, langganan).
/// v4 (fitur v1.1): dibuat dari sheet tambah transaksi, digenerate
/// otomatis oleh `processDueRecurring()` tiap dashboard dimuat.
class RecurringTransactions extends Table {
  IntColumn get id => integer().autoIncrement()();
  RealColumn get amount => real()();
  TextColumn get transactionType => text()(); // income | expense
  IntColumn get categoryId =>
      integer().nullable().customConstraint('NULL REFERENCES categories(id) ON DELETE SET NULL')();
  TextColumn get note => text().nullable()();
  TextColumn get frequency => text().withDefault(const Constant('monthly'))(); // weekly | monthly
  DateTimeColumn get nextDate => dateTime()();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

/// Hitung kemunculan berikutnya (pure, unit-testable).
/// monthly: tanggal sama, dijepit ke akhir bulan bila perlu (31 Jan -> 28/29 Feb).
DateTime nextRecurrence(DateTime from, String frequency) {
  if (frequency == 'weekly') return from.add(const Duration(days: 7));
  // monthly (default)
  final year = from.month == 12 ? from.year + 1 : from.year;
  final month = from.month == 12 ? 1 : from.month + 1;
  final lastDay = DateTime(year, month + 1, 0).day;
  final day = from.day > lastDay ? lastDay : from.day;
  return DateTime(year, month, day, from.hour, from.minute);
}
