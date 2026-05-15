import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class NotificationsSectionWidget extends StatefulWidget {
  final bool dueDateReminders;
  final bool overdueTaskAlerts;
  final bool dailySummary;
  final TimeOfDay quietHoursStart;
  final TimeOfDay quietHoursEnd;
  final Function(bool) onDueDateChanged;
  final Function(bool) onOverdueChanged;
  final Function(bool) onDailySummaryChanged;
  final Function(TimeOfDay) onQuietHoursStartChanged;
  final Function(TimeOfDay) onQuietHoursEndChanged;

  const NotificationsSectionWidget({
    super.key,
    required this.dueDateReminders,
    required this.overdueTaskAlerts,
    required this.dailySummary,
    required this.quietHoursStart,
    required this.quietHoursEnd,
    required this.onDueDateChanged,
    required this.onOverdueChanged,
    required this.onDailySummaryChanged,
    required this.onQuietHoursStartChanged,
    required this.onQuietHoursEndChanged,
  });

  @override
  State<NotificationsSectionWidget> createState() =>
      _NotificationsSectionWidgetState();
}

class _NotificationsSectionWidgetState
    extends State<NotificationsSectionWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(4.w),
            child: Row(
              children: [
                CustomIconWidget(
                  iconName: 'notifications',
                  color: AppTheme.lightTheme.primaryColor,
                  size: 24,
                ),
                SizedBox(width: 3.w),
                Text(
                  'Notifications',
                  style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: AppTheme.lightTheme.dividerColor),
          _buildNotificationToggle(
            'Due Date Reminders',
            'Get notified when tasks are due',
            'schedule',
            widget.dueDateReminders,
            widget.onDueDateChanged,
          ),
          Divider(height: 1, color: AppTheme.lightTheme.dividerColor),
          _buildNotificationToggle(
            'Overdue Task Alerts',
            'Alerts for tasks past their due date',
            'warning',
            widget.overdueTaskAlerts,
            widget.onOverdueChanged,
          ),
          Divider(height: 1, color: AppTheme.lightTheme.dividerColor),
          _buildNotificationToggle(
            'Daily Summary',
            'Daily overview of your tasks',
            'today',
            widget.dailySummary,
            widget.onDailySummaryChanged,
          ),
          Divider(height: 1, color: AppTheme.lightTheme.dividerColor),
          _buildQuietHoursSection(),
          Divider(height: 1, color: AppTheme.lightTheme.dividerColor),
          _buildTestNotificationButton(),
        ],
      ),
    );
  }

  Widget _buildNotificationToggle(
    String title,
    String subtitle,
    String iconName,
    bool value,
    Function(bool) onChanged,
  ) {
    return ListTile(
      contentPadding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      leading: CustomIconWidget(
        iconName: iconName,
        color: AppTheme.lightTheme.colorScheme.onSurface,
        size: 24,
      ),
      title: Text(
        title,
        style: AppTheme.lightTheme.textTheme.bodyLarge,
      ),
      subtitle: Text(
        subtitle,
        style: AppTheme.lightTheme.textTheme.bodySmall,
      ),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeThumbColor: AppTheme.lightTheme.primaryColor,
      ),
    );
  }

  Widget _buildQuietHoursSection() {
    return Padding(
      padding: EdgeInsets.all(4.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CustomIconWidget(
                iconName: 'bedtime',
                color: AppTheme.lightTheme.colorScheme.onSurface,
                size: 20,
              ),
              SizedBox(width: 2.w),
              Text(
                'Quiet Hours',
                style: AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          SizedBox(height: 1.h),
          Text(
            'No notifications during these hours',
            style: AppTheme.lightTheme.textTheme.bodySmall,
          ),
          SizedBox(height: 2.h),
          Row(
            children: [
              Expanded(
                child: _buildTimeSelector(
                  'Start',
                  widget.quietHoursStart,
                  widget.onQuietHoursStartChanged,
                ),
              ),
              SizedBox(width: 4.w),
              Expanded(
                child: _buildTimeSelector(
                  'End',
                  widget.quietHoursEnd,
                  widget.onQuietHoursEndChanged,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTimeSelector(
    String label,
    TimeOfDay time,
    Function(TimeOfDay) onChanged,
  ) {
    return GestureDetector(
      onTap: () async {
        final TimeOfDay? selectedTime = await showTimePicker(
          context: context,
          initialTime: time,
        );
        if (selectedTime != null) {
          onChanged(selectedTime);
        }
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 2.h),
        decoration: BoxDecoration(
          border: Border.all(color: AppTheme.lightTheme.dividerColor),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: AppTheme.lightTheme.textTheme.labelMedium,
            ),
            SizedBox(height: 0.5.h),
            Text(
              time.format(context),
              style: AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTestNotificationButton() {
    return Padding(
      padding: EdgeInsets.all(4.w),
      child: SizedBox(
        width: double.infinity,
        child: OutlinedButton.icon(
          onPressed: _showTestNotification,
          icon: CustomIconWidget(
            iconName: 'notifications_active',
            color: AppTheme.lightTheme.primaryColor,
            size: 20,
          ),
          label: Text('Test Notification'),
          style: OutlinedButton.styleFrom(
            padding: EdgeInsets.symmetric(vertical: 2.h),
          ),
        ),
      ),
    );
  }

  void _showTestNotification() {
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
            Text('Test notification sent successfully!'),
          ],
        ),
        backgroundColor: AppTheme.getSuccessColor(true),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}
