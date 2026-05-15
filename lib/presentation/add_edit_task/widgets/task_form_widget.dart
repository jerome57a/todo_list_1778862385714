import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class TaskFormWidget extends StatefulWidget {
  final Map<String, dynamic>? task;
  final Function(Map<String, dynamic>) onSave;

  const TaskFormWidget({
    super.key,
    this.task,
    required this.onSave,
  });

  @override
  State<TaskFormWidget> createState() => _TaskFormWidgetState();
}

class _TaskFormWidgetState extends State<TaskFormWidget> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _titleFocusNode = FocusNode();

  String _selectedPriority = 'Medium';
  String _selectedCategory = 'Work';
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  bool _isRecurring = false;
  String _recurringInterval = 'Daily';
  bool _isFormValid = false;

  final List<String> _priorities = ['High', 'Medium', 'Low'];
  final List<String> _categories = [
    'Work',
    'Personal',
    'Shopping',
    'Health',
    'Education',
    'Finance'
  ];
  final List<String> _recurringIntervals = ['Daily', 'Weekly', 'Monthly'];

  @override
  void initState() {
    super.initState();
    _initializeForm();
    _titleController.addListener(_validateForm);
    _descriptionController.addListener(_validateForm);
  }

  void _initializeForm() {
    if (widget.task != null) {
      _titleController.text = widget.task!['title'] ?? '';
      _descriptionController.text = widget.task!['description'] ?? '';
      // Capitalize first letter to match the UI list values
      final rawPriority = widget.task!['priority'] as String? ?? 'Medium';
      _selectedPriority =
          rawPriority[0].toUpperCase() + rawPriority.substring(1).toLowerCase();
      final rawCategory = widget.task!['category'] as String? ?? 'Work';
      _selectedCategory =
          rawCategory[0].toUpperCase() + rawCategory.substring(1).toLowerCase();
      _selectedDate = widget.task!['dueDate'] ?? DateTime.now();
      _selectedTime = widget.task!['dueTime'] ?? TimeOfDay.now();
      _isRecurring = widget.task!['isRecurring'] ?? false;
      _recurringInterval = widget.task!['recurringInterval'] ?? 'Daily';
    }
    // Validate after initialization so save button is enabled when title is pre-filled
    _isFormValid = _titleController.text.trim().isNotEmpty;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _titleFocusNode.requestFocus();
    });
  }

  void _validateForm() {
    setState(() {
      _isFormValid = _titleController.text.trim().isNotEmpty;
    });
  }

  Color _getPriorityColor(String priority) {
    switch (priority) {
      case 'High':
        return AppTheme.lightTheme.colorScheme.error;
      case 'Medium':
        return AppTheme.lightTheme.colorScheme.tertiary;
      case 'Low':
        return AppTheme.lightTheme.colorScheme.secondary;
      default:
        return AppTheme.lightTheme.colorScheme.secondary;
    }
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
                  primary: AppTheme.lightTheme.colorScheme.primary,
                ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
                  primary: AppTheme.lightTheme.colorScheme.primary,
                ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  void _saveTask() {
    if (!_isFormValid) return;

    final taskData = {
      'id': widget.task?['id'] ?? DateTime.now().millisecondsSinceEpoch,
      'title': _titleController.text.trim(),
      'description': _descriptionController.text.trim(),
      'priority': _selectedPriority,
      'category': _selectedCategory,
      'dueDate': _selectedDate,
      'dueTime': _selectedTime,
      'isRecurring': _isRecurring,
      'recurringInterval': _recurringInterval,
      'isCompleted': widget.task?['isCompleted'] ?? false,
      'createdAt': widget.task?['createdAt'] ?? DateTime.now(),
      'updatedAt': DateTime.now(),
    };

    widget.onSave(taskData);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _titleFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(4.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title Field
          _buildSectionTitle('Task Title'),
          SizedBox(height: 1.h),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _titleController,
                  focusNode: _titleFocusNode,
                  style: Theme.of(context).textTheme.bodyLarge,
                  decoration: InputDecoration(
                    hintText: 'Enter task title...',
                    prefixIcon: Padding(
                      padding: EdgeInsets.all(3.w),
                      child: CustomIconWidget(
                        iconName: 'task_alt',
                        color: AppTheme.lightTheme.colorScheme.secondary,
                        size: 20,
                      ),
                    ),
                  ),
                  textCapitalization: TextCapitalization.sentences,
                  maxLines: 1,
                ),
              ),
              SizedBox(width: 2.w),
              Container(
                decoration: BoxDecoration(
                  color: AppTheme.lightTheme.colorScheme.primary
                      .withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: IconButton(
                  onPressed: () {
                    // Voice input functionality would be implemented here
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Voice input feature coming soon!')),
                    );
                  },
                  icon: CustomIconWidget(
                    iconName: 'mic',
                    color: AppTheme.lightTheme.colorScheme.primary,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 3.h),

          // Description Field
          _buildSectionTitle('Description'),
          SizedBox(height: 1.h),
          TextFormField(
            controller: _descriptionController,
            style: Theme.of(context).textTheme.bodyMedium,
            decoration: InputDecoration(
              hintText: 'Add task description (optional)...',
              prefixIcon: Padding(
                padding: EdgeInsets.all(3.w),
                child: CustomIconWidget(
                  iconName: 'description',
                  color: AppTheme.lightTheme.colorScheme.secondary,
                  size: 20,
                ),
              ),
            ),
            textCapitalization: TextCapitalization.sentences,
            maxLines: 3,
            minLines: 1,
          ),

          SizedBox(height: 3.h),

          // Date and Time Section
          _buildSectionTitle('Due Date & Time'),
          SizedBox(height: 1.h),
          Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: _selectDate,
                  child: Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 4.w, vertical: 3.h),
                    decoration: BoxDecoration(
                      border: Border.all(
                          color: AppTheme.lightTheme.colorScheme.outline),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        CustomIconWidget(
                          iconName: 'calendar_today',
                          color: AppTheme.lightTheme.colorScheme.secondary,
                          size: 20,
                        ),
                        SizedBox(width: 3.w),
                        Text(
                          '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: InkWell(
                  onTap: _selectTime,
                  child: Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 4.w, vertical: 3.h),
                    decoration: BoxDecoration(
                      border: Border.all(
                          color: AppTheme.lightTheme.colorScheme.outline),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        CustomIconWidget(
                          iconName: 'access_time',
                          color: AppTheme.lightTheme.colorScheme.secondary,
                          size: 20,
                        ),
                        SizedBox(width: 3.w),
                        Text(
                          _selectedTime.format(context),
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 3.h),

          // Priority Section
          _buildSectionTitle('Priority Level'),
          SizedBox(height: 1.h),
          Row(
            children: _priorities.map((priority) {
              final isSelected = _selectedPriority == priority;
              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(
                      right: priority != _priorities.last ? 2.w : 0),
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        _selectedPriority = priority;
                      });
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 2.h),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? _getPriorityColor(priority).withValues(alpha: 0.1)
                            : Colors.transparent,
                        border: Border.all(
                          color: isSelected
                              ? _getPriorityColor(priority)
                              : AppTheme.lightTheme.colorScheme.outline,
                          width: isSelected ? 2 : 1,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text(
                          priority,
                          style: Theme.of(context)
                              .textTheme
                              .labelLarge
                              ?.copyWith(
                                color: isSelected
                                    ? _getPriorityColor(priority)
                                    : AppTheme.lightTheme.colorScheme.onSurface,
                                fontWeight: isSelected
                                    ? FontWeight.w600
                                    : FontWeight.w400,
                              ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),

          SizedBox(height: 3.h),

          // Category Section
          _buildSectionTitle('Category'),
          SizedBox(height: 1.h),
          DropdownButtonFormField<String>(
            initialValue: _selectedCategory,
            decoration: InputDecoration(
              prefixIcon: Padding(
                padding: EdgeInsets.all(3.w),
                child: CustomIconWidget(
                  iconName: 'category',
                  color: AppTheme.lightTheme.colorScheme.secondary,
                  size: 20,
                ),
              ),
            ),
            items: _categories.map((category) {
              return DropdownMenuItem(
                value: category,
                child: Text(category),
              );
            }).toList(),
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  _selectedCategory = value;
                });
              }
            },
          ),

          SizedBox(height: 3.h),

          // Recurring Task Section
          Row(
            children: [
              Switch(
                value: _isRecurring,
                onChanged: (value) {
                  setState(() {
                    _isRecurring = value;
                  });
                },
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: Text(
                  'Recurring Task',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
            ],
          ),

          _isRecurring
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 2.h),
                    _buildSectionTitle('Repeat Interval'),
                    SizedBox(height: 1.h),
                    DropdownButtonFormField<String>(
                      initialValue: _recurringInterval,
                      decoration: InputDecoration(
                        prefixIcon: Padding(
                          padding: EdgeInsets.all(3.w),
                          child: CustomIconWidget(
                            iconName: 'repeat',
                            color: AppTheme.lightTheme.colorScheme.secondary,
                            size: 20,
                          ),
                        ),
                      ),
                      items: _recurringIntervals.map((interval) {
                        return DropdownMenuItem(
                          value: interval,
                          child: Text(interval),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            _recurringInterval = value;
                          });
                        }
                      },
                    ),
                  ],
                )
              : const SizedBox.shrink(),

          SizedBox(height: 4.h),

          // Save Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isFormValid ? _saveTask : null,
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 2.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CustomIconWidget(
                    iconName: 'save',
                    color: Colors.white,
                    size: 20,
                  ),
                  SizedBox(width: 2.w),
                  Text(
                    widget.task != null ? 'Update Task' : 'Save Task',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: Colors.white,
                        ),
                  ),
                ],
              ),
            ),
          ),

          SizedBox(height: 2.h),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: AppTheme.lightTheme.colorScheme.onSurface,
          ),
    );
  }
}
