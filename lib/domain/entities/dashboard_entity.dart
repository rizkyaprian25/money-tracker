import 'transaction_entity.dart';

/// Aggregated dashboard value-object — mirror `DashboardData` di `lib/presentation/providers/dashboard_provider.dart:5-20`
class DashboardEntity {
  final double balance;
  final double monthlyIncome;
  final double monthlyExpense;
  final double remainingBudget;
  final List<TransactionEntity> recent;
  final Map<String, double> expenseByCategory;

  const DashboardEntity({
    required this.balance,
    required this.monthlyIncome,
    required this.monthlyExpense,
    required this.remainingBudget,
    required this.recent,
    required this.expenseByCategory,
  });

  double get netMonthly => monthlyIncome - monthlyExpense;
  double get budgetUsage => monthlyIncome == 0 ? 0 : (monthlyExpense / monthlyIncome).clamp(0, 1);
}
