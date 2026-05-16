import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/language_section_widget.dart';
import './widgets/notifications_section_widget.dart';
import './widgets/privacy_section_widget.dart';

class SettingsAndPreferences extends StatefulWidget {
  const SettingsAndPreferences({super.key});

  @override
  State<SettingsAndPreferences> createState() => _SettingsAndPreferencesState();
}

class _SettingsAndPreferencesState extends State<SettingsAndPreferences> {
  // Notification settings
  bool _dueDateReminders = true;
  bool _overdueTaskAlerts = true;
  bool _dailySummary = false;
  TimeOfDay _quietHoursStart = const TimeOfDay(hour: 22, minute: 0);
  TimeOfDay _quietHoursEnd = const TimeOfDay(hour: 7, minute: 0);

  // Privacy settings
  bool _biometricAuth = false;
  String _dataRetention = "1_year";
  bool _analyticsEnabled = true;

  // Language settings
  String _currentLanguage = "en";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            SizedBox(height: 2.h),
            
            // Notifications
            NotificationsSectionWidget(
              dueDateReminders: _dueDateReminders,
              overdueTaskAlerts: _overdueTaskAlerts,
              dailySummary: _dailySummary,
              quietHoursStart: _quietHoursStart,
              quietHoursEnd: _quietHoursEnd,
              onDueDateChanged: (value) =>
                  setState(() => _dueDateReminders = value),
              onOverdueChanged: (value) =>
                  setState(() => _overdueTaskAlerts = value),
              onDailySummaryChanged: (value) =>
                  setState(() => _dailySummary = value),
              onQuietHoursStartChanged: (time) =>
                  setState(() => _quietHoursStart = time),
              onQuietHoursEndChanged: (time) =>
                  setState(() => _quietHoursEnd = time),
            ),
            
            // Privacy
            PrivacySectionWidget(
              biometricAuth: _biometricAuth,
              dataRetention: _dataRetention,
              analyticsEnabled: _analyticsEnabled,
              onBiometricChanged: (value) =>
                  setState(() => _biometricAuth = value),
              onDataRetentionChanged: (value) =>
                  setState(() => _dataRetention = value),
              onAnalyticsChanged: (value) =>
                  setState(() => _analyticsEnabled = value),
            ),
            
            // Language
            LanguageSectionWidget(
              currentLanguage: _currentLanguage,
              onLanguageChanged: (language) =>
                  setState(() => _currentLanguage = language),
            ),
            
            // App Info
            _buildAppInfoSection(),
            SizedBox(height: 4.h),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: Text(
        'Settings',
        style: AppTheme.lightTheme.appBarTheme.titleTextStyle,
      ),
      leading: IconButton(
        onPressed: () => Navigator.pop(context),
        icon: CustomIconWidget(
          iconName: 'arrow_back',
          color: AppTheme.lightTheme.colorScheme.onSurface,
          size: 24,
        ),
      ),
      actions: [
        IconButton(
          onPressed: _showHelpDialog,
          icon: CustomIconWidget(
            iconName: 'help_outline',
            color: AppTheme.lightTheme.colorScheme.onSurface,
            size: 24,
          ),
        ),
      ],
      backgroundColor: AppTheme.lightTheme.appBarTheme.backgroundColor,
      elevation: 0,
    );
  }

  Widget _buildAppInfoSection() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(4.w),
            child: Row(
              children: [
                CustomIconWidget(
                  iconName: 'info',
                  color: AppTheme.lightTheme.primaryColor,
                  size: 24,
                ),
                SizedBox(width: 3.w),
                Text(
                  'About',
                  style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: AppTheme.lightTheme.dividerColor),
          ListTile(
            contentPadding:
                EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
            leading: CustomIconWidget(
              iconName: 'apps',
              color: AppTheme.lightTheme.colorScheme.onSurface,
              size: 24,
            ),
            title: Text(
              'App Version',
              style: AppTheme.lightTheme.textTheme.bodyLarge,
            ),
            subtitle: Text(
              'To Do Checklist App v2.1.0 (Build 2025.08.22)',
              style: AppTheme.lightTheme.textTheme.bodySmall,
            ),
          ),
          Divider(height: 1, color: AppTheme.lightTheme.dividerColor),
          ListTile(
            contentPadding:
                EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
            leading: CustomIconWidget(
              iconName: 'code',
              color: AppTheme.lightTheme.colorScheme.onSurface,
              size: 24,
            ),
            title: Text(
              'Developer',
              style: AppTheme.lightTheme.textTheme.bodyLarge,
            ),
            subtitle: Text(
              'jerome57a (GitHub)',
              style: AppTheme.lightTheme.textTheme.bodySmall,
            ),
          ),
          Divider(height: 1, color: AppTheme.lightTheme.dividerColor),
          ListTile(
            contentPadding:
                EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
            leading: CustomIconWidget(
              iconName: 'feedback',
              color: AppTheme.lightTheme.colorScheme.onSurface,
              size: 24,
            ),
            title: Text(
              'Send Feedback',
              style: AppTheme.lightTheme.textTheme.bodyLarge,
            ),
            subtitle: Text(
              'Help us improve To Do Checklist App',
              style: AppTheme.lightTheme.textTheme.bodySmall,
            ),
            trailing: CustomIconWidget(
              iconName: 'chevron_right',
              color: AppTheme.lightTheme.colorScheme.onSurface,
              size: 20,
            ),
            onTap: _showFeedbackDialog,
          ),
          Divider(height: 1, color: AppTheme.lightTheme.dividerColor),
          ListTile(
            contentPadding:
                EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
            leading: CustomIconWidget(
              iconName: 'star_rate',
              color: AppTheme.lightTheme.colorScheme.onSurface,
              size: 24,
            ),
            title: Text(
              'Rate App',
              style: AppTheme.lightTheme.textTheme.bodyLarge,
            ),
            subtitle: Text(
              'Rate us on the App Store',
              style: AppTheme.lightTheme.textTheme.bodySmall,
            ),
            trailing: CustomIconWidget(
              iconName: 'chevron_right',
              color: AppTheme.lightTheme.colorScheme.onSurface,
              size: 20,
            ),
            onTap: _handleRateApp,
          ),
        ],
      ),
    );
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            CustomIconWidget(
              iconName: 'help',
              color: AppTheme.lightTheme.primaryColor,
              size: 24,
            ),
            SizedBox(width: 2.w),
            const Text('Help & Support'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Need help with To Do Checklist App?',
              style: AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 2.h),
            Text(
              '• Check our FAQ section\n• Contact support team\n• Browse user guides\n• Join our community forum',
              style: AppTheme.lightTheme.textTheme.bodyMedium,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Opening support center...'),
                  backgroundColor: AppTheme.lightTheme.primaryColor,
                ),
              );
            },
            child: const Text('Get Help'),
          ),
        ],
      ),
    );
  }

  void _showFeedbackDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Send Feedback'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const TextField(
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Tell us what you think about To Do Checklist App...',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 2.h),
            Row(
              children: [
                const CustomIconWidget(
                  iconName: 'star',
                  color: Colors.amber,
                  size: 20,
                ),
                SizedBox(width: 1.w),
                const Text('Rate your experience:'),
              ],
            ),
            SizedBox(height: 1.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                return GestureDetector(
                  onTap: () {},
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 1.w),
                    child: const CustomIconWidget(
                      iconName: 'star_border',
                      color: Colors.amber,
                      size: 24,
                    ),
                  ),
                );
              }),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Thank you for your feedback!'),
                  backgroundColor: AppTheme.getSuccessColor(true),
                ),
              );
            },
            child: const Text('Send'),
          ),
        ],
      ),
    );
  }

  void _handleRateApp() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const CustomIconWidget(
              iconName: 'star',
              color: Colors.white,
              size: 20,
            ),
            SizedBox(width: 2.w),
            const Text('Opening App Store...'),
          ],
        ),
        backgroundColor: AppTheme.lightTheme.primaryColor,
      ),
    );
  }
}