import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../database/app_database.dart';
import 'database_provider.dart';

class DashboardData {
  final double balance;
  final double monthlyIncome;
  final double monthlyExpense;
  final double remainingBudget;
  final List<TransactionWithCategory> recent;
  final Map<String, double> expenseByCategory;
  DashboardData({
    required this.balance,
    required this.monthlyIncome,
    required this.monthlyExpense,
    required this.recent,
    required this.expenseByCategory,
    required this.remainingBudget,
  });
}

final dashboardProvider = FutureProvider<DashboardData>((ref) async {
  final db = ref.watch(databaseProvider);
  // watch for invalidation
  final recent = await db.getTransactions(limit: 5);
  final now = DateTime.now();
  final start = DateTime(now.year, now.month, 1);
  final end = DateTime(now.year, now.month + 1, 0, 23, 59, 59);
  final income = await db.getTotalIncome(start, end);
  final expense = await db.getTotalExpense(start, end);
  final balance = await db.getBalance();

  // expense by category
  final allExpenseTx = await db.getTransactions(
    type: 'expense',
    startDate: start,
    endDate: end,
    limit: 1000,
  );
  final Map<String, double> byCat = {};
  for (final twc in allExpenseTx) {
    final name = twc.category?.name ?? 'Lainnya';
    byCat[name] = (byCat[name] ?? 0) + twc.transaction.amount;
  }

  // remaining budget: sum budgets - expense
  final budgets = await db.select(db.budgets).get();
  // filter current month budgets
  final currentBudgets = budgets.where((b) => b.month == now.month && b.year == now.year);
  final totalBudget = currentBudgets.fold<double>(0, (p, b) => p + b.amount);
  final remaining = totalBudget - expense;
  // also watch streams to auto refresh
  ref.watch(databaseProvider).watchTransactions(limit: 5);

  return DashboardData(
    balance: balance,
    monthlyIncome: income,
    monthlyExpense: expense,
    recent: recent,
    expenseByCategory: byCat,
    remainingBudget: remaining > 0 ? remaining : 0,
  );
});
