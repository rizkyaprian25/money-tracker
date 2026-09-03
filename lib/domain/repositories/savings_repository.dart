import '../entities/savings_goal_entity.dart';

abstract class SavingsRepository {
  Stream<List<SavingsGoalEntity>> watchGoals();
  Stream<List<SavingsContributionEntity>> watchContributions(int goalId);
  Future<int> createGoal({
    required String name,
    required double target,
    String? icon,
    String? color,
    String? imagePath,
    DateTime? deadline,
  });
  Future<bool> updateGoal(SavingsGoalEntity entity);
  Future<int> deleteGoal(int id);
  Future<void> addContribution(int goalId, double amount, {String? note});
}
