import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class FilterChipsWidget extends StatelessWidget {
  final Map<String, dynamic> activeFilters;
  final Function(String) onRemoveFilter;
  final VoidCallback onClearAll;

  const FilterChipsWidget({
    super.key,
    required this.activeFilters,
    required this.onRemoveFilter,
    required this.onClearAll,
  });

  @override
  Widget build(BuildContext context) {
    if (activeFilters.isEmpty) return const SizedBox.shrink();

    return Container(
      height: 6.h,
      margin: EdgeInsets.symmetric(horizontal: 4.w),
      child: Row(
        children: [
          Expanded(
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _getFilterChips().length,
              itemBuilder: (context, index) {
                final chip = _getFilterChips()[index];
                return Container(
                  margin: EdgeInsets.only(right: 2.w),
                  child: FilterChip(
                    label: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          chip['label'],
                          style: AppTheme.lightTheme.textTheme.labelMedium
                              ?.copyWith(
                            color: AppTheme.lightTheme.colorScheme.primary,
                          ),
                        ),
                        if (chip['count'] != null) ...[
                          SizedBox(width: 1.w),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 1.5.w,
                              vertical: 0.5.h,
                            ),
                            decoration: BoxDecoration(
                              color: AppTheme.lightTheme.colorScheme.primary,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              chip['count'].toString(),
                              style: AppTheme.lightTheme.textTheme.labelSmall
                                  ?.copyWith(
                                color: Colors.white,
                                fontSize: 10.sp,
                              ),
                            ),
                          ),
                        ],
                        SizedBox(width: 1.w),
                        GestureDetector(
                          onTap: () => onRemoveFilter(chip['key']),
                          child: CustomIconWidget(
                            iconName: 'close',
                            color: AppTheme.lightTheme.colorScheme.primary,
                            size: 16,
                          ),
                        ),
                      ],
                    ),
                    backgroundColor:
                        AppTheme.lightTheme.colorScheme.primaryContainer,
                    side: BorderSide(
                      color: AppTheme.lightTheme.colorScheme.primary,
                      width: 1,
                    ),
                    onSelected: (_) => onRemoveFilter(chip['key']),
                  ),
                );
              },
            ),
          ),
          if (activeFilters.isNotEmpty) ...[
            SizedBox(width: 2.w),
            TextButton(
              onPressed: onClearAll,
              child: Text(
                'Clear All',
                style: AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
                  color: AppTheme.lightTheme.colorScheme.error,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _getFilterChips() {
    List<Map<String, dynamic>> chips = [];

    if (activeFilters['dateRange'] != null) {
      final dateRange = activeFilters['dateRange'] as Map<String, DateTime>;
      chips.add({
        'key': 'dateRange',
        'label': 'Date: ${_formatDateRange(dateRange)}',
        'count': null,
      });
    }

    if (activeFilters['priorities'] != null &&
        (activeFilters['priorities'] as List).isNotEmpty) {
      final priorities = activeFilters['priorities'] as List<String>;
      chips.add({
        'key': 'priorities',
        'label': 'Priority',
        'count': priorities.length,
      });
    }

    if (activeFilters['categories'] != null &&
        (activeFilters['categories'] as List).isNotEmpty) {
      final categories = activeFilters['categories'] as List<String>;
      chips.add({
        'key': 'categories',
        'label': 'Categories',
        'count': categories.length,
      });
    }

    if (activeFilters['status'] != null) {
      chips.add({
        'key': 'status',
        'label': 'Status: ${activeFilters['status']}',
        'count': null,
      });
    }

    return chips;
  }

  String _formatDateRange(Map<String, DateTime> dateRange) {
    final start = dateRange['start'];
    final end = dateRange['end'];
    if (start != null && end != null) {
      return '${start.month}/${start.day} - ${end.month}/${end.day}';
    }
    return 'Custom';
  }
}
