import '../entities/transaction_entity.dart';
import '../repositories/transaction_repository.dart';

class AddTransaction {
  final TransactionRepository repo;
  AddTransaction(this.repo);
  Future<int> call({
    required double amount,
    required String type,
    required int categoryId,
    String? note,
    required DateTime date,
  }) =>
      repo.insertTransaction(amount: amount, type: type, categoryId: categoryId, note: note, date: date);
}

class UpdateTransaction {
  final TransactionRepository repo;
  UpdateTransaction(this.repo);
  Future<bool> call(TransactionEntity e) => repo.updateTransaction(e);
}

class DeleteTransaction {
  final TransactionRepository repo;
  DeleteTransaction(this.repo);
  Future<int> call(int id) => repo.deleteTransaction(id);
}

class GetTransactions {
  final TransactionRepository repo;
  GetTransactions(this.repo);
  Future<List<TransactionEntity>> call(TransactionFilterEntity filter) => repo.getTransactions(filter);
  Stream<List<TransactionEntity>> watch(TransactionFilterEntity filter) => repo.watchTransactions(filter);
}
