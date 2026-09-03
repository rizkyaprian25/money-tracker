import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../providers/dashboard_provider.dart';
import '../../widgets/balance_card.dart';
import '../../widgets/transaction_tile.dart';
import '../../widgets/donut_chart.dart';
import '../transactions/add_edit_transaction_sheet.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboardAsync = ref.watch(dashboardProvider);
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Row(children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(color: scheme.primary, borderRadius: BorderRadius.circular(8)),
            clipBehavior: Clip.antiAlias,
            child: Image.asset('assets/images/logo.png', width: 32, height: 32, fit: BoxFit.cover,
                errorBuilder: (_, _, _) => const Icon(Icons.account_balance_wallet, color: Colors.white, size: 20)),
          ),
          const SizedBox(width: 10),
          const Text('Beranda', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
        ]),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: CircleAvatar(backgroundColor: scheme.primary, child: const Icon(Icons.person, color: Colors.white, size: 18)),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (_) => const AddEditTransactionSheet(),
        ),
        backgroundColor: scheme.primaryContainer,
        foregroundColor: scheme.onPrimaryContainer,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: const Icon(Icons.add, size: 28),
      ),
      body: dashboardAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(child: Text('Error: $e')),
        data: (data) {
          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(dashboardProvider),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  BalanceCard(balance: data.balance, income: data.monthlyIncome, expense: data.monthlyExpense),
                  const SizedBox(height: 16),
                  // Budget + Expense breakdown row
                  LayoutBuilder(builder: (context, constraints) {
                    final isWide = constraints.maxWidth > 600;
                    final budgetWidget = _BudgetRemainingCard(remaining: data.remainingBudget, percent: data.monthlyExpense == 0 && data.monthlyIncome == 0 ? 0 : (data.monthlyExpense / (data.monthlyIncome > 0 ? data.monthlyIncome : data.monthlyExpense + 1)).clamp(0, 1));
                    final expenseWidget = _TopExpenseCard(expenseByCategory: data.expenseByCategory);
                    if (isWide) {
                      return Row(children: [Expanded(child: budgetWidget), const SizedBox(width: 12), Expanded(child: expenseWidget)]);
                    } else {
                      return Column(children: [budgetWidget, const SizedBox(height: 12), expenseWidget]);
                    }
                  }),
                  const SizedBox(height: 20),
                  // Recent transactions
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Aktivitas Terbaru', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                      TextButton(onPressed: () {}, child: const Text('Lihat Semua')),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: scheme.surfaceContainerLowest,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8)],
                    ),
                    child: data.recent.isEmpty
                        ? Padding(
                            padding: const EdgeInsets.all(24),
                            child: Center(
                                child: Column(children: [
                              Icon(Icons.receipt_long, size: 40, color: scheme.outline),
                              const SizedBox(height: 8),
                              Text('Belum ada transaksi', style: TextStyle(color: scheme.outline)),
                            ])),
                          )
                        : Column(
                            children: data.recent
                                .map((e) => Column(children: [
                                      TransactionTile(item: e),
                                      if (e != data.recent.last) Divider(height: 1, color: scheme.outlineVariant.withValues(alpha: 0.3)),
                                    ]))
                                .toList(),
                          ),
                  ),
                  const SizedBox(height: 16),
                  // Monthly summary quick
                  if (data.expenseByCategory.isNotEmpty) _ExpensePieSection(data: data),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _BudgetRemainingCard extends StatelessWidget {
  final double remaining;
  final double percent;
  const _BudgetRemainingCard({required this.remaining, required this.percent});
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final now = DateTime.now();
    final monthName = ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'][now.month - 1];
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: scheme.surfaceContainerLowest, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8)]),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Anggaran Bulanan', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14), maxLines: 1, overflow: TextOverflow.ellipsis),
              Text('Sisa untuk $monthName', style: TextStyle(fontSize: 11, color: scheme.onSurfaceVariant), maxLines: 1, overflow: TextOverflow.ellipsis),
              const SizedBox(height: 8),
              Text(CurrencyFormatter.format(remaining), style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: scheme.primary), maxLines: 1, overflow: TextOverflow.ellipsis),
            ]),
          ),
          const SizedBox(width: 8),
          DonutChart(percent: (1 - percent).clamp(0, 1), label: '${((1 - percent).clamp(0, 1) * 100).toStringAsFixed(0)}%', color: scheme.primary),
        ],
      ),
    );
  }
}

class _TopExpenseCard extends StatelessWidget {
  final Map<String, double> expenseByCategory;
  const _TopExpenseCard({required this.expenseByCategory});
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final sorted = expenseByCategory.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    final top2 = sorted.take(2).toList();
    final total = expenseByCategory.values.fold(0.0, (p, e) => p + e);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: scheme.surfaceContainerLowest, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8)]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            const Expanded(child: Text('Pengeluaran Teratas', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14), maxLines: 1, overflow: TextOverflow.ellipsis)),
            TextButton(onPressed: () {}, child: const Row(children: [Text('Detail', style: TextStyle(fontSize: 11)), Icon(Icons.chevron_right, size: 14)])),
          ]),
          if (top2.isEmpty)
            Padding(padding: const EdgeInsets.all(8), child: Text('Belum ada data', style: TextStyle(color: scheme.outline))),
          for (final e in top2) ...[
            Row(children: [
              Container(width: 8, height: 8, decoration: BoxDecoration(color: e.key == top2.first.key ? scheme.tertiary : scheme.secondary, shape: BoxShape.circle)),
              const SizedBox(width: 8),
              Expanded(child: Text(e.key, style: TextStyle(fontSize: 13, color: scheme.onSurfaceVariant))),
              Text(CurrencyFormatter.format(e.value), style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
            ]),
            const SizedBox(height: 4),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: total == 0 ? 0 : e.value / total,
                minHeight: 6,
                backgroundColor: scheme.surfaceContainerHighest,
                valueColor: AlwaysStoppedAnimation(e.key == top2.first.key ? scheme.tertiary : scheme.secondary),
              ),
            ),
            if (e != top2.last) const SizedBox(height: 12),
          ],
        ],
      ),
    );
  }
}

class _ExpensePieSection extends StatelessWidget {
  final dynamic data;
  const _ExpensePieSection({required this.data});
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final byCat = data.expenseByCategory as Map<String, double>;
    if (byCat.isEmpty) return const SizedBox();
    final total = byCat.values.fold(0.0, (p, e) => p + e);
    final colors = [scheme.primary, scheme.secondary, scheme.tertiary, scheme.outline, scheme.primaryContainer];
    int i = 0;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: scheme.surfaceContainerLowest, borderRadius: BorderRadius.circular(12)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Breakdown Pengeluaran', style: TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 16),
        SizedBox(
          height: 160,
          child: PieChart(
            PieChartData(
              sectionsSpace: 2,
              centerSpaceRadius: 40,
              sections: byCat.entries.map((e) {
                final c = colors[i++ % colors.length];
                return PieChartSectionData(
                  value: e.value,
                  title: '${((e.value / total) * 100).toStringAsFixed(0)}%',
                  color: c,
                  radius: 50,
                  titleStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white),
                );
              }).toList(),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 8,
          children: byCat.entries.map((e) {
            final idx = byCat.keys.toList().indexOf(e.key);
            final c = colors[idx % colors.length];
            return Row(mainAxisSize: MainAxisSize.min, children: [
              Container(width: 10, height: 10, decoration: BoxDecoration(color: c, shape: BoxShape.circle)),
              const SizedBox(width: 6),
              Text(e.key, style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant)),
            ]);
          }).toList(),
        ),
      ]),
    );
  }
}
