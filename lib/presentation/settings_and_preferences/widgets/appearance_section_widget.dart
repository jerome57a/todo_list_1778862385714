import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class AppearanceSectionWidget extends StatefulWidget {
  final bool isDarkMode;
  final Function(bool) onThemeChanged;
  final String selectedThemeColor;
  final Function(String) onThemeColorChanged;

  const AppearanceSectionWidget({
    super.key,
    required this.isDarkMode,
    required this.onThemeChanged,
    required this.selectedThemeColor,
    required this.onThemeColorChanged,
  });

  @override
  State<AppearanceSectionWidget> createState() =>
      _AppearanceSectionWidgetState();
}

class _AppearanceSectionWidgetState extends State<AppearanceSectionWidget> {
  final List<Map<String, dynamic>> themeColors = [
    {"name": "Blue", "color": Color(0xFF2563EB), "value": "blue"},
    {"name": "Purple", "color": Color(0xFF8B5CF6), "value": "purple"},
    {"name": "Green", "color": Color(0xFF059669), "value": "green"},
    {"name": "Orange", "color": Color(0xFFD97706), "value": "orange"},
    {"name": "Red", "color": Color(0xFFDC2626), "value": "red"},
    {"name": "Teal", "color": Color(0xFF0891B2), "value": "teal"},
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
                  iconName: 'palette',
                  color: AppTheme.lightTheme.primaryColor,
                  size: 24,
                ),
                SizedBox(width: 3.w),
                Text(
                  'Appearance',
                  style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Divider(
            height: 1,
            color: AppTheme.lightTheme.dividerColor,
          ),
          _buildThemeToggle(),
          Divider(
            height: 1,
            color: AppTheme.lightTheme.dividerColor,
          ),
          _buildThemeColorSelection(),
        ],
      ),
    );
  }

  Widget _buildThemeToggle() {
    return ListTile(
      contentPadding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      leading: CustomIconWidget(
        iconName: widget.isDarkMode ? 'dark_mode' : 'light_mode',
        color: AppTheme.lightTheme.colorScheme.onSurface,
        size: 24,
      ),
      title: Text(
        'Dark Mode',
        style: AppTheme.lightTheme.textTheme.bodyLarge,
      ),
      subtitle: Text(
        widget.isDarkMode ? 'Dark theme enabled' : 'Light theme enabled',
        style: AppTheme.lightTheme.textTheme.bodySmall,
      ),
      trailing: Switch(
        value: widget.isDarkMode,
        onChanged: widget.onThemeChanged,
        activeThumbColor: AppTheme.lightTheme.primaryColor,
      ),
    );
  }

  Widget _buildThemeColorSelection() {
    return Padding(
      padding: EdgeInsets.all(4.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CustomIconWidget(
                iconName: 'color_lens',
                color: AppTheme.lightTheme.colorScheme.onSurface,
                size: 20,
              ),
              SizedBox(width: 2.w),
              Text(
                'Theme Color',
                style: AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          Wrap(
            spacing: 3.w,
            runSpacing: 2.h,
            children: themeColors.map((colorData) {
              final isSelected =
                  widget.selectedThemeColor == colorData["value"];
              return GestureDetector(
                onTap: () => widget.onThemeColorChanged(colorData["value"]),
                child: Container(
                  width: 20.w,
                  height: 8.h,
                  decoration: BoxDecoration(
                    color: colorData["color"],
                    borderRadius: BorderRadius.circular(8),
                    border: isSelected
                        ? Border.all(
                            color: AppTheme.lightTheme.primaryColor,
                            width: 3,
                          )
                        : null,
                    boxShadow: [
                      BoxShadow(
                        color: colorData["color"].withValues(alpha: 0.3),
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (isSelected)
                        CustomIconWidget(
                          iconName: 'check',
                          color: Colors.white,
                          size: 20,
                        ),
                      SizedBox(height: 0.5.h),
                      Text(
                        colorData["name"],
                        style:
                            AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
