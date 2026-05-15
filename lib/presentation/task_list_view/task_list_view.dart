import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../core/services/task_storage_service.dart';
import './widgets/empty_state_widget.dart';
import './widgets/filter_bottom_sheet_widget.dart';
import './widgets/sort_bottom_sheet_widget.dart';
import './widgets/task_card_widget.dart';

class TaskListView extends StatefulWidget {
  const TaskListView({super.key});

  @override
  State<TaskListView> createState() => _TaskListViewState();
}

class _TaskListViewState extends State<TaskListView>
    with TickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  List<Map<String, dynamic>> _allTasks = [];
  List<Map<String, dynamic>> _filteredTasks = [];
  Map<String, dynamic> _activeFilters = {};
  String _sortBy = 'dueDate';
  bool _sortAscending = true;
  bool _isLoading = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    _loadTasks();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadTasks() async {
    final tasks = await TaskStorageService.instance.loadTasks();
    if (mounted) {
      setState(() {
        _allTasks = tasks;
        _isLoading = false;
        _applyFiltersAndSort();
      });
    }
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text.toLowerCase();
      _applyFiltersAndSort();
    });
  }

  void _applyFiltersAndSort() {
    List<Map<String, dynamic>> filtered = List.from(_allTasks);

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((task) {
        final title = (task['title'] as String? ?? '').toLowerCase();
        final description =
            (task['description'] as String? ?? '').toLowerCase();
        return title.contains(_searchQuery) ||
            description.contains(_searchQuery);
      }).toList();
    }

    // Apply date range filter
    if (_activeFilters.containsKey('dateRange')) {
      final dateRange = _activeFilters['dateRange'] as DateTimeRange;
      filtered = filtered.where((task) {
        final dueDate = task['dueDate'] as DateTime?;
        if (dueDate == null) return false;
        return dueDate
                .isAfter(dateRange.start.subtract(const Duration(days: 1))) &&
            dueDate.isBefore(dateRange.end.add(const Duration(days: 1)));
      }).toList();
    }

    // Apply priority filter
    if (_activeFilters.containsKey('priority')) {
      final priorities = (_activeFilters['priority'] as List<String>)
          .map((p) => p.toLowerCase())
          .toList();
      filtered = filtered.where((task) {
        return priorities.contains((task['priority'] as String).toLowerCase());
      }).toList();
    }

    // Apply category filter
    if (_activeFilters.containsKey('category')) {
      final categories = (_activeFilters['category'] as List<String>)
          .map((c) => c.toLowerCase())
          .toList();
      filtered = filtered.where((task) {
        return categories.contains((task['category'] as String).toLowerCase());
      }).toList();
    }

    // Apply status filter
    if (_activeFilters.containsKey('status')) {
      final statuses = _activeFilters['status'] as List<String>;
      filtered = filtered.where((task) {
        final isCompleted = task['isCompleted'] as bool? ?? false;
        final dueDate = task['dueDate'] as DateTime?;
        final isOverdue =
            dueDate != null && dueDate.isBefore(DateTime.now()) && !isCompleted;

        for (String status in statuses) {
          if (status == 'Completed' && isCompleted) return true;
          if (status == 'Pending' && !isCompleted && !isOverdue) return true;
          if (status == 'Overdue' && isOverdue) return true;
        }
        return false;
      }).toList();
    }

    // Apply sorting
    filtered.sort((a, b) {
      int comparison = 0;
      switch (_sortBy) {
        case 'dueDate':
          final aDate = a['dueDate'] as DateTime?;
          final bDate = b['dueDate'] as DateTime?;
          if (aDate == null && bDate == null) {
            comparison = 0;
          } else if (aDate == null) {
            comparison = 1;
          } else if (bDate == null) {
            comparison = -1;
          } else {
            comparison = aDate.compareTo(bDate);
          }
          break;
        case 'priority':
          final priorityOrder = {'high': 3, 'medium': 2, 'low': 1};
          final aPriority =
              priorityOrder[(a['priority'] as String).toLowerCase()] ?? 0;
          final bPriority =
              priorityOrder[(b['priority'] as String).toLowerCase()] ?? 0;
          comparison = aPriority.compareTo(bPriority);
          break;
        case 'category':
          comparison = (a['category'] as String? ?? '')
              .compareTo(b['category'] as String? ?? '');
          break;
        case 'createdAt':
          final aCreated = a['createdAt'] as DateTime?;
          final bCreated = b['createdAt'] as DateTime?;
          if (aCreated == null && bCreated == null) {
            comparison = 0;
          } else if (aCreated == null) {
            comparison = 1;
          } else if (bCreated == null) {
            comparison = -1;
          } else {
            comparison = aCreated.compareTo(bCreated);
          }
          break;
      }
      return _sortAscending ? comparison : -comparison;
    });

    setState(() {
      _filteredTasks = filtered;
    });
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => FilterBottomSheetWidget(
        currentFilters: _activeFilters,
        onFiltersChanged: (filters) {
          setState(() {
            _activeFilters = filters;
            _applyFiltersAndSort();
          });
        },
      ),
    );
  }

  void _showSortBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => SortBottomSheetWidget(
        currentSortBy: _sortBy,
        currentSortAscending: _sortAscending,
        onSortChanged: (sortBy, ascending) {
          setState(() {
            _sortBy = sortBy;
            _sortAscending = ascending;
            _applyFiltersAndSort();
          });
        },
      ),
    );
  }

  void _clearAllFilters() {
    setState(() {
      _activeFilters.clear();
      _searchController.clear();
      _searchQuery = '';
      _applyFiltersAndSort();
    });
  }

  void _toggleTaskCompletion(dynamic taskId) async {
    final updated =
        await TaskStorageService.instance.toggleCompletion(_allTasks, taskId);
    if (mounted) {
      setState(() {
        _allTasks = updated;
        _applyFiltersAndSort();
      });
    }
    HapticFeedback.lightImpact();
  }

  void _deleteTask(dynamic taskId) async {
    final deleted = _allTasks.firstWhere(
        (t) => t['id'].toString() == taskId.toString(),
        orElse: () => {});
    final updated =
        await TaskStorageService.instance.deleteTask(_allTasks, taskId);
    if (mounted) {
      setState(() {
        _allTasks = updated;
        _applyFiltersAndSort();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Task deleted'),
          action: SnackBarAction(
            label: 'Undo',
            onPressed: () async {
              if (deleted.isNotEmpty) {
                final restored = await TaskStorageService.instance
                    .addTask(_allTasks, deleted);
                if (mounted) {
                  setState(() {
                    _allTasks = restored;
                    _applyFiltersAndSort();
                  });
                }
              }
            },
          ),
        ),
      );
    }
  }

  void _snoozeTask(dynamic taskId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Snooze Task'),
        content: const Text('Choose how long to snooze this task:'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              final taskIndex = _allTasks
                  .indexWhere((t) => t['id'].toString() == taskId.toString());
              if (taskIndex != -1) {
                final currentDue = _allTasks[taskIndex]['dueDate'] as DateTime?;
                if (currentDue != null) {
                  final updated = List<Map<String, dynamic>>.from(_allTasks);
                  updated[taskIndex] = {
                    ...updated[taskIndex],
                    'dueDate': currentDue.add(const Duration(hours: 1)),
                  };
                  await TaskStorageService.instance.saveTasks(updated);
                  if (mounted) {
                    setState(() {
                      _allTasks = updated;
                      _applyFiltersAndSort();
                    });
                  }
                }
              }
              if (mounted) Navigator.pop(context);
            },
            child: const Text('1 Hour'),
          ),
          TextButton(
            onPressed: () async {
              final taskIndex = _allTasks
                  .indexWhere((t) => t['id'].toString() == taskId.toString());
              if (taskIndex != -1) {
                final currentDue = _allTasks[taskIndex]['dueDate'] as DateTime?;
                if (currentDue != null) {
                  final updated = List<Map<String, dynamic>>.from(_allTasks);
                  updated[taskIndex] = {
                    ...updated[taskIndex],
                    'dueDate': currentDue.add(const Duration(days: 1)),
                  };
                  await TaskStorageService.instance.saveTasks(updated);
                  if (mounted) {
                    setState(() {
                      _allTasks = updated;
                      _applyFiltersAndSort();
                    });
                  }
                }
              }
              if (mounted) Navigator.pop(context);
            },
            child: const Text('1 Day'),
          ),
        ],
      ),
    );
  }

  Future<void> _refreshTasks() async {
    setState(() => _isLoading = true);
    await _loadTasks();
  }

  bool get _hasActiveFilters {
    return _activeFilters.isNotEmpty || _searchQuery.isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Tasks',
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.w600,
            color: AppTheme.lightTheme.colorScheme.onSurface,
          ),
        ),
        backgroundColor: AppTheme.lightTheme.colorScheme.surface,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: CustomIconWidget(
            iconName: 'arrow_back',
            color: AppTheme.lightTheme.colorScheme.onSurface,
            size: 24,
          ),
        ),
        actions: [
          IconButton(
            onPressed: _showSortBottomSheet,
            icon: CustomIconWidget(
              iconName: 'sort',
              color: AppTheme.lightTheme.colorScheme.onSurface,
              size: 24,
            ),
          ),
          IconButton(
            onPressed: () =>
                Navigator.pushNamed(context, '/settings-and-preferences'),
            icon: CustomIconWidget(
              iconName: 'settings',
              color: AppTheme.lightTheme.colorScheme.onSurface,
              size: 24,
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Search and Filter Header
                Container(
                  color: AppTheme.lightTheme.colorScheme.surface,
                  padding: EdgeInsets.fromLTRB(4.w, 0, 4.w, 2.h),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                color:
                                    AppTheme.lightTheme.scaffoldBackgroundColor,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: AppTheme.lightTheme.colorScheme.outline
                                      .withValues(alpha: 0.2),
                                ),
                              ),
                              child: TextField(
                                controller: _searchController,
                                decoration: InputDecoration(
                                  hintText: 'Search tasks...',
                                  prefixIcon: Padding(
                                    padding: EdgeInsets.all(3.w),
                                    child: CustomIconWidget(
                                      iconName: 'search',
                                      color: AppTheme
                                          .lightTheme.colorScheme.onSurface
                                          .withValues(alpha: 0.6),
                                      size: 20,
                                    ),
                                  ),
                                  suffixIcon: _searchQuery.isNotEmpty
                                      ? IconButton(
                                          onPressed: () {
                                            _searchController.clear();
                                          },
                                          icon: CustomIconWidget(
                                            iconName: 'close',
                                            color: AppTheme.lightTheme
                                                .colorScheme.onSurface
                                                .withValues(alpha: 0.6),
                                            size: 20,
                                          ),
                                        )
                                      : null,
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.symmetric(
                                      horizontal: 4.w, vertical: 2.h),
                                ),
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  color:
                                      AppTheme.lightTheme.colorScheme.onSurface,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 3.w),
                          Container(
                            decoration: BoxDecoration(
                              color: _hasActiveFilters
                                  ? AppTheme.lightTheme.colorScheme.primary
                                  : AppTheme.lightTheme.scaffoldBackgroundColor,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: _hasActiveFilters
                                    ? AppTheme.lightTheme.colorScheme.primary
                                    : AppTheme.lightTheme.colorScheme.outline
                                        .withValues(alpha: 0.2),
                              ),
                            ),
                            child: IconButton(
                              onPressed: _showFilterBottomSheet,
                              icon: CustomIconWidget(
                                iconName: 'filter_list',
                                color: _hasActiveFilters
                                    ? Colors.white
                                    : AppTheme.lightTheme.colorScheme.onSurface
                                        .withValues(alpha: 0.6),
                                size: 24,
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (_hasActiveFilters) ...[
                        SizedBox(height: 2.h),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                '${_filteredTasks.length} task${_filteredTasks.length != 1 ? 's' : ''} found',
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  color: AppTheme
                                      .lightTheme.colorScheme.onSurface
                                      .withValues(alpha: 0.6),
                                ),
                              ),
                            ),
                            TextButton(
                              onPressed: _clearAllFilters,
                              child: Text(
                                'Clear All',
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  color:
                                      AppTheme.lightTheme.colorScheme.primary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),

                // Task List
                Expanded(
                  child: _filteredTasks.isEmpty
                      ? EmptyStateWidget(
                          hasActiveFilters: _hasActiveFilters,
                          onClearFilters: _clearAllFilters,
                          onCreateTask: () async {
                            final result = await Navigator.pushNamed(
                                context, '/add-edit-task');
                            if (result != null &&
                                result is Map<String, dynamic> &&
                                result['deleted'] != true) {
                              final updated = await TaskStorageService.instance
                                  .addTask(_allTasks, result);
                              if (mounted) {
                                setState(() {
                                  _allTasks = updated;
                                  _applyFiltersAndSort();
                                });
                              }
                            }
                          },
                        )
                      : RefreshIndicator(
                          onRefresh: _refreshTasks,
                          color: AppTheme.lightTheme.colorScheme.primary,
                          child: ListView.builder(
                            controller: _scrollController,
                            physics: const AlwaysScrollableScrollPhysics(),
                            itemCount: _filteredTasks.length,
                            itemBuilder: (context, index) {
                              final task = _filteredTasks[index];
                              return TaskCardWidget(
                                task: task,
                                onTap: () async {
                                  final result = await Navigator.pushNamed(
                                      context, '/add-edit-task',
                                      arguments: task);
                                  if (result != null &&
                                      result is Map<String, dynamic>) {
                                    if (result['deleted'] == true) {
                                      _deleteTask(task['id']);
                                    } else {
                                      final updated = await TaskStorageService
                                          .instance
                                          .updateTask(_allTasks, result);
                                      if (mounted) {
                                        setState(() {
                                          _allTasks = updated;
                                          _applyFiltersAndSort();
                                        });
                                      }
                                    }
                                  }
                                },
                                onComplete: () =>
                                    _toggleTaskCompletion(task['id']),
                                onDelete: () => _deleteTask(task['id']),
                                onSnooze: () => _snoozeTask(task['id']),
                              );
                            },
                          ),
                        ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.pushNamed(context, '/add-edit-task');
          if (result != null &&
              result is Map<String, dynamic> &&
              result['deleted'] != true) {
            final updated =
                await TaskStorageService.instance.addTask(_allTasks, result);
            if (mounted) {
              setState(() {
                _allTasks = updated;
                _applyFiltersAndSort();
              });
            }
          }
        },
        backgroundColor: AppTheme.lightTheme.colorScheme.primary,
        child: CustomIconWidget(
          iconName: 'add',
          color: Colors.white,
          size: 24,
        ),
      ),
    );
  }
}
