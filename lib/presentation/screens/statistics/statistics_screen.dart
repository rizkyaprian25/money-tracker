import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../providers/statistics_provider.dart';

class StatisticsScreen extends ConsumerWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final period = ref.watch(periodProvider);
    final statsAsync = ref.watch(statisticsProvider);
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Row(children: [
          Container(width: 32, height: 32, decoration: BoxDecoration(color: scheme.primary, borderRadius: BorderRadius.circular(8)), clipBehavior: Clip.antiAlias, child: Image.asset('assets/images/logo.png', width: 32, height: 32, fit: BoxFit.cover, errorBuilder: (_, _, _) => const Icon(Icons.account_balance_wallet, color: Colors.white, size: 20))),
          const SizedBox(width: 10),
          const Text('Statistik', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
        ]),
        actions: [Padding(padding: const EdgeInsets.only(right: 12), child: CircleAvatar(backgroundColor: scheme.primary, child: const Icon(Icons.person, color: Colors.white, size: 18)))],
      ),
      body: statsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (data) {
          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // period toggle
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(color: scheme.surfaceContainer, borderRadius: BorderRadius.circular(12)),
                  child: Row(children: [
                    for (final p in Period.values)
                      Expanded(
                        child: InkWell(
                          onTap: () => ref.read(periodProvider.notifier).state = p,
                          borderRadius: BorderRadius.circular(10),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(color: period == p ? scheme.primary : Colors.transparent, borderRadius: BorderRadius.circular(10)),
                            child: Center(child: Text(_periodLabel(p), style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: period == p ? Colors.white : scheme.onSurfaceVariant))),
                          ),
                        ),
                      ),
                  ]),
                ),
                const SizedBox(height: 16),
                // Total Pengeluaran card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: scheme.surfaceContainerLowest, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8)]),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        const Text('Total Pengeluaran', style: TextStyle(fontWeight: FontWeight.w600)),
                        Text(_periodDesc(period), style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant)),
                      ]),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(color: data.changePercent >= 0 ? scheme.errorContainer : scheme.secondaryContainer, borderRadius: BorderRadius.circular(20)),
                        child: Row(children: [
                          Icon(data.changePercent >= 0 ? Icons.trending_up : Icons.trending_down, size: 14, color: data.changePercent >= 0 ? scheme.error : scheme.secondary),
                          const SizedBox(width: 4),
                          Text('${data.changePercent.abs().toStringAsFixed(1)}%', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: data.changePercent >= 0 ? scheme.error : scheme.secondary)),
                        ]),
                      ),
                    ]),
                    const SizedBox(height: 12),
                    Text(CurrencyFormatter.format(data.totalExpense), style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700)),
                    Text(data.changePercent >= 0 ? '+${CurrencyFormatter.format((data.changePercent / 100 * data.totalExpense).abs())} dibanding periode lalu' : '-${CurrencyFormatter.format((data.changePercent / 100 * data.totalExpense).abs())} dibanding periode lalu', style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant)),
                    const SizedBox(height: 12),
                    // simple comparison bars
                    _MiniBar(label: _currentLabel(period), value: 1.0, color: scheme.primary),
                    const SizedBox(height: 6),
                    _MiniBar(label: _prevLabel(period), value: (1 - (data.changePercent / 100)).clamp(0.1, 1.0), color: scheme.outlineVariant),
                  ]),
                ),
                const SizedBox(height: 16),
                // Income vs Expense
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: scheme.surfaceContainerLowest, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8)]),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const Text('Pemasukan vs Pengeluaran', style: TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 180,
                      child: Builder(builder: (context) {
                        // Fase 3: bar interval dinamis — hitung maxY + interval adaptif (PRD §8.4)
                        final maxY = data.monthlyPoints.isEmpty
                            ? 1000000.0
                            : data.monthlyPoints.map((x) => x.income > x.expense ? x.income : x.expense).fold(0.0, (a, b) => a > b ? a : b);
                        // interval: maxY/4, clamp 500rb–5jt agar grid tidak terlalu rapat/renggang
                        double interval = (maxY / 4);
                        if (maxY < 2000000) {
                          interval = 500000;
                        } else if (maxY < 10000000) {
                          interval = 1000000;
                        } else if (maxY < 20000000) {
                          interval = 2000000;
                        } else {
                          interval = 5000000;
                        }
                        // lebar bar adaptif: 6 bulan => 10, 12 bulan => 6
                        final barWidth = data.monthlyPoints.length > 8 ? 6.0 : 10.0;
                        return BarChart(
                          BarChartData(
                            maxY: maxY == 0 ? null : maxY * 1.2,
                            barGroups: data.monthlyPoints.asMap().entries.map((e) {
                              final i = e.key;
                              final p = e.value;
                              return BarChartGroupData(x: i, barRods: [
                                BarChartRodData(toY: p.income, color: scheme.secondaryFixed, width: barWidth, borderRadius: BorderRadius.circular(4)),
                                BarChartRodData(toY: p.expense, color: scheme.tertiaryFixed, width: barWidth, borderRadius: BorderRadius.circular(4)),
                              ]);
                            }).toList(),
                            titlesData: FlTitlesData(
                              leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                              rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                              topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  getTitlesWidget: (v, meta) {
                                    if (v.toInt() < 0 || v.toInt() >= data.monthlyPoints.length) return const SizedBox();
                                    return Padding(
                                      padding: const EdgeInsets.only(top: 4),
                                      child: Text(data.monthlyPoints[v.toInt()].label, style: TextStyle(fontSize: 10, color: scheme.onSurfaceVariant)),
                                    );
                                  },
                                ),
                              ),
                            ),
                            gridData: FlGridData(show: true, drawVerticalLine: false, horizontalInterval: interval),
                            borderData: FlBorderData(show: false),
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 12),
                    Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Container(width: 10, height: 10, decoration: BoxDecoration(color: scheme.secondaryFixed, shape: BoxShape.circle)),
                      const SizedBox(width: 6),
                      Text('Pemasukan', style: TextStyle(fontSize: 11, color: scheme.onSurfaceVariant)),
                      const SizedBox(width: 16),
                      Container(width: 10, height: 10, decoration: BoxDecoration(color: scheme.tertiaryFixed, shape: BoxShape.circle)),
                      const SizedBox(width: 6),
                      Text('Pengeluaran', style: TextStyle(fontSize: 11, color: scheme.onSurfaceVariant)),
                    ]),
                  ]),
                ),
                const SizedBox(height: 16),
                // Trend line
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: scheme.surfaceContainerLowest, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8)]),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                      const Text('Tren Pengeluaran', style: TextStyle(fontWeight: FontWeight.w600)),
                      Icon(Icons.more_horiz, color: scheme.onSurfaceVariant),
                    ]),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 140,
                      child: LineChart(
                        LineChartData(
                          gridData: FlGridData(show: true, drawVerticalLine: false),
                          titlesData: FlTitlesData(
                            leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget: (v, meta) {
                                  if (v.toInt() < 0 || v.toInt() >= data.trendPoints.length) return const SizedBox();
                                  // show first, mid, last
                                  if (v.toInt() == 0 || v.toInt() == data.trendPoints.length - 1 || v.toInt() == data.trendPoints.length ~/ 2) {
                                    final d = data.trendPoints[v.toInt()].date;
                                    return Text('${d.day}/${d.month}', style: TextStyle(fontSize: 10, color: scheme.onSurfaceVariant));
                                  }
                                  return const SizedBox();
                                },
                                interval: 1,
                              ),
                            ),
                          ),
                          borderData: FlBorderData(show: false),
                          lineBarsData: [
                            LineChartBarData(
                              spots: data.trendPoints.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value.amount)).toList(),
                              isCurved: true,
                              color: scheme.primary,
                              barWidth: 2,
                              dotData: FlDotData(show: false),
                              belowBarData: BarAreaData(show: true, color: scheme.primary.withValues(alpha: 0.1)),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ]),
                ),
                const SizedBox(height: 16),
                // Category breakdown
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: scheme.surfaceContainerLowest, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8)]),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const Text('Kategori', style: TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 12),
                    if (data.byCategory.isEmpty)
                      Padding(padding: const EdgeInsets.all(12), child: Text('Belum ada data', style: TextStyle(color: scheme.outline)))
                    else
                      for (final entry in (data.byCategory.entries.toList()..sort((a, b) => b.value.compareTo(a.value))))
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Row(children: [
                            Container(width: 36, height: 36, decoration: BoxDecoration(color: scheme.surfaceContainerHighest, shape: BoxShape.circle), child: Icon(_iconForCategory(entry.key), size: 18, color: scheme.primary)),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                                  Text(entry.key, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                                  Text(CurrencyFormatter.format(entry.value), style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant, fontWeight: FontWeight.w600)),
                                ]),
                                const SizedBox(height: 4),
                                Row(children: [
                                  Expanded(
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(4),
                                      child: LinearProgressIndicator(
                                        value: data.totalExpense == 0 ? 0 : entry.value / data.totalExpense,
                                        minHeight: 6,
                                        backgroundColor: scheme.surfaceContainerHighest,
                                        valueColor: AlwaysStoppedAnimation(_colorForCategory(entry.key, scheme)),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text('${data.totalExpense == 0 ? 0 : ((entry.value / data.totalExpense) * 100).toStringAsFixed(0)}%', style: TextStyle(fontSize: 11, color: scheme.onSurfaceVariant)),
                                ]),
                              ]),
                            ),
                          ]),
                        ),
                  ]),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  String _periodLabel(Period p) {
    switch (p) {
      case Period.daily: return 'Harian';
      case Period.weekly: return 'Mingguan';
      case Period.monthly: return 'Bulanan';
      case Period.yearly: return 'Tahunan';
    }
  }

  String _periodDesc(Period p) {
    switch (p) {
      case Period.daily: return 'Hari Ini';
      case Period.weekly: return 'Minggu Ini';
      case Period.monthly: return 'Bulan Ini';
      case Period.yearly: return 'Tahun Ini';
    }
  }

  String _currentLabel(Period p) => _periodDesc(p);
  String _prevLabel(Period p) {
    switch (p) {
      case Period.daily: return 'Kemarin';
      case Period.weekly: return 'Minggu Lalu';
      case Period.monthly: return 'Bulan Lalu';
      case Period.yearly: return 'Tahun Lalu';
    }
  }

  IconData _iconForCategory(String name) {
    final lower = name.toLowerCase();
    if (lower.contains('makan')) return Icons.restaurant;
    if (lower.contains('transport')) return Icons.directions_car;
    if (lower.contains('belanja')) return Icons.shopping_bag;
    if (lower.contains('hiburan')) return Icons.movie;
    if (lower.contains('tagihan') || lower.contains('rumah')) return Icons.home;
    if (lower.contains('kesehatan')) return Icons.favorite;
    if (lower.contains('pendidikan')) return Icons.school;
    return Icons.category;
  }

  Color _colorForCategory(String name, ColorScheme scheme) {
    final lower = name.toLowerCase();
    if (lower.contains('makan')) return scheme.primary;
    if (lower.contains('transport')) return scheme.secondary;
    if (lower.contains('belanja')) return scheme.tertiary;
    if (lower.contains('hiburan')) return Colors.orange;
    return scheme.primaryContainer;
  }
}

class _MiniBar extends StatelessWidget {
  final String label;
  final double value;
  final Color color;
  const _MiniBar({required this.label, required this.value, required this.color});
  @override
  Widget build(BuildContext context) {
    return Row(children: [
      SizedBox(width: 40, child: Text(label, style: TextStyle(fontSize: 11, color: Theme.of(context).colorScheme.onSurfaceVariant))),
      Expanded(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(value: value.clamp(0, 1), minHeight: 8, backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest, valueColor: AlwaysStoppedAnimation(color)),
        ),
      ),
    ]);
  }
}
