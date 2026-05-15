import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../theme/app_theme.dart';

class CalendarWeekWidget extends StatelessWidget {
  final DateTime selectedWeek;
  final DateTime selectedDate;
  final Map<DateTime, List<Map<String, dynamic>>> tasksByDate;
  final Function(DateTime) onDateSelected;
  final Function(DateTime) onDateLongPressed;

  const CalendarWeekWidget({
    super.key,
    required this.selectedWeek,
    required this.selectedDate,
    required this.tasksByDate,
    required this.onDateSelected,
    required this.onDateLongPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 2.h),
      child: Column(
        children: [
          _buildWeekdayHeaders(),
          SizedBox(height: 1.h),
          _buildWeekDays(context),
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

  Widget _buildWeekDays(BuildContext context) {
    final startOfWeek = _getStartOfWeek(selectedWeek);

    return Row(
      children: List.generate(7, (index) {
        final date = startOfWeek.add(Duration(days: index));
        return Expanded(
          child: _buildWeekDayCell(context, date),
        );
      }),
    );
  }

  Widget _buildWeekDayCell(BuildContext context, DateTime date) {
    final isToday = _isSameDay(date, DateTime.now());
    final isSelected = _isSameDay(date, selectedDate);
    final tasks = tasksByDate[DateTime(date.year, date.month, date.day)] ?? [];

    return GestureDetector(
      onTap: () => onDateSelected(date),
      onLongPress: () => onDateLongPressed(date),
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 1.w),
        padding: EdgeInsets.symmetric(vertical: 2.h),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.lightTheme.primaryColor
              : isToday
                  ? AppTheme.lightTheme.primaryColor.withValues(alpha: 0.1)
                  : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: isToday && !isSelected
              ? Border.all(color: AppTheme.lightTheme.primaryColor, width: 1)
              : null,
        ),
        child: Column(
          children: [
            Text(
              date.day.toString(),
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: isToday ? FontWeight.w600 : FontWeight.w400,
                color: isSelected
                    ? Colors.white
                    : isToday
                        ? AppTheme.lightTheme.primaryColor
                        : AppTheme.lightTheme.colorScheme.onSurface,
              ),
            ),
            SizedBox(height: 1.h),
            _buildTaskList(tasks, isSelected),
          ],
        ),
      ),
    );
  }

  Widget _buildTaskList(List<Map<String, dynamic>> tasks, bool isSelected) {
    if (tasks.isEmpty) {
      return SizedBox(
        height: 15.h,
        child: Center(
          child: Text(
            'No tasks',
            style: TextStyle(
              fontSize: 10.sp,
              color: isSelected
                  ? Colors.white.withValues(alpha: 0.7)
                  : AppTheme.lightTheme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      );
    }

    return SizedBox(
      height: 15.h,
      child: ListView.builder(
        itemCount: tasks.length > 3 ? 3 : tasks.length,
        itemBuilder: (context, index) {
          if (index == 2 && tasks.length > 3) {
            return Container(
              margin: EdgeInsets.only(bottom: 0.5.h),
              padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
              decoration: BoxDecoration(
                color: isSelected
                    ? Colors.white.withValues(alpha: 0.2)
                    : AppTheme.lightTheme.colorScheme.surface,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                '+${tasks.length - 2} more',
                style: TextStyle(
                  fontSize: 9.sp,
                  color: isSelected
                      ? Colors.white
                      : AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            );
          }

          final task = tasks[index];
          return Container(
            margin: EdgeInsets.only(bottom: 0.5.h),
            padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
            decoration: BoxDecoration(
              color: _getPriorityColor(task['priority'] as String, isSelected),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              task['title'] as String,
              style: TextStyle(
                fontSize: 9.sp,
                fontWeight: FontWeight.w500,
                color: isSelected ? Colors.white : Colors.white,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          );
        },
      ),
    );
  }

  Color _getPriorityColor(String priority, bool isSelected) {
    if (isSelected) {
      return Colors.white.withValues(alpha: 0.3);
    }

    switch (priority) {
      case 'High':
        return AppTheme.lightTheme.colorScheme.error;
      case 'Medium':
        return Colors.orange;
      case 'Low':
      default:
        return AppTheme.lightTheme.primaryColor;
    }
  }

  DateTime _getStartOfWeek(DateTime date) {
    final weekday = date.weekday % 7;
    return date.subtract(Duration(days: weekday));
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }
}
