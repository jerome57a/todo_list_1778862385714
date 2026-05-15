import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class TaskStorageService {
  static const String _tasksKey = 'tasks_data';
  static TaskStorageService? _instance;

  TaskStorageService._();

  static TaskStorageService get instance {
    _instance ??= TaskStorageService._();
    return _instance!;
  }

  /// Load all tasks from local storage
  Future<List<Map<String, dynamic>>> loadTasks() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_tasksKey);
      if (jsonString == null || jsonString.isEmpty) {
        return _getDefaultTasks();
      }
      final List<dynamic> decoded = jsonDecode(jsonString);
      return decoded
          .map((item) => _deserializeTask(item as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return _getDefaultTasks();
    }
  }

  /// Save all tasks to local storage
  Future<void> saveTasks(List<Map<String, dynamic>> tasks) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final serialized = tasks.map((t) => _serializeTask(t)).toList();
      await prefs.setString(_tasksKey, jsonEncode(serialized));
    } catch (_) {}
  }

  /// Add a single task
  Future<List<Map<String, dynamic>>> addTask(
      List<Map<String, dynamic>> current, Map<String, dynamic> task) async {
    final updated = List<Map<String, dynamic>>.from(current)..add(task);
    await saveTasks(updated);
    return updated;
  }

  /// Update a single task by id
  Future<List<Map<String, dynamic>>> updateTask(
      List<Map<String, dynamic>> current, Map<String, dynamic> task) async {
    final updated = current.map((t) {
      if (t['id'].toString() == task['id'].toString()) return task;
      return t;
    }).toList();
    await saveTasks(updated);
    return updated;
  }

  /// Delete a task by id
  Future<List<Map<String, dynamic>>> deleteTask(
      List<Map<String, dynamic>> current, dynamic taskId) async {
    final updated =
        current.where((t) => t['id'].toString() != taskId.toString()).toList();
    await saveTasks(updated);
    return updated;
  }

  /// Toggle task completion
  Future<List<Map<String, dynamic>>> toggleCompletion(
      List<Map<String, dynamic>> current, dynamic taskId) async {
    final updated = current.map((t) {
      if (t['id'].toString() == taskId.toString()) {
        return {...t, 'isCompleted': !(t['isCompleted'] as bool? ?? false)};
      }
      return t;
    }).toList();
    await saveTasks(updated);
    return updated;
  }

  /// Serialize a task map to JSON-safe format
  Map<String, dynamic> _serializeTask(Map<String, dynamic> task) {
    final result = Map<String, dynamic>.from(task);
    if (result['dueDate'] is DateTime) {
      result['dueDate'] = (result['dueDate'] as DateTime).toIso8601String();
    }
    if (result['createdAt'] is DateTime) {
      result['createdAt'] = (result['createdAt'] as DateTime).toIso8601String();
    }
    if (result['date'] is DateTime) {
      result['date'] = (result['date'] as DateTime).toIso8601String();
    }
    return result;
  }

  /// Deserialize a task map from JSON
  Map<String, dynamic> _deserializeTask(Map<String, dynamic> task) {
    final result = Map<String, dynamic>.from(task);
    if (result['dueDate'] is String) {
      result['dueDate'] = DateTime.tryParse(result['dueDate'] as String);
    }
    if (result['createdAt'] is String) {
      result['createdAt'] = DateTime.tryParse(result['createdAt'] as String);
    }
    if (result['date'] is String) {
      result['date'] = DateTime.tryParse(result['date'] as String);
    }
    return result;
  }

  /// Default seed tasks (shown on first launch only)
  List<Map<String, dynamic>> _getDefaultTasks() {
    final now = DateTime.now();
    return [
      {
        "id": 1,
        "title": "Review quarterly reports",
        "description":
            "Analyze Q3 performance metrics and prepare summary for board meeting",
        "priority": "high",
        "category": "work",
        "dueDate": now.add(const Duration(hours: 2)),
        "createdAt": now.subtract(const Duration(days: 1)),
        "isCompleted": false,
      },
      {
        "id": 2,
        "title": "Team standup meeting",
        "description": "Daily sync with development team",
        "priority": "medium",
        "category": "work",
        "dueDate": now.add(const Duration(hours: 1)),
        "createdAt": now.subtract(const Duration(days: 1)),
        "isCompleted": false,
      },
      {
        "id": 3,
        "title": "Grocery shopping",
        "description": "Buy ingredients for weekend dinner party",
        "priority": "low",
        "category": "shopping",
        "dueDate": now.add(const Duration(hours: 4)),
        "createdAt": now.subtract(const Duration(days: 2)),
        "isCompleted": false,
      },
      {
        "id": 4,
        "title": "Submit expense report",
        "description": "Upload receipts and submit monthly expenses",
        "priority": "high",
        "category": "work",
        "dueDate": now.subtract(const Duration(days: 1)),
        "createdAt": now.subtract(const Duration(days: 3)),
        "isCompleted": false,
      },
      {
        "id": 5,
        "title": "Call dentist",
        "description": "Schedule routine cleaning appointment",
        "priority": "medium",
        "category": "personal",
        "dueDate": now.add(const Duration(days: 2)),
        "createdAt": now.subtract(const Duration(days: 1)),
        "isCompleted": false,
      },
      {
        "id": 6,
        "title": "Finish project proposal",
        "description": "Complete the client presentation slides",
        "priority": "high",
        "category": "work",
        "dueDate": now.add(const Duration(days: 1)),
        "createdAt": now.subtract(const Duration(days: 4)),
        "isCompleted": true,
      },
      {
        "id": 7,
        "title": "Morning workout",
        "description": "30-minute cardio session at the gym",
        "priority": "medium",
        "category": "health",
        "dueDate": now.subtract(const Duration(hours: 2)),
        "createdAt": now.subtract(const Duration(days: 1)),
        "isCompleted": true,
      },
    ];
  }
}
