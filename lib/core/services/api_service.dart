import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../data/models/goal.dart';
import '../../data/models/task_item.dart';
import '../../data/models/daily_reflection.dart';
import '../../data/models/user_profile.dart';

/// Contract for future Laravel API backend integration.
/// When switching from local storage to Laravel, this client will communicate
/// directly with Laravel's REST API endpoints with Sanctum / Passport auth token.
abstract class IApiService {
  Future<List<Goal>> getGoals();
  Future<Goal> createGoal(Goal goal);
  Future<Goal> updateGoal(Goal goal);
  Future<void> deleteGoal(String id);

  Future<List<TaskItem>> getTasks();
  Future<TaskItem> updateTask(TaskItem task);
  Future<TaskItem> createTask(TaskItem task);

  Future<void> submitReflection(DailyReflection reflection);
  Future<UserProfile> getUserProfile();
  Future<UserProfile> updateUserProfile(UserProfile profile);
}

/// Ready-to-connect Laravel API Client implementation
class LaravelApiClient implements IApiService {
  final String baseUrl;
  final String? authToken;
  final http.Client client;

  LaravelApiClient({
    this.baseUrl = 'https://api.onegoal.app/api/v1',
    this.authToken,
    http.Client? client,
  }) : client = client ?? http.Client();

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        if (authToken != null) 'Authorization': 'Bearer $authToken',
      };

  @override
  Future<List<Goal>> getGoals() async {
    final response = await client.get(
      Uri.parse('$baseUrl/goals'),
      headers: _headers,
    );
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body)['data'];
      return data.map((json) => Goal.fromMap(json)).toList();
    }
    throw Exception('Failed to fetch goals from Laravel API: ${response.statusCode}');
  }

  @override
  Future<Goal> createGoal(Goal goal) async {
    final response = await client.post(
      Uri.parse('$baseUrl/goals'),
      headers: _headers,
      body: goal.toJson(),
    );
    if (response.statusCode == 201 || response.statusCode == 200) {
      final dynamic data = json.decode(response.body)['data'];
      return Goal.fromMap(data);
    }
    throw Exception('Failed to create goal: ${response.body}');
  }

  @override
  Future<Goal> updateGoal(Goal goal) async {
    final response = await client.put(
      Uri.parse('$baseUrl/goals/${goal.id}'),
      headers: _headers,
      body: goal.toJson(),
    );
    if (response.statusCode == 200) {
      final dynamic data = json.decode(response.body)['data'];
      return Goal.fromMap(data);
    }
    throw Exception('Failed to update goal: ${response.body}');
  }

  @override
  Future<void> deleteGoal(String id) async {
    final response = await client.delete(
      Uri.parse('$baseUrl/goals/$id'),
      headers: _headers,
    );
    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Failed to delete goal: ${response.body}');
    }
  }

  @override
  Future<List<TaskItem>> getTasks() async {
    final response = await client.get(
      Uri.parse('$baseUrl/tasks'),
      headers: _headers,
    );
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body)['data'];
      return data.map((json) => TaskItem.fromMap(json)).toList();
    }
    throw Exception('Failed to fetch tasks: ${response.statusCode}');
  }

  @override
  Future<TaskItem> createTask(TaskItem task) async {
    final response = await client.post(
      Uri.parse('$baseUrl/tasks'),
      headers: _headers,
      body: task.toJson(),
    );
    if (response.statusCode == 201 || response.statusCode == 200) {
      final dynamic data = json.decode(response.body)['data'];
      return TaskItem.fromMap(data);
    }
    throw Exception('Failed to create task: ${response.body}');
  }

  @override
  Future<TaskItem> updateTask(TaskItem task) async {
    final response = await client.put(
      Uri.parse('$baseUrl/tasks/${task.id}'),
      headers: _headers,
      body: task.toJson(),
    );
    if (response.statusCode == 200) {
      final dynamic data = json.decode(response.body)['data'];
      return TaskItem.fromMap(data);
    }
    throw Exception('Failed to update task: ${response.body}');
  }

  @override
  Future<void> submitReflection(DailyReflection reflection) async {
    final response = await client.post(
      Uri.parse('$baseUrl/reflections'),
      headers: _headers,
      body: reflection.toJson(),
    );
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Failed to submit reflection: ${response.body}');
    }
  }

  @override
  Future<UserProfile> getUserProfile() async {
    final response = await client.get(
      Uri.parse('$baseUrl/user/profile'),
      headers: _headers,
    );
    if (response.statusCode == 200) {
      final dynamic data = json.decode(response.body)['data'];
      return UserProfile.fromMap(data);
    }
    throw Exception('Failed to get user profile: ${response.statusCode}');
  }

  @override
  Future<UserProfile> updateUserProfile(UserProfile profile) async {
    final response = await client.put(
      Uri.parse('$baseUrl/user/profile'),
      headers: _headers,
      body: profile.toJson(),
    );
    if (response.statusCode == 200) {
      final dynamic data = json.decode(response.body)['data'];
      return UserProfile.fromMap(data);
    }
    throw Exception('Failed to update user profile: ${response.body}');
  }
}
