import '../repositories/transaction_repository.dart';

class GetBalance {
  final TransactionRepository repo;
  GetBalance(this.repo);
  Future<double> call() => repo.getBalance();
}
