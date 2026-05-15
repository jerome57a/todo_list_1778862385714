import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/account_section_widget.dart';
import './widgets/appearance_section_widget.dart';
import './widgets/language_section_widget.dart';
import './widgets/notifications_section_widget.dart';
import './widgets/privacy_section_widget.dart';

class SettingsAndPreferences extends StatefulWidget {
  const SettingsAndPreferences({super.key});

  @override
  State<SettingsAndPreferences> createState() => _SettingsAndPreferencesState();
}

class _SettingsAndPreferencesState extends State<SettingsAndPreferences> {
  // Appearance settings
  bool _isDarkMode = false;
  String _selectedThemeColor = "blue";

  // Notification settings
  bool _dueDateReminders = true;
  bool _overdueTaskAlerts = true;
  bool _dailySummary = false;
  TimeOfDay _quietHoursStart = TimeOfDay(hour: 22, minute: 0);
  TimeOfDay _quietHoursEnd = TimeOfDay(hour: 7, minute: 0);

  // Account settings
  String _syncStatus = "Synced";
  DateTime _lastSyncTime = DateTime.now().subtract(Duration(minutes: 15));
  final String _storageUsed = "2.3 MB";

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
        physics: BouncingScrollPhysics(),
        child: Column(
          children: [
            SizedBox(height: 2.h),
            _buildUserProfileHeader(),
            SizedBox(height: 2.h),
            AppearanceSectionWidget(
              isDarkMode: _isDarkMode,
              onThemeChanged: _handleThemeChanged,
              selectedThemeColor: _selectedThemeColor,
              onThemeColorChanged: _handleThemeColorChanged,
            ),
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
            AccountSectionWidget(
              syncStatus: _syncStatus,
              lastSyncTime: _lastSyncTime,
              storageUsed: _storageUsed,
              onManualSync: _handleManualSync,
              onExportData: _handleExportData,
              onSignOut: _handleSignOut,
              onDeleteAccount: _handleDeleteAccount,
            ),
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
            LanguageSectionWidget(
              currentLanguage: _currentLanguage,
              onLanguageChanged: (language) =>
                  setState(() => _currentLanguage = language),
            ),
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

  Widget _buildUserProfileHeader() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w),
      padding: EdgeInsets.all(4.w),
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
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Center(
              child: CustomIconWidget(
                iconName: 'person',
                color: AppTheme.lightTheme.primaryColor,
                size: 32,
              ),
            ),
          ),
          SizedBox(width: 4.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'John Doe',
                  style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 0.5.h),
                Text(
                  'john.doe@email.com',
                  style: AppTheme.lightTheme.textTheme.bodySmall,
                ),
                SizedBox(height: 0.5.h),
                Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
                  decoration: BoxDecoration(
                    color:
                        AppTheme.getSuccessColor(true).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'Premium Member',
                    style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
                      color: AppTheme.getSuccessColor(true),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          CustomIconWidget(
            iconName: 'edit',
            color: AppTheme.lightTheme.colorScheme.onSurface,
            size: 20,
          ),
        ],
      ),
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
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: Offset(0, 2),
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
              'TaskFlow Pro v2.1.0 (Build 2025.08.22)',
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
              'Help us improve TaskFlow Pro',
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

  void _handleThemeChanged(bool isDark) {
    setState(() => _isDarkMode = isDark);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            CustomIconWidget(
              iconName: isDark ? 'dark_mode' : 'light_mode',
              color: Colors.white,
              size: 20,
            ),
            SizedBox(width: 2.w),
            Text('${isDark ? 'Dark' : 'Light'} theme applied'),
          ],
        ),
        backgroundColor: AppTheme.lightTheme.primaryColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  void _handleThemeColorChanged(String color) {
    setState(() => _selectedThemeColor = color);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            CustomIconWidget(
              iconName: 'palette',
              color: Colors.white,
              size: 20,
            ),
            SizedBox(width: 2.w),
            Text(
                'Theme color updated to ${color[0].toUpperCase()}${color.substring(1)}'),
          ],
        ),
        backgroundColor: AppTheme.lightTheme.primaryColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  Future<void> _handleManualSync() async {
    setState(() {
      _syncStatus = "Syncing";
      _lastSyncTime = DateTime.now();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
            SizedBox(width: 2.w),
            Text('Syncing data...'),
          ],
        ),
        backgroundColor: AppTheme.lightTheme.primaryColor,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );

    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      setState(() => _syncStatus = "Synced");
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
              Text('Sync completed successfully!'),
            ],
          ),
          backgroundColor: AppTheme.getSuccessColor(true),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
    }
  }

  void _handleExportData() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            CustomIconWidget(
              iconName: 'download',
              color: Colors.white,
              size: 20,
            ),
            SizedBox(width: 2.w),
            Text('Data export started...'),
          ],
        ),
        backgroundColor: AppTheme.getSuccessColor(true),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  void _handleSignOut() {
    Navigator.pushNamedAndRemoveUntil(
      context,
      '/',
      (route) => false,
    );
  }

  void _handleDeleteAccount() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            CustomIconWidget(
              iconName: 'warning',
              color: Colors.white,
              size: 20,
            ),
            SizedBox(width: 2.w),
            Text('Account deletion initiated'),
          ],
        ),
        backgroundColor: AppTheme.lightTheme.colorScheme.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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
            Text('Help & Support'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Need help with TaskFlow Pro?',
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
            child: Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Opening support center...'),
                  backgroundColor: AppTheme.lightTheme.primaryColor,
                ),
              );
            },
            child: Text('Get Help'),
          ),
        ],
      ),
    );
  }

  void _showFeedbackDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Send Feedback'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Tell us what you think about TaskFlow Pro...',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 2.h),
            Row(
              children: [
                CustomIconWidget(
                  iconName: 'star',
                  color: Colors.amber,
                  size: 20,
                ),
                SizedBox(width: 1.w),
                Text('Rate your experience:'),
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
                    child: CustomIconWidget(
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
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Thank you for your feedback!'),
                  backgroundColor: AppTheme.getSuccessColor(true),
                ),
              );
            },
            child: Text('Send'),
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
            CustomIconWidget(
              iconName: 'star',
              color: Colors.white,
              size: 20,
            ),
            SizedBox(width: 2.w),
            Text('Opening App Store...'),
          ],
        ),
        backgroundColor: AppTheme.lightTheme.primaryColor,
      ),
    );
  }
}
