import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class SortBottomSheetWidget extends StatefulWidget {
  final String currentSortBy;
  final bool currentSortAscending;
  final Function(String, bool) onSortChanged;

  const SortBottomSheetWidget({
    super.key,
    required this.currentSortBy,
    required this.currentSortAscending,
    required this.onSortChanged,
  });

  @override
  State<SortBottomSheetWidget> createState() => _SortBottomSheetWidgetState();
}

class _SortBottomSheetWidgetState extends State<SortBottomSheetWidget> {
  late String _selectedSortBy;
  late bool _sortAscending;

  final List<Map<String, dynamic>> _sortOptions = [
    {
      'key': 'dueDate',
      'title': 'Due Date',
      'icon': 'schedule',
      'description': 'Sort by task due date and time',
    },
    {
      'key': 'priority',
      'title': 'Priority',
      'icon': 'flag',
      'description': 'Sort by task priority level',
    },
    {
      'key': 'category',
      'title': 'Category',
      'icon': 'category',
      'description': 'Sort by task category',
    },
    {
      'key': 'createdAt',
      'title': 'Creation Date',
      'icon': 'add_circle',
      'description': 'Sort by when task was created',
    },
  ];

  @override
  void initState() {
    super.initState();
    _selectedSortBy = widget.currentSortBy;
    _sortAscending = widget.currentSortAscending;
  }

  void _applySorting() {
    widget.onSortChanged(_selectedSortBy, _sortAscending);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            margin: EdgeInsets.only(top: 2.h),
            width: 12.w,
            height: 0.5.h,
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.colorScheme.outline
                  .withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(4.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'Sort Tasks',
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.lightTheme.colorScheme.onSurface,
                      ),
                    ),
                    const Spacer(),
                    CustomIconWidget(
                      iconName: 'sort',
                      color: AppTheme.lightTheme.colorScheme.primary,
                      size: 24,
                    ),
                  ],
                ),
                SizedBox(height: 3.h),

                // Sort Options
                ...(_sortOptions.map((option) {
                  final isSelected = _selectedSortBy == option['key'];
                  return Container(
                    margin: EdgeInsets.only(bottom: 2.h),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            _selectedSortBy = option['key'] as String;
                          });
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: EdgeInsets.all(3.w),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppTheme.lightTheme.colorScheme.primary
                                    .withValues(alpha: 0.1)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected
                                  ? AppTheme.lightTheme.colorScheme.primary
                                      .withValues(alpha: 0.3)
                                  : AppTheme.lightTheme.colorScheme.outline
                                      .withValues(alpha: 0.2),
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: EdgeInsets.all(2.w),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? AppTheme.lightTheme.colorScheme.primary
                                          .withValues(alpha: 0.2)
                                      : AppTheme.lightTheme.colorScheme.surface,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: CustomIconWidget(
                                  iconName: option['icon'] as String,
                                  color: isSelected
                                      ? AppTheme.lightTheme.colorScheme.primary
                                      : AppTheme
                                          .lightTheme.colorScheme.onSurface
                                          .withValues(alpha: 0.6),
                                  size: 20,
                                ),
                              ),
                              SizedBox(width: 3.w),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      option['title'] as String,
                                      style: TextStyle(
                                        fontSize: 14.sp,
                                        fontWeight: FontWeight.w600,
                                        color: isSelected
                                            ? AppTheme
                                                .lightTheme.colorScheme.primary
                                            : AppTheme.lightTheme.colorScheme
                                                .onSurface,
                                      ),
                                    ),
                                    SizedBox(height: 0.5.h),
                                    Text(
                                      option['description'] as String,
                                      style: TextStyle(
                                        fontSize: 11.sp,
                                        color: AppTheme
                                            .lightTheme.colorScheme.onSurface
                                            .withValues(alpha: 0.6),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (isSelected)
                                CustomIconWidget(
                                  iconName: 'check_circle',
                                  color:
                                      AppTheme.lightTheme.colorScheme.primary,
                                  size: 20,
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList()),

                SizedBox(height: 2.h),

                // Sort Direction
                Container(
                  padding: EdgeInsets.all(3.w),
                  decoration: BoxDecoration(
                    color: AppTheme.lightTheme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppTheme.lightTheme.colorScheme.outline
                          .withValues(alpha: 0.2),
                    ),
                  ),
                  child: Row(
                    children: [
                      CustomIconWidget(
                        iconName:
                            _sortAscending ? 'arrow_upward' : 'arrow_downward',
                        color: AppTheme.lightTheme.colorScheme.primary,
                        size: 20,
                      ),
                      SizedBox(width: 3.w),
                      Expanded(
                        child: Text(
                          'Sort Direction',
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.lightTheme.colorScheme.onSurface,
                          ),
                        ),
                      ),
                      Switch(
                        value: _sortAscending,
                        onChanged: (value) {
                          setState(() {
                            _sortAscending = value;
                          });
                        },
                        activeThumbColor: AppTheme.lightTheme.colorScheme.primary,
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 1.h),
                Text(
                  _sortAscending
                      ? 'Ascending (A-Z, 1-9, Oldest first)'
                      : 'Descending (Z-A, 9-1, Newest first)',
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: AppTheme.lightTheme.colorScheme.onSurface
                        .withValues(alpha: 0.6),
                  ),
                ),
                SizedBox(height: 4.h),

                // Apply Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _applySorting,
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 3.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Apply Sorting',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 2.h),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
