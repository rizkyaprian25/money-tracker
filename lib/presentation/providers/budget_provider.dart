import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../database/app_database.dart';
import 'dashboard_provider.dart';
import 'database_provider.dart';

final budgetsStreamProvider = StreamProvider<List<Budget>>((ref) {
  final db = ref.watch(databaseProvider);
  return db.watchBudgets();
});

final budgetWithSpentProvider = FutureProvider<List<BudgetWithSpent>>((ref) async {
  final db = ref.watch(databaseProvider);
  final now = DateTime.now();
  final start = DateTime(now.year, now.month, 1);
  final end = DateTime(now.year, now.month + 1, 0, 23, 59, 59);

  final budgets = await (db.select(db.budgets)..where((b) => b.month.equals(now.month) & b.year.equals(now.year))).get();
  final categories = await db.select(db.categories).get();
  final catMap = {for (var c in categories) c.id: c};

  List<BudgetWithSpent> result = [];
  for (final b in budgets) {
    double spent = 0;
    if (b.categoryId != null) {
      final txs = await db.getTransactions(
        type: 'expense',
        categoryId: b.categoryId,
        startDate: start,
        endDate: end,
        limit: 1000,
      );
      spent = txs.fold(0, (p, e) => p + e.transaction.amount);
    } else {
      spent = await db.getTotalExpense(start, end);
    }
    result.add(BudgetWithSpent(budget: b, spent: spent, category: b.categoryId != null ? catMap[b.categoryId] : null));
  }
  // watch to refresh
  ref.watch(budgetsStreamProvider);
  return result;
});

class BudgetWithSpent {
  final Budget budget;
  final double spent;
  final Category? category;
  BudgetWithSpent({required this.budget, required this.spent, this.category});
  double get progress => budget.amount == 0 ? 0 : spent / budget.amount;
  bool get isWarning => progress >= 0.8 && progress < 1.0;
  bool get isOver => progress >= 1.0;
}

class BudgetNotifier {
  final AppDatabase db;
  final Ref ref;
  BudgetNotifier(this.db, this.ref);

  Future<int> setBudget({int? categoryId, required double amount, required int month, required int year}) async {
    // if exists for cat+month+year update else insert
    final existing = await (db.select(db.budgets)..where((b) {
          if (categoryId == null) {
            return b.categoryId.isNull() & b.month.equals(month) & b.year.equals(year);
          } else {
            return b.categoryId.equals(categoryId) & b.month.equals(month) & b.year.equals(year);
          }
        })).getSingleOrNull();
    final int id;
    if (existing != null) {
      await db.updateBudget(existing.copyWith(amount: amount));
      id = existing.id;
    } else {
      id = await db.insertBudget(BudgetsCompanion.insert(
        categoryId: Value(categoryId),
        amount: amount,
        month: month,
        year: year,
      ));
    }
    // Sisa anggaran di dashboard ikut berubah -> refresh otomatis
    ref.invalidate(dashboardProvider);
    return id;
  }

  Future<int> deleteBudget(int id) async {
    final count = await db.deleteBudget(id);
    ref.invalidate(dashboardProvider);
    return count;
  }
}

final budgetNotifierProvider = Provider<BudgetNotifier>((ref) {
  final db = ref.watch(databaseProvider);
  return BudgetNotifier(db, ref);
});
