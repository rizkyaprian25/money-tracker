import 'package:flutter/material.dart';
import '../../core/utils/currency_formatter.dart';

class BalanceCard extends StatelessWidget {
  final double balance;
  final double income;
  final double expense;
  const BalanceCard({super.key, required this.balance, required this.income, required this.expense});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: scheme.primary,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.12), blurRadius: 8, offset: const Offset(0, 4))],
      ),
      padding: const EdgeInsets.all(16),
      child: Stack(
        children: [
          Positioned(
            right: -20,
            top: -20,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Saldo Saat Ini', style: TextStyle(color: scheme.onPrimary.withValues(alpha: 0.85), fontSize: 12, letterSpacing: 0.5)),
              const SizedBox(height: 4),
              Text(CurrencyFormatter.format(balance),
                  style: TextStyle(color: scheme.onPrimary, fontSize: 24, fontWeight: FontWeight.w700, letterSpacing: -0.5)),
              const SizedBox(height: 16),
              Container(height: 1, color: Colors.white.withValues(alpha: 0.15)),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Row(children: [
                      Icon(Icons.arrow_downward, size: 14, color: scheme.onPrimary.withValues(alpha: 0.8)),
                      const SizedBox(width: 4),
                      Text('Pemasukan', style: TextStyle(color: scheme.onPrimary.withValues(alpha: 0.85), fontSize: 11)),
                    ]),
                    const SizedBox(height: 4),
                    Text(CurrencyFormatter.format(income),
                        style: TextStyle(color: scheme.onPrimary, fontSize: 14, fontWeight: FontWeight.w600)),
                  ]),
                  Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                    Row(children: [
                      Icon(Icons.arrow_upward, size: 14, color: scheme.onPrimary.withValues(alpha: 0.8)),
                      const SizedBox(width: 4),
                      Text('Pengeluaran', style: TextStyle(color: scheme.onPrimary.withValues(alpha: 0.85), fontSize: 11)),
                    ]),
                    const SizedBox(height: 4),
                    Text(CurrencyFormatter.format(expense),
                        style: TextStyle(color: scheme.onPrimary, fontSize: 14, fontWeight: FontWeight.w600)),
                  ]),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
