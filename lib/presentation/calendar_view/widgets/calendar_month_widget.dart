import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../theme/app_theme.dart';

class CalendarMonthWidget extends StatelessWidget {
  final DateTime currentMonth;
  final DateTime selectedDate;
  final Map<DateTime, List<Map<String, dynamic>>> tasksByDate;
  final Function(DateTime) onDateSelected;
  final Function(DateTime) onDateLongPressed;

  const CalendarMonthWidget({
    super.key,
    required this.currentMonth,
    required this.selectedDate,
    required this.tasksByDate,
    required this.onDateSelected,
    required this.onDateLongPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      child: Column(
        children: [
          _buildWeekdayHeaders(),
          SizedBox(height: 1.h),
          _buildCalendarGrid(context),
        ],
      ),
    );
  }

  Widget _buildWeekdayHeaders() {
    final weekdays = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];

    return Row(
      children: weekdays
          .map((day) => Expanded(
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 1.h),
                  child: Text(
                    day,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ))
          .toList(),
    );
  }

  Widget _buildCalendarGrid(BuildContext context) {
    final firstDayOfMonth = DateTime(currentMonth.year, currentMonth.month, 1);
    final lastDayOfMonth =
        DateTime(currentMonth.year, currentMonth.month + 1, 0);
    final firstDayOfWeek = firstDayOfMonth.weekday % 7;
    final daysInMonth = lastDayOfMonth.day;

    List<Widget> dayWidgets = [];

    // Add empty cells for days before the first day of the month
    for (int i = 0; i < firstDayOfWeek; i++) {
      dayWidgets.add(Container());
    }

    // Add day cells
    for (int day = 1; day <= daysInMonth; day++) {
      final date = DateTime(currentMonth.year, currentMonth.month, day);
      dayWidgets.add(_buildDayCell(context, date));
    }

    return GridView.count(
      crossAxisCount: 7,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: dayWidgets,
    );
  }

  Widget _buildDayCell(BuildContext context, DateTime date) {
    final isToday = _isSameDay(date, DateTime.now());
    final isSelected = _isSameDay(date, selectedDate);
    final tasks = tasksByDate[DateTime(date.year, date.month, date.day)] ?? [];
    final hasHighPriorityTasks =
        tasks.any((task) => task['priority'] == 'High');
    final hasMediumPriorityTasks =
        tasks.any((task) => task['priority'] == 'Medium');

    return GestureDetector(
      onTap: () => onDateSelected(date),
      onLongPress: () => onDateLongPressed(date),
      child: Container(
        margin: EdgeInsets.all(0.5.w),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.lightTheme.primaryColor
              : isToday
                  ? AppTheme.lightTheme.primaryColor.withValues(alpha: 0.1)
                  : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: isToday && !isSelected
              ? Border.all(color: AppTheme.lightTheme.primaryColor, width: 1)
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              date.day.toString(),
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: isToday ? FontWeight.w600 : FontWeight.w400,
                color: isSelected
                    ? Colors.white
                    : isToday
                        ? AppTheme.lightTheme.primaryColor
                        : AppTheme.lightTheme.colorScheme.onSurface,
              ),
            ),
            SizedBox(height: 0.5.h),
            _buildTaskIndicators(tasks.length, hasHighPriorityTasks,
                hasMediumPriorityTasks, isSelected),
          ],
        ),
      ),
    );
  }

  Widget _buildTaskIndicators(
      int taskCount, bool hasHigh, bool hasMedium, bool isSelected) {
    if (taskCount == 0) return SizedBox(height: 1.h);

    Color indicatorColor;
    double indicatorSize;

    if (hasHigh) {
      indicatorColor =
          isSelected ? Colors.white : AppTheme.lightTheme.colorScheme.error;
    } else if (hasMedium) {
      indicatorColor = isSelected ? Colors.white : Colors.orange;
    } else {
      indicatorColor =
          isSelected ? Colors.white : AppTheme.lightTheme.primaryColor;
    }

    if (taskCount <= 2) {
      indicatorSize = 1.w;
    } else if (taskCount <= 5) {
      indicatorSize = 1.5.w;
    } else {
      indicatorSize = 2.w;
    }

    return Container(
      width: indicatorSize,
      height: indicatorSize,
      decoration: BoxDecoration(
        color: indicatorColor,
        shape: taskCount > 5 ? BoxShape.circle : BoxShape.circle,
      ),
    );
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }
}
