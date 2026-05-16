import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../core/services/task_storage_service.dart';
import './widgets/dashboard_header_widget.dart';
import './widgets/empty_state_widget.dart';
import './widgets/quick_add_fab_widget.dart';
import './widgets/statistics_bar_widget.dart';
import './widgets/task_section_widget.dart';

class MainTaskDashboard extends StatefulWidget {
  const MainTaskDashboard({super.key});

  @override
  State<MainTaskDashboard> createState() => _MainTaskDashboardState();
}

class _MainTaskDashboardState extends State<MainTaskDashboard>
    with TickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  bool _isRefreshing = false;
  bool _isLoading = true;

  final String _userName = "User";
  List<Map<String, dynamic>> _tasks = [];

  List<Map<String, dynamic>> get _todayTasks {
    final today = DateTime.now();
    return _tasks.where((task) {
      final dueDate = task['dueDate'] as DateTime?;
      if (dueDate == null) return false;
      return dueDate.year == today.year &&
          dueDate.month == today.month &&
          dueDate.day == today.day &&
          !(task['isCompleted'] as bool? ?? false);
    }).toList();
  }

  List<Map<String, dynamic>> get _overdueTasks {
    final now = DateTime.now();
    return _tasks.where((task) {
      final dueDate = task['dueDate'] as DateTime?;
      if (dueDate == null) return false;
      return dueDate.isBefore(now) && !(task['isCompleted'] as bool? ?? false);
    }).toList();
  }

  List<Map<String, dynamic>> get _upcomingTasks {
    final now = DateTime.now();
    final nextWeek = now.add(const Duration(days: 7));
    return _tasks.where((task) {
      final dueDate = task['dueDate'] as DateTime?;
      if (dueDate == null) return false;
      return dueDate.isAfter(now) &&
          dueDate.isBefore(nextWeek) &&
          !(task['isCompleted'] as bool? ?? false) &&
          !_todayTasks.contains(task);
    }).toList();
  }

  List<Map<String, dynamic>> get _completedTasks {
    return _tasks
        .where((task) => task['isCompleted'] as bool? ?? false)
        .toList();
  }

  int get _completionStreak => 7;

  double get _todayProgress {
    final today = DateTime.now();
    final totalTodayTasks = _tasks.where((task) {
      final dueDate = task['dueDate'] as DateTime?;
      if (dueDate == null) return false;
      return dueDate.year == today.year &&
          dueDate.month == today.month &&
          dueDate.day == today.day;
    }).length;

    if (totalTodayTasks == 0) return 1.0;

    final completedTodayTasks = _tasks.where((task) {
      final dueDate = task['dueDate'] as DateTime?;
      if (dueDate == null) return false;
      return dueDate.year == today.year &&
          dueDate.month == today.month &&
          dueDate.day == today.day &&
          (task['isCompleted'] as bool? ?? false);
    }).length;

    return completedTodayTasks / totalTodayTasks;
  }

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _loadTasks();
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadTasks() async {
    final tasks = await TaskStorageService.instance.loadTasks();
    if (mounted) {
      setState(() {
        _tasks = tasks;
        _isLoading = false;
      });
    }
  }

  void _onScroll() {}

  Future<void> _onRefresh() async {
    setState(() => _isRefreshing = true);
    HapticFeedback.lightImpact();
    await _loadTasks();
    setState(() => _isRefreshing = false);
    HapticFeedback.mediumImpact();
  }

  void _onTaskTap(Map<String, dynamic> task) {
    HapticFeedback.lightImpact();
    _onTaskEdit(task);
  }

  void _onTaskComplete(Map<String, dynamic> task) async {
    final updated =
        await TaskStorageService.instance.toggleCompletion(_tasks, task['id']);
    if (mounted) {
      setState(() => _tasks = updated);
    }
    HapticFeedback.mediumImpact();
  }

  void _onTaskDelete(Map<String, dynamic> task) async {
    final updated =
        await TaskStorageService.instance.deleteTask(_tasks, task['id']);
    if (mounted) {
      setState(() => _tasks = updated);
    }
    HapticFeedback.heavyImpact();
    // The pop-up notification has been entirely removed
  }

  void _onTaskEdit(Map<String, dynamic> task) async {
    HapticFeedback.lightImpact();
    final result = await Navigator.pushNamed(
      context,
      '/add-edit-task',
      arguments: task,
    );
    if (result != null && result is Map<String, dynamic>) {
      if (result['deleted'] == true) {
        final updated =
            await TaskStorageService.instance.deleteTask(_tasks, task['id']);
        if (mounted) setState(() => _tasks = updated);
      } else {
        final updated =
            await TaskStorageService.instance.updateTask(_tasks, result);
        if (mounted) setState(() => _tasks = updated);
      }
    }
  }

  void _onSearchTap() {
    HapticFeedback.lightImpact();
    Navigator.pushNamed(context, '/search-and-filter');
  }

  void _onProfileTap() {
    HapticFeedback.lightImpact();
    Navigator.pushNamed(context, '/settings-and-preferences');
  }

  void _onAddTask() async {
    HapticFeedback.mediumImpact();
    final result = await Navigator.pushNamed(context, '/add-edit-task');
    if (result != null &&
        result is Map<String, dynamic> &&
        result['deleted'] != true) {
      final updated = await TaskStorageService.instance.addTask(_tasks, result);
      if (mounted) setState(() => _tasks = updated);
    }
  }

  void _onVoiceInput() {
    HapticFeedback.mediumImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Voice input feature coming soon!'),
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      currentIndex: 0,
      onTap: (index) {
        HapticFeedback.lightImpact();
        switch (index) {
          case 0:
            break;
          case 1:
            Navigator.pushNamed(context, '/task-list-view');
            break;
          case 2:
            Navigator.pushNamed(context, '/calendar-view');
            break;
          case 3:
            Navigator.pushNamed(context, '/analytics-dashboard');
            break;
        }
      },
      items: [
        BottomNavigationBarItem(
          icon: CustomIconWidget(
            iconName: 'dashboard',
            color: AppTheme.lightTheme.colorScheme.primary,
            size: 24,
          ),
          label: 'Dashboard',
        ),
        BottomNavigationBarItem(
          icon: CustomIconWidget(
            iconName: 'list',
            color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
            size: 24,
          ),
          label: 'Tasks',
        ),
        BottomNavigationBarItem(
          icon: CustomIconWidget(
            iconName: 'calendar_today',
            color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
            size: 24,
          ),
          label: 'Calendar',
        ),
        BottomNavigationBarItem(
          icon: CustomIconWidget(
            iconName: 'analytics',
            color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
            size: 24,
          ),
          label: 'Analytics',
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
        body: const Center(child: CircularProgressIndicator()),
        bottomNavigationBar: _buildBottomNavigationBar(),
      );
    }

    final hasAnyTasks = _todayTasks.isNotEmpty ||
        _overdueTasks.isNotEmpty ||
        _upcomingTasks.isNotEmpty ||
        _completedTasks.isNotEmpty;

    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      body: SafeArea(
        child: hasAnyTasks
            ? RefreshIndicator(
                onRefresh: _onRefresh,
                color: AppTheme.lightTheme.colorScheme.primary,
                child: CustomScrollView(
                  controller: _scrollController,
                  physics: const AlwaysScrollableScrollPhysics(),
                  slivers: [
                    SliverToBoxAdapter(
                      child: Column(
                        children: [
                          DashboardHeaderWidget(
                            userName: _userName,
                            onSearchTap: _onSearchTap,
                            onProfileTap: _onProfileTap,
                          ),
                          StatisticsBarWidget(
                            completionStreak: _completionStreak,
                            todayProgress: _todayProgress,
                            completedTasks: _completedTasks.length,
                            totalTasks: _tasks.length,
                          ),
                        ],
                      ),
                    ),
                    SliverList(
                      delegate: SliverChildListDelegate([
                        _overdueTasks.isNotEmpty
                            ? TaskSectionWidget(
                                title: 'Overdue',
                                tasks: _overdueTasks,
                                accentColor: const Color(0xFFDC2626),
                                onTaskTap: _onTaskTap,
                                onTaskComplete: _onTaskComplete,
                                onTaskDelete: _onTaskDelete,
                                onTaskEdit: _onTaskEdit,
                              )
                            : const SizedBox.shrink(),
                        _todayTasks.isNotEmpty
                            ? TaskSectionWidget(
                                title: 'Today',
                                tasks: _todayTasks,
                                accentColor:
                                    AppTheme.lightTheme.colorScheme.primary,
                                onTaskTap: _onTaskTap,
                                onTaskComplete: _onTaskComplete,
                                onTaskDelete: _onTaskDelete,
                                onTaskEdit: _onTaskEdit,
                              )
                            : const SizedBox.shrink(),
                        _upcomingTasks.isNotEmpty
                            ? TaskSectionWidget(
                                title: 'Upcoming',
                                tasks: _upcomingTasks,
                                accentColor: const Color(0xFFD97706),
                                onTaskTap: _onTaskTap,
                                onTaskComplete: _onTaskComplete,
                                onTaskDelete: _onTaskDelete,
                                onTaskEdit: _onTaskEdit,
                              )
                            : const SizedBox.shrink(),
                        _completedTasks.isNotEmpty
                            ? TaskSectionWidget(
                                title: 'Recently Completed',
                                tasks: _completedTasks.take(5).toList(),
                                accentColor: const Color(0xFF059669),
                                onTaskTap: _onTaskTap,
                                onTaskComplete: _onTaskComplete,
                                onTaskDelete: _onTaskDelete,
                                onTaskEdit: _onTaskEdit,
                              )
                            : const SizedBox.shrink(),
                        SizedBox(height: 10.h),
                      ]),
                    ),
                  ],
                ),
              )
            : EmptyStateWidget(
                title: 'Welcome to TaskFlow Pro!',
                subtitle:
                    'Start organizing your life by adding your first task. Tap the button below to get started.',
                buttonText: 'Add Your First Task',
                onButtonTap: _onAddTask,
              ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
      floatingActionButton: QuickAddFabWidget(
        onAddTask: _onAddTask,
        onVoiceInput: _onVoiceInput,
      ),
    );
  }
}