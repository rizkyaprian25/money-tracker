import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/providers/repository_providers.dart';
import '../../domain/entities/transaction_entity.dart';

/// Entity-based filter (new clean layer)
final transactionFilterEntityProvider = StateProvider<TransactionFilterEntity>((ref) => const TransactionFilterEntity());

final transactionsEntityStreamProvider = StreamProvider<List<TransactionEntity>>((ref) {
  final repo = ref.watch(transactionRepositoryProvider);
  final filter = ref.watch(transactionFilterEntityProvider);
  return repo.watchTransactions(filter);
});

final paginatedTransactionsEntityProvider =
    StateNotifierProvider<PaginatedTransactionsEntityNotifier, AsyncValue<List<TransactionEntity>>>((ref) {
  final repo = ref.watch(transactionRepositoryProvider);
  return PaginatedTransactionsEntityNotifier(repo, ref);
});

class PaginatedTransactionsEntityNotifier extends StateNotifier<AsyncValue<List<TransactionEntity>>> {
  final dynamic repo; // TransactionRepository
  final Ref ref;
  int _offset = 0;
  static const int _limit = 20;
  bool _hasMore = true;
  TransactionFilterEntity _filter = const TransactionFilterEntity();

  PaginatedTransactionsEntityNotifier(this.repo, this.ref) : super(const AsyncValue.loading()) {
    loadInitial();
    ref.listen<TransactionFilterEntity>(transactionFilterEntityProvider, (prev, next) {
      _filter = next;
      loadInitial();
    });
  }

  Future<void> loadInitial() async {
    _offset = 0;
    _hasMore = true;
    state = const AsyncValue.loading();
    try {
      final data = await repo.getTransactions(TransactionFilterEntity(
        search: _filter.search,
        type: _filter.type,
        categoryId: _filter.categoryId,
        startDate: _filter.startDate,
        endDate: _filter.endDate,
        limit: _limit,
        offset: 0,
      )) as List<TransactionEntity>;
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
      final more = await repo.getTransactions(TransactionFilterEntity(
        search: _filter.search,
        type: _filter.type,
        categoryId: _filter.categoryId,
        startDate: _filter.startDate,
        endDate: _filter.endDate,
        limit: _limit,
        offset: _offset,
      )) as List<TransactionEntity>;
      _offset += more.length;
      if (more.length < _limit) _hasMore = false;
      state = AsyncValue.data([...current, ...more]);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  bool get hasMore => _hasMore;
}
