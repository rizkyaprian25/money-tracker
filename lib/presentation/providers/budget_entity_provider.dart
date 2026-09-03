import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/providers/repository_providers.dart';
import '../../domain/entities/budget_entity.dart';

/// Clean-architecture budget provider — uses `BudgetRepository` instead of direct `AppDatabase`.
/// Keep `budget_provider.dart` (legacy) for backward compat; new screens should watch this one.

final budgetsStreamEntityProvider = StreamProvider<List<BudgetEntity>>((ref) {
  final repo = ref.watch(budgetRepositoryProvider);
  return repo.watchBudgets();
});

final budgetWithSpentEntityProvider = FutureProvider<List<BudgetWithSpentEntity>>((ref) async {
  final repo = ref.watch(budgetRepositoryProvider);
  final now = DateTime.now();
  // watch to refresh — trick similar to legacy provider
  ref.watch(budgetsStreamEntityProvider);
  return repo.getBudgetsWithSpent(now.month, now.year);
});

class BudgetEntityNotifier {
  final dynamic repo; // BudgetRepository
  BudgetEntityNotifier(this.repo);

  Future<int> setBudget({
    int? categoryId,
    required double amount,
    required int month,
    required int year,
  }) =>
      repo.setBudget(categoryId: categoryId, amount: amount, month: month, year: year);

  Future<int> deleteBudget(int id) => repo.deleteBudget(id);
}

final budgetEntityNotifierProvider = Provider<BudgetEntityNotifier>((ref) {
  final repo = ref.watch(budgetRepositoryProvider);
  return BudgetEntityNotifier(repo);
});
