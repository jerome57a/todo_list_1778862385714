import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/task_form_widget.dart';

class AddEditTask extends StatefulWidget {
  final Map<String, dynamic>? task;

  const AddEditTask({super.key, this.task});

  @override
  State<AddEditTask> createState() => _AddEditTaskState();
}

class _AddEditTaskState extends State<AddEditTask> {
  final bool _hasUnsavedChanges = false;

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.task != null;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;

        if (_hasUnsavedChanges) {
          final shouldPop = await _showUnsavedChangesDialog();
          if (shouldPop == true && context.mounted) {
            Navigator.of(context).pop();
          }
        } else {
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: AppTheme.lightTheme.appBarTheme.backgroundColor,
          leading: IconButton(
            onPressed: () async {
              if (_hasUnsavedChanges) {
                final shouldPop = await _showUnsavedChangesDialog();
                if (shouldPop == true && context.mounted) {
                  Navigator.of(context).pop();
                }
              } else {
                Navigator.of(context).pop();
              }
            },
            icon: CustomIconWidget(
              iconName: 'arrow_back',
              color: AppTheme.lightTheme.colorScheme.onSurface,
              size: 24,
            ),
          ),
          title: Text(
            isEditing ? 'Edit Task' : 'Add New Task',
            style: AppTheme.lightTheme.appBarTheme.titleTextStyle,
          ),
          centerTitle: true,
          actions: [
            if (isEditing)
              IconButton(
                onPressed: () => _showDeleteConfirmationDialog(),
                icon: CustomIconWidget(
                  iconName: 'delete',
                  color: AppTheme.lightTheme.colorScheme.error,
                  size: 24,
                ),
              ),
          ],
        ),
        body: SafeArea(
          child: TaskFormWidget(
            task: widget.task,
            onSave: _handleSaveTask,
          ),
        ),
      ),
    );
  }

  void _handleSaveTask(Map<String, dynamic> taskData) {
    // Normalize data to match dashboard expectations
    final normalizedTask = {
      ...taskData,
      'id': taskData['id'] is int
          ? taskData['id']
          : DateTime.now().millisecondsSinceEpoch,
      'priority': (taskData['priority'] as String).toLowerCase(),
      'category': (taskData['category'] as String).toLowerCase(),
    };

    _showSuccessMessage(widget.task != null
        ? 'Task updated successfully!'
        : 'Task created successfully!');

    _triggerHapticFeedback();

    Navigator.of(context).pop(normalizedTask);
  }

  void _showSuccessMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            CustomIconWidget(
              iconName: 'check_circle',
              color: AppTheme.getSuccessColor(true),
              size: 20,
            ),
            SizedBox(width: 3.w),
            Expanded(
              child: Text(
                message,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.white,
                    ),
              ),
            ),
          ],
        ),
        backgroundColor: AppTheme.getSuccessColor(true),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _triggerHapticFeedback() {
    // Simulate haptic feedback for success
    // In a real implementation, you would use HapticFeedback.lightImpact()
  }

  Future<bool?> _showUnsavedChangesDialog() {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              CustomIconWidget(
                iconName: 'warning',
                color: AppTheme.getWarningColor(true),
                size: 24,
              ),
              SizedBox(width: 3.w),
              Text(
                'Unsaved Changes',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ],
          ),
          content: Text(
            'You have unsaved changes. Are you sure you want to leave without saving?',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(
                'Cancel',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: AppTheme.lightTheme.colorScheme.secondary,
                    ),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(
                'Leave',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: AppTheme.lightTheme.colorScheme.error,
                    ),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showDeleteConfirmationDialog() {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              CustomIconWidget(
                iconName: 'delete_forever',
                color: AppTheme.lightTheme.colorScheme.error,
                size: 24,
              ),
              SizedBox(width: 3.w),
              Text(
                'Delete Task',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ],
          ),
          content: Text(
            'Are you sure you want to delete this task? This action cannot be undone.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancel',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: AppTheme.lightTheme.colorScheme.secondary,
                    ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _deleteTask();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.lightTheme.colorScheme.error,
                foregroundColor: Colors.white,
              ),
              child: Text(
                'Delete',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: Colors.white,
                    ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _deleteTask() {
    // Simulate task deletion
    _showSuccessMessage('Task deleted successfully!');

    // Navigate back to dashboard
    Navigator.of(context).pop({'deleted': true});
  }
}
