import 'package:drift/drift.dart';
import '../../database/app_database.dart';
import '../../domain/entities/budget_entity.dart';
import '../../domain/repositories/budget_repository.dart';
import '../mappers/entity_mapper.dart';

class BudgetRepositoryImpl implements BudgetRepository {
  final AppDatabase db;
  BudgetRepositoryImpl(this.db);

  @override
  Stream<List<BudgetEntity>> watchBudgets() =>
      db.watchBudgets().map((list) => list.map((b) => b.toEntity()).toList());

  @override
  Future<List<BudgetEntity>> getBudgetsByMonth(int month, int year) async {
    final rows = await (db.select(db.budgets)..where((b) => b.month.equals(month) & b.year.equals(year))).get();
    final cats = await db.select(db.categories).get();
    final catMap = {for (var c in cats) c.id: c.toEntity()};
    return rows.map((b) => b.toEntity(cat: b.categoryId != null ? catMap[b.categoryId] : null)).toList();
  }

  @override
  Future<List<BudgetWithSpentEntity>> getBudgetsWithSpent(int month, int year) async {
    final budgets = await (db.select(db.budgets)..where((b) => b.month.equals(month) & b.year.equals(year))).get();
    final cats = await db.select(db.categories).get();
    final catMap = {for (var c in cats) c.id: c.toEntity()};

    final start = DateTime(year, month, 1);
    final end = DateTime(year, month + 1, 0, 23, 59, 59);
    List<BudgetWithSpentEntity> result = [];
    for (final b in budgets) {
      double spent = 0;
      if (b.categoryId != null) {
        final txs = await db.getTransactions(type: 'expense', categoryId: b.categoryId, startDate: start, endDate: end, limit: 1000);
        spent = txs.fold(0, (p, e) => p + e.transaction.amount);
      } else {
        spent = await db.getTotalExpense(start, end);
      }
      final budgetEntity = b.toEntity(cat: b.categoryId != null ? catMap[b.categoryId] : null);
      result.add(BudgetWithSpentEntity(budget: budgetEntity, spent: spent, category: b.categoryId != null ? catMap[b.categoryId] : null));
    }
    return result;
  }

  @override
  Future<int> setBudget({int? categoryId, required double amount, required int month, required int year}) async {
    final existing = await (db.select(db.budgets)
          ..where((b) {
            if (categoryId == null) {
              return b.categoryId.isNull() & b.month.equals(month) & b.year.equals(year);
            } else {
              return b.categoryId.equals(categoryId) & b.month.equals(month) & b.year.equals(year);
            }
          }))
        .getSingleOrNull();
    if (existing != null) {
      await db.updateBudget(existing.copyWith(amount: amount));
      return existing.id;
    } else {
      return db.insertBudget(BudgetsCompanion.insert(
        categoryId: Value(categoryId),
        amount: amount,
        month: month,
        year: year,
      ));
    }
  }

  @override
  Future<int> deleteBudget(int id) => db.deleteBudget(id);
}
