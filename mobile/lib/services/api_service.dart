import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../models/multi_agent_turn.dart';

class UserAccount {
  final String id;
  final String email;
  final String fullName;
  final String? token;

  UserAccount({
    required this.id,
    required this.email,
    required this.fullName,
    this.token,
  });

  factory UserAccount.fromJson(Map<String, dynamic> json, {String? token}) {
    return UserAccount(
      id: json['id']?.toString() ?? '',
      email: json['email'] as String? ?? '',
      fullName: json['fullName'] as String? ?? json['name'] as String? ?? '',
      token: token ?? json['token'] as String?,
    );
  }
}

class ApiService {
  static String? activeToken;
  static UserAccount? currentUser;

  /// Base API URL.
  /// - Priority: `--dart-define=API_URL=http://...`
  /// - Android default: `127.0.0.1:5000/api` (relies on `adb reverse tcp:5000 tcp:5000` which works on physical USB devices),
  ///   falling back to `10.0.2.2:5000/api` only if emulator.
  static String get baseUrl {
    const fromEnv = String.fromEnvironment('API_URL');
    if (fromEnv.isNotEmpty) return fromEnv;
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      return 'http://127.0.0.1:5000/api';
    }
    return 'http://localhost:5000/api';
  }

  Map<String, String> get _headers {
    final headers = {'Content-Type': 'application/json'};
    if (activeToken != null) {
      headers['Authorization'] = 'Bearer $activeToken';
    }
    return headers;
  }

  Future<UserAccount> signup({
    required String email,
    required String password,
    required String fullName,
  }) async {
    final response = await http
        .post(
          Uri.parse('$baseUrl/auth/signup'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'email': email.trim().toLowerCase(),
            'password': password,
            'fullName': fullName.trim(),
          }),
        )
        .timeout(const Duration(seconds: 15));

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    if (response.statusCode == 201 || response.statusCode == 200) {
      final token = data['token'] as String?;
      activeToken = token;
      final userMap = data['user'] as Map<String, dynamic>;
      final user = UserAccount.fromJson(userMap, token: token);
      currentUser = user;
      return user;
    }
    throw Exception(data['error'] ?? 'Signup failed');
  }

  Future<UserAccount> login({
    required String email,
    required String password,
  }) async {
    final response = await http
        .post(
          Uri.parse('$baseUrl/auth/login'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'email': email.trim().toLowerCase(),
            'password': password,
          }),
        )
        .timeout(const Duration(seconds: 15));

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    if (response.statusCode == 200) {
      final token = data['token'] as String?;
      activeToken = token;
      final userMap = data['user'] as Map<String, dynamic>;
      final user = UserAccount.fromJson(userMap, token: token);
      currentUser = user;
      return user;
    }
    throw Exception(data['error'] ?? 'Invalid email or password');
  }

  Future<void> logout() async {
    try {
      await http
          .post(
            Uri.parse('$baseUrl/auth/logout'),
            headers: _headers,
          )
          .timeout(const Duration(seconds: 5));
    } catch (_) {}
    activeToken = null;
    currentUser = null;
  }

  Future<MultiAgentTurn> sendPrompt({
    required String prompt,
    String? threadId,
  }) async {
    final response = await http
        .post(
          Uri.parse('$baseUrl/multi-agent'),
          headers: _headers,
          body: jsonEncode({'prompt': prompt, 'threadId': threadId}),
        )
        .timeout(const Duration(seconds: 45));

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return MultiAgentTurn.fromJson(data);
    } else {
      final errorBody = jsonDecode(response.body) as Map<String, dynamic>;
      throw Exception(
        errorBody['error'] ?? 'Failed to execute multi-agent deliberation',
      );
    }
  }

  Future<List<ThreadSummary>> fetchThreads() async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/threads'), headers: _headers)
          .timeout(const Duration(seconds: 8));
      if (response.statusCode == 200) {
        final List<dynamic> list = jsonDecode(response.body);
        return list.map((e) => ThreadSummary.fromJson(e)).toList();
      }
    } catch (_) {}
    return [];
  }

  Future<List<MultiAgentTurn>> fetchThreadMessages(String threadId) async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/threads/$threadId/messages'), headers: _headers)
          .timeout(const Duration(seconds: 8));
      if (response.statusCode == 200) {
        final List<dynamic> list = jsonDecode(response.body);
        return list.map((e) => MultiAgentTurn.fromJson(e)).toList();
      }
    } catch (_) {}
    return [];
  }

  Future<ThreadSummary> createThread({String? title}) async {
    final response = await http
        .post(
          Uri.parse('$baseUrl/threads'),
          headers: _headers,
          body: jsonEncode({'title': title ?? 'New Session'}),
        )
        .timeout(const Duration(seconds: 8));
    if (response.statusCode == 200) {
      return ThreadSummary.fromJson(jsonDecode(response.body));
    }
    throw Exception('Failed to create session');
  }
}
