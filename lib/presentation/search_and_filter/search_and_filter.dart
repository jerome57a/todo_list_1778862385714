import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/advanced_filter_widget.dart';
import './widgets/filter_chips_widget.dart';
import './widgets/recent_searches_widget.dart';
import './widgets/search_bar_widget.dart';
import './widgets/search_results_widget.dart';

class SearchAndFilter extends StatefulWidget {
  const SearchAndFilter({super.key});

  @override
  State<SearchAndFilter> createState() => _SearchAndFilterState();
}

class _SearchAndFilterState extends State<SearchAndFilter> {
  final TextEditingController _searchController = TextEditingController();

  // Search and filter state
  String _searchQuery = '';
  bool _isVoiceSearching = false;
  bool _isAdvancedFilterExpanded = false;
  String _sortBy = 'relevance';

  // Filter state
  Map<String, dynamic> _activeFilters = {};

  // Recent searches
  final List<String> _recentSearches = [
    'Meeting preparation',
    'Shopping list',
    'Project deadline',
    'Doctor appointment',
    'Workout routine',
  ];

  // Search results
  List<Map<String, dynamic>> _searchResults = [];
  List<Map<String, dynamic>> _allTasks = [];

  @override
  void initState() {
    super.initState();
    _initializeMockData();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _initializeMockData() {
    _allTasks = [
      {
        "id": 1,
        "title": "Complete project proposal",
        "description":
            "Finalize the quarterly project proposal with budget analysis and timeline. Include stakeholder feedback and risk assessment.",
        "dueDate": DateTime.now().add(const Duration(days: 3)),
        "priority": "High",
        "category": "Work",
        "isCompleted": false,
        "createdAt": DateTime.now().subtract(const Duration(days: 5)),
        "modifiedAt": DateTime.now().subtract(const Duration(hours: 2)),
      },
      {
        "id": 2,
        "title": "Buy groceries for dinner",
        "description":
            "Get ingredients for pasta dinner: tomatoes, basil, parmesan cheese, and ground beef.",
        "dueDate": DateTime.now(),
        "priority": "Medium",
        "category": "Shopping",
        "isCompleted": false,
        "createdAt": DateTime.now().subtract(const Duration(days: 1)),
        "modifiedAt": DateTime.now().subtract(const Duration(minutes: 30)),
      },
      {
        "id": 3,
        "title": "Schedule dentist appointment",
        "description":
            "Call Dr. Smith's office to schedule routine cleaning and checkup.",
        "dueDate": DateTime.now().add(const Duration(days: 7)),
        "priority": "Low",
        "category": "Health",
        "isCompleted": true,
        "createdAt": DateTime.now().subtract(const Duration(days: 10)),
        "modifiedAt": DateTime.now().subtract(const Duration(days: 2)),
      },
      {
        "id": 4,
        "title": "Review quarterly budget",
        "description":
            "Analyze Q3 expenses and prepare budget recommendations for Q4.",
        "dueDate": DateTime.now().subtract(const Duration(days: 2)),
        "priority": "High",
        "category": "Finance",
        "isCompleted": false,
        "createdAt": DateTime.now().subtract(const Duration(days: 15)),
        "modifiedAt": DateTime.now().subtract(const Duration(days: 1)),
      },
      {
        "id": 5,
        "title": "Prepare presentation slides",
        "description":
            "Create slides for Monday's team meeting covering project updates and next steps.",
        "dueDate": DateTime.now().add(const Duration(days: 1)),
        "priority": "Medium",
        "category": "Work",
        "isCompleted": false,
        "createdAt": DateTime.now().subtract(const Duration(days: 3)),
        "modifiedAt": DateTime.now().subtract(const Duration(hours: 4)),
      },
      {
        "id": 6,
        "title": "Morning workout routine",
        "description":
            "30-minute cardio session followed by strength training focusing on upper body.",
        "dueDate": DateTime.now().add(const Duration(days: 1)),
        "priority": "Low",
        "category": "Personal",
        "isCompleted": false,
        "createdAt": DateTime.now().subtract(const Duration(days: 7)),
        "modifiedAt": DateTime.now().subtract(const Duration(hours: 12)),
      },
      {
        "id": 7,
        "title": "Update project documentation",
        "description":
            "Revise technical documentation and user guides for the new software release.",
        "dueDate": DateTime.now().add(const Duration(days: 5)),
        "priority": "Medium",
        "category": "Work",
        "isCompleted": false,
        "createdAt": DateTime.now().subtract(const Duration(days: 8)),
        "modifiedAt": DateTime.now().subtract(const Duration(hours: 6)),
      },
      {
        "id": 8,
        "title": "Plan weekend trip",
        "description":
            "Research destinations, book accommodations, and create itinerary for weekend getaway.",
        "dueDate": DateTime.now().add(const Duration(days: 10)),
        "priority": "Low",
        "category": "Personal",
        "isCompleted": false,
        "createdAt": DateTime.now().subtract(const Duration(days: 12)),
        "modifiedAt": DateTime.now().subtract(const Duration(days: 3)),
      },
    ];

    _performSearch();
  }

  void _onSearchChanged() {
    final query = _searchController.text;
    if (query != _searchQuery) {
      setState(() {
        _searchQuery = query;
      });
      _performSearch();

      // Add to recent searches if not empty and not already present
      if (query.isNotEmpty && !_recentSearches.contains(query)) {
        setState(() {
          _recentSearches.insert(0, query);
          if (_recentSearches.length > 10) {
            _recentSearches.removeLast();
          }
        });
      }
    }
  }

  void _performSearch() {
    List<Map<String, dynamic>> results = List.from(_allTasks);

    // Apply text search
    if (_searchQuery.isNotEmpty) {
      results = results.where((task) {
        final title = (task['title'] as String).toLowerCase();
        final description = (task['description'] as String).toLowerCase();
        final category = (task['category'] as String).toLowerCase();
        final query = _searchQuery.toLowerCase();

        final titleMatch = title.contains(query);
        final descriptionMatch = description.contains(query);
        final categoryMatch = category.contains(query);

        // Calculate relevance score
        double relevanceScore = 0.0;
        if (titleMatch) relevanceScore += 0.6;
        if (descriptionMatch) relevanceScore += 0.3;
        if (categoryMatch) relevanceScore += 0.1;

        task['relevanceScore'] = relevanceScore;

        return titleMatch || descriptionMatch || categoryMatch;
      }).toList();
    } else {
      // Set default relevance score for all tasks
      for (var task in results) {
        task['relevanceScore'] = 1.0;
      }
    }

    // Apply filters
    results = _applyFilters(results);

    // Apply sorting
    results = _applySorting(results);

    setState(() {
      _searchResults = results;
    });
  }

  List<Map<String, dynamic>> _applyFilters(List<Map<String, dynamic>> tasks) {
    List<Map<String, dynamic>> filtered = List.from(tasks);

    // Date range filter
    if (_activeFilters['dateRange'] != null) {
      final dateRange = _activeFilters['dateRange'] as Map<String, DateTime>;
      final startDate = dateRange['start']!;
      final endDate = dateRange['end']!;

      filtered = filtered.where((task) {
        final dueDate = task['dueDate'] as DateTime?;
        if (dueDate == null) return false;

        final taskDate = DateTime(dueDate.year, dueDate.month, dueDate.day);
        final start = DateTime(startDate.year, startDate.month, startDate.day);
        final end = DateTime(endDate.year, endDate.month, endDate.day);

        return (taskDate.isAtSameMomentAs(start) || taskDate.isAfter(start)) &&
            (taskDate.isAtSameMomentAs(end) || taskDate.isBefore(end));
      }).toList();
    }

    // Priority filter
    if (_activeFilters['priorities'] != null &&
        (_activeFilters['priorities'] as List).isNotEmpty) {
      final priorities = _activeFilters['priorities'] as List<String>;
      filtered = filtered.where((task) {
        return priorities.contains(task['priority']);
      }).toList();
    }

    // Category filter
    if (_activeFilters['categories'] != null &&
        (_activeFilters['categories'] as List).isNotEmpty) {
      final categories = _activeFilters['categories'] as List<String>;
      filtered = filtered.where((task) {
        return categories.contains(task['category']);
      }).toList();
    }

    // Status filter
    if (_activeFilters['status'] != null && _activeFilters['status'] != 'All') {
      final status = _activeFilters['status'] as String;
      filtered = filtered.where((task) {
        switch (status) {
          case 'Completed':
            return task['isCompleted'] == true;
          case 'Pending':
            return task['isCompleted'] == false &&
                (task['dueDate'] as DateTime?)?.isAfter(DateTime.now()) == true;
          case 'Overdue':
            return task['isCompleted'] == false &&
                (task['dueDate'] as DateTime?)?.isBefore(DateTime.now()) ==
                    true;
          default:
            return true;
        }
      }).toList();
    }

    return filtered;
  }

  List<Map<String, dynamic>> _applySorting(List<Map<String, dynamic>> tasks) {
    List<Map<String, dynamic>> sorted = List.from(tasks);

    switch (_sortBy) {
      case 'relevance':
        sorted.sort((a, b) {
          final scoreA = a['relevanceScore'] as double? ?? 0.0;
          final scoreB = b['relevanceScore'] as double? ?? 0.0;
          return scoreB.compareTo(scoreA);
        });
        break;
      case 'dueDate':
        sorted.sort((a, b) {
          final dateA = a['dueDate'] as DateTime?;
          final dateB = b['dueDate'] as DateTime?;
          if (dateA == null && dateB == null) return 0;
          if (dateA == null) return 1;
          if (dateB == null) return -1;
          return dateA.compareTo(dateB);
        });
        break;
      case 'priority':
        final priorityOrder = {'High': 0, 'Medium': 1, 'Low': 2};
        sorted.sort((a, b) {
          final priorityA = priorityOrder[a['priority']] ?? 3;
          final priorityB = priorityOrder[b['priority']] ?? 3;
          return priorityA.compareTo(priorityB);
        });
        break;
      case 'modified':
        sorted.sort((a, b) {
          final dateA = a['modifiedAt'] as DateTime;
          final dateB = b['modifiedAt'] as DateTime;
          return dateB.compareTo(dateA);
        });
        break;
    }

    return sorted;
  }

  void _onVoiceSearch() {
    setState(() {
      _isVoiceSearching = true;
    });

    // Simulate voice search processing
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _isVoiceSearching = false;
          _searchController.text = 'meeting preparation';
          _searchQuery = 'meeting preparation';
        });
        _performSearch();
      }
    });
  }

  void _onFiltersChanged(Map<String, dynamic> filters) {
    setState(() {
      _activeFilters = Map.from(filters);
    });
    _performSearch();
  }

  void _onRemoveFilter(String filterKey) {
    setState(() {
      _activeFilters.remove(filterKey);
    });
    _performSearch();
  }

  void _onClearAllFilters() {
    setState(() {
      _activeFilters.clear();
    });
    _performSearch();
  }

  void _onRecentSearchTap(String search) {
    _searchController.text = search;
    setState(() {
      _searchQuery = search;
    });
    _performSearch();
  }

  void _onRemoveRecentSearch(String search) {
    setState(() {
      _recentSearches.remove(search);
    });
  }

  void _onSortChanged(String sortBy) {
    setState(() {
      _sortBy = sortBy;
    });
    _performSearch();
  }

  void _onTaskTap(Map<String, dynamic> task) {
    Navigator.pushNamed(context, '/add-edit-task', arguments: task);
  }

  void _onToggleAdvancedFilter() {
    setState(() {
      _isAdvancedFilterExpanded = !_isAdvancedFilterExpanded;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Search & Filter'),
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
            onPressed: () =>
                Navigator.pushNamed(context, '/main-task-dashboard'),
            icon: CustomIconWidget(
              iconName: 'home',
              color: AppTheme.lightTheme.colorScheme.onSurface,
              size: 24,
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          SearchBarWidget(
            searchController: _searchController,
            onSearchChanged: (query) {
              // Handled by controller listener
            },
            onVoiceSearch: _onVoiceSearch,
            isVoiceSearching: _isVoiceSearching,
          ),

          // Filter Chips
          FilterChipsWidget(
            activeFilters: _activeFilters,
            onRemoveFilter: _onRemoveFilter,
            onClearAll: _onClearAllFilters,
          ),

          // Advanced Filters
          AdvancedFilterWidget(
            currentFilters: _activeFilters,
            onFiltersChanged: _onFiltersChanged,
            isExpanded: _isAdvancedFilterExpanded,
            onToggleExpanded: _onToggleAdvancedFilter,
          ),

          SizedBox(height: 2.h),

          // Content Area
          Expanded(
            child: _searchQuery.isEmpty && _activeFilters.isEmpty
                ? RecentSearchesWidget(
                    recentSearches: _recentSearches,
                    onSearchTap: _onRecentSearchTap,
                    onRemoveSearch: _onRemoveRecentSearch,
                  )
                : SearchResultsWidget(
                    searchResults: _searchResults,
                    searchQuery: _searchQuery,
                    sortBy: _sortBy,
                    onSortChanged: _onSortChanged,
                    onTaskTap: _onTaskTap,
                  ),
          ),
        ],
      ),
    );
  }
}
