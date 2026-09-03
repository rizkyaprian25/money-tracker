import 'package:flutter/material.dart';
import '../providers/budget_provider.dart';

/// Banner peringatan anggaran 80% / over-budget — Fase 2 DB Hardening.
/// Tampil di atas daftar anggaran jika ada kategori >= AppConstants.budgetWarningThreshold
class BudgetWarningBanner extends StatelessWidget {
  final List<BudgetWithSpent> budgets;
  const BudgetWarningBanner({super.key, required this.budgets});

  @override
  Widget build(BuildContext context) {
    final warnings = budgets.where((b) => b.isWarning).toList();
    final overs = budgets.where((b) => b.isOver).toList();
    if (warnings.isEmpty && overs.isEmpty) return const SizedBox.shrink();

    final scheme = Theme.of(context).colorScheme;
    final total = warnings.length + overs.length;
    String title;
    IconData icon;
    Color bg;
    Color fg;
    if (overs.isNotEmpty) {
      title = 'Melebihi Anggaran!';
      icon = Icons.error_outline;
      bg = scheme.error;
      fg = scheme.onError;
    } else {
      title = 'Peringatan Anggaran 80%';
      icon = Icons.warning_amber_rounded;
      bg = scheme.error;
      fg = scheme.onError;
    }

    final names = [...overs, ...warnings].map((b) => b.category?.name ?? 'Semua').join(', ');

    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: fg.withValues(alpha: 0.2), shape: BoxShape.circle),
            child: Icon(icon, color: fg, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(color: fg, fontWeight: FontWeight.w700, fontSize: 13)),
                const SizedBox(height: 2),
                Text(
                  overs.isNotEmpty
                      ? '$total kategori melebihi anggaran: $names'
                      : '$total kategori mencapai ${((warnings.first.progress) * 100).toStringAsFixed(0)}%: $names',
                  style: TextStyle(color: fg.withValues(alpha: 0.9), fontSize: 11),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
