import 'package:drift/drift.dart';
import '../../database/app_database.dart';
import '../../domain/entities/transaction_entity.dart';
import '../../domain/repositories/transaction_repository.dart';
import '../mappers/entity_mapper.dart';

class TransactionRepositoryImpl implements TransactionRepository {
  final AppDatabase db;
  TransactionRepositoryImpl(this.db);

  @override
  Stream<List<TransactionEntity>> watchTransactions(TransactionFilterEntity filter) {
    return db
        .watchTransactions(
          search: filter.search,
          type: filter.type,
          categoryId: filter.categoryId,
          startDate: filter.startDate,
          endDate: filter.endDate,
          limit: filter.limit,
          offset: filter.offset,
        )
        .map((list) => list.map((e) => e.toEntity()).toList());
  }

  @override
  Future<List<TransactionEntity>> getTransactions(TransactionFilterEntity filter) async {
    final rows = await db.getTransactions(
      search: filter.search,
      type: filter.type,
      categoryId: filter.categoryId,
      startDate: filter.startDate,
      endDate: filter.endDate,
      limit: filter.limit,
      offset: filter.offset,
    );
    return rows.map((e) => e.toEntity()).toList();
  }

  @override
  Future<double> getTotalIncome(DateTime from, DateTime to) => db.getTotalIncome(from, to);

  @override
  Future<double> getTotalExpense(DateTime from, DateTime to) => db.getTotalExpense(from, to);

  @override
  Future<double> getBalance() => db.getBalance();

  @override
  Future<int> insertTransaction({required double amount, required String type, required int categoryId, String? note, required DateTime date}) {
    return db.insertTransaction(TransactionsCompanion.insert(
      amount: amount,
      transactionType: type,
      categoryId: Value(categoryId),
      note: Value(note),
      transactionDate: date,
    ));
  }

  @override
  Future<bool> updateTransaction(TransactionEntity entity) {
    // Convert entity -> drift Transaction then replace
    final driftTx = Transaction(
      id: entity.id,
      amount: entity.amount,
      transactionType: entity.transactionType,
      categoryId: entity.categoryId,
      note: entity.note,
      transactionDate: entity.transactionDate,
      createdAt: entity.createdAt,
    );
    return db.updateTransaction(driftTx);
  }

  @override
  Future<int> deleteTransaction(int id) => db.deleteTransaction(id);
}
