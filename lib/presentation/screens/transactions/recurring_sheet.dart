import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../database/app_database.dart';
import '../../providers/category_provider.dart';
import '../../providers/recurring_provider.dart';

/// Kelola aturan transaksi berulang (v1.1): aktif/nonaktif + hapus.
class RecurringSheet extends ConsumerWidget {
  const RecurringSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rulesAsync = ref.watch(recurringStreamProvider);
    final catsAsync = ref.watch(categoriesStreamProvider);
    final scheme = Theme.of(context).colorScheme;
    final catMap = {for (final c in (catsAsync.valueOrNull ?? <Category>[])) c.id: c};

    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      maxChildSize: 0.9,
      minChildSize: 0.4,
      expand: false,
      builder: (context, scrollController) => Container(
        decoration: BoxDecoration(color: scheme.surface, borderRadius: const BorderRadius.vertical(top: Radius.circular(24))),
        padding: const EdgeInsets.all(20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: scheme.outlineVariant, borderRadius: BorderRadius.circular(2)))),
          const SizedBox(height: 16),
          const Text('Transaksi Berulang', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          Text('Gaji, cicilan, dan langganan tercatat otomatis tiap periode.', style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant)),
          const SizedBox(height: 16),
          Expanded(
            child: rulesAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
              data: (rules) {
                if (rules.isEmpty) {
                  return Center(
                    child: Column(mainAxisSize: MainAxisSize.min, children: [
                      Icon(Icons.event_repeat, size: 40, color: scheme.outline),
                      const SizedBox(height: 8),
                      Text('Belum ada aturan berulang', style: TextStyle(color: scheme.outline)),
                      const SizedBox(height: 4),
                      Text('Aktifkan "Ulangi otomatis" saat menambah transaksi.', style: TextStyle(fontSize: 12, color: scheme.outline)),
                    ]),
                  );
                }
                return ListView.separated(
                  controller: scrollController,
                  itemCount: rules.length,
                  separatorBuilder: (_, _) => const Divider(height: 1),
                  itemBuilder: (context, i) {
                    final r = rules[i];
                    final cat = r.categoryId != null ? catMap[r.categoryId] : null;
                    final isIncome = r.transactionType == 'income';
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: (isIncome ? scheme.secondary : scheme.primary).withValues(alpha: 0.15),
                        child: Icon(isIncome ? Icons.arrow_downward : Icons.arrow_upward,
                            size: 18, color: isIncome ? scheme.secondary : scheme.primary),
                      ),
                      title: Text(r.note ?? cat?.name ?? '-', maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                      subtitle: Text(
                        '${r.frequency == 'weekly' ? 'Mingguan' : 'Bulanan'} • berikutnya ${DateFormat('d MMM yyyy', 'id_ID').format(r.nextDate)}',
                        style: const TextStyle(fontSize: 11),
                      ),
                      trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                        Text(CurrencyFormatter.format(r.amount), style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                        Switch(
                          value: r.isActive,
                          onChanged: (v) => ref.read(recurringNotifierProvider).setActive(r.id, v),
                        ),
                        IconButton(
                          icon: Icon(Icons.delete_outline, size: 20, color: scheme.error),
                          onPressed: () => ref.read(recurringNotifierProvider).deleteRule(r.id),
                        ),
                      ]),
                    );
                  },
                );
              },
            ),
          ),
        ]),
      ),
    );
  }
}
