import 'dart:convert';
import 'package:frontend/core/constants/constants.dart';
import 'package:frontend/core/constants/utils.dart';
import 'package:frontend/features/home/repository/task_local_repository.dart';
import 'package:frontend/models/task_model.dart';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';

class TaskRemoteRepository {
  final taskLocalRepository = TaskLocalRepository();

  Future<TaskModel> createTask({
    required String title,
    required String description,
    required String hexColor,
    required String token,
    required String uid,
    required DateTime dueAt,
  }) async {
    try {
      final res = await http.post(Uri.parse("${Constants.backendUri}/tasks"),
          headers: {
            'Content-Type': 'application/json',
            'x-auth-token': token,
          },
          body: jsonEncode({
            'title': title,
            'description': description,
            'hexColor': hexColor,
            'dueAt': dueAt.toIso8601String(),
          }));

      if (res.statusCode != 201) {
        print('Error response: ${res.body}');
        throw Exception('Failed to create task');
      }

      final Map<String, dynamic> taskJson = jsonDecode(res.body);
      final taskModel = TaskModel.fromMap(taskJson);

      await taskLocalRepository.insertTask(taskModel);
      return taskModel;
    } catch (e) {
      // fallback: save locally if network fails
      final taskModel = TaskModel(
        id: const Uuid().v6(),
        uid: uid,
        title: title,
        description: description,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        dueAt: dueAt,
        color: hexToRgb(hexColor),
        isSynced: 0,
      );
      await taskLocalRepository.insertTask(taskModel);
      return taskModel;
    }
  }

  Future<List<TaskModel>> getTasks({required String token}) async {
    try {
      final res = await http.get(
        Uri.parse("${Constants.backendUri}/tasks"),
        headers: {
          'Content-Type': 'application/json',
          'x-auth-token': token,
        },
      );

      if (res.statusCode != 200) {
        print('Error response: ${res.body}');
        throw Exception('Failed to fetch tasks');
      }

      final List<dynamic> listOfTasks = jsonDecode(res.body);
      final tasksList =
      listOfTasks.map((e) => TaskModel.fromMap(e)).toList();

      await taskLocalRepository.insertTasks(tasksList);

      return tasksList;
    } catch (e) {
      final tasks = await taskLocalRepository.getTasks();
      if (tasks.isNotEmpty) return tasks;
      rethrow;
    }
  }

  Future<bool> syncTasks({
    required String token,
    required List<TaskModel> tasks,
  }) async {
    try {
      final taskListInMap = tasks.map((task) => task.toMap()).toList();

      final res = await http.post(
        Uri.parse("${Constants.backendUri}/tasks/sync"),
        headers: {
          'Content-Type': 'application/json',
          'x-auth-token': token,
        },
        body: jsonEncode(taskListInMap),
      );

      if (res.statusCode != 201) {
        print('Error response from sync: ${res.body}');
        throw Exception('Failed to sync tasks');
      }

      return true;
    } catch (e) {
      print('Sync failed: $e');
      return false;
    }
  }
}
