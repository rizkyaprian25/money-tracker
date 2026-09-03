import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../database/app_database.dart';
import 'database_provider.dart';

class TransactionFilter {
  final String? search;
  final String? type; // income/expense
  final int? categoryId;
  final DateTime? startDate;
  final DateTime? endDate;
  final int limit;
  final int offset;

  const TransactionFilter({
    this.search,
    this.type,
    this.categoryId,
    this.startDate,
    this.endDate,
    this.limit = 50,
    this.offset = 0,
  });

  TransactionFilter copyWith({
    String? search,
    String? type,
    int? categoryId,
    DateTime? startDate,
    DateTime? endDate,
    int? limit,
    int? offset,
  }) {
    return TransactionFilter(
      search: search ?? this.search,
      type: type ?? this.type,
      categoryId: categoryId ?? this.categoryId,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      limit: limit ?? this.limit,
      offset: offset ?? this.offset,
    );
  }
}

final transactionFilterProvider = StateProvider<TransactionFilter>((ref) => const TransactionFilter());

final transactionsStreamProvider = StreamProvider<List<TransactionWithCategory>>((ref) {
  final db = ref.watch(databaseProvider);
  final filter = ref.watch(transactionFilterProvider);
  return db.watchTransactions(
    search: filter.search,
    type: filter.type,
    categoryId: filter.categoryId,
    startDate: filter.startDate,
    endDate: filter.endDate,
    limit: filter.limit,
    offset: filter.offset,
  );
});

final recentTransactionsProvider = StreamProvider<List<TransactionWithCategory>>((ref) {
  final db = ref.watch(databaseProvider);
  return db.watchTransactions(limit: 5);
});

final monthlyIncomeProvider = FutureProvider<double>((ref) async {
  final db = ref.watch(databaseProvider);
  final now = DateTime.now();
  final start = DateTime(now.year, now.month, 1);
  final end = DateTime(now.year, now.month + 1, 0, 23, 59, 59);
  return db.getTotalIncome(start, end);
});

final monthlyExpenseProvider = FutureProvider<double>((ref) async {
  final db = ref.watch(databaseProvider);
  final now = DateTime.now();
  final start = DateTime(now.year, now.month, 1);
  final end = DateTime(now.year, now.month + 1, 0, 23, 59, 59);
  return db.getTotalExpense(start, end);
});

final balanceProvider = FutureProvider<double>((ref) async {
  final db = ref.watch(databaseProvider);
  // need to invalidate when transactions change - watch a stream
  ref.watch(transactionsStreamProvider);
  return db.getBalance();
});

class TransactionNotifier {
  final AppDatabase db;
  final Ref ref;
  TransactionNotifier(this.db, this.ref);

  Future<int> addTransaction({
    required double amount,
    required String type,
    required int categoryId,
    String? note,
    required DateTime date,
  }) {
    return db.insertTransaction(TransactionsCompanion.insert(
      amount: amount,
      transactionType: type,
      categoryId: Value(categoryId),
      note: Value(note),
      transactionDate: date,
    ));
  }

  Future<bool> updateTransaction(Transaction transaction) => db.updateTransaction(transaction);

  Future<int> deleteTransaction(int id) => db.deleteTransaction(id);
}

final transactionNotifierProvider = Provider<TransactionNotifier>((ref) {
  final db = ref.watch(databaseProvider);
  return TransactionNotifier(db, ref);
});

// For pagination - simple list provider with load more
final paginatedTransactionsProvider = StateNotifierProvider<PaginatedTransactionsNotifier, AsyncValue<List<TransactionWithCategory>>>((ref) {
  final db = ref.watch(databaseProvider);
  return PaginatedTransactionsNotifier(db, ref);
});

class PaginatedTransactionsNotifier extends StateNotifier<AsyncValue<List<TransactionWithCategory>>> {
  final AppDatabase db;
  final Ref ref;
  int _offset = 0;
  static const int _limit = 20;
  bool _hasMore = true;
  TransactionFilter _filter = const TransactionFilter();

  PaginatedTransactionsNotifier(this.db, this.ref) : super(const AsyncValue.loading()) {
    loadInitial();
    ref.listen<TransactionFilter>(transactionFilterProvider, (prev, next) {
      _filter = next;
      loadInitial();
    });
  }

  Future<void> loadInitial() async {
    _offset = 0;
    _hasMore = true;
    state = const AsyncValue.loading();
    try {
      final data = await db.getTransactions(
        search: _filter.search,
        type: _filter.type,
        categoryId: _filter.categoryId,
        startDate: _filter.startDate,
        endDate: _filter.endDate,
        limit: _limit,
        offset: 0,
      );
      _offset = data.length;
      _hasMore = data.length >= _limit;
      state = AsyncValue.data(data);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> loadMore() async {
    if (!_hasMore || state.isLoading) return;
    final current = state.value ?? [];
    try {
      final more = await db.getTransactions(
        search: _filter.search,
        type: _filter.type,
        categoryId: _filter.categoryId,
        startDate: _filter.startDate,
        endDate: _filter.endDate,
        limit: _limit,
        offset: _offset,
      );
      _offset += more.length;
      if (more.length < _limit) _hasMore = false;
      state = AsyncValue.data([...current, ...more]);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  bool get hasMore => _hasMore;
}
