import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class DonutChart extends StatelessWidget {
  final double percent; // 0-1
  final String label;
  final Color color;
  const DonutChart({super.key, required this.percent, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return SizedBox(
      width: 90,
      height: 90,
      child: Stack(
        alignment: Alignment.center,
        children: [
          PieChart(
            PieChartData(
              startDegreeOffset: -90,
              sectionsSpace: 0,
              centerSpaceRadius: 32,
              sections: [
                PieChartSectionData(
                  value: percent * 100,
                  color: color,
                  radius: 10,
                  showTitle: false,
                ),
                PieChartSectionData(
                  value: (1 - percent) * 100,
                  color: scheme.surfaceContainerHighest,
                  radius: 10,
                  showTitle: false,
                ),
              ],
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('${(percent * 100).toStringAsFixed(0)}%', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
              Text(label, style: TextStyle(fontSize: 10, color: scheme.onSurfaceVariant)),
            ],
          ),
        ],
      ),
    );
  }
}
