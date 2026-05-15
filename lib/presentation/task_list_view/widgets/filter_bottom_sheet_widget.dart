import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class FilterBottomSheetWidget extends StatefulWidget {
  final Map<String, dynamic> currentFilters;
  final Function(Map<String, dynamic>) onFiltersChanged;

  const FilterBottomSheetWidget({
    super.key,
    required this.currentFilters,
    required this.onFiltersChanged,
  });

  @override
  State<FilterBottomSheetWidget> createState() =>
      _FilterBottomSheetWidgetState();
}

class _FilterBottomSheetWidgetState extends State<FilterBottomSheetWidget> {
  late Map<String, dynamic> _filters;
  DateTimeRange? _selectedDateRange;

  @override
  void initState() {
    super.initState();
    _filters = Map<String, dynamic>.from(widget.currentFilters);
    _selectedDateRange = _filters['dateRange'] as DateTimeRange?;
  }

  void _selectDateRange() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      initialDateRange: _selectedDateRange,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: AppTheme.lightTheme.colorScheme,
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedDateRange = picked;
        _filters['dateRange'] = picked;
      });
    }
  }

  void _clearDateRange() {
    setState(() {
      _selectedDateRange = null;
      _filters.remove('dateRange');
    });
  }

  void _applyFilters() {
    widget.onFiltersChanged(_filters);
    Navigator.pop(context);
  }

  void _clearAllFilters() {
    setState(() {
      _filters.clear();
      _selectedDateRange = null;
    });
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
                      'Filter Tasks',
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.lightTheme.colorScheme.onSurface,
                      ),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: _clearAllFilters,
                      child: Text(
                        'Clear All',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: AppTheme.lightTheme.colorScheme.error,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 3.h),

                // Date Range Filter
                Text(
                  'Date Range',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.lightTheme.colorScheme.onSurface,
                  ),
                ),
                SizedBox(height: 1.h),
                GestureDetector(
                  onTap: _selectDateRange,
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(3.w),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: AppTheme.lightTheme.colorScheme.outline
                            .withValues(alpha: 0.3),
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        CustomIconWidget(
                          iconName: 'date_range',
                          color: AppTheme.lightTheme.colorScheme.primary,
                          size: 20,
                        ),
                        SizedBox(width: 3.w),
                        Expanded(
                          child: Text(
                            _selectedDateRange != null
                                ? '${_selectedDateRange!.start.month}/${_selectedDateRange!.start.day} - ${_selectedDateRange!.end.month}/${_selectedDateRange!.end.day}'
                                : 'Select date range',
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: _selectedDateRange != null
                                  ? AppTheme.lightTheme.colorScheme.onSurface
                                  : AppTheme.lightTheme.colorScheme.onSurface
                                      .withValues(alpha: 0.6),
                            ),
                          ),
                        ),
                        if (_selectedDateRange != null)
                          GestureDetector(
                            onTap: _clearDateRange,
                            child: CustomIconWidget(
                              iconName: 'close',
                              color: AppTheme.lightTheme.colorScheme.onSurface
                                  .withValues(alpha: 0.6),
                              size: 18,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 3.h),

                // Priority Filter
                Text(
                  'Priority Level',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.lightTheme.colorScheme.onSurface,
                  ),
                ),
                SizedBox(height: 1.h),
                Wrap(
                  spacing: 2.w,
                  children: ['High', 'Medium', 'Low'].map((priority) {
                    final isSelected = (_filters['priority'] as List<String>?)
                            ?.contains(priority) ??
                        false;
                    return FilterChip(
                      label: Text(priority),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          final priorities =
                              (_filters['priority'] as List<String>?) ??
                                  <String>[];
                          if (selected) {
                            priorities.add(priority);
                          } else {
                            priorities.remove(priority);
                          }
                          if (priorities.isEmpty) {
                            _filters.remove('priority');
                          } else {
                            _filters['priority'] = priorities;
                          }
                        });
                      },
                      selectedColor: AppTheme.lightTheme.colorScheme.primary
                          .withValues(alpha: 0.2),
                      checkmarkColor: AppTheme.lightTheme.colorScheme.primary,
                      labelStyle: TextStyle(
                        fontSize: 11.sp,
                        color: isSelected
                            ? AppTheme.lightTheme.colorScheme.primary
                            : AppTheme.lightTheme.colorScheme.onSurface,
                      ),
                    );
                  }).toList(),
                ),
                SizedBox(height: 3.h),

                // Category Filter
                Text(
                  'Category',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.lightTheme.colorScheme.onSurface,
                  ),
                ),
                SizedBox(height: 1.h),
                Wrap(
                  spacing: 2.w,
                  children: ['Work', 'Personal', 'Shopping', 'Health']
                      .map((category) {
                    final isSelected = (_filters['category'] as List<String>?)
                            ?.contains(category) ??
                        false;
                    return FilterChip(
                      label: Text(category),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          final categories =
                              (_filters['category'] as List<String>?) ??
                                  <String>[];
                          if (selected) {
                            categories.add(category);
                          } else {
                            categories.remove(category);
                          }
                          if (categories.isEmpty) {
                            _filters.remove('category');
                          } else {
                            _filters['category'] = categories;
                          }
                        });
                      },
                      selectedColor: AppTheme.lightTheme.colorScheme.tertiary
                          .withValues(alpha: 0.2),
                      checkmarkColor: AppTheme.lightTheme.colorScheme.tertiary,
                      labelStyle: TextStyle(
                        fontSize: 11.sp,
                        color: isSelected
                            ? AppTheme.lightTheme.colorScheme.tertiary
                            : AppTheme.lightTheme.colorScheme.onSurface,
                      ),
                    );
                  }).toList(),
                ),
                SizedBox(height: 3.h),

                // Completion Status Filter
                Text(
                  'Status',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.lightTheme.colorScheme.onSurface,
                  ),
                ),
                SizedBox(height: 1.h),
                Wrap(
                  spacing: 2.w,
                  children: ['Completed', 'Pending', 'Overdue'].map((status) {
                    final isSelected = (_filters['status'] as List<String>?)
                            ?.contains(status) ??
                        false;
                    return FilterChip(
                      label: Text(status),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          final statuses =
                              (_filters['status'] as List<String>?) ??
                                  <String>[];
                          if (selected) {
                            statuses.add(status);
                          } else {
                            statuses.remove(status);
                          }
                          if (statuses.isEmpty) {
                            _filters.remove('status');
                          } else {
                            _filters['status'] = statuses;
                          }
                        });
                      },
                      selectedColor: Colors.green.withValues(alpha: 0.2),
                      checkmarkColor: Colors.green,
                      labelStyle: TextStyle(
                        fontSize: 11.sp,
                        color: isSelected
                            ? Colors.green
                            : AppTheme.lightTheme.colorScheme.onSurface,
                      ),
                    );
                  }).toList(),
                ),
                SizedBox(height: 4.h),

                // Apply Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _applyFilters,
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 3.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Apply Filters',
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
