import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class AchievementBadgesWidget extends StatelessWidget {
  const AchievementBadgesWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final List<Map<String, dynamic>> achievements = [
      {
        "title": "Task Master",
        "description": "Completed 100 tasks",
        "iconName": "emoji_events",
        "isUnlocked": true,
        "color": Color(0xFFFFD700),
      },
      {
        "title": "Streak Champion",
        "description": "10-day completion streak",
        "iconName": "local_fire_department",
        "isUnlocked": true,
        "color": Color(0xFFFF6B35),
      },
      {
        "title": "Early Bird",
        "description": "Complete 5 tasks before 9 AM",
        "iconName": "wb_sunny",
        "isUnlocked": true,
        "color": Color(0xFFFFA726),
      },
      {
        "title": "Productivity Pro",
        "description": "95% completion rate for a week",
        "iconName": "trending_up",
        "isUnlocked": false,
        "color": Color(0xFF42A5F5),
      },
      {
        "title": "Category King",
        "description": "Complete tasks in 5 different categories",
        "iconName": "category",
        "isUnlocked": false,
        "color": Color(0xFF66BB6A),
      },
      {
        "title": "Speed Demon",
        "description": "Complete 20 tasks in one day",
        "iconName": "flash_on",
        "isUnlocked": false,
        "color": Color(0xFFAB47BC),
      },
    ];

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Achievement Badges',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 3.h),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 3.w,
              mainAxisSpacing: 2.h,
              childAspectRatio: 0.8,
            ),
            itemCount: achievements.length,
            itemBuilder: (context, index) {
              final achievement = achievements[index];
              return _buildAchievementBadge(context, achievement);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAchievementBadge(
      BuildContext context, Map<String, dynamic> achievement) {
    final theme = Theme.of(context);
    final isUnlocked = achievement["isUnlocked"] as bool;

    return GestureDetector(
      onTap: () {
        _showAchievementDetails(context, achievement);
      },
      child: Container(
        padding: EdgeInsets.all(3.w),
        decoration: BoxDecoration(
          color: isUnlocked
              ? (achievement["color"] as Color).withValues(alpha: 0.1)
              : theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isUnlocked
                ? (achievement["color"] as Color).withValues(alpha: 0.3)
                : theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(2.w),
              decoration: BoxDecoration(
                color: isUnlocked
                    ? achievement["color"] as Color
                    : theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
                shape: BoxShape.circle,
              ),
              child: CustomIconWidget(
                iconName: achievement["iconName"] as String,
                color: isUnlocked
                    ? Colors.white
                    : theme.colorScheme.onSurfaceVariant,
                size: 20,
              ),
            ),
            SizedBox(height: 1.h),
            Text(
              achievement["title"] as String,
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: isUnlocked
                    ? theme.colorScheme.onSurface
                    : theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            if (!isUnlocked) ...[
              SizedBox(height: 0.5.h),
              CustomIconWidget(
                iconName: 'lock',
                color:
                    theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                size: 12,
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showAchievementDetails(
      BuildContext context, Map<String, dynamic> achievement) {
    final theme = Theme.of(context);
    final isUnlocked = achievement["isUnlocked"] as bool;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Container(
                padding: EdgeInsets.all(2.w),
                decoration: BoxDecoration(
                  color: isUnlocked
                      ? achievement["color"] as Color
                      : theme.colorScheme.onSurfaceVariant
                          .withValues(alpha: 0.3),
                  shape: BoxShape.circle,
                ),
                child: CustomIconWidget(
                  iconName: achievement["iconName"] as String,
                  color: isUnlocked
                      ? Colors.white
                      : theme.colorScheme.onSurfaceVariant,
                  size: 24,
                ),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: Text(
                  achievement["title"] as String,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                achievement["description"] as String,
                style: theme.textTheme.bodyMedium,
              ),
              SizedBox(height: 2.h),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
                decoration: BoxDecoration(
                  color: isUnlocked
                      ? AppTheme.getSuccessColor(
                              theme.brightness == Brightness.light)
                          .withValues(alpha: 0.1)
                      : theme.colorScheme.onSurfaceVariant
                          .withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CustomIconWidget(
                      iconName: isUnlocked ? 'check_circle' : 'lock',
                      color: isUnlocked
                          ? AppTheme.getSuccessColor(
                              theme.brightness == Brightness.light)
                          : theme.colorScheme.onSurfaceVariant,
                      size: 16,
                    ),
                    SizedBox(width: 2.w),
                    Text(
                      isUnlocked ? 'Unlocked' : 'Locked',
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w500,
                        color: isUnlocked
                            ? AppTheme.getSuccessColor(
                                theme.brightness == Brightness.light)
                            : theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Close'),
            ),
          ],
        );
      },
    );
  }
}
