import '../../database/app_database.dart';
import '../../domain/entities/statistics_entity.dart';
import '../../domain/repositories/statistics_repository.dart';

class StatisticsRepositoryImpl implements StatisticsRepository {
  final AppDatabase db;
  StatisticsRepositoryImpl(this.db);

  @override
  Future<StatisticsEntity> getStatistics(StatisticsPeriod period) async {
    final now = DateTime.now();
    DateTime start;
    DateTime end;
    DateTime prevStart;
    DateTime prevEnd;

    switch (period) {
      case StatisticsPeriod.daily:
        start = DateTime(now.year, now.month, now.day);
        end = DateTime(now.year, now.month, now.day, 23, 59, 59);
        prevStart = start.subtract(const Duration(days: 1));
        prevEnd = end.subtract(const Duration(days: 1));
        break;
      case StatisticsPeriod.weekly:
        start = now.subtract(Duration(days: now.weekday - 1));
        start = DateTime(start.year, start.month, start.day);
        end = start.add(const Duration(days: 6, hours: 23, minutes: 59, seconds: 59));
        prevStart = start.subtract(const Duration(days: 7));
        prevEnd = end.subtract(const Duration(days: 7));
        break;
      case StatisticsPeriod.yearly:
        start = DateTime(now.year, 1, 1);
        end = DateTime(now.year, 12, 31, 23, 59, 59);
        prevStart = DateTime(now.year - 1, 1, 1);
        prevEnd = DateTime(now.year - 1, 12, 31, 23, 59, 59);
        break;
      case StatisticsPeriod.monthly:
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

    final txs = await db.getTransactions(type: 'expense', startDate: start, endDate: end, limit: 2000);
    final Map<String, double> byCat = {};
    for (final t in txs) {
      final name = t.category?.name ?? 'Lainnya';
      byCat[name] = (byCat[name] ?? 0) + t.transaction.amount;
    }

    List<MonthlyPointEntity> monthlyPoints = [];
    for (int i = 5; i >= 0; i--) {
      final d = DateTime(now.year, now.month - i, 1);
      final s = DateTime(d.year, d.month, 1);
      final e = DateTime(d.year, d.month + 1, 0, 23, 59, 59);
      final inc = await db.getTotalIncome(s, e);
      final exp = await db.getTotalExpense(s, e);
      final label = _monthLabel(d.month);
      monthlyPoints.add(MonthlyPointEntity(label, inc, exp));
    }

    List<DailyPointEntity> trend = [];
    final days = period == StatisticsPeriod.daily ? 1 : period == StatisticsPeriod.weekly ? 7 : period == StatisticsPeriod.monthly ? 30 : 12;
    if (period == StatisticsPeriod.yearly) {
      for (int m = 1; m <= 12; m++) {
        final s = DateTime(now.year, m, 1);
        final e = DateTime(now.year, m + 1, 0, 23, 59, 59);
        final exp = await db.getTotalExpense(s, e);
        trend.add(DailyPointEntity(s, exp));
      }
    } else {
      for (int i = days - 1; i >= 0; i--) {
        final d = DateTime(now.year, now.month, now.day).subtract(Duration(days: i));
        final s = DateTime(d.year, d.month, d.day);
        final e = DateTime(d.year, d.month, d.day, 23, 59, 59);
        final exp = await db.getTotalExpense(s, e);
        trend.add(DailyPointEntity(d, exp));
      }
    }

    return StatisticsEntity(
      totalExpense: expense,
      totalIncome: income,
      changePercent: change,
      byCategory: byCat,
      monthlyPoints: monthlyPoints,
      trendPoints: trend,
    );
  }

  String _monthLabel(int month) {
    const labels = ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'];
    return labels[month - 1];
  }
}
