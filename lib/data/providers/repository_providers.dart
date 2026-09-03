import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/repositories/transaction_repository.dart';
import '../../domain/repositories/category_repository.dart';
import '../../domain/repositories/budget_repository.dart';
import '../../domain/repositories/savings_repository.dart';
import '../../domain/repositories/settings_repository.dart';
import '../../domain/repositories/dashboard_repository.dart';
import '../../domain/repositories/statistics_repository.dart';
import '../../presentation/providers/database_provider.dart';
import '../repositories/transaction_repository_impl.dart';
import '../repositories/category_repository_impl.dart';
import '../repositories/budget_repository_impl.dart';
import '../repositories/savings_repository_impl.dart';
import '../repositories/settings_repository_impl.dart';
import '../repositories/dashboard_repository_impl.dart';
import '../repositories/statistics_repository_impl.dart';

/// Data layer providers — single source to inject Drift via repositories.
/// Presentation layer should `ref.watch(transactionRepositoryProvider)` instead of `databaseProvider` directly.

final transactionRepositoryProvider = Provider<TransactionRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return TransactionRepositoryImpl(db);
});

final categoryRepositoryProvider = Provider<CategoryRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return CategoryRepositoryImpl(db);
});

final budgetRepositoryProvider = Provider<BudgetRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return BudgetRepositoryImpl(db);
});

final savingsRepositoryProvider = Provider<SavingsRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return SavingsRepositoryImpl(db);
});

final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return SettingsRepositoryImpl(db);
});

final dashboardRepositoryProvider = Provider<DashboardRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return DashboardRepositoryImpl(db);
});

final statisticsRepositoryProvider = Provider<StatisticsRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return StatisticsRepositoryImpl(db);
});
