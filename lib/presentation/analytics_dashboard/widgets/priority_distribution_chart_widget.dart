import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:sizer/sizer.dart';

class PriorityDistributionChartWidget extends StatelessWidget {
  const PriorityDistributionChartWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final List<Map<String, dynamic>> priorityData = [
      {
        "priority": "High",
        "completed": 18,
        "total": 25,
        "color": Color(0xFFDC2626)
      },
      {
        "priority": "Medium",
        "completed": 32,
        "total": 40,
        "color": Color(0xFFD97706)
      },
      {
        "priority": "Low",
        "completed": 28,
        "total": 30,
        "color": Color(0xFF059669)
      },
    ];

    return Container(
        margin: EdgeInsets.symmetric(horizontal: 4.w),
        padding: EdgeInsets.all(4.w),
        decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                  color: theme.shadowColor,
                  blurRadius: 8,
                  offset: const Offset(0, 2)),
            ]),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Priority Distribution',
              style: theme.textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.w600)),
          SizedBox(height: 3.h),
          SizedBox(
              height: 25.h,
              child: BarChart(BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: 50,
                  barTouchData: BarTouchData(
                      enabled: true,
                      touchTooltipData: BarTouchTooltipData(
                          tooltipRoundedRadius: 8,
                          getTooltipItem: (group, groupIndex, rod, rodIndex) {
                            final data = priorityData[group.x.toInt()];
                            final completed = data["completed"];
                            final total = data["total"];
                            final priority = data["priority"];

                            return BarTooltipItem(
                                '$priority Priority\n$completed/$total tasks\n${((completed / total) * 100).toStringAsFixed(1)}%',
                                TextStyle(
                                    color: theme.colorScheme.onInverseSurface,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 12.sp));
                          })),
                  titlesData: FlTitlesData(
                      show: true,
                      rightTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false)),
                      topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false)),
                      bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (double value, TitleMeta meta) {
                                final index = value.toInt();
                                if (index >= 0 && index < priorityData.length) {
                                  return SideTitleWidget(
                                      axisSide: meta.axisSide,
                                      child: Text(
                                          priorityData[index]["priority"]
                                              as String,
                                          style: theme
                                              .textTheme.bodySmall
                                              ?.copyWith(
                                                  color: theme.colorScheme
                                                      .onSurfaceVariant,
                                                  fontWeight:
                                                      FontWeight.w500)));
                                }
                                return const SizedBox();
                              },
                              reservedSize: 30)),
                      leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                              showTitles: true,
                              interval: 10,
                              getTitlesWidget: (double value, TitleMeta meta) {
                                return SideTitleWidget(
                                    axisSide: meta.axisSide,
                                    child: Text(value.toInt().toString(),
                                        style: theme.textTheme.bodySmall
                                            ?.copyWith(
                                                color: theme.colorScheme
                                                    .onSurfaceVariant)));
                              },
                              reservedSize: 40))),
                  borderData: FlBorderData(
                      show: true,
                      border: Border.all(color: theme.dividerColor)),
                  gridData: FlGridData(
                      show: true,
                      drawVerticalLine: false,
                      horizontalInterval: 10,
                      getDrawingHorizontalLine: (value) {
                        return FlLine(
                            color: theme.dividerColor, strokeWidth: 1);
                      }),
                  barGroups: priorityData.asMap().entries.map((entry) {
                    final index = entry.key;
                    final data = entry.value;
                    final completed = data["completed"] as int;
                    final total = data["total"] as int;
                    final color = data["color"] as Color;

                    return BarChartGroupData(x: index, barRods: [
                      BarChartRodData(
                          toY: total.toDouble(),
                          color: color.withValues(alpha: 0.3),
                          width: 8.w,
                          borderRadius: BorderRadius.circular(4)),
                      BarChartRodData(
                          toY: completed.toDouble(),
                          color: color,
                          width: 8.w,
                          borderRadius: BorderRadius.circular(4)),
                    ]);
                  }).toList()))),
          SizedBox(height: 2.h),
          Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
            _buildLegendItem(context, 'Total Tasks',
                theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.3)),
            _buildLegendItem(context, 'Completed', theme.colorScheme.primary),
          ]),
        ]));
  }

  Widget _buildLegendItem(BuildContext context, String label, Color color) {
    final theme = Theme.of(context);

    return Row(mainAxisSize: MainAxisSize.min, children: [
      Container(
          width: 3.w,
          height: 3.w,
          decoration: BoxDecoration(
              color: color, borderRadius: BorderRadius.circular(2))),
      SizedBox(width: 2.w),
      Text(label,
          style: theme.textTheme.bodySmall
              ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
    ]);
  }
}
