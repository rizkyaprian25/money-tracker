import 'package:flutter/material.dart';
import '../constants/app_constants.dart';
import '../../presentation/providers/budget_provider.dart';

/// Helper untuk menampilkan warning 80% / over-budget via Snackbar / Banner.
/// Threshold: AppConstants.budgetWarningThreshold = 0.8 — lib/core/constants/app_constants.dart:7
class BudgetWarningHelper {
  static void showBudgetWarningSnackbars(BuildContext context, List<BudgetWithSpent> budgets) {
    final warnings = budgets.where((b) => b.isWarning).toList();
    final overs = budgets.where((b) => b.isOver).toList();

    if (overs.isNotEmpty) {
      final names = overs.map((b) => b.category?.name ?? 'Semua').join(', ');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Theme.of(context).colorScheme.error,
          content: Text('Melebihi anggaran: $names (${overs.length} kategori)', style: const TextStyle(color: Colors.white)),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 4),
        ),
      );
    } else if (warnings.isNotEmpty) {
      final names = warnings.map((b) => b.category?.name ?? 'Semua').join(', ');
      final percent = (warnings.first.progress * 100).toStringAsFixed(0);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Theme.of(context).colorScheme.error,
          content: Text('Peringatan $percent% anggaran tercapai: $names', style: const TextStyle(color: Colors.white)),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  static bool hasWarning(List<BudgetWithSpent> budgets) =>
      budgets.any((b) => b.isWarning || b.isOver);

  static int warningCount(List<BudgetWithSpent> budgets) =>
      budgets.where((b) => b.isWarning || b.isOver).length;

  static bool shouldWarn(double progress) => progress >= AppConstants.budgetWarningThreshold;
}
