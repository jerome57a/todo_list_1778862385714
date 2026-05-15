import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import './task_card_widget.dart';

class TaskSectionWidget extends StatefulWidget {
  final String title;
  final List<Map<String, dynamic>> tasks;
  final Color? accentColor;
  final bool isExpandable;
  final Function(Map<String, dynamic>)? onTaskTap;
  final Function(Map<String, dynamic>)? onTaskComplete;
  final Function(Map<String, dynamic>)? onTaskDelete;
  final Function(Map<String, dynamic>)? onTaskEdit;

  const TaskSectionWidget({
    super.key,
    required this.title,
    required this.tasks,
    this.accentColor,
    this.isExpandable = true,
    this.onTaskTap,
    this.onTaskComplete,
    this.onTaskDelete,
    this.onTaskEdit,
  });

  @override
  State<TaskSectionWidget> createState() => _TaskSectionWidgetState();
}

class _TaskSectionWidgetState extends State<TaskSectionWidget>
    with SingleTickerProviderStateMixin {
  bool _isExpanded = true;
  late AnimationController _animationController;
  late Animation<double> _expandAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _expandAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleExpanded() {
    if (!widget.isExpandable) return;

    setState(() {
      _isExpanded = !_isExpanded;
    });

    _isExpanded
        ? _animationController.forward()
        : _animationController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final taskCount = widget.tasks.length;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: _toggleExpanded,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
              child: Row(
                children: [
                  widget.accentColor != null
                      ? Container(
                          width: 4,
                          height: 20,
                          decoration: BoxDecoration(
                            color: widget.accentColor,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        )
                      : const SizedBox.shrink(),
                  widget.accentColor != null
                      ? SizedBox(width: 3.w)
                      : const SizedBox.shrink(),
                  Expanded(
                    child: Text(
                      widget.title,
                      style:
                          AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppTheme.lightTheme.colorScheme.onSurface,
                      ),
                    ),
                  ),
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
                    decoration: BoxDecoration(
                      color: widget.accentColor?.withValues(alpha: 0.1) ??
                          AppTheme.lightTheme.colorScheme.primary
                              .withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      taskCount.toString(),
                      style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
                        color: widget.accentColor ??
                            AppTheme.lightTheme.colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  SizedBox(width: 2.w),
                  widget.isExpandable
                      ? AnimatedRotation(
                          turns: _isExpanded ? 0.5 : 0,
                          duration: const Duration(milliseconds: 300),
                          child: CustomIconWidget(
                            iconName: 'keyboard_arrow_down',
                            color: AppTheme
                                .lightTheme.colorScheme.onSurfaceVariant,
                            size: 20,
                          ),
                        )
                      : const SizedBox.shrink(),
                ],
              ),
            ),
          ),
          SizeTransition(
            sizeFactor: _expandAnimation,
            child: Column(
              children: [
                taskCount > 0
                    ? ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        padding: EdgeInsets.symmetric(horizontal: 4.w),
                        itemCount: widget.tasks.length,
                        separatorBuilder: (context, index) =>
                            SizedBox(height: 1.h),
                        itemBuilder: (context, index) {
                          final task = widget.tasks[index];
                          return TaskCardWidget(
                            task: task,
                            onTap: () => widget.onTaskTap?.call(task),
                            onComplete: () => widget.onTaskComplete?.call(task),
                            onDelete: () => widget.onTaskDelete?.call(task),
                            onEdit: () => widget.onTaskEdit?.call(task),
                          );
                        },
                      )
                    : Container(
                        padding: EdgeInsets.all(4.w),
                        child: Column(
                          children: [
                            CustomIconWidget(
                              iconName: 'task_alt',
                              color: AppTheme
                                  .lightTheme.colorScheme.onSurfaceVariant
                                  .withValues(alpha: 0.5),
                              size: 48,
                            ),
                            SizedBox(height: 1.h),
                            Text(
                              'No tasks in this section',
                              style: AppTheme.lightTheme.textTheme.bodyMedium
                                  ?.copyWith(
                                color: AppTheme
                                    .lightTheme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
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
