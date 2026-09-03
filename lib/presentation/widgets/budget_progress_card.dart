import 'package:flutter/material.dart';
import '../../core/utils/currency_formatter.dart';
import '../providers/budget_provider.dart';

IconData _iconFromName(String name) {
  const map = {
    'restaurant': Icons.restaurant,
    'directions_car': Icons.directions_car,
    'shopping_bag': Icons.shopping_bag,
    'shopping_cart': Icons.shopping_cart,
    'movie': Icons.movie,
    'receipt': Icons.receipt,
    'favorite': Icons.favorite,
    'school': Icons.school,
    'payments': Icons.payments,
    'category': Icons.category,
  };
  return map[name] ?? Icons.account_balance_wallet;
}

Color _colorFromHex(String hex) {
  try {
    final c = hex.replaceAll('#', '');
    return Color(int.parse('FF$c', radix: 16));
  } catch (_) {
    return Colors.grey;
  }
}

class BudgetProgressCard extends StatelessWidget {
  final BudgetWithSpent data;
  final VoidCallback? onTap;
  const BudgetProgressCard({super.key, required this.data, this.onTap});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final progress = data.progress.clamp(0.0, 1.0);
    final isWarn = data.isWarning;
    final isOver = data.isOver;
    final catName = data.category?.name ?? 'Semua Kategori';
    final iconName = data.category?.icon ?? 'account_balance_wallet';
    final colorHex = data.category?.color ?? '#24389C';
    final baseColor = _colorFromHex(colorHex);

    Color barColor;
    if (isOver) {
      barColor = scheme.error;
    } else if (isWarn) {
      barColor = scheme.error;
    } else {
      barColor = data.category != null ? baseColor : scheme.primary;
    }

    return Container(
      decoration: BoxDecoration(
        color: scheme.surfaceContainer,
        borderRadius: BorderRadius.circular(12),
        border: isWarn || isOver ? Border(left: BorderSide(color: scheme.error, width: 4)) : null,
      ),
      padding: const EdgeInsets.all(16),
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(color: scheme.surfaceContainerHighest, shape: BoxShape.circle),
                    child: Icon(_iconFromName(iconName), color: isOver ? scheme.error : scheme.primary, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Text(catName, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                ]),
                Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                  Text(CurrencyFormatter.format(data.spent),
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: isOver ? scheme.error : scheme.onSurface)),
                  Text('/ ${CurrencyFormatter.format(data.budget.amount)}',
                      style: TextStyle(fontSize: 12, color: scheme.outline)),
                ]),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 8,
                backgroundColor: scheme.surfaceContainerHighest,
                valueColor: AlwaysStoppedAnimation(barColor),
              ),
            ),
            if (isWarn || isOver) ...[
              const SizedBox(height: 6),
              Row(children: [
                Icon(Icons.warning_amber_rounded, size: 14, color: scheme.error),
                const SizedBox(width: 4),
                Text('${(progress * 100).toStringAsFixed(0)}% tercapai', style: TextStyle(fontSize: 11, color: scheme.error, fontWeight: FontWeight.w500)),
                if (isOver) Text(' • Melebihi anggaran!', style: TextStyle(fontSize: 11, color: scheme.error)),
              ]),
            ],
          ],
        ),
      ),
    );
  }
}
