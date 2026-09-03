import '../entities/budget_entity.dart';

abstract class BudgetRepository {
  Stream<List<BudgetEntity>> watchBudgets();
  Future<List<BudgetEntity>> getBudgetsByMonth(int month, int year);
  Future<List<BudgetWithSpentEntity>> getBudgetsWithSpent(int month, int year);
  Future<int> setBudget({
    int? categoryId,
    required double amount,
    required int month,
    required int year,
  });
  Future<int> deleteBudget(int id);
}
