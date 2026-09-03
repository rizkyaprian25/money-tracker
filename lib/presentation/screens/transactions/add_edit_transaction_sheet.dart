import 'package:drift/drift.dart' as drift;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/utils/budget_warning_helper.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../database/app_database.dart';
import '../../providers/budget_provider.dart';
import '../../providers/category_provider.dart';
import '../../providers/database_provider.dart';
import '../../providers/transaction_provider.dart';

class AddEditTransactionSheet extends ConsumerStatefulWidget {
  final TransactionWithCategory? existing;
  const AddEditTransactionSheet({super.key, this.existing});

  @override
  ConsumerState<AddEditTransactionSheet> createState() => _AddEditTransactionSheetState();
}

class _AddEditTransactionSheetState extends ConsumerState<AddEditTransactionSheet> {
  String type = 'expense';
  int? selectedCategoryId;
  final amountCtrl = TextEditingController();
  final noteCtrl = TextEditingController();
  DateTime date = DateTime.now();
  bool isSaving = false;

  @override
  void initState() {
    super.initState();
    if (widget.existing != null) {
      final tx = widget.existing!.transaction;
      type = tx.transactionType;
      selectedCategoryId = tx.categoryId;
      amountCtrl.text = tx.amount.toStringAsFixed(0);
      noteCtrl.text = tx.note ?? '';
      date = tx.transactionDate;
    }
  }

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(categoriesByTypeProvider(type));
    final scheme = Theme.of(context).colorScheme;

    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      maxChildSize: 0.95,
      minChildSize: 0.6,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(color: scheme.surface, borderRadius: const BorderRadius.vertical(top: Radius.circular(24))),
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: SingleChildScrollView(
            controller: scrollController,
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: scheme.outlineVariant, borderRadius: BorderRadius.circular(2)))),
                const SizedBox(height: 16),
                Text(widget.existing == null ? 'Tambah Transaksi' : 'Edit Transaksi', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
                const SizedBox(height: 16),
                // Type toggle
                Container(
                  decoration: BoxDecoration(color: scheme.surfaceContainerHighest.withValues(alpha: 0.6), borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.all(4),
                  child: Row(children: [
                    Expanded(
                      child: _TypeButton(
                        label: 'Pengeluaran',
                        icon: Icons.arrow_upward,
                        selected: type == 'expense',
                        color: scheme.error,
                        onTap: () => setState(() {
                          type = 'expense';
                          selectedCategoryId = null;
                        }),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _TypeButton(
                        label: 'Pemasukan',
                        icon: Icons.arrow_downward,
                        selected: type == 'income',
                        color: scheme.secondary,
                        onTap: () => setState(() {
                          type = 'income';
                          selectedCategoryId = null;
                        }),
                      ),
                    ),
                  ]),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: amountCtrl,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Jumlah (Rp)',
                    prefixText: 'Rp ',
                    filled: true,
                    fillColor: scheme.surfaceContainerHighest.withValues(alpha: 0.4),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  ),
                  onChanged: (v) {
                    // format display? keep raw
                  },
                ),
                const SizedBox(height: 12),
                categoriesAsync.when(
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (e, _) => Text('Error: $e'),
                  data: (cats) {
                    if (cats.isEmpty) return Text('Belum ada kategori $type', style: TextStyle(color: scheme.outline));
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Kategori', style: TextStyle(fontWeight: FontWeight.w500)),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: cats.map((c) {
                            final selected = selectedCategoryId == c.id;
                            final col = _hexToColor(c.color);
                            return ChoiceChip(
                              label: Row(mainAxisSize: MainAxisSize.min, children: [
                                Icon(_iconFromName(c.icon), size: 16, color: selected ? Colors.white : col),
                                const SizedBox(width: 6),
                                Text(c.name),
                              ]),
                              selected: selected,
                              selectedColor: col,
                              labelStyle: TextStyle(color: selected ? Colors.white : scheme.onSurface),
                              onSelected: (v) => setState(() => selectedCategoryId = c.id),
                            );
                          }).toList(),
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: noteCtrl,
                  decoration: InputDecoration(
                    labelText: 'Catatan',
                    hintText: 'Contoh: Makan siang',
                    filled: true,
                    fillColor: scheme.surfaceContainerHighest.withValues(alpha: 0.4),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 12),
                InkWell(
                  onTap: () async {
                    final picked = await showDatePicker(context: context, initialDate: date, firstDate: DateTime(2020), lastDate: DateTime(2030));
                    if (!context.mounted) return;
                    if (picked != null) {
                      final time = await showTimePicker(context: context, initialTime: TimeOfDay.fromDateTime(date));
                      setState(() {
                        date = DateTime(picked.year, picked.month, picked.day, time?.hour ?? date.hour, time?.minute ?? date.minute);
                      });
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(color: scheme.surfaceContainerHighest.withValues(alpha: 0.4), borderRadius: BorderRadius.circular(12)),
                    child: Row(children: [
                      Icon(Icons.calendar_today, size: 18, color: scheme.primary),
                      const SizedBox(width: 10),
                      Text(DateFormat('d MMM yyyy HH:mm', 'id_ID').format(date)),
                      const Spacer(),
                      Icon(Icons.chevron_right, color: scheme.outline),
                    ]),
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: isSaving ? null : _save,
                    style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                    child: isSaving
                        ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : Text(widget.existing == null ? 'Simpan' : 'Update'),
                  ),
                ),
                if (widget.existing != null) ...[
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () async {
                        final confirm = await showDialog<bool>(context: context, builder: (c) => AlertDialog(title: const Text('Hapus Transaksi?'), content: const Text('Tindakan ini tidak bisa dibatalkan.'), actions: [TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Batal')), FilledButton(onPressed: () => Navigator.pop(c, true), child: const Text('Hapus'))]));
                        if (confirm == true) {
                          await ref.read(transactionNotifierProvider).deleteTransaction(widget.existing!.transaction.id);
                          if (context.mounted) Navigator.pop(context);
                        }
                      },
                      style: OutlinedButton.styleFrom(foregroundColor: scheme.error, side: BorderSide(color: scheme.error)),
                      child: const Text('Hapus Transaksi'),
                    ),
                  ),
                ],
                SizedBox(height: MediaQuery.of(context).padding.bottom + 10),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _save() async {
    final amount = CurrencyFormatter.parse(amountCtrl.text);
    if (amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Jumlah harus lebih dari 0')));
      return;
    }
    if (selectedCategoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Pilih kategori')));
      return;
    }
    setState(() => isSaving = true);
    try {
      final notifier = ref.read(transactionNotifierProvider);
      if (widget.existing == null) {
        await notifier.addTransaction(amount: amount, type: type, categoryId: selectedCategoryId!, note: noteCtrl.text.trim().isEmpty ? null : noteCtrl.text.trim(), date: date);
      } else {
        final old = widget.existing!.transaction;
        await notifier.updateTransaction(old.copyWith(amount: amount, transactionType: type, categoryId: drift.Value(selectedCategoryId), note: drift.Value(noteCtrl.text.trim().isEmpty ? null : noteCtrl.text.trim()), transactionDate: date));
      }
      final savedContext = context;
      if (mounted) Navigator.pop(context);
      // Fase 2: threshold snackbar 80% — cek budget bulan transaksi setelah simpan
      if (type == 'expense') {
        try {
          final db = ref.read(databaseProvider);
          final budgets = await (db.select(db.budgets)..where((b) => b.month.equals(date.month) & b.year.equals(date.year))).get();
          if (budgets.isNotEmpty) {
            final start = DateTime(date.year, date.month, 1);
            final end = DateTime(date.year, date.month + 1, 0, 23, 59, 59);
            List<BudgetWithSpent> withSpent = [];
            final cats = await db.select(db.categories).get();
            final catMap = {for (var c in cats) c.id: c};
            for (final b in budgets) {
              double spent = 0;
              if (b.categoryId != null) {
                final txs = await db.getTransactions(type: 'expense', categoryId: b.categoryId, startDate: start, endDate: end, limit: 2000);
                spent = txs.fold(0.0, (p, e) => p + e.transaction.amount);
              } else {
                spent = await db.getTotalExpense(start, end);
              }
              withSpent.add(BudgetWithSpent(budget: b, spent: spent, category: b.categoryId != null ? catMap[b.categoryId] : null));
            }
            final relevant = withSpent.where((b) => b.budget.categoryId == selectedCategoryId || b.budget.categoryId == null).toList();
            if (relevant.any((b) => b.isOver || b.isWarning)) {
              // delay agar pop selesai, tampilkan via root scaffold
              Future.delayed(const Duration(milliseconds: 300), () {
                if (savedContext.mounted) BudgetWarningHelper.showBudgetWarningSnackbars(savedContext, relevant);
              });
            }
          }
        } catch (_) {}
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal simpan: $e')));
    } finally {
      if (mounted) setState(() => isSaving = false);
    }
  }

  Color _hexToColor(String hex) {
    try {
      return Color(int.parse(hex.replaceAll('#', 'FF'), radix: 16));
    } catch (_) {
      return Colors.grey;
    }
  }

  IconData _iconFromName(String name) {
    const map = {
      'restaurant': Icons.restaurant,
      'directions_car': Icons.directions_car,
      'shopping_bag': Icons.shopping_bag,
      'shopping_cart': Icons.shopping_cart,
      'movie': Icons.movie,
      'receipt': Icons.receipt,
      'favorite': Icons.favorite,
      'school': Icons.school,
      'payments': Icons.payments,
      'work': Icons.work,
      'card_giftcard': Icons.card_giftcard,
      'category': Icons.category,
      'more_horiz': Icons.more_horiz,
    };
    return map[name] ?? Icons.circle;
  }
}

class _TypeButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final Color color;
  final VoidCallback onTap;
  const _TypeButton({required this.label, required this.icon, required this.selected, required this.color, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(color: selected ? color : Colors.transparent, borderRadius: BorderRadius.circular(10)),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(icon, size: 16, color: selected ? Colors.white : color),
          const SizedBox(width: 6),
          Text(label, style: TextStyle(fontWeight: FontWeight.w600, color: selected ? Colors.white : color, fontSize: 13)),
        ]),
      ),
    );
  }
}
