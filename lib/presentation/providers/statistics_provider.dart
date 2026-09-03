import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'database_provider.dart';

enum Period { daily, weekly, monthly, yearly }

final periodProvider = StateProvider<Period>((ref) => Period.monthly);

class StatisticsData {
  final double totalExpense;
  final double totalIncome;
  final double changePercent;
  final Map<String, double> byCategory;
  final List<MonthlyPoint> monthlyPoints; // last 6 months
  final List<DailyPoint> trendPoints;
  StatisticsData({
    required this.totalExpense,
    required this.totalIncome,
    required this.changePercent,
    required this.byCategory,
    required this.monthlyPoints,
    required this.trendPoints,
  });
}

class MonthlyPoint {
  final String label;
  final double income;
  final double expense;
  MonthlyPoint(this.label, this.income, this.expense);
}

class DailyPoint {
  final DateTime date;
  final double amount;
  DailyPoint(this.date, this.amount);
}

final statisticsProvider = FutureProvider<StatisticsData>((ref) async {
  final db = ref.watch(databaseProvider);
  final period = ref.watch(periodProvider);
  final now = DateTime.now();

  DateTime start;
  DateTime end;
  DateTime prevStart;
  DateTime prevEnd;

  switch (period) {
    case Period.daily:
      start = DateTime(now.year, now.month, now.day);
      end = DateTime(now.year, now.month, now.day, 23, 59, 59);
      prevStart = start.subtract(const Duration(days: 1));
      prevEnd = end.subtract(const Duration(days: 1));
      break;
    case Period.weekly:
      start = now.subtract(Duration(days: now.weekday - 1));
      start = DateTime(start.year, start.month, start.day);
      end = start.add(const Duration(days: 6, hours: 23, minutes: 59, seconds: 59));
      prevStart = start.subtract(const Duration(days: 7));
      prevEnd = end.subtract(const Duration(days: 7));
      break;
    case Period.yearly:
      start = DateTime(now.year, 1, 1);
      end = DateTime(now.year, 12, 31, 23, 59, 59);
      prevStart = DateTime(now.year - 1, 1, 1);
      prevEnd = DateTime(now.year - 1, 12, 31, 23, 59, 59);
      break;
    case Period.monthly:
      start = DateTime(now.year, now.month, 1);
      end = DateTime(now.year, now.month + 1, 0, 23, 59, 59);
      prevStart = DateTime(now.year, now.month - 1, 1);
      prevEnd = DateTime(now.year, now.month, 0, 23, 59, 59);
  }

  final expense = await db.getTotalExpense(start, end);
  final income = await db.getTotalIncome(start, end);
  final prevExpense = await db.getTotalExpense(prevStart, prevEnd);
  double change = 0;
  if (prevExpense > 0) {
    change = ((expense - prevExpense) / prevExpense) * 100;
  }

  // by category
  final txs = await db.getTransactions(type: 'expense', startDate: start, endDate: end, limit: 2000);
  final Map<String, double> byCat = {};
  for (final t in txs) {
    final name = t.category?.name ?? 'Lainnya';
    byCat[name] = (byCat[name] ?? 0) + t.transaction.amount;
  }

  // monthly points last 6 months
  List<MonthlyPoint> monthlyPoints = [];
  for (int i = 5; i >= 0; i--) {
    final d = DateTime(now.year, now.month - i, 1);
    final s = DateTime(d.year, d.month, 1);
    final e = DateTime(d.year, d.month + 1, 0, 23, 59, 59);
    final inc = await db.getTotalIncome(s, e);
    final exp = await db.getTotalExpense(s, e);
    final label = _monthLabel(d.month);
    monthlyPoints.add(MonthlyPoint(label, inc, exp));
  }

  // trend last 30 days or period days
  List<DailyPoint> trend = [];
  final days = period == Period.daily ? 1 : period == Period.weekly ? 7 : period == Period.monthly ? 30 : 12;
  if (period == Period.yearly) {
    // monthly trend for year
    for (int m = 1; m <= 12; m++) {
      final s = DateTime(now.year, m, 1);
      final e = DateTime(now.year, m + 1, 0, 23, 59, 59);
      final exp = await db.getTotalExpense(s, e);
      trend.add(DailyPoint(s, exp));
    }
  } else {
    for (int i = days - 1; i >= 0; i--) {
      final d = DateTime(now.year, now.month, now.day).subtract(Duration(days: i));
      final s = DateTime(d.year, d.month, d.day);
      final e = DateTime(d.year, d.month, d.day, 23, 59, 59);
      final exp = await db.getTotalExpense(s, e);
      trend.add(DailyPoint(d, exp));
    }
  }

  return StatisticsData(
    totalExpense: expense,
    totalIncome: income,
    changePercent: change,
    byCategory: byCat,
    monthlyPoints: monthlyPoints,
    trendPoints: trend,
  );
});

String _monthLabel(int month) {
  const labels = ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'];
  return labels[month - 1];
}
