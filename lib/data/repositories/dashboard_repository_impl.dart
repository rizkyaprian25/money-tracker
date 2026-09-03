import '../../database/app_database.dart';
import '../../domain/entities/dashboard_entity.dart';
import '../../domain/repositories/dashboard_repository.dart';
import '../mappers/entity_mapper.dart';

class DashboardRepositoryImpl implements DashboardRepository {
  final AppDatabase db;
  DashboardRepositoryImpl(this.db);

  @override
  Future<DashboardEntity> getDashboard() async {
    final recentRows = await db.getTransactions(limit: 5);
    final recent = recentRows.map((e) => e.toEntity()).toList();

    final now = DateTime.now();
    final start = DateTime(now.year, now.month, 1);
    final end = DateTime(now.year, now.month + 1, 0, 23, 59, 59);
    final income = await db.getTotalIncome(start, end);
    final expense = await db.getTotalExpense(start, end);
    final balance = await db.getBalance();

    final allExpenseTx = await db.getTransactions(type: 'expense', startDate: start, endDate: end, limit: 1000);
    final Map<String, double> byCat = {};
    for (final twc in allExpenseTx) {
      final name = twc.category?.name ?? 'Lainnya';
      byCat[name] = (byCat[name] ?? 0) + twc.transaction.amount;
    }

    final budgets = await db.select(db.budgets).get();
    final currentBudgets = budgets.where((b) => b.month == now.month && b.year == now.year);
    final totalBudget = currentBudgets.fold<double>(0, (p, b) => p + b.amount);
    final remaining = (totalBudget - expense) > 0 ? totalBudget - expense : 0.0;

    return DashboardEntity(
      balance: balance,
      monthlyIncome: income,
      monthlyExpense: expense,
      recent: recent,
      expenseByCategory: byCat,
      remainingBudget: remaining.toDouble(),
    );
  }

  @override
  Stream<void> watchDashboardTrigger() {
    // Trigger stream: watch transactions briefly to invalidate dashboard
    return db.watchTransactions(limit: 5).map((_) {});
  }
}
