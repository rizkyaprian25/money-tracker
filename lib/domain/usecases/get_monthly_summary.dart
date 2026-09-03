import '../repositories/transaction_repository.dart';

class MonthlySummary {
  final double income;
  final double expense;
  final double balance;
  final double net;
  const MonthlySummary({required this.income, required this.expense, required this.balance, required this.net});
}

class GetMonthlySummary {
  final TransactionRepository repo;
  GetMonthlySummary(this.repo);

  Future<MonthlySummary> call(DateTime month) async {
    final start = DateTime(month.year, month.month, 1);
    final end = DateTime(month.year, month.month + 1, 0, 23, 59, 59);
    final income = await repo.getTotalIncome(start, end);
    final expense = await repo.getTotalExpense(start, end);
    final balance = await repo.getBalance();
    return MonthlySummary(income: income, expense: expense, balance: balance, net: income - expense);
  }
}
