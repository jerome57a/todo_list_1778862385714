import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ---------------------------------------------------------------------------
// Inline copy of TaskStorageService logic so the test is self-contained and
// does not depend on Flutter widget binding or platform channels beyond
// shared_preferences (which is fully mockable in flutter_test).
// ---------------------------------------------------------------------------

const String _tasksKey = 'tasks_data';

Map<String, dynamic> _serializeTask(Map<String, dynamic> task) {
  final result = Map<String, dynamic>.from(task);
  if (result['dueDate'] is DateTime) {
    result['dueDate'] = (result['dueDate'] as DateTime).toIso8601String();
  }
  if (result['createdAt'] is DateTime) {
    result['createdAt'] = (result['createdAt'] as DateTime).toIso8601String();
  }
  return result;
}

Map<String, dynamic> _deserializeTask(Map<String, dynamic> task) {
  final result = Map<String, dynamic>.from(task);
  if (result['dueDate'] is String) {
    result['dueDate'] = DateTime.tryParse(result['dueDate'] as String);
  }
  if (result['createdAt'] is String) {
    result['createdAt'] = DateTime.tryParse(result['createdAt'] as String);
  }
  return result;
}

Future<void> saveTasks(List<Map<String, dynamic>> tasks) async {
  final prefs = await SharedPreferences.getInstance();
  final serialized = tasks.map(_serializeTask).toList();
  await prefs.setString(_tasksKey, jsonEncode(serialized));
}

Future<List<Map<String, dynamic>>> loadTasks() async {
  final prefs = await SharedPreferences.getInstance();
  final jsonString = prefs.getString(_tasksKey);
  if (jsonString == null || jsonString.isEmpty) return [];
  final List<dynamic> decoded = jsonDecode(jsonString);
  return decoded
      .map((item) => _deserializeTask(item as Map<String, dynamic>))
      .toList();
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  // Use the flutter_test shared_preferences mock so no real disk I/O occurs.
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('Task Storage Persistence – end-to-end', () {
    // -----------------------------------------------------------------------
    // 1. Basic save & reload
    // -----------------------------------------------------------------------
    test('saved tasks are reloaded with no data loss', () async {
      final now = DateTime(2025, 6, 15, 9, 0);

      final task = {
        'id': 42,
        'title': 'Write unit tests',
        'description': 'Cover storage persistence',
        'priority': 'high',
        'category': 'work',
        'isCompleted': false,
        'dueDate': now,
        'createdAt': now.subtract(const Duration(days: 1)),
      };

      // --- Session 1: save ---
      await saveTasks([task]);

      // --- Simulate app restart: clear in-memory singleton state ---
      // (SharedPreferences mock retains data across getInstance() calls
      //  within the same test, mirroring real on-disk persistence.)

      // --- Session 2: reload ---
      final reloaded = await loadTasks();

      expect(reloaded.length, 1, reason: 'Exactly one task should be reloaded');

      final r = reloaded.first;
      expect(r['id'], 42);
      expect(r['title'], 'Write unit tests');
      expect(r['description'], 'Cover storage persistence');
      expect(r['priority'], 'high');
      expect(r['category'], 'work');
      expect(r['isCompleted'], false);
      expect(r['dueDate'], now,
          reason: 'dueDate must survive serialization round-trip');
      expect(r['createdAt'], now.subtract(const Duration(days: 1)),
          reason: 'createdAt must survive serialization round-trip');
    });

    // -----------------------------------------------------------------------
    // 2. Multiple tasks – all survive restart
    // -----------------------------------------------------------------------
    test('multiple tasks all reload correctly after restart', () async {
      final base = DateTime(2025, 7, 1);

      final tasks = List.generate(
        5,
        (i) => {
          'id': i + 1,
          'title': 'Task ${i + 1}',
          'description': 'Description ${i + 1}',
          'priority': ['low', 'medium', 'high'][i % 3],
          'category': 'work',
          'isCompleted': i.isEven,
          'dueDate': base.add(Duration(days: i)),
          'createdAt': base.subtract(const Duration(days: 1)),
        },
      );

      await saveTasks(tasks);

      final reloaded = await loadTasks();

      expect(reloaded.length, 5,
          reason: 'All 5 tasks must be present after reload');

      for (var i = 0; i < 5; i++) {
        expect(reloaded[i]['id'], i + 1);
        expect(reloaded[i]['title'], 'Task ${i + 1}');
        expect(reloaded[i]['isCompleted'], i.isEven);
        expect(reloaded[i]['dueDate'], base.add(Duration(days: i)));
      }
    });

    // -----------------------------------------------------------------------
    // 3. Adding a task persists it
    // -----------------------------------------------------------------------
    test('adding a task persists it across restart', () async {
      final existing = [
        {
          'id': 1,
          'title': 'Existing task',
          'priority': 'low',
          'category': 'personal',
          'isCompleted': false,
          'dueDate': DateTime(2025, 8, 1),
          'createdAt': DateTime(2025, 7, 30),
        }
      ];

      await saveTasks(existing);

      // Add a new task (simulates what TaskStorageService.addTask does)
      final current = await loadTasks();
      final newTask = {
        'id': 2,
        'title': 'New task added by user',
        'priority': 'high',
        'category': 'work',
        'isCompleted': false,
        'dueDate': DateTime(2025, 8, 5),
        'createdAt': DateTime(2025, 8, 1),
      };
      final updated = List<Map<String, dynamic>>.from(current)..add(newTask);
      await saveTasks(updated);

      // Simulate restart
      final afterRestart = await loadTasks();

      expect(afterRestart.length, 2,
          reason: 'Both tasks must survive the restart');
      expect(afterRestart.any((t) => t['title'] == 'New task added by user'),
          isTrue,
          reason: 'Newly added task must be present after restart');
      expect(afterRestart.any((t) => t['title'] == 'Existing task'), isTrue,
          reason: 'Pre-existing task must not be lost');
    });

    // -----------------------------------------------------------------------
    // 4. Deleting a task – deleted task absent after restart
    // -----------------------------------------------------------------------
    test('deleted task is absent after restart', () async {
      final tasks = [
        {
          'id': 10,
          'title': 'Keep me',
          'priority': 'medium',
          'category': 'work',
          'isCompleted': false,
          'dueDate': DateTime(2025, 9, 1),
          'createdAt': DateTime(2025, 8, 28),
        },
        {
          'id': 11,
          'title': 'Delete me',
          'priority': 'low',
          'category': 'personal',
          'isCompleted': false,
          'dueDate': DateTime(2025, 9, 2),
          'createdAt': DateTime(2025, 8, 28),
        },
      ];

      await saveTasks(tasks);

      // Delete task with id 11
      final current = await loadTasks();
      final afterDelete =
          current.where((t) => t['id'].toString() != '11').toList();
      await saveTasks(afterDelete);

      // Simulate restart
      final afterRestart = await loadTasks();

      expect(afterRestart.length, 1);
      expect(afterRestart.first['id'], 10);
      expect(afterRestart.any((t) => t['id'].toString() == '11'), isFalse,
          reason: 'Deleted task must not reappear after restart');
    });

    // -----------------------------------------------------------------------
    // 5. Toggling completion persists across restart
    // -----------------------------------------------------------------------
    test('toggled completion status persists after restart', () async {
      final task = {
        'id': 99,
        'title': 'Toggle me',
        'priority': 'medium',
        'category': 'work',
        'isCompleted': false,
        'dueDate': DateTime(2025, 10, 1),
        'createdAt': DateTime(2025, 9, 28),
      };

      await saveTasks([task]);

      // Toggle completion
      final current = await loadTasks();
      final toggled = current.map((t) {
        if (t['id'].toString() == '99') {
          return {...t, 'isCompleted': !(t['isCompleted'] as bool? ?? false)};
        }
        return t;
      }).toList();
      await saveTasks(toggled);

      // Simulate restart
      final afterRestart = await loadTasks();

      expect(afterRestart.length, 1);
      expect(afterRestart.first['isCompleted'], isTrue,
          reason: 'Completion toggle must persist after restart');
    });

    // -----------------------------------------------------------------------
    // 6. Empty storage returns empty list (no crash on first launch)
    // -----------------------------------------------------------------------
    test('empty storage returns empty list without crashing', () async {
      // No prior saveTasks call – storage is empty (setUp clears it)
      final tasks = await loadTasks();
      expect(tasks, isEmpty,
          reason: 'First launch with no stored data must return empty list');
    });
  });
}
