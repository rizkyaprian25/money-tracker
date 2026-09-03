import '../repositories/budget_repository.dart';

class GetBudgetsWithSpent {
  final BudgetRepository repo;
  GetBudgetsWithSpent(this.repo);
  Future<dynamic> call(int month, int year) => repo.getBudgetsWithSpent(month, year);
}

class SetBudget {
  final BudgetRepository repo;
  SetBudget(this.repo);
  Future<int> call({int? categoryId, required double amount, required int month, required int year}) =>
      repo.setBudget(categoryId: categoryId, amount: amount, month: month, year: year);
}

class DeleteBudget {
  final BudgetRepository repo;
  DeleteBudget(this.repo);
  Future<int> call(int id) => repo.deleteBudget(id);
}
