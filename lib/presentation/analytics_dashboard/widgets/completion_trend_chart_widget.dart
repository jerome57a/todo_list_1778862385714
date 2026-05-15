import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:sizer/sizer.dart';

class CompletionTrendChartWidget extends StatefulWidget {
  final bool isWeeklyView;
  final Function(bool) onViewToggle;

  const CompletionTrendChartWidget({
    super.key,
    required this.isWeeklyView,
    required this.onViewToggle,
  });

  @override
  State<CompletionTrendChartWidget> createState() =>
      _CompletionTrendChartWidgetState();
}

class _CompletionTrendChartWidgetState
    extends State<CompletionTrendChartWidget> {
  final List<Map<String, dynamic>> weeklyData = [
    {"day": "Mon", "completed": 8, "total": 12},
    {"day": "Tue", "completed": 15, "total": 18},
    {"day": "Wed", "completed": 12, "total": 15},
    {"day": "Thu", "completed": 20, "total": 22},
    {"day": "Fri", "completed": 18, "total": 20},
    {"day": "Sat", "completed": 10, "total": 12},
    {"day": "Sun", "completed": 6, "total": 8},
  ];

  final List<Map<String, dynamic>> monthlyData = [
    {"week": "Week 1", "completed": 89, "total": 107},
    {"week": "Week 2", "completed": 95, "total": 110},
    {"week": "Week 3", "completed": 78, "total": 95},
    {"week": "Week 4", "completed": 102, "total": 115},
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final data = widget.isWeeklyView ? weeklyData : monthlyData;

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
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text('Completion Trend',
                style: theme.textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.w600)),
            Container(
                decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20)),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  GestureDetector(
                      onTap: () => widget.onViewToggle(true),
                      child: Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 3.w, vertical: 1.h),
                          decoration: BoxDecoration(
                              color: widget.isWeeklyView
                                  ? theme.colorScheme.primary
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(16)),
                          child: Text('7D',
                              style: theme.textTheme.bodySmall?.copyWith(
                                  color: widget.isWeeklyView
                                      ? Colors.white
                                      : theme.colorScheme.primary,
                                  fontWeight: FontWeight.w500)))),
                  GestureDetector(
                      onTap: () => widget.onViewToggle(false),
                      child: Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 3.w, vertical: 1.h),
                          decoration: BoxDecoration(
                              color: !widget.isWeeklyView
                                  ? theme.colorScheme.primary
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(16)),
                          child: Text('30D',
                              style: theme.textTheme.bodySmall?.copyWith(
                                  color: !widget.isWeeklyView
                                      ? Colors.white
                                      : theme.colorScheme.primary,
                                  fontWeight: FontWeight.w500)))),
                ])),
          ]),
          SizedBox(height: 3.h),
          SizedBox(
              height: 25.h,
              child: LineChart(LineChartData(
                  gridData: FlGridData(
                      show: true,
                      drawVerticalLine: false,
                      horizontalInterval: widget.isWeeklyView ? 5 : 20,
                      getDrawingHorizontalLine: (value) {
                        return FlLine(
                            color: theme.dividerColor, strokeWidth: 1);
                      }),
                  titlesData: FlTitlesData(
                      show: true,
                      rightTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false)),
                      topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false)),
                      bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 30,
                              interval: 1,
                              getTitlesWidget: (double value, TitleMeta meta) {
                                final index = value.toInt();
                                if (index >= 0 && index < data.length) {
                                  final label = widget.isWeeklyView
                                      ? (data[index]["day"] as String)
                                          .substring(0, 1)
                                      : "W${index + 1}";
                                  return SideTitleWidget(
                                      axisSide: meta.axisSide,
                                      child: Text(label,
                                          style: theme.textTheme.bodySmall
                                              ?.copyWith(
                                                  color: theme.colorScheme
                                                      .onSurfaceVariant)));
                                }
                                return const SizedBox();
                              })),
                      leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                              showTitles: true,
                              interval: widget.isWeeklyView ? 5 : 20,
                              reservedSize: 40,
                              getTitlesWidget: (double value, TitleMeta meta) {
                                return SideTitleWidget(
                                    axisSide: meta.axisSide,
                                    child: Text(value.toInt().toString(),
                                        style: theme.textTheme.bodySmall
                                            ?.copyWith(
                                                color: theme.colorScheme
                                                    .onSurfaceVariant)));
                              }))),
                  borderData: FlBorderData(
                      show: true,
                      border: Border.all(color: theme.dividerColor)),
                  minX: 0,
                  maxX: (data.length - 1).toDouble(),
                  minY: 0,
                  maxY: widget.isWeeklyView ? 25 : 120,
                  lineBarsData: [
                    LineChartBarData(
                        spots: data.asMap().entries.map((entry) {
                          return FlSpot(entry.key.toDouble(),
                              (entry.value["completed"] as int).toDouble());
                        }).toList(),
                        isCurved: true,
                        gradient: LinearGradient(colors: [
                          theme.colorScheme.primary,
                          theme.colorScheme.primary.withValues(alpha: 0.7),
                        ]),
                        barWidth: 3,
                        isStrokeCapRound: true,
                        dotData: FlDotData(
                            show: true,
                            getDotPainter: (spot, percent, barData, index) {
                              return FlDotCirclePainter(
                                  radius: 4,
                                  color: theme.colorScheme.primary,
                                  strokeWidth: 2,
                                  strokeColor: Colors.white);
                            }),
                        belowBarData: BarAreaData(
                            show: true,
                            gradient: LinearGradient(
                                colors: [
                                  theme.colorScheme.primary
                                      .withValues(alpha: 0.3),
                                  theme.colorScheme.primary
                                      .withValues(alpha: 0.1),
                                ],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter))),
                  ],
                  lineTouchData: LineTouchData(
                      enabled: true,
                      touchTooltipData: LineTouchTooltipData(
                          tooltipRoundedRadius: 8,
                          getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
                            return touchedBarSpots.map((barSpot) {
                              final index = barSpot.x.toInt();
                              final completed = data[index]["completed"];
                              final total = data[index]["total"];
                              final label = widget.isWeeklyView
                                  ? data[index]["day"]
                                  : data[index]["week"];

                              return LineTooltipItem(
                                  '$label\n$completed/$total tasks',
                                  TextStyle(
                                      color: theme.colorScheme.onInverseSurface,
                                      fontWeight: FontWeight.w500,
                                      fontSize: 12.sp));
                            }).toList();
                          }))))),
        ]));
  }
}
