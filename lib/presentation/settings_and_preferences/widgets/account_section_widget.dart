import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class AccountSectionWidget extends StatefulWidget {
  final String syncStatus;
  final DateTime lastSyncTime;
  final String storageUsed;
  final Function() onManualSync;
  final Function() onExportData;
  final Function() onSignOut;
  final Function() onDeleteAccount;

  const AccountSectionWidget({
    super.key,
    required this.syncStatus,
    required this.lastSyncTime,
    required this.storageUsed,
    required this.onManualSync,
    required this.onExportData,
    required this.onSignOut,
    required this.onDeleteAccount,
  });

  @override
  State<AccountSectionWidget> createState() => _AccountSectionWidgetState();
}

class _AccountSectionWidgetState extends State<AccountSectionWidget> {
  bool _isSyncing = false;

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
                  iconName: 'account_circle',
                  color: AppTheme.lightTheme.primaryColor,
                  size: 24,
                ),
                SizedBox(width: 3.w),
                Text(
                  'Account & Data',
                  style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: AppTheme.lightTheme.dividerColor),
          _buildSyncStatusTile(),
          Divider(height: 1, color: AppTheme.lightTheme.dividerColor),
          _buildStorageInfoTile(),
          Divider(height: 1, color: AppTheme.lightTheme.dividerColor),
          _buildDataExportTile(),
          Divider(height: 1, color: AppTheme.lightTheme.dividerColor),
          _buildSignOutTile(),
          Divider(height: 1, color: AppTheme.lightTheme.dividerColor),
          _buildDeleteAccountTile(),
        ],
      ),
    );
  }

  Widget _buildSyncStatusTile() {
    final Color statusColor = widget.syncStatus == 'Synced'
        ? AppTheme.getSuccessColor(true)
        : widget.syncStatus == 'Syncing'
            ? AppTheme.getWarningColor(true)
            : AppTheme.lightTheme.colorScheme.error;

    return ListTile(
      contentPadding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      leading: _isSyncing
          ? SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(
                  AppTheme.lightTheme.primaryColor,
                ),
              ),
            )
          : CustomIconWidget(
              iconName:
                  widget.syncStatus == 'Synced' ? 'cloud_done' : 'cloud_sync',
              color: statusColor,
              size: 24,
            ),
      title: Text(
        'Cloud Sync',
        style: AppTheme.lightTheme.textTheme.bodyLarge,
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Status: ${widget.syncStatus}',
            style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
              color: statusColor,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 0.5.h),
          Text(
            'Last sync: ${_formatLastSync()}',
            style: AppTheme.lightTheme.textTheme.bodySmall,
          ),
        ],
      ),
      trailing: TextButton(
        onPressed: _isSyncing ? null : _handleManualSync,
        child: Text(_isSyncing ? 'Syncing...' : 'Sync Now'),
      ),
    );
  }

  Widget _buildStorageInfoTile() {
    return ListTile(
      contentPadding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      leading: CustomIconWidget(
        iconName: 'storage',
        color: AppTheme.lightTheme.colorScheme.onSurface,
        size: 24,
      ),
      title: Text(
        'Storage Usage',
        style: AppTheme.lightTheme.textTheme.bodyLarge,
      ),
      subtitle: Text(
        '${widget.storageUsed} used of 5 GB',
        style: AppTheme.lightTheme.textTheme.bodySmall,
      ),
      trailing: CustomIconWidget(
        iconName: 'chevron_right',
        color: AppTheme.lightTheme.colorScheme.onSurface,
        size: 20,
      ),
    );
  }

  Widget _buildDataExportTile() {
    return ListTile(
      contentPadding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      leading: CustomIconWidget(
        iconName: 'download',
        color: AppTheme.lightTheme.colorScheme.onSurface,
        size: 24,
      ),
      title: Text(
        'Export Data',
        style: AppTheme.lightTheme.textTheme.bodyLarge,
      ),
      subtitle: Text(
        'Download your tasks as CSV or Excel',
        style: AppTheme.lightTheme.textTheme.bodySmall,
      ),
      trailing: CustomIconWidget(
        iconName: 'chevron_right',
        color: AppTheme.lightTheme.colorScheme.onSurface,
        size: 20,
      ),
      onTap: _showExportDialog,
    );
  }

  Widget _buildSignOutTile() {
    return ListTile(
      contentPadding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      leading: CustomIconWidget(
        iconName: 'logout',
        color: AppTheme.getWarningColor(true),
        size: 24,
      ),
      title: Text(
        'Sign Out',
        style: AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
          color: AppTheme.getWarningColor(true),
        ),
      ),
      subtitle: Text(
        'Sign out of your account',
        style: AppTheme.lightTheme.textTheme.bodySmall,
      ),
      onTap: _showSignOutDialog,
    );
  }

  Widget _buildDeleteAccountTile() {
    return ListTile(
      contentPadding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      leading: CustomIconWidget(
        iconName: 'delete_forever',
        color: AppTheme.lightTheme.colorScheme.error,
        size: 24,
      ),
      title: Text(
        'Delete Account',
        style: AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
          color: AppTheme.lightTheme.colorScheme.error,
        ),
      ),
      subtitle: Text(
        'Permanently delete your account and data',
        style: AppTheme.lightTheme.textTheme.bodySmall,
      ),
      onTap: _showDeleteAccountDialog,
    );
  }

  String _formatLastSync() {
    final now = DateTime.now();
    final difference = now.difference(widget.lastSyncTime);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }

  Future<void> _handleManualSync() async {
    setState(() => _isSyncing = true);

    try {
      await widget.onManualSync();

      if (mounted) {
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
                Text('Sync completed successfully'),
              ],
            ),
            backgroundColor: AppTheme.getSuccessColor(true),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                CustomIconWidget(
                  iconName: 'error',
                  color: Colors.white,
                  size: 20,
                ),
                SizedBox(width: 2.w),
                Text('Sync failed. Please try again.'),
              ],
            ),
            backgroundColor: AppTheme.lightTheme.colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSyncing = false);
      }
    }
  }

  void _showExportDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Export Data'),
        content: Text('Choose export format:'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              widget.onExportData();
            },
            child: Text('CSV Format'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              widget.onExportData();
            },
            child: Text('Excel Format'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _showSignOutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Sign Out'),
        content: Text(
            'Are you sure you want to sign out? Your data will remain synced to the cloud.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              widget.onSignOut();
            },
            style: TextButton.styleFrom(
              foregroundColor: AppTheme.getWarningColor(true),
            ),
            child: Text('Sign Out'),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Account'),
        content: Text(
            'This action cannot be undone. All your data will be permanently deleted from our servers.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              widget.onDeleteAccount();
            },
            style: TextButton.styleFrom(
              foregroundColor: AppTheme.lightTheme.colorScheme.error,
            ),
            child: Text('Delete Account'),
          ),
        ],
      ),
    );
  }
}
