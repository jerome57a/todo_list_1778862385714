import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class PrivacySectionWidget extends StatefulWidget {
  final bool biometricAuth;
  final String dataRetention;
  final bool analyticsEnabled;
  final Function(bool) onBiometricChanged;
  final Function(String) onDataRetentionChanged;
  final Function(bool) onAnalyticsChanged;

  const PrivacySectionWidget({
    super.key,
    required this.biometricAuth,
    required this.dataRetention,
    required this.analyticsEnabled,
    required this.onBiometricChanged,
    required this.onDataRetentionChanged,
    required this.onAnalyticsChanged,
  });

  @override
  State<PrivacySectionWidget> createState() => _PrivacySectionWidgetState();
}

class _PrivacySectionWidgetState extends State<PrivacySectionWidget> {
  final List<Map<String, String>> retentionOptions = [
    {"label": "1 Month", "value": "1_month"},
    {"label": "3 Months", "value": "3_months"},
    {"label": "6 Months", "value": "6_months"},
    {"label": "1 Year", "value": "1_year"},
    {"label": "Forever", "value": "forever"},
  ];

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
                  iconName: 'security',
                  color: AppTheme.lightTheme.primaryColor,
                  size: 24,
                ),
                SizedBox(width: 3.w),
                Text(
                  'Privacy & Security',
                  style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: AppTheme.lightTheme.dividerColor),
          _buildBiometricToggle(),
          Divider(height: 1, color: AppTheme.lightTheme.dividerColor),
          _buildDataRetentionTile(),
          Divider(height: 1, color: AppTheme.lightTheme.dividerColor),
          _buildAnalyticsToggle(),
          Divider(height: 1, color: AppTheme.lightTheme.dividerColor),
          _buildPrivacyPolicyTile(),
        ],
      ),
    );
  }

  Widget _buildBiometricToggle() {
    return ListTile(
      contentPadding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      leading: CustomIconWidget(
        iconName: 'fingerprint',
        color: AppTheme.lightTheme.colorScheme.onSurface,
        size: 24,
      ),
      title: Text(
        'Biometric Authentication',
        style: AppTheme.lightTheme.textTheme.bodyLarge,
      ),
      subtitle: Text(
        widget.biometricAuth
            ? 'Use fingerprint or face ID to unlock app'
            : 'Biometric authentication disabled',
        style: AppTheme.lightTheme.textTheme.bodySmall,
      ),
      trailing: Switch(
        value: widget.biometricAuth,
        onChanged: widget.onBiometricChanged,
        activeThumbColor: AppTheme.lightTheme.primaryColor,
      ),
    );
  }

  Widget _buildDataRetentionTile() {
    final selectedOption = retentionOptions.firstWhere(
      (option) => option["value"] == widget.dataRetention,
      orElse: () => retentionOptions.first,
    );

    return ListTile(
      contentPadding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      leading: CustomIconWidget(
        iconName: 'schedule_send',
        color: AppTheme.lightTheme.colorScheme.onSurface,
        size: 24,
      ),
      title: Text(
        'Data Retention',
        style: AppTheme.lightTheme.textTheme.bodyLarge,
      ),
      subtitle: Text(
        'Keep completed tasks for: ${selectedOption["label"]}',
        style: AppTheme.lightTheme.textTheme.bodySmall,
      ),
      trailing: CustomIconWidget(
        iconName: 'chevron_right',
        color: AppTheme.lightTheme.colorScheme.onSurface,
        size: 20,
      ),
      onTap: _showDataRetentionDialog,
    );
  }

  Widget _buildAnalyticsToggle() {
    return ListTile(
      contentPadding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      leading: CustomIconWidget(
        iconName: 'analytics',
        color: AppTheme.lightTheme.colorScheme.onSurface,
        size: 24,
      ),
      title: Text(
        'Usage Analytics',
        style: AppTheme.lightTheme.textTheme.bodyLarge,
      ),
      subtitle: Text(
        widget.analyticsEnabled
            ? 'Help improve the app by sharing usage data'
            : 'Analytics data collection disabled',
        style: AppTheme.lightTheme.textTheme.bodySmall,
      ),
      trailing: Switch(
        value: widget.analyticsEnabled,
        onChanged: widget.onAnalyticsChanged,
        activeThumbColor: AppTheme.lightTheme.primaryColor,
      ),
    );
  }

  Widget _buildPrivacyPolicyTile() {
    return ListTile(
      contentPadding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      leading: CustomIconWidget(
        iconName: 'policy',
        color: AppTheme.lightTheme.colorScheme.onSurface,
        size: 24,
      ),
      title: Text(
        'Privacy Policy',
        style: AppTheme.lightTheme.textTheme.bodyLarge,
      ),
      subtitle: Text(
        'View our privacy policy and terms',
        style: AppTheme.lightTheme.textTheme.bodySmall,
      ),
      trailing: CustomIconWidget(
        iconName: 'open_in_new',
        color: AppTheme.lightTheme.colorScheme.onSurface,
        size: 20,
      ),
      onTap: _openPrivacyPolicy,
    );
  }

  void _showDataRetentionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Data Retention Period'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: retentionOptions.map((option) {
            final isSelected = widget.dataRetention == option["value"];
            return RadioListTile<String>(
              title: Text(option["label"]!),
              value: option["value"]!,
              groupValue: widget.dataRetention,
              onChanged: (value) {
                if (value != null) {
                  widget.onDataRetentionChanged(value);
                  Navigator.pop(context);
                }
              },
              activeColor: AppTheme.lightTheme.primaryColor,
            );
          }).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _openPrivacyPolicy() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Privacy Policy'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'TaskFlow Pro Privacy Policy',
                style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                'Last updated: August 22, 2025',
                style: AppTheme.lightTheme.textTheme.bodySmall,
              ),
              SizedBox(height: 2.h),
              Text(
                'We are committed to protecting your privacy and ensuring the security of your personal information. This policy outlines how we collect, use, and protect your data.',
                style: AppTheme.lightTheme.textTheme.bodyMedium,
              ),
              SizedBox(height: 2.h),
              Text(
                'Data Collection:',
                style: AppTheme.lightTheme.textTheme.titleSmall,
              ),
              SizedBox(height: 1.h),
              Text(
                '• Task data and personal productivity information\n• Device information for app optimization\n• Usage analytics (if enabled)\n• Account information for cloud sync',
                style: AppTheme.lightTheme.textTheme.bodySmall,
              ),
              SizedBox(height: 2.h),
              Text(
                'Data Usage:',
                style: AppTheme.lightTheme.textTheme.titleSmall,
              ),
              SizedBox(height: 1.h),
              Text(
                '• Provide and improve our services\n• Sync data across your devices\n• Send notifications and reminders\n• Analyze app performance',
                style: AppTheme.lightTheme.textTheme.bodySmall,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }
}
