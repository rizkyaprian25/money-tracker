import '../../database/app_database.dart';
import '../../domain/entities/category_entity.dart';
import '../../domain/entities/transaction_entity.dart';
import '../../domain/entities/budget_entity.dart';
import '../../domain/entities/savings_goal_entity.dart';
import '../../domain/entities/app_settings_entity.dart';

extension CategoryMapper on Category {
  CategoryEntity toEntity() => CategoryEntity(
        id: id,
        name: name,
        type: type,
        color: color,
        icon: icon,
        createdAt: createdAt,
      );
}

extension CategoryEntityMapper on CategoryEntity {
  CategoriesCompanion toCompanion() => CategoriesCompanion.insert(
        name: name,
        type: type,
        color: color,
        icon: icon,
      );
  // untuk update: butuh Drift Category model
  Category toDrift() => Category(id: id, name: name, type: type, color: color, icon: icon, createdAt: createdAt);
}

extension TransactionWithCategoryMapper on TransactionWithCategory {
  TransactionEntity toEntity() => TransactionEntity(
        id: transaction.id,
        amount: transaction.amount,
        transactionType: transaction.transactionType,
        categoryId: transaction.categoryId,
        note: transaction.note,
        transactionDate: transaction.transactionDate,
        createdAt: transaction.createdAt,
        category: category?.toEntity(),
      );
}

extension TransactionEntityMapper on TransactionEntity {
  Transaction toDrift() => Transaction(
        id: id,
        amount: amount,
        transactionType: transactionType,
        categoryId: categoryId,
        note: note,
        transactionDate: transactionDate,
        createdAt: createdAt,
      );
}

extension BudgetMapper on Budget {
  BudgetEntity toEntity({CategoryEntity? cat}) => BudgetEntity(
        id: id,
        categoryId: categoryId,
        amount: amount,
        month: month,
        year: year,
        createdAt: createdAt,
        category: cat,
      );
}

extension SavingsGoalMapper on SavingsGoal {
  SavingsGoalEntity toEntity() => SavingsGoalEntity(
        id: id,
        name: name,
        targetAmount: targetAmount,
        currentAmount: currentAmount,
        icon: icon,
        color: color,
        imagePath: imagePath,
        deadline: deadline,
        createdAt: createdAt,
      );
}

extension SavingsContributionMapper on SavingsContribution {
  SavingsContributionEntity toEntity() => SavingsContributionEntity(
        id: id,
        goalId: goalId,
        amount: amount,
        date: date,
        note: note,
      );
}

extension AppSettingMapper on AppSetting {
  AppSettingsEntity toEntity() => AppSettingsEntity(
        id: id,
        currency: currency,
        isDarkMode: isDarkMode,
        language: language,
        lastBackup: lastBackup,
        profileName: profileName,
        profileEmail: profileEmail,
        budgetWarningEnabled: budgetWarningEnabled,
        biometricEnabled: biometricEnabled,
        autoBackupFreq: autoBackupFreq,
        pinSalt: pinSalt,
      );
}


