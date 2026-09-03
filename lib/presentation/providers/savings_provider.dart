import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../database/app_database.dart';
import 'database_provider.dart';

final savingsGoalsStreamProvider = StreamProvider<List<SavingsGoal>>((ref) {
  final db = ref.watch(databaseProvider);
  return db.watchSavingsGoals();
});

final savingsContributionsProvider = StreamProvider.family<List<SavingsContribution>, int>((ref, goalId) {
  final db = ref.watch(databaseProvider);
  return db.watchContributions(goalId);
});

class SavingsNotifier {
  final AppDatabase db;
  SavingsNotifier(this.db);

  Future<int> createGoal({
    required String name,
    required double target,
    String? icon,
    String? color,
    DateTime? deadline,
    String? imagePath,
  }) {
    return db.insertSavingsGoal(SavingsGoalsCompanion.insert(
      name: name,
      targetAmount: target,
      currentAmount: const Value(0.0),
      icon: Value(icon),
      color: Value(color),
      imagePath: Value(imagePath),
      deadline: Value(deadline),
    ));
  }

  Future<void> addContribution(int goalId, double amount, {String? note}) async {
    await db.transaction(() async {
      await db.insertContribution(SavingsContributionsCompanion.insert(
        goalId: goalId,
        amount: amount,
        date: DateTime.now(),
        note: Value(note),
      ));
      final goal = await (db.select(db.savingsGoals)..where((g) => g.id.equals(goalId))).getSingle();
      await db.updateSavingsGoal(goal.copyWith(currentAmount: goal.currentAmount + amount));
    });
  }

  Future<bool> updateGoal(SavingsGoal goal) => db.updateSavingsGoal(goal);
  Future<int> deleteGoal(int id) => db.deleteSavingsGoal(id);
}

final savingsNotifierProvider = Provider<SavingsNotifier>((ref) {
  final db = ref.watch(databaseProvider);
  return SavingsNotifier(db);
});
