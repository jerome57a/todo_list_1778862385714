import 'package:flutter/material.dart';
import '../presentation/analytics_dashboard/analytics_dashboard.dart';
import '../presentation/splash_screen/splash_screen.dart';
import '../presentation/search_and_filter/search_and_filter.dart';
import '../presentation/settings_and_preferences/settings_and_preferences.dart';
import '../presentation/task_list_view/task_list_view.dart';
import '../presentation/calendar_view/calendar_view.dart';
import '../presentation/main_task_dashboard/main_task_dashboard.dart';
import '../presentation/add_edit_task/add_edit_task.dart';

class AppRoutes {
  // TODO: Add your routes here
  static const String initial = '/';
  static const String analyticsDashboard = '/analytics-dashboard';
  static const String splash = '/splash-screen';
  static const String searchAndFilter = '/search-and-filter';
  static const String settingsAndPreferences = '/settings-and-preferences';
  static const String taskListView = '/task-list-view';
  static const String calendarView = '/calendar-view';
  static const String mainTaskDashboard = '/main-task-dashboard';
  static const String addEditTask = '/add-edit-task';

  static Map<String, WidgetBuilder> routes = {
    initial: (context) => const SplashScreen(),
    analyticsDashboard: (context) => const AnalyticsDashboard(),
    splash: (context) => const SplashScreen(),
    searchAndFilter: (context) => const SearchAndFilter(),
    settingsAndPreferences: (context) => const SettingsAndPreferences(),
    taskListView: (context) => const TaskListView(),
    calendarView: (context) => const CalendarView(),
    mainTaskDashboard: (context) => const MainTaskDashboard(),
    addEditTask: (context) => const AddEditTask(),
    // TODO: Add your other routes here
  };
}
