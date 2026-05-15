import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../core/services/task_storage_service.dart';
import './widgets/calendar_header_widget.dart';
import './widgets/calendar_month_widget.dart';
import './widgets/calendar_week_widget.dart';
import './widgets/daily_tasks_bottom_sheet.dart';

class CalendarView extends StatefulWidget {
  const CalendarView({super.key});

  @override
  State<CalendarView> createState() => _CalendarViewState();
}

class _CalendarViewState extends State<CalendarView>
    with TickerProviderStateMixin {
  late PageController _monthPageController;
  late PageController _weekPageController;
  late AnimationController _refreshController;

  DateTime _currentMonth = DateTime.now();
  DateTime _selectedDate = DateTime.now();
  bool _isWeekView = false;
  bool _isRefreshing = false;

  // Tasks grouped by date (loaded from storage)
  final Map<DateTime, List<Map<String, dynamic>>> _tasksByDate = {};

  @override
  void initState() {
    super.initState();
    _monthPageController = PageController(initialPage: 1000);
    _weekPageController = PageController(initialPage: 1000);
    _refreshController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _loadTasksFromStorage();
  }

  @override
  void dispose() {
    _monthPageController.dispose();
    _weekPageController.dispose();
    _refreshController.dispose();
    super.dispose();
  }

  Future<void> _loadTasksFromStorage() async {
    final tasks = await TaskStorageService.instance.loadTasks();
    final Map<DateTime, List<Map<String, dynamic>>> grouped = {};

    for (final task in tasks) {
      final dueDate = task['dueDate'] as DateTime?;
      if (dueDate == null) continue;
      final dateKey = DateTime(dueDate.year, dueDate.month, dueDate.day);
      grouped[dateKey] ??= [];
      grouped[dateKey]!.add({
        ...task,
        'time':
            '${dueDate.hour.toString().padLeft(2, '0')}:${dueDate.minute.toString().padLeft(2, '0')}',
        'date': dateKey,
      });
    }

    if (mounted) {
      setState(() {
        _tasksByDate
          ..clear()
          ..addAll(grouped);
      });
    }
  }

  void _onDateSelected(DateTime date) {
    setState(() {
      _selectedDate = date;
    });

    final tasks = _tasksByDate[DateTime(date.year, date.month, date.day)] ?? [];
    _showDailyTasksBottomSheet(date, tasks);
    HapticFeedback.selectionClick();
  }

  void _onDateLongPressed(DateTime date) {
    HapticFeedback.mediumImpact();
    _navigateToAddTask(date);
  }

  void _onPreviousMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month - 1);
    });

    if (_isWeekView) {
      _weekPageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _monthPageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }

    HapticFeedback.lightImpact();
  }

  void _onNextMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + 1);
    });

    if (_isWeekView) {
      _weekPageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _monthPageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }

    HapticFeedback.lightImpact();
  }

  void _onTodayPressed() {
    final today = DateTime.now();
    setState(() {
      _currentMonth = DateTime(today.year, today.month);
      _selectedDate = today;
    });
    HapticFeedback.mediumImpact();
  }

  void _onViewToggle() {
    setState(() {
      _isWeekView = !_isWeekView;
    });
    HapticFeedback.selectionClick();
  }

  Future<void> _onRefresh() async {
    setState(() => _isRefreshing = true);
    _refreshController.forward();
    await _loadTasksFromStorage();
    setState(() => _isRefreshing = false);
    _refreshController.reset();
  }

  void _showDailyTasksBottomSheet(
      DateTime date, List<Map<String, dynamic>> tasks) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DailyTasksBottomSheet(
        selectedDate: date,
        tasks: tasks,
        onTaskTap: _onTaskTapFromSheet,
        onAddTask: () => _navigateToAddTaskFromSheet(date),
      ),
    );
  }

  void _onTaskTapFromSheet(Map<String, dynamic> task) async {
    Navigator.pop(context);
    final result =
        await Navigator.pushNamed(context, '/add-edit-task', arguments: task);
    if (result != null && result is Map<String, dynamic>) {
      await _loadTasksFromStorage();
    }
  }

  void _onTaskTap(Map<String, dynamic> task) async {
    final result =
        await Navigator.pushNamed(context, '/add-edit-task', arguments: task);
    if (result != null && result is Map<String, dynamic>) {
      await _loadTasksFromStorage();
    }
  }

  void _navigateToAddTaskFromSheet(DateTime? date) async {
    Navigator.pop(context);
    final result =
        await Navigator.pushNamed(context, '/add-edit-task', arguments: {
      'selectedDate': date ?? _selectedDate,
    });
    if (result != null && result is Map<String, dynamic>) {
      await _loadTasksFromStorage();
    }
  }

  void _navigateToAddTask(DateTime? date) async {
    final result =
        await Navigator.pushNamed(context, '/add-edit-task', arguments: {
      'selectedDate': date ?? _selectedDate,
    });
    if (result != null && result is Map<String, dynamic>) {
      await _loadTasksFromStorage();
    }
  }

  void _navigateToTimeline() {
    Navigator.pushNamed(context, '/task-list-view');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            CalendarHeaderWidget(
              currentMonth: _currentMonth,
              isWeekView: _isWeekView,
              onPreviousMonth: _onPreviousMonth,
              onNextMonth: _onNextMonth,
              onTodayPressed: _onTodayPressed,
              onViewToggle: _onViewToggle,
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: _onRefresh,
                color: AppTheme.lightTheme.primaryColor,
                child: _isWeekView ? _buildWeekView() : _buildMonthView(),
              ),
            ),
            _buildBottomActions(),
          ],
        ),
      ),
    );
  }

  Widget _buildMonthView() {
    return PageView.builder(
      controller: _monthPageController,
      onPageChanged: (index) {
        final monthOffset = index - 1000;
        final now = DateTime.now();
        setState(() {
          _currentMonth = DateTime(now.year, now.month + monthOffset);
        });
      },
      itemBuilder: (context, index) {
        final monthOffset = index - 1000;
        final now = DateTime.now();
        final month = DateTime(now.year, now.month + monthOffset);

        return CalendarMonthWidget(
          currentMonth: month,
          selectedDate: _selectedDate,
          tasksByDate: _tasksByDate,
          onDateSelected: _onDateSelected,
          onDateLongPressed: _onDateLongPressed,
        );
      },
    );
  }

  Widget _buildWeekView() {
    return PageView.builder(
      controller: _weekPageController,
      onPageChanged: (index) {
        final weekOffset = index - 1000;
        final now = DateTime.now();
        final startOfWeek = _getStartOfWeek(now);
        final selectedWeek = startOfWeek.add(Duration(days: weekOffset * 7));

        setState(() {
          _currentMonth = DateTime(selectedWeek.year, selectedWeek.month);
        });
      },
      itemBuilder: (context, index) {
        final weekOffset = index - 1000;
        final now = DateTime.now();
        final startOfWeek = _getStartOfWeek(now);
        final selectedWeek = startOfWeek.add(Duration(days: weekOffset * 7));

        return CalendarWeekWidget(
          selectedWeek: selectedWeek,
          selectedDate: _selectedDate,
          tasksByDate: _tasksByDate,
          onDateSelected: _onDateSelected,
          onDateLongPressed: _onDateLongPressed,
        );
      },
    );
  }

  Widget _buildBottomActions() {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: _navigateToTimeline,
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 2.h),
                decoration: BoxDecoration(
                  color:
                      AppTheme.lightTheme.primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color:
                        AppTheme.lightTheme.primaryColor.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CustomIconWidget(
                      iconName: 'timeline',
                      size: 20,
                      color: AppTheme.lightTheme.primaryColor,
                    ),
                    SizedBox(width: 2.w),
                    Text(
                      'Timeline View',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.lightTheme.primaryColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(width: 4.w),
          GestureDetector(
            onTap: () => _navigateToAddTask(null),
            child: Container(
              padding: EdgeInsets.all(4.w),
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.primaryColor,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color:
                        AppTheme.lightTheme.primaryColor.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: CustomIconWidget(
                iconName: 'add',
                size: 24,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  DateTime _getStartOfWeek(DateTime date) {
    final weekday = date.weekday % 7;
    return date.subtract(Duration(days: weekday));
  }
}
