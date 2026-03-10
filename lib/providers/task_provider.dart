import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/task.dart';

class TaskProvider with ChangeNotifier {
  List<Task> _tasks = [];

  // Dependency Injection from AuthProvider
  final String? authToken;
  final String? userId;

  final String _dbUrl =
      "https://hiretasktodo-default-rtdb.asia-southeast1.firebasedatabase.app";

  TaskProvider(this.authToken, this.userId, this._tasks);

  //  Return a copy of the list and sort active tasks to the top!
  List<Task> get tasks {
    final sortedList = [..._tasks];
    sortedList.sort((a, b) {
      // If 'a' is completed and 'b' is not, push 'a' down the list
      if (a.isCompleted && !b.isCompleted) return 1;
      // If 'a' is active and 'b' is completed, keep 'a' at the top
      if (!a.isCompleted && b.isCompleted) return -1;
      return 0; // Keep their original order otherwise
    });
    return sortedList;
  }

  // GET: View tasks
  Future<void> fetchTasks() async {
    if (userId == null || authToken == null) return;

    final url = Uri.parse('$_dbUrl/tasks/$userId.json?auth=$authToken');

    try {
      final response = await http.get(url);
      if (response.body == 'null') {
        _tasks = [];
        notifyListeners();
        return;
      }

      final extractedData = json.decode(response.body) as Map<String, dynamic>;
      final List<Task> loadedTasks = [];

      extractedData.forEach((taskId, taskData) {
        loadedTasks.add(Task.fromJson(taskData, taskId));
      });

      _tasks = loadedTasks.reversed.toList(); // Show newest tasks first
      notifyListeners();
    } catch (error) {
      rethrow;
    }
  }

  // POST: Add new tasks
  Future<void> addTask(String title) async {
    final url = Uri.parse('$_dbUrl/tasks/$userId.json?auth=$authToken');

    try {
      final response = await http.post(
        url,
        body: json.encode({'title': title, 'isCompleted': false}),
      );

      final newId = json.decode(response.body)['name'];
      final newTask = Task(id: newId, title: title);

      _tasks.insert(0, newTask); // Insert at the top of the list
      notifyListeners();
    } catch (error) {
      rethrow;
    }
  }

  // PATCH: Edit tasks and Mark tasks as completed
  Future<void> updateTask(String id, String newTitle, bool isCompleted) async {
    final taskIndex = _tasks.indexWhere((t) => t.id == id);
    if (taskIndex < 0) return;

    final url = Uri.parse('$_dbUrl/tasks/$userId/$id.json?auth=$authToken');

    // Optimistic updating: Update UI instantly, revert if API fails
    final backupTask = _tasks[taskIndex];
    _tasks[taskIndex] = _tasks[taskIndex].copyWith(
      title: newTitle,
      isCompleted: isCompleted,
    );
    notifyListeners();

    try {
      await http.patch(
        url,
        body: json.encode({'title': newTitle, 'isCompleted': isCompleted}),
      );
    } catch (error) {
      _tasks[taskIndex] = backupTask; // Revert on error
      notifyListeners();
      rethrow;
    }
  }

  // DELETE: Remove tasks
  Future<void> deleteTask(String id) async {
    final taskIndex = _tasks.indexWhere((t) => t.id == id);
    if (taskIndex < 0) return;

    final url = Uri.parse('$_dbUrl/tasks/$userId/$id.json?auth=$authToken');

    final backupTask = _tasks[taskIndex];
    _tasks.removeAt(taskIndex);
    notifyListeners();

    try {
      final response = await http.delete(url);
      if (response.statusCode >= 400) {
        throw Exception('Could not delete task.');
      }
    } catch (error) {
      _tasks.insert(taskIndex, backupTask);
      notifyListeners();
      rethrow;
    }
  }
}
