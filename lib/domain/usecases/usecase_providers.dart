import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/providers/repository_providers.dart';
import 'get_balance.dart';
import 'get_dashboard.dart';
import 'get_monthly_summary.dart';
import 'get_statistics.dart';
import 'manage_budget.dart';
import 'manage_savings.dart';
import 'manage_transaction.dart';

// Transaction usecases
final getBalanceProvider = Provider<GetBalance>((ref) => GetBalance(ref.watch(transactionRepositoryProvider)));
final getMonthlySummaryProvider = Provider<GetMonthlySummary>((ref) => GetMonthlySummary(ref.watch(transactionRepositoryProvider)));
final addTransactionProvider = Provider<AddTransaction>((ref) => AddTransaction(ref.watch(transactionRepositoryProvider)));
final updateTransactionProvider = Provider<UpdateTransaction>((ref) => UpdateTransaction(ref.watch(transactionRepositoryProvider)));
final deleteTransactionProvider = Provider<DeleteTransaction>((ref) => DeleteTransaction(ref.watch(transactionRepositoryProvider)));
final getTransactionsProvider = Provider<GetTransactions>((ref) => GetTransactions(ref.watch(transactionRepositoryProvider)));

// Dashboard
final getDashboardProvider = Provider<GetDashboard>((ref) => GetDashboard(ref.watch(dashboardRepositoryProvider)));

// Statistics
final getStatisticsProvider = Provider<GetStatistics>((ref) => GetStatistics(ref.watch(statisticsRepositoryProvider)));

// Budget
final getBudgetsWithSpentProvider = Provider<GetBudgetsWithSpent>((ref) => GetBudgetsWithSpent(ref.watch(budgetRepositoryProvider)));
final setBudgetProvider = Provider<SetBudget>((ref) => SetBudget(ref.watch(budgetRepositoryProvider)));
final deleteBudgetProvider = Provider<DeleteBudget>((ref) => DeleteBudget(ref.watch(budgetRepositoryProvider)));

// Savings
final createSavingsGoalProvider = Provider<CreateSavingsGoal>((ref) => CreateSavingsGoal(ref.watch(savingsRepositoryProvider)));
final addSavingsContributionProvider = Provider<AddSavingsContribution>((ref) => AddSavingsContribution(ref.watch(savingsRepositoryProvider)));
final deleteSavingsGoalProvider = Provider<DeleteSavingsGoal>((ref) => DeleteSavingsGoal(ref.watch(savingsRepositoryProvider)));
