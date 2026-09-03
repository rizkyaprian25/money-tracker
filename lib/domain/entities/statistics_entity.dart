/// Mirror `StatisticsData` / `MonthlyPoint` / `DailyPoint` di `lib/presentation/providers/statistics_provider.dart:9-37`
library;

enum StatisticsPeriod { daily, weekly, monthly, yearly }

class StatisticsEntity {
  final double totalExpense;
  final double totalIncome;
  final double changePercent;
  final Map<String, double> byCategory;
  final List<MonthlyPointEntity> monthlyPoints;
  final List<DailyPointEntity> trendPoints;

  const StatisticsEntity({
    required this.totalExpense,
    required this.totalIncome,
    required this.changePercent,
    required this.byCategory,
    required this.monthlyPoints,
    required this.trendPoints,
  });
}

class MonthlyPointEntity {
  final String label;
  final double income;
  final double expense;
  const MonthlyPointEntity(this.label, this.income, this.expense);
}

class DailyPointEntity {
  final DateTime date;
  final double amount;
  const DailyPointEntity(this.date, this.amount);
}
