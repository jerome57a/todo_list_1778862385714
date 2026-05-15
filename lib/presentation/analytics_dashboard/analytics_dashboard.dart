import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
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

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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
        child: Column(
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
    return SingleChildScrollView(
      child: Column(
        children: [
          // Key Metrics Cards
          SizedBox(height: 2.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              MetricsCardWidget(
                title: 'Tasks Completed',
                value: '89',
                subtitle: 'This week',
                iconName: 'check_circle',
                iconColor: AppTheme.getSuccessColor(
                  Theme.of(context).brightness == Brightness.light,
                ),
              ),
              MetricsCardWidget(
                title: 'Completion Rate',
                value: '84%',
                subtitle: '+12% from last week',
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
                value: '12',
                subtitle: 'Days in a row',
                iconName: 'local_fire_department',
                iconColor: AppTheme.getWarningColor(
                  Theme.of(context).brightness == Brightness.light,
                ),
              ),
              MetricsCardWidget(
                title: 'Daily Average',
                value: '12.7',
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
                      progress: 0.84,
                      centerText: '84%',
                      progressColor: AppTheme.getSuccessColor(
                        Theme.of(context).brightness == Brightness.light,
                      ),
                    ),
                    ProgressRingWidget(
                      title: 'Weekly Goal',
                      progress: 0.72,
                      centerText: '72%',
                      progressColor: Theme.of(context).colorScheme.primary,
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Completion Trend Chart
          SizedBox(height: 3.h),
          CompletionTrendChartWidget(
            isWeeklyView: isWeeklyView,
            onViewToggle: (bool weekly) {
              setState(() {
                isWeeklyView = weekly;
              });
            },
          ),

          // Category Breakdown
          SizedBox(height: 3.h),
          const CategoryBreakdownChartWidget(),

          // Priority Distribution
          SizedBox(height: 3.h),
          const PriorityDistributionChartWidget(),

          // Productivity Insights
          SizedBox(height: 3.h),
          const ProductivityInsightsWidget(),

          // Achievement Badges
          SizedBox(height: 3.h),
          const AchievementBadgesWidget(),

          SizedBox(height: 4.h),
        ],
      ),
    );
  }

  Widget _buildMonthlyView() {
    return SingleChildScrollView(
      child: Column(
        children: [
          SizedBox(height: 2.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              MetricsCardWidget(
                title: 'Tasks Completed',
                value: '342',
                subtitle: 'This month',
                iconName: 'check_circle',
                iconColor: AppTheme.getSuccessColor(
                  Theme.of(context).brightness == Brightness.light,
                ),
              ),
              MetricsCardWidget(
                title: 'Completion Rate',
                value: '78%',
                subtitle: '+5% from last month',
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
                value: '18',
                subtitle: 'Days this month',
                iconName: 'local_fire_department',
                iconColor: AppTheme.getWarningColor(
                  Theme.of(context).brightness == Brightness.light,
                ),
              ),
              MetricsCardWidget(
                title: 'Monthly Average',
                value: '11.4',
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
    return SingleChildScrollView(
      child: Column(
        children: [
          SizedBox(height: 2.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              MetricsCardWidget(
                title: 'Tasks Completed',
                value: '3,847',
                subtitle: 'This year',
                iconName: 'check_circle',
                iconColor: AppTheme.getSuccessColor(
                  Theme.of(context).brightness == Brightness.light,
                ),
              ),
              MetricsCardWidget(
                title: 'Completion Rate',
                value: '82%',
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
                value: '45',
                subtitle: 'Days this year',
                iconName: 'local_fire_department',
                iconColor: AppTheme.getWarningColor(
                  Theme.of(context).brightness == Brightness.light,
                ),
              ),
              MetricsCardWidget(
                title: 'Yearly Average',
                value: '10.5',
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
                leading: CustomIconWidget(
                  iconName: 'picture_as_pdf',
                  color: Colors.red,
                  size: 24,
                ),
                title: Text('PDF Report'),
                subtitle: Text('Detailed analytics with charts'),
                onTap: () {
                  Navigator.of(context).pop();
                  _generatePDFReport();
                },
              ),
              ListTile(
                leading: CustomIconWidget(
                  iconName: 'table_chart',
                  color: Colors.green,
                  size: 24,
                ),
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
    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            CustomIconWidget(
              iconName: 'check_circle',
              color: Colors.white,
              size: 20,
            ),
            SizedBox(width: 2.w),
            Text('PDF report generated successfully!'),
          ],
        ),
        backgroundColor: AppTheme.getSuccessColor(
          Theme.of(context).brightness == Brightness.light,
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _generateCSVReport() {
    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            CustomIconWidget(
              iconName: 'check_circle',
              color: Colors.white,
              size: 20,
            ),
            SizedBox(width: 2.w),
            Text('CSV data exported successfully!'),
          ],
        ),
        backgroundColor: AppTheme.getSuccessColor(
          Theme.of(context).brightness == Brightness.light,
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
