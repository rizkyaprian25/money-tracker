import 'package:drift/drift.dart';
import '../../database/app_database.dart';
import '../../domain/entities/savings_goal_entity.dart';
import '../../domain/repositories/savings_repository.dart';
import '../mappers/entity_mapper.dart';

class SavingsRepositoryImpl implements SavingsRepository {
  final AppDatabase db;
  SavingsRepositoryImpl(this.db);

  @override
  Stream<List<SavingsGoalEntity>> watchGoals() =>
      db.watchSavingsGoals().map((list) => list.map((g) => g.toEntity()).toList());

  @override
  Stream<List<SavingsContributionEntity>> watchContributions(int goalId) =>
      db.watchContributions(goalId).map((list) => list.map((c) => c.toEntity()).toList());

  @override
  Future<int> createGoal({required String name, required double target, String? icon, String? color, String? imagePath, DateTime? deadline}) =>
      db.insertSavingsGoal(SavingsGoalsCompanion.insert(
        name: name,
        targetAmount: target,
        currentAmount: const Value(0.0),
        icon: Value(icon),
        color: Value(color),
        imagePath: Value(imagePath),
        deadline: Value(deadline),
      ));

  @override
  Future<bool> updateGoal(SavingsGoalEntity entity) {
    final drift = SavingsGoal(
      id: entity.id,
      name: entity.name,
      targetAmount: entity.targetAmount,
      currentAmount: entity.currentAmount,
      icon: entity.icon,
      color: entity.color,
      imagePath: entity.imagePath,
      deadline: entity.deadline,
      createdAt: entity.createdAt,
    );
    return db.updateSavingsGoal(drift);
  }

  @override
  Future<int> deleteGoal(int id) => db.deleteSavingsGoal(id);

  @override
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
}
