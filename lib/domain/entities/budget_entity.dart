import 'category_entity.dart';
import '../../core/constants/app_constants.dart';

/// Domain entity Budget — mirror `lib/database/tables/budgets.dart:3-10`
class BudgetEntity {
  final int id;
  final int? categoryId;
  final double amount;
  final int month; // 1-12
  final int year;
  final DateTime createdAt;
  final CategoryEntity? category;

  const BudgetEntity({
    required this.id,
    this.categoryId,
    required this.amount,
    required this.month,
    required this.year,
    required this.createdAt,
    this.category,
  });

  BudgetEntity copyWith({
    int? id,
    int? categoryId,
    double? amount,
    int? month,
    int? year,
    DateTime? createdAt,
    CategoryEntity? category,
  }) =>
      BudgetEntity(
        id: id ?? this.id,
        categoryId: categoryId ?? this.categoryId,
        amount: amount ?? this.amount,
        month: month ?? this.month,
        year: year ?? this.year,
        createdAt: createdAt ?? this.createdAt,
        category: category ?? this.category,
      );
}

/// Value-object Budget dengan hitungan spent — mirror `BudgetWithSpent` di `lib/presentation/providers/budget_provider.dart:43-51`
class BudgetWithSpentEntity {
  final BudgetEntity budget;
  final double spent;
  final CategoryEntity? category;

  const BudgetWithSpentEntity({
    required this.budget,
    required this.spent,
    this.category,
  });

  double get progress => budget.amount == 0 ? 0 : spent / budget.amount;
  bool get isWarning => progress >= AppConstants.budgetWarningThreshold && progress < 1.0;
  bool get isOver => progress >= 1.0;
  double get remaining => (budget.amount - spent).clamp(0, double.infinity);
  int get percent => (progress * 100).clamp(0, 100).toInt();
}
