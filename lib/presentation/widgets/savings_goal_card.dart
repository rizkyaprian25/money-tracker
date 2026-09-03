import 'package:flutter/material.dart';
import '../../database/app_database.dart';
import '../../core/utils/currency_formatter.dart';
import 'goal_image_widget.dart' as goal_image;

class SavingsGoalCard extends StatelessWidget {
  final SavingsGoal goal;
  final VoidCallback? onTap;
  final VoidCallback? onAdd;
  const SavingsGoalCard({super.key, required this.goal, this.onTap, this.onAdd});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final progress = goal.targetAmount == 0 ? 0.0 : (goal.currentAmount / goal.targetAmount).clamp(0.0, 1.0);
    // Web-safe: cek filesystem hanya di IO via goal_image.hasGoalImage().
    // Di web path lokal Android -> false -> tampil placeholder (tidak crash).
    final hasImage = goal_image.hasGoalImage(goal.imagePath);

    return Container(
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8)],
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 110,
              width: double.infinity,
              decoration: BoxDecoration(
                color: scheme.primaryContainer.withValues(alpha: 0.2),
              ),
              child: hasImage
                  ? goal_image.GoalImageWidget(
                      imagePath: goal.imagePath,
                      fallbackIcon: goal.icon == 'beach_access'
                          ? Icons.beach_access
                          : Icons.laptop,
                      fallbackColor:
                          scheme.primary.withValues(alpha: 0.5),
                    )
                  : Icon(
                      goal.icon == 'beach_access' ? Icons.beach_access : Icons.laptop,
                      size: 40,
                      color: scheme.primary.withValues(alpha: 0.5),
                    ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                          child: Text(goal.name,
                              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis)),
                      if (onAdd != null)
                        InkWell(
                          onTap: onAdd,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration:
                                BoxDecoration(color: scheme.primaryContainer, borderRadius: BorderRadius.circular(20)),
                            child: Text('+ Tambah', style: TextStyle(fontSize: 10, color: scheme.onPrimaryContainer, fontWeight: FontWeight.w600)),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(CurrencyFormatter.format(goal.currentAmount),
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                      Text('Target: ${CurrencyFormatter.format(goal.targetAmount)}',
                          style: TextStyle(fontSize: 11, color: scheme.outline)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 6,
                      backgroundColor: scheme.surfaceContainerHighest,
                      valueColor: AlwaysStoppedAnimation(scheme.primaryContainer),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text('${(progress * 100).toStringAsFixed(0)}% terkumpul',
                        style: TextStyle(fontSize: 11, color: scheme.primary, fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
