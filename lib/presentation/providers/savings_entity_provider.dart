import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/providers/repository_providers.dart';
import '../../domain/entities/savings_goal_entity.dart';

/// Clean-architecture savings provider — uses `SavingsRepository`.
/// Legacy `savings_provider.dart` remains for backward compat.

final savingsGoalsStreamEntityProvider = StreamProvider<List<SavingsGoalEntity>>((ref) {
  final repo = ref.watch(savingsRepositoryProvider);
  return repo.watchGoals();
});

final savingsContributionsEntityProvider =
    StreamProvider.family<List<SavingsContributionEntity>, int>((ref, goalId) {
  final repo = ref.watch(savingsRepositoryProvider);
  return repo.watchContributions(goalId);
});

class SavingsEntityNotifier {
  final dynamic repo; // SavingsRepository
  SavingsEntityNotifier(this.repo);

  Future<int> createGoal({
    required String name,
    required double target,
    String? icon,
    String? color,
    DateTime? deadline,
    String? imagePath,
  }) =>
      repo.createGoal(name: name, target: target, icon: icon, color: color, imagePath: imagePath, deadline: deadline);

  Future<void> addContribution(int goalId, double amount, {String? note}) =>
      repo.addContribution(goalId, amount, note: note);

  Future<bool> updateGoal(SavingsGoalEntity entity) => repo.updateGoal(entity);
  Future<int> deleteGoal(int id) => repo.deleteGoal(id);
}

final savingsEntityNotifierProvider = Provider<SavingsEntityNotifier>((ref) {
  final repo = ref.watch(savingsRepositoryProvider);
  return SavingsEntityNotifier(repo);
});
