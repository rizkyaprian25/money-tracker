import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../database/app_database.dart';
import '../../providers/transaction_provider.dart';
import '../../providers/category_provider.dart';
import '../../widgets/transaction_tile.dart';
import 'add_edit_transaction_sheet.dart';
import 'recurring_sheet.dart';

class TransactionsScreen extends ConsumerStatefulWidget {
  const TransactionsScreen({super.key});
  @override
  ConsumerState<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends ConsumerState<TransactionsScreen> {
  final searchCtrl = TextEditingController();
  String selectedFilter = 'Semua';
  DateTimeRange? _dateRange;
  int? _filterCategoryId;
  String _filterCategoryName = 'Semua Kategori';

  @override
  void initState() {
    super.initState();
    searchCtrl.addListener(() {
      final text = searchCtrl.text;
      ref.read(transactionFilterProvider.notifier).state = TransactionFilter(search: text.isEmpty ? null : text);
      ref.read(paginatedTransactionsProvider.notifier).loadInitial();
    });
  }

  void _applyFilter(String filter) {
    setState(() => selectedFilter = filter);
    final now = DateTime.now();
    TransactionFilter f = const TransactionFilter();
    switch (filter) {
      case 'Semua':
        f = const TransactionFilter();
        _dateRange = null;
        _filterCategoryId = null;
        _filterCategoryName = 'Semua Kategori';
        break;
      case 'Bulan Ini':
        f = TransactionFilter(startDate: DateTime(now.year, now.month, 1), endDate: DateTime(now.year, now.month + 1, 0, 23, 59, 59));
        _dateRange = DateTimeRange(start: DateTime(now.year, now.month, 1), end: DateTime(now.year, now.month + 1, 0));
        break;
      case 'Minggu Ini':
        final start = now.subtract(Duration(days: now.weekday - 1));
        f = TransactionFilter(startDate: DateTime(start.year, start.month, start.day), endDate: DateTime(now.year, now.month, now.day, 23, 59, 59));
        _dateRange = DateTimeRange(start: DateTime(start.year, start.month, start.day), end: DateTime(now.year, now.month, now.day));
        break;
      case 'Pemasukan':
        f = const TransactionFilter(type: 'income');
        break;
      case 'Pengeluaran':
        f = const TransactionFilter(type: 'expense');
        break;
    }
    // gabungkan dengan dateRange & category jika ada (Fase 3)
    if (_dateRange != null) {
      f = f.copyWith(startDate: _dateRange!.start, endDate: DateTime(_dateRange!.end.year, _dateRange!.end.month, _dateRange!.end.day, 23, 59, 59));
    }
    if (_filterCategoryId != null) f = f.copyWith(categoryId: _filterCategoryId);
    if (searchCtrl.text.isNotEmpty) f = f.copyWith(search: searchCtrl.text);
    ref.read(transactionFilterProvider.notifier).state = f;
    ref.read(paginatedTransactionsProvider.notifier).loadInitial();
  }

  Future<void> _pickDateRange() async {
    final now = DateTime.now();
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      initialDateRange: _dateRange ?? DateTimeRange(start: DateTime(now.year, now.month, 1), end: now),
      locale: const Locale('id', 'ID'),
    );
    if (picked != null) {
      setState(() => _dateRange = picked);
      final current = ref.read(transactionFilterProvider);
      final f = current.copyWith(startDate: picked.start, endDate: DateTime(picked.end.year, picked.end.month, picked.end.day, 23, 59, 59));
      ref.read(transactionFilterProvider.notifier).state = f;
      ref.read(paginatedTransactionsProvider.notifier).loadInitial();
    }
  }

  void _clearDateRange() {
    setState(() => _dateRange = null);
    final current = ref.read(transactionFilterProvider);
    final f = TransactionFilter(
      search: current.search,
      type: current.type,
      categoryId: current.categoryId,
      limit: current.limit,
      offset: current.offset,
    );
    ref.read(transactionFilterProvider.notifier).state = f;
    ref.read(paginatedTransactionsProvider.notifier).loadInitial();
  }

  Future<void> _pickCategory() async {
    final catsAsync = ref.read(categoriesStreamProvider);
    // fallback: fetch via provider value
    final cats = catsAsync.valueOrNull ?? [];
    // jika belum load, ambil dari stream pertama
    List<dynamic> allCats = cats;
    if (allCats.isEmpty) {
      // tidak ada, tampilkan bottom sheet tetap
    }
    final selected = await showModalBottomSheet<int?>(
      context: context,
      showDragHandle: true,
      builder: (c) {
        return SafeArea(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Padding(padding: EdgeInsets.all(16), child: Text('Pilih Kategori', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16))),
            ListTile(
              leading: const Icon(Icons.all_inclusive),
              title: const Text('Semua Kategori'),
              onTap: () => Navigator.pop(c, null),
            ),
            ...allCats.map((cat) => ListTile(
                  leading: Icon(_iconFromName(cat.icon), color: _hexToColor(cat.color)),
                  title: Text(cat.name),
                  subtitle: Text(cat.type),
                  onTap: () => Navigator.pop(c, cat.id),
                  trailing: cat.name == _filterCategoryName ? const Icon(Icons.check, color: Colors.green) : null,
                )),
            const SizedBox(height: 16),
          ]),
        );
      },
    );
    // jika user pilih, terapkan filter
    if (selected != null || _filterCategoryId != null) {
      // cari nama kategori
      String name = 'Semua Kategori';
      if (selected != null) {
        final found = allCats.where((e) => e.id == selected);
        if (found.isNotEmpty) name = found.first.name;
      }
      setState(() {
        _filterCategoryId = selected;
        _filterCategoryName = name;
      });
      final current = ref.read(transactionFilterProvider);
      final f = current.copyWith(categoryId: selected);
      // jika clear (selected==null) kita perlu buat copy tanpa categoryId: buat baru
      TransactionFilter newF;
      if (selected == null) {
        newF = TransactionFilter(search: current.search, type: current.type, startDate: current.startDate, endDate: current.endDate);
      } else {
        newF = f;
      }
      ref.read(transactionFilterProvider.notifier).state = newF;
      ref.read(paginatedTransactionsProvider.notifier).loadInitial();
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

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final paginated = ref.watch(paginatedTransactionsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Row(children: [
          Container(
            width: 32, height: 32,
            decoration: BoxDecoration(color: scheme.primary, borderRadius: BorderRadius.circular(8)),
            clipBehavior: Clip.antiAlias,
            child: Image.asset('assets/images/logo.png', width: 32, height: 32, fit: BoxFit.cover,
                errorBuilder: (_, _, _) => const Icon(Icons.account_balance_wallet, color: Colors.white, size: 20)),
          ),
          const SizedBox(width: 10),
          const Text('Transaksi', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
        ]),
        actions: [
          IconButton(
            tooltip: 'Transaksi berulang',
            onPressed: () => showModalBottomSheet(context: context, isScrollControlled: true, backgroundColor: Colors.transparent, builder: (_) => const RecurringSheet()),
            icon: Icon(Icons.event_repeat, color: scheme.primary),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: CircleAvatar(backgroundColor: scheme.primary, child: const Icon(Icons.person, color: Colors.white, size: 18)),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showModalBottomSheet(context: context, isScrollControlled: true, backgroundColor: Colors.transparent, builder: (_) => const AddEditTransactionSheet()),
        backgroundColor: scheme.primaryContainer,
        foregroundColor: scheme.onPrimaryContainer,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: const Icon(Icons.add, size: 28),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: Column(
              children: [
                TextField(
                  controller: searchCtrl,
                  decoration: InputDecoration(
                    hintText: 'Cari transaksi...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: searchCtrl.text.isNotEmpty
                        ? IconButton(icon: const Icon(Icons.clear), onPressed: () => searchCtrl.clear())
                        : const Icon(Icons.tune),
                    filled: true,
                    fillColor: scheme.surfaceContainerHighest.withValues(alpha: 0.5),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
                const SizedBox(height: 10),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(children: [
                    for (final f in ['Semua', 'Bulan Ini', 'Minggu Ini', 'Pemasukan', 'Pengeluaran'])
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Row(mainAxisSize: MainAxisSize.min, children: [
                            if (f == 'Pemasukan') const Icon(Icons.arrow_downward, size: 14),
                            if (f == 'Pengeluaran') const Icon(Icons.arrow_upward, size: 14),
                            if (f == 'Pemasukan' || f == 'Pengeluaran') const SizedBox(width: 4),
                            Text(f),
                          ]),
                          selected: selectedFilter == f,
                          selectedColor: scheme.primary,
                          labelStyle: TextStyle(color: selectedFilter == f ? Colors.white : scheme.onSurfaceVariant, fontSize: 12),
                          onSelected: (_) => _applyFilter(f),
                        ),
                      ),
                  ]),
                ),
                const SizedBox(height: 8),
                // Fase 3: DateRangePicker + Dropdown Category filter (PRD §8.5 - cover penuh spec)
                Row(children: [
                  Expanded(
                    child: InkWell(
                      onTap: _pickDateRange,
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        decoration: BoxDecoration(
                          color: _dateRange == null ? scheme.surfaceContainerHighest.withValues(alpha: 0.5) : scheme.primaryContainer,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: _dateRange == null ? Colors.transparent : scheme.primary),
                        ),
                        child: Row(children: [
                          Icon(Icons.calendar_today, size: 16, color: _dateRange == null ? scheme.onSurfaceVariant : scheme.onPrimaryContainer),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _dateRange == null
                                  ? 'Rentang Tanggal'
                                  : '${DateFormat('d MMM', 'id_ID').format(_dateRange!.start)} - ${DateFormat('d MMM yyyy', 'id_ID').format(_dateRange!.end)}',
                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: _dateRange == null ? scheme.onSurfaceVariant : scheme.onPrimaryContainer),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (_dateRange != null)
                            GestureDetector(
                              onTap: _clearDateRange,
                              child: Icon(Icons.clear, size: 16, color: scheme.onPrimaryContainer),
                            ),
                        ]),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: InkWell(
                      onTap: _pickCategory,
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        decoration: BoxDecoration(
                          color: _filterCategoryId == null ? scheme.surfaceContainerHighest.withValues(alpha: 0.5) : scheme.secondaryContainer,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: _filterCategoryId == null ? Colors.transparent : scheme.secondary),
                        ),
                        child: Row(children: [
                          Icon(Icons.category, size: 16, color: _filterCategoryId == null ? scheme.onSurfaceVariant : scheme.onSecondaryContainer),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(_filterCategoryName, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: _filterCategoryId == null ? scheme.onSurfaceVariant : scheme.onSecondaryContainer), overflow: TextOverflow.ellipsis),
                          ),
                          Icon(Icons.arrow_drop_down, size: 16, color: _filterCategoryId == null ? scheme.onSurfaceVariant : scheme.onSecondaryContainer),
                        ]),
                      ),
                    ),
                  ),
                ]),
              ],
            ),
          ),
          Expanded(
            child: paginated.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
              data: (list) {
                if (list.isEmpty) {
                  return Center(
                    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Icon(Icons.wallet_outlined, size: 64, color: scheme.outline.withValues(alpha: 0.5)),
                      const SizedBox(height: 12),
                      Text('Tidak ada transaksi ditemukan', style: TextStyle(fontWeight: FontWeight.w600, color: scheme.onSurface)),
                      const SizedBox(height: 6),
                      Text('Coba sesuaikan filter atau cari', style: TextStyle(color: scheme.onSurfaceVariant, fontSize: 12)),
                      const SizedBox(height: 16),
                      FilledButton.tonal(onPressed: () => _applyFilter('Semua'), child: const Text('Hapus Filter')),
                    ]),
                  );
                }
                // group by date
                final groups = <String, List<TransactionWithCategory>>{};
                for (final t in list) {
                  final d = t.transaction.transactionDate;
                  final now = DateTime.now();
                  String key;
                  if (d.year == now.year && d.month == now.month && d.day == now.day) {
                    key = 'Hari Ini';
                  } else if (d.year == now.year && d.month == now.month && d.day == now.day - 1) {
                    key = 'Kemarin';
                  } else {
                    key = DateFormat('d MMMM yyyy', 'id_ID').format(d);
                  }
                  groups.putIfAbsent(key, () => []).add(t);
                }

                return RefreshIndicator(
                  onRefresh: () => ref.read(paginatedTransactionsProvider.notifier).loadInitial(),
                  child: ListView.builder(
                    padding: const EdgeInsets.only(bottom: 100),
                    itemCount: groups.length + 1,
                    itemBuilder: (context, index) {
                      if (index == groups.length) {
                        final hasMore = ref.read(paginatedTransactionsProvider.notifier).hasMore;
                        if (!hasMore) return const SizedBox(height: 20);
                        return Padding(
                          padding: const EdgeInsets.all(16),
                          child: Center(
                            child: OutlinedButton(
                              onPressed: () => ref.read(paginatedTransactionsProvider.notifier).loadMore(),
                              child: const Text('Muat Lebih Banyak'),
                            ),
                          ),
                        );
                      }
                      final key = groups.keys.elementAt(index);
                      final items = groups[key]!;
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
                            child: Text(key.toUpperCase(), style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: scheme.outline, letterSpacing: 0.5)),
                          ),
                          Container(
                            margin: const EdgeInsets.symmetric(horizontal: 16),
                            decoration: BoxDecoration(color: scheme.surfaceContainerLowest, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 6)]),
                            child: Column(children: [
                              for (int i = 0; i < items.length; i++) ...[
                                Dismissible(
                                  key: ValueKey(items[i].transaction.id),
                                  background: Container(color: scheme.primary, alignment: Alignment.centerLeft, padding: const EdgeInsets.only(left: 16), child: const Icon(Icons.edit, color: Colors.white)),
                                  secondaryBackground: Container(color: scheme.error, alignment: Alignment.centerRight, padding: const EdgeInsets.only(right: 16), child: const Icon(Icons.delete, color: Colors.white)),
                                  confirmDismiss: (dir) async {
                                    if (dir == DismissDirection.startToEnd) {
                                      showModalBottomSheet(context: context, isScrollControlled: true, backgroundColor: Colors.transparent, builder: (_) => AddEditTransactionSheet(existing: items[i]));
                                      return false;
                                    } else {
                                      final ok = await showDialog<bool>(context: context, builder: (c) => AlertDialog(title: const Text('Hapus?'), content: const Text('Yakin hapus transaksi ini?'), actions: [TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Batal')), FilledButton(onPressed: () => Navigator.pop(c, true), child: const Text('Hapus'))]));
                                      if (ok == true) {
                                        await ref.read(transactionNotifierProvider).deleteTransaction(items[i].transaction.id);
                                        ref.read(paginatedTransactionsProvider.notifier).loadInitial();
                                      }
                                      return false;
                                    }
                                  },
                                  child: TransactionTile(
                                    item: items[i],
                                    onTap: () => showModalBottomSheet(context: context, isScrollControlled: true, backgroundColor: Colors.transparent, builder: (_) => AddEditTransactionSheet(existing: items[i])),
                                  ),
                                ),
                                if (i != items.length - 1) Divider(height: 1, indent: 60, color: scheme.outlineVariant.withValues(alpha: 0.3)),
                              ],
                            ]),
                          ),
                        ],
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
