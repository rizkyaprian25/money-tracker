/// Domain entity SavingsGoal — mirror `lib/database/tables/savings_goals.dart:3-13`
class SavingsGoalEntity {
  final int id;
  final String name;
  final double targetAmount;
  final double currentAmount;
  final String? icon;
  final String? color;
  final String? imagePath;
  final DateTime? deadline;
  final DateTime createdAt;

  const SavingsGoalEntity({
    required this.id,
    required this.name,
    required this.targetAmount,
    required this.currentAmount,
    this.icon,
    this.color,
    this.imagePath,
    this.deadline,
    required this.createdAt,
  });

  double get progress => targetAmount == 0 ? 0 : (currentAmount / targetAmount).clamp(0.0, 1.0);
  double get remaining => (targetAmount - currentAmount).clamp(0, double.infinity);
  bool get isCompleted => currentAmount >= targetAmount;
  int get percent => (progress * 100).round();

  SavingsGoalEntity copyWith({
    int? id,
    String? name,
    double? targetAmount,
    double? currentAmount,
    String? icon,
    String? color,
    String? imagePath,
    DateTime? deadline,
    DateTime? createdAt,
  }) =>
      SavingsGoalEntity(
        id: id ?? this.id,
        name: name ?? this.name,
        targetAmount: targetAmount ?? this.targetAmount,
        currentAmount: currentAmount ?? this.currentAmount,
        icon: icon ?? this.icon,
        color: color ?? this.color,
        imagePath: imagePath ?? this.imagePath,
        deadline: deadline ?? this.deadline,
        createdAt: createdAt ?? this.createdAt,
      );
}

/// Domain entity SavingsContribution — mirror `lib/database/tables/savings_contributions.dart:3-9`
class SavingsContributionEntity {
  final int id;
  final int goalId;
  final double amount;
  final DateTime date;
  final String? note;

  const SavingsContributionEntity({
    required this.id,
    required this.goalId,
    required this.amount,
    required this.date,
    this.note,
  });
}
