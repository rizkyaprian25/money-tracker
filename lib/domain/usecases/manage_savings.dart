import '../repositories/savings_repository.dart';

class CreateSavingsGoal {
  final SavingsRepository repo;
  CreateSavingsGoal(this.repo);
  Future<int> call({required String name, required double target, String? icon, String? color, String? imagePath, DateTime? deadline}) =>
      repo.createGoal(name: name, target: target, icon: icon, color: color, imagePath: imagePath, deadline: deadline);
}

class AddSavingsContribution {
  final SavingsRepository repo;
  AddSavingsContribution(this.repo);
  Future<void> call(int goalId, double amount, {String? note}) => repo.addContribution(goalId, amount, note: note);
}

class DeleteSavingsGoal {
  final SavingsRepository repo;
  DeleteSavingsGoal(this.repo);
  Future<int> call(int id) => repo.deleteGoal(id);
}
