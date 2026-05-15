import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class LanguageSectionWidget extends StatefulWidget {
  final String currentLanguage;
  final Function(String) onLanguageChanged;

  const LanguageSectionWidget({
    super.key,
    required this.currentLanguage,
    required this.onLanguageChanged,
  });

  @override
  State<LanguageSectionWidget> createState() => _LanguageSectionWidgetState();
}

class _LanguageSectionWidgetState extends State<LanguageSectionWidget> {
  final List<Map<String, String>> languages = [
    {"name": "English", "code": "en", "flag": "🇺🇸"},
    {"name": "Español", "code": "es", "flag": "🇪🇸"},
    {"name": "Français", "code": "fr", "flag": "🇫🇷"},
    {"name": "Deutsch", "code": "de", "flag": "🇩🇪"},
    {"name": "Italiano", "code": "it", "flag": "🇮🇹"},
    {"name": "Português", "code": "pt", "flag": "🇵🇹"},
    {"name": "中文", "code": "zh", "flag": "🇨🇳"},
    {"name": "日本語", "code": "ja", "flag": "🇯🇵"},
    {"name": "한국어", "code": "ko", "flag": "🇰🇷"},
    {"name": "العربية", "code": "ar", "flag": "🇸🇦"},
  ];

  @override
  Widget build(BuildContext context) {
    final currentLang = languages.firstWhere(
      (lang) => lang["code"] == widget.currentLanguage,
      orElse: () => languages.first,
    );

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
                  iconName: 'language',
                  color: AppTheme.lightTheme.primaryColor,
                  size: 24,
                ),
                SizedBox(width: 3.w),
                Text(
                  'Language & Region',
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
            leading: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  currentLang["flag"]!,
                  style: TextStyle(fontSize: 20),
                ),
              ),
            ),
            title: Text(
              'App Language',
              style: AppTheme.lightTheme.textTheme.bodyLarge,
            ),
            subtitle: Text(
              currentLang["name"]!,
              style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (widget.currentLanguage != "en")
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
                    decoration: BoxDecoration(
                      color:
                          AppTheme.getWarningColor(true).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'Coming Soon',
                      style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
                        color: AppTheme.getWarningColor(true),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                SizedBox(width: 2.w),
                CustomIconWidget(
                  iconName: 'chevron_right',
                  color: AppTheme.lightTheme.colorScheme.onSurface,
                  size: 20,
                ),
              ],
            ),
            onTap: _showLanguageDialog,
          ),
          Divider(height: 1, color: AppTheme.lightTheme.dividerColor),
          _buildRegionInfoTile(),
        ],
      ),
    );
  }

  Widget _buildRegionInfoTile() {
    return ListTile(
      contentPadding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      leading: CustomIconWidget(
        iconName: 'public',
        color: AppTheme.lightTheme.colorScheme.onSurface,
        size: 24,
      ),
      title: Text(
        'Region Settings',
        style: AppTheme.lightTheme.textTheme.bodyLarge,
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Date Format: MM/DD/YYYY',
            style: AppTheme.lightTheme.textTheme.bodySmall,
          ),
          SizedBox(height: 0.5.h),
          Text(
            'Currency: USD (\$)',
            style: AppTheme.lightTheme.textTheme.bodySmall,
          ),
          SizedBox(height: 0.5.h),
          Text(
            'Time Format: 12-hour',
            style: AppTheme.lightTheme.textTheme.bodySmall,
          ),
        ],
      ),
    );
  }

  void _showLanguageDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            CustomIconWidget(
              iconName: 'language',
              color: AppTheme.lightTheme.primaryColor,
              size: 24,
            ),
            SizedBox(width: 2.w),
            Text('Select Language'),
          ],
        ),
        content: Container(
          width: double.maxFinite,
          constraints: BoxConstraints(maxHeight: 60.h),
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: languages.length,
            itemBuilder: (context, index) {
              final language = languages[index];
              final isSelected = widget.currentLanguage == language["code"];
              final isComingSoon = language["code"] != "en";

              return ListTile(
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppTheme.lightTheme.primaryColor
                            .withValues(alpha: 0.1)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                    border: isSelected
                        ? Border.all(color: AppTheme.lightTheme.primaryColor)
                        : null,
                  ),
                  child: Center(
                    child: Text(
                      language["flag"]!,
                      style: TextStyle(fontSize: 20),
                    ),
                  ),
                ),
                title: Row(
                  children: [
                    Expanded(
                      child: Text(
                        language["name"]!,
                        style:
                            AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
                          fontWeight:
                              isSelected ? FontWeight.w600 : FontWeight.w400,
                          color: isComingSoon
                              ? AppTheme.lightTheme.colorScheme.onSurface
                                  .withValues(alpha: 0.6)
                              : null,
                        ),
                      ),
                    ),
                    if (isComingSoon)
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 2.w, vertical: 0.5.h),
                        decoration: BoxDecoration(
                          color: AppTheme.getWarningColor(true)
                              .withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'Soon',
                          style: AppTheme.lightTheme.textTheme.labelSmall
                              ?.copyWith(
                            color: AppTheme.getWarningColor(true),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                  ],
                ),
                trailing: isSelected
                    ? CustomIconWidget(
                        iconName: 'check_circle',
                        color: AppTheme.lightTheme.primaryColor,
                        size: 20,
                      )
                    : null,
                onTap: isComingSoon
                    ? () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Row(
                              children: [
                                CustomIconWidget(
                                  iconName: 'info',
                                  color: Colors.white,
                                  size: 20,
                                ),
                                SizedBox(width: 2.w),
                                Text(
                                    '${language["name"]} support coming soon!'),
                              ],
                            ),
                            backgroundColor: AppTheme.getWarningColor(true),
                          ),
                        );
                      }
                    : () {
                        widget.onLanguageChanged(language["code"]!);
                        Navigator.pop(context);
                      },
              );
            },
          ),
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
}
