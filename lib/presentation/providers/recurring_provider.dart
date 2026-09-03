import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../database/app_database.dart';
import '../../database/tables/recurring_transactions.dart';
import 'database_provider.dart';

final recurringStreamProvider = StreamProvider<List<RecurringTransaction>>((ref) {
  final db = ref.watch(databaseProvider);
  return db.watchRecurring();
});

class RecurringNotifier {
  final AppDatabase db;
  RecurringNotifier(this.db);

  /// Buat aturan baru. nextDate = kemunculan berikutnya SETELAH [from]
  /// (transaksi saat ini dicatat manual terpisah agar tidak dobel).
  Future<int> createRule({
    required double amount,
    required String type,
    required int categoryId,
    String? note,
    required String frequency,
    required DateTime from,
  }) {
    return db.insertRecurring(RecurringTransactionsCompanion.insert(
      amount: amount,
      transactionType: type,
      categoryId: Value(categoryId),
      note: Value(note),
      frequency: Value(frequency),
      nextDate: nextRecurrence(from, frequency),
    ));
  }

  Future<void> setActive(int id, bool active) async {
    final rule = await (db.select(db.recurringTransactions)..where((r) => r.id.equals(id))).getSingleOrNull();
    if (rule != null) await db.updateRecurring(rule.copyWith(isActive: active));
  }

  Future<int> deleteRule(int id) => db.deleteRecurring(id);
}

final recurringNotifierProvider = Provider<RecurringNotifier>((ref) {
  final db = ref.watch(databaseProvider);
  return RecurringNotifier(db);
});
