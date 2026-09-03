import 'package:flutter/material.dart';
import '../../database/app_database.dart';
import '../../core/utils/currency_formatter.dart';
import '../../core/utils/date_formatter.dart';

IconData _iconFromName(String name) {
  switch (name) {
    case 'restaurant': return Icons.restaurant;
    case 'directions_car': return Icons.directions_car;
    case 'shopping_bag': return Icons.shopping_bag;
    case 'shopping_cart': return Icons.shopping_cart;
    case 'movie': return Icons.movie;
    case 'receipt': return Icons.receipt;
    case 'favorite': return Icons.favorite;
    case 'school': return Icons.school;
    case 'payments': return Icons.payments;
    case 'work': return Icons.work;
    case 'card_giftcard': return Icons.card_giftcard;
    case 'category': return Icons.category;
    case 'home': return Icons.home;
    case 'local_gas_station': return Icons.local_gas_station;
    case 'subscriptions': return Icons.subscriptions;
    default: return Icons.circle;
  }
}

class TransactionTile extends StatelessWidget {
  final TransactionWithCategory item;
  final VoidCallback? onTap;
  const TransactionTile({super.key, required this.item, this.onTap});

  @override
  Widget build(BuildContext context) {
    final tx = item.transaction;
    final cat = item.category;
    final isIncome = tx.transactionType == 'income';
    final scheme = Theme.of(context).colorScheme;
    final icon = cat != null ? _iconFromName(cat.icon) : Icons.circle;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: isIncome ? scheme.secondaryContainer.withValues(alpha: 0.5) : scheme.surfaceContainerHighest,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 20, color: isIncome ? scheme.onSecondaryContainer : scheme.onSurfaceVariant),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(tx.note ?? cat?.name ?? '-',
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600), maxLines: 1, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 2),
                  Text('${cat?.name ?? 'Lainnya'} • ${DateFormatter.formatShort(tx.transactionDate)}',
                      style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant)),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${isIncome ? '+' : '-'}${CurrencyFormatter.format(tx.amount)}',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isIncome ? scheme.secondary : scheme.onSurface,
                  ),
                ),
                Text(DateFormatter.formatTime(tx.transactionDate),
                    style: TextStyle(fontSize: 11, color: scheme.outline)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
