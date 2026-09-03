import '../entities/transaction_entity.dart';

abstract class TransactionRepository {
  Stream<List<TransactionEntity>> watchTransactions(TransactionFilterEntity filter);
  Future<List<TransactionEntity>> getTransactions(TransactionFilterEntity filter);
  Future<double> getTotalIncome(DateTime from, DateTime to);
  Future<double> getTotalExpense(DateTime from, DateTime to);
  Future<double> getBalance();
  Future<int> insertTransaction({
    required double amount,
    required String type,
    required int categoryId,
    String? note,
    required DateTime date,
  });
  Future<bool> updateTransaction(TransactionEntity entity);
  Future<int> deleteTransaction(int id);
}
