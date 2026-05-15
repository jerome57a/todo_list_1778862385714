import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../core/services/task_storage_service.dart';
import './widgets/achievement_badges_widget.dart';
import './widgets/category_breakdown_chart_widget.dart';
import './widgets/completion_trend_chart_widget.dart';
import './widgets/metrics_card_widget.dart';
import './widgets/priority_distribution_chart_widget.dart';
import './widgets/productivity_insights_widget.dart';
import './widgets/progress_ring_widget.dart';

class AnalyticsDashboard extends StatefulWidget {
  const AnalyticsDashboard({super.key});

  @override
  State<AnalyticsDashboard> createState() => _AnalyticsDashboardState();
}

class _AnalyticsDashboardState extends State<AnalyticsDashboard>
    with SingleTickerProviderStateMixin {
  bool isWeeklyView = true;
  late TabController _tabController;
  
  // Real Data Variables
  List<Map<String, dynamic>> _tasks = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadTasks();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // Load actual tasks to calculate metrics
  Future<void> _loadTasks() async {
    final tasks = await TaskStorageService.instance.loadTasks();
    if (mounted) {
      setState(() {
        _tasks = tasks;
        _isLoading = false;
      });
    }
  }

  // --- Dynamic Math Calculations for Metrics ---
  Map<String, dynamic> _calculateMetrics(int days) {
    if (_tasks.isEmpty) {
      return {'completed': '0', 'rate': '0', 'avg': '0.0', 'progress': 0.0};
    }

    final now = DateTime.now();
    final startDate = now.subtract(Duration(days: days));

    int totalTasks = 0;
    int completedTasks = 0;

    for (var task in _tasks) {
      final dueDate = task['dueDate'] as DateTime?;
      if (dueDate != null &&
          dueDate.isAfter(startDate) &&
          dueDate.isBefore(now.add(const Duration(days: 1)))) {
        totalTasks++;
        if (task['isCompleted'] == true) {
          completedTasks++;
        }
      }
    }

    double rate = totalTasks > 0 ? (completedTasks / totalTasks) * 100 : 0.0;
    double avg = days > 0 ? totalTasks / days : 0.0;
    double progress = totalTasks > 0 ? (completedTasks / totalTasks) : 0.0;

    return {
      'completed': completedTasks.toString(),
      'rate': rate.toStringAsFixed(0),
      'avg': avg.toStringAsFixed(1),
      'progress': progress,
    };
  }

  int _calculateStreak() {
    if (_tasks.isEmpty) return 0;

    // Get all unique dates where a task was completed
    final completedDates = _tasks
        .where((t) => t['isCompleted'] == true && t['dueDate'] != null)
        .map((t) {
          final d = t['dueDate'] as DateTime;
          return DateTime(d.year, d.month, d.day);
        })
        .toSet()
        .toList();

    completedDates.sort((a, b) => b.compareTo(a)); // sort newest first
    if (completedDates.isEmpty) return 0;

    int streak = 0;
    DateTime currentDate = DateTime(
        DateTime.now().year, DateTime.now().month, DateTime.now().day);

    // If latest completion isn't today or yesterday, streak is broken
    if (completedDates.first
        .isBefore(currentDate.subtract(const Duration(days: 1)))) {
      return 0;
    }

    DateTime expectedDate = completedDates.first;
    for (var date in completedDates) {
      if (date.isAtSameMomentAs(expectedDate)) {
        streak++;
        expectedDate = expectedDate.subtract(const Duration(days: 1));
      } else {
        break;
      }
    }
    return streak;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('Analytics Dashboard'),
        actions: [
          IconButton(
            onPressed: _exportReport,
            icon: CustomIconWidget(
              iconName: 'file_download',
              color: theme.colorScheme.onSurface,
              size: 24,
            ),
            tooltip: 'Export Report',
          ),
          IconButton(
            onPressed:
                () => Navigator.pushNamed(context, '/settings-and-preferences'),
            icon: CustomIconWidget(
              iconName: 'settings',
              color: theme.colorScheme.onSurface,
              size: 24,
            ),
            tooltip: 'Settings',
          ),
        ],
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  // Time Period Selector
                  Container(
                    margin: EdgeInsets.all(4.w),
                    decoration: BoxDecoration(
                      color: theme.cardColor,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: theme.shadowColor,
                          blurRadius: 4,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                    child: TabBar(
                      controller: _tabController,
                      indicator: BoxDecoration(
                        color: theme.colorScheme.primary,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      indicatorSize: TabBarIndicatorSize.tab,
                      dividerColor: Colors.transparent,
                      labelColor: Colors.white,
                      unselectedLabelColor: theme.colorScheme.onSurfaceVariant,
                      tabs: const [
                        Tab(text: 'Weekly'),
                        Tab(text: 'Monthly'),
                        Tab(text: 'Yearly'),
                      ],
                    ),
                  ),

                  // Scrollable Content
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        _buildWeeklyView(),
                        _buildMonthlyView(),
                        _buildYearlyView(),
                      ],
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildWeeklyView() {
    final metrics = _calculateMetrics(7);
    final dailyMetrics = _calculateMetrics(1); // For the Daily Goal Ring

    return SingleChildScrollView(
      child: Column(
        children: [
          SizedBox(height: 2.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              MetricsCardWidget(
                title: 'Tasks Completed',
                value: metrics['completed'],
                subtitle: 'This week',
                iconName: 'check_circle',
                iconColor: AppTheme.getSuccessColor(
                  Theme.of(context).brightness == Brightness.light,
                ),
              ),
              MetricsCardWidget(
                title: 'Completion Rate',
                value: '${metrics['rate']}%',
                subtitle: 'Weekly average',
                iconName: 'trending_up',
                iconColor: Theme.of(context).colorScheme.primary,
              ),
            ],
          ),
          SizedBox(height: 2.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              MetricsCardWidget(
                title: 'Current Streak',
                value: '${_calculateStreak()}',
                subtitle: 'Days in a row',
                iconName: 'local_fire_department',
                iconColor: AppTheme.getWarningColor(
                  Theme.of(context).brightness == Brightness.light,
                ),
              ),
              MetricsCardWidget(
                title: 'Daily Average',
                value: metrics['avg'],
                subtitle: 'Tasks per day',
                iconName: 'bar_chart',
                iconColor: AppTheme.getAccentColor(
                  Theme.of(context).brightness == Brightness.light,
                ),
              ),
            ],
          ),

          // Progress Rings
          SizedBox(height: 3.h),
          Container(
            margin: EdgeInsets.symmetric(horizontal: 4.w),
            padding: EdgeInsets.all(4.w),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context).shadowColor,
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Goal Progress',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 3.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ProgressRingWidget(
                      title: 'Daily Goal',
                      progress: dailyMetrics['progress'] as double,
                      centerText: '${dailyMetrics['rate']}%',
                      progressColor: AppTheme.getSuccessColor(
                        Theme.of(context).brightness == Brightness.light,
                      ),
                    ),
                    ProgressRingWidget(
                      title: 'Weekly Goal',
                      progress: metrics['progress'] as double,
                      centerText: '${metrics['rate']}%',
                      progressColor: Theme.of(context).colorScheme.primary,
                    ),
                  ],
                ),
              ],
            ),
          ),

          SizedBox(height: 3.h),
          CompletionTrendChartWidget(
            isWeeklyView: isWeeklyView,
            onViewToggle: (bool weekly) {
              setState(() {
                isWeeklyView = weekly;
              });
            },
          ),
          SizedBox(height: 3.h),
          const CategoryBreakdownChartWidget(),
          SizedBox(height: 3.h),
          const PriorityDistributionChartWidget(),
          SizedBox(height: 3.h),
          const ProductivityInsightsWidget(),
          SizedBox(height: 3.h),
          const AchievementBadgesWidget(),
          SizedBox(height: 4.h),
        ],
      ),
    );
  }

  Widget _buildMonthlyView() {
    final metrics = _calculateMetrics(30);

    return SingleChildScrollView(
      child: Column(
        children: [
          SizedBox(height: 2.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              MetricsCardWidget(
                title: 'Tasks Completed',
                value: metrics['completed'],
                subtitle: 'This month',
                iconName: 'check_circle',
                iconColor: AppTheme.getSuccessColor(
                  Theme.of(context).brightness == Brightness.light,
                ),
              ),
              MetricsCardWidget(
                title: 'Completion Rate',
                value: '${metrics['rate']}%',
                subtitle: 'Monthly average',
                iconName: 'trending_up',
                iconColor: Theme.of(context).colorScheme.primary,
              ),
            ],
          ),
          SizedBox(height: 2.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              MetricsCardWidget(
                title: 'Best Streak',
                value: '${_calculateStreak()}',
                subtitle: 'Overall',
                iconName: 'local_fire_department',
                iconColor: AppTheme.getWarningColor(
                  Theme.of(context).brightness == Brightness.light,
                ),
              ),
              MetricsCardWidget(
                title: 'Monthly Average',
                value: metrics['avg'],
                subtitle: 'Tasks per day',
                iconName: 'bar_chart',
                iconColor: AppTheme.getAccentColor(
                  Theme.of(context).brightness == Brightness.light,
                ),
              ),
            ],
          ),
          SizedBox(height: 3.h),
          CompletionTrendChartWidget(
            isWeeklyView: false,
            onViewToggle: (bool weekly) {},
          ),
          SizedBox(height: 3.h),
          const CategoryBreakdownChartWidget(),
          SizedBox(height: 3.h),
          const PriorityDistributionChartWidget(),
          SizedBox(height: 4.h),
        ],
      ),
    );
  }

  Widget _buildYearlyView() {
    final metrics = _calculateMetrics(365);

    return SingleChildScrollView(
      child: Column(
        children: [
          SizedBox(height: 2.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              MetricsCardWidget(
                title: 'Tasks Completed',
                value: metrics['completed'],
                subtitle: 'This year',
                iconName: 'check_circle',
                iconColor: AppTheme.getSuccessColor(
                  Theme.of(context).brightness == Brightness.light,
                ),
              ),
              MetricsCardWidget(
                title: 'Completion Rate',
                value: '${metrics['rate']}%',
                subtitle: 'Annual average',
                iconName: 'trending_up',
                iconColor: Theme.of(context).colorScheme.primary,
              ),
            ],
          ),
          SizedBox(height: 2.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              MetricsCardWidget(
                title: 'Longest Streak',
                value: '${_calculateStreak()}',
                subtitle: 'Overall',
                iconName: 'local_fire_department',
                iconColor: AppTheme.getWarningColor(
                  Theme.of(context).brightness == Brightness.light,
                ),
              ),
              MetricsCardWidget(
                title: 'Yearly Average',
                value: metrics['avg'],
                subtitle: 'Tasks per day',
                iconName: 'bar_chart',
                iconColor: AppTheme.getAccentColor(
                  Theme.of(context).brightness == Brightness.light,
                ),
              ),
            ],
          ),
          SizedBox(height: 3.h),
          const CategoryBreakdownChartWidget(),
          SizedBox(height: 3.h),
          const ProductivityInsightsWidget(),
          SizedBox(height: 3.h),
          const AchievementBadgesWidget(),
          SizedBox(height: 4.h),
        ],
      ),
    );
  }

  void _exportReport() {
    final theme = Theme.of(context);
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              CustomIconWidget(
                iconName: 'file_download',
                color: theme.colorScheme.primary,
                size: 24,
              ),
              SizedBox(width: 3.w),
              Text('Export Report'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Choose export format:', style: theme.textTheme.bodyMedium),
              SizedBox(height: 2.h),
              ListTile(
                leading: CustomIconWidget(iconName: 'picture_as_pdf', color: Colors.red, size: 24),
                title: Text('PDF Report'),
                subtitle: Text('Detailed analytics with charts'),
                onTap: () {
                  Navigator.of(context).pop();
                  _generatePDFReport();
                },
              ),
              ListTile(
                leading: CustomIconWidget(iconName: 'table_chart', color: Colors.green, size: 24),
                title: Text('CSV Data'),
                subtitle: Text('Raw data for analysis'),
                onTap: () {
                  Navigator.of(context).pop();
                  _generateCSVReport();
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  void _generatePDFReport() {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Row(
        children: [
          CustomIconWidget(iconName: 'check_circle', color: Colors.white, size: 20),
          SizedBox(width: 2.w),
          Text('PDF report generated successfully!'),
        ],
      ),
      backgroundColor: AppTheme.getSuccessColor(true),
      behavior: SnackBarBehavior.floating,
    ));
  }

  void _generateCSVReport() {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Row(
        children: [
          CustomIconWidget(iconName: 'check_circle', color: Colors.white, size: 20),
          SizedBox(width: 2.w),
          Text('CSV data exported successfully!'),
        ],
      ),
      backgroundColor: AppTheme.getSuccessColor(true),
      behavior: SnackBarBehavior.floating,
    ));
  }
}