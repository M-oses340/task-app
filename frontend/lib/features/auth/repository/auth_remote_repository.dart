import 'dart:convert';
import 'package:frontend/core/services/sp_service.dart';
import 'package:frontend/models/user_model.dart';
import 'package:http/http.dart' as http;
import '../../../core/constants/constants.dart';
import 'auth_local_repository.dart';

class AuthRemoteRepository {
  final spService = SpService();
  final authLocalRepository = AuthLocalRepository();

  dynamic tryDecode(String body) {
    try {
      return jsonDecode(body);
    } catch (_) {
      return null; // fallback for HTML or plain text
    }
  }

  // -------------------- SIGNUP --------------------
  Future<UserModel> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    final res = await http.post(
      Uri.parse('${Constants.backendUri}/auth/signup'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'name': name, 'email': email, 'password': password}),
    );

    print("Signup status: ${res.statusCode}");
    print("Signup response: ${res.body}");

    final json = tryDecode(res.body);
    if (res.statusCode != 201) {
      throw json != null && json['error'] != null
          ? json['error']
          : "Unknown error: ${res.body}";
    }

    if (json == null) throw "Invalid JSON response from server";

    return UserModel.fromMap(json);
  }

  // -------------------- LOGIN --------------------
  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    final res = await http.post(
      Uri.parse('${Constants.backendUri}/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    print("Login status: ${res.statusCode}");
    print("Login response: ${res.body}");

    final json = tryDecode(res.body);
    if (res.statusCode != 200) {
      throw json != null && json['error'] != null
          ? json['error']
          : "Unknown error: ${res.body}";
    }

    if (json == null) throw "Invalid JSON response";

    return UserModel.fromMap(json);
  }

  // -------------------- GET USER DATA --------------------
  Future<UserModel?> getUserData() async {
    try {
      final token = await spService.getToken();
      if (token == null) return null;

      final res = await http.post(
        Uri.parse('${Constants.backendUri}/auth/tokenIsValid'),
        headers: {'Content-Type': 'application/json', 'x-auth-token': token},
      );

      final valid = tryDecode(res.body);
      if (res.statusCode != 200 || valid == false) return null;

      final userRes = await http.get(
        Uri.parse('${Constants.backendUri}/auth'),
        headers: {'Content-Type': 'application/json', 'x-auth-token': token},
      );

      final userJson = tryDecode(userRes.body);
      if (userRes.statusCode != 200 || userJson == null) {
        throw userJson != null && userJson['error'] != null
            ? userJson['error']
            : "Unknown error: ${userRes.body}";
      }

      return UserModel.fromMap(userJson);
    } catch (_) {
      return await authLocalRepository.getUser();
    }
  }
}
