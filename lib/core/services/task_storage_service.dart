import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TaskStorageService {
  // CHANGE: We updated the key so it ignores the old saved dummy tasks and starts fresh!
  static const String _tasksKey = 'tasks_data_v2'; 
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
      
      // Return empty list if no data exists (no more dummy tasks!)
      if (jsonString == null || jsonString.isEmpty) {
        return []; 
      }
      
      final List<dynamic> decoded = jsonDecode(jsonString);
      return decoded
          .map((item) => _deserializeTask(item as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  /// Save all tasks to local storage
  Future<void> saveTasks(List<Map<String, dynamic>> tasks) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final serialized = tasks.map((t) => _serializeTask(t)).toList();
      await prefs.setString(_tasksKey, jsonEncode(serialized));
    } catch (e) {
      debugPrint("Failed to save tasks: $e");
    }
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
    
    final dateFields = ['dueDate', 'createdAt', 'updatedAt', 'date'];
    for (var field in dateFields) {
      if (result[field] is DateTime) {
        result[field] = (result[field] as DateTime).toIso8601String();
      }
    }
    
    if (result['dueTime'] is TimeOfDay) {
      final time = result['dueTime'] as TimeOfDay;
      result['dueTime'] = '${time.hour}:${time.minute}';
    }
    
    return result;
  }

  /// Deserialize a task map from JSON
  Map<String, dynamic> _deserializeTask(Map<String, dynamic> task) {
    final result = Map<String, dynamic>.from(task);
    
    final dateFields = ['dueDate', 'createdAt', 'updatedAt', 'date'];
    for (var field in dateFields) {
      if (result[field] is String) {
        final parsedDate = DateTime.tryParse(result[field] as String);
        if (parsedDate != null) {
          result[field] = parsedDate;
        }
      }
    }
    
    if (result['dueTime'] is String) {
      final parts = (result['dueTime'] as String).split(':');
      if (parts.length == 2) {
        result['dueTime'] = TimeOfDay(
          hour: int.tryParse(parts[0]) ?? 0,
          minute: int.tryParse(parts[1]) ?? 0,
        );
      }
    }
    
    return result;
  }
}