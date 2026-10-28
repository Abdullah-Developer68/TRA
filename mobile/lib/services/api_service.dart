import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/multi_agent_turn.dart';

class ApiService {
  // Use localhost for Linux/Desktop/Web; 10.0.2.2 for Android emulator
  static const String baseUrl = 'http://localhost:5000/api';

  Future<MultiAgentTurn> sendPrompt({
    required String prompt,
    String? threadId,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/multi-agent'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'prompt': prompt,
        if (threadId != null) 'threadId': threadId,
      }),
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return MultiAgentTurn.fromJson(data);
    } else {
      final errorBody = jsonDecode(response.body) as Map<String, dynamic>;
      throw Exception(errorBody['error'] ?? 'Failed to execute multi-agent deliberation');
    }
  }

  Future<List<ThreadSummary>> fetchThreads() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/threads'));
      if (response.statusCode == 200) {
        final List<dynamic> list = jsonDecode(response.body);
        return list.map((e) => ThreadSummary.fromJson(e)).toList();
      }
    } catch (_) {}
    return [];
  }

  Future<List<MultiAgentTurn>> fetchThreadMessages(String threadId) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/threads/$threadId/messages'));
      if (response.statusCode == 200) {
        final List<dynamic> list = jsonDecode(response.body);
        return list.map((e) => MultiAgentTurn.fromJson(e)).toList();
      }
    } catch (_) {}
    return [];
  }

  Future<ThreadSummary> createThread({String? title}) async {
    final response = await http.post(
      Uri.parse('$baseUrl/threads'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'title': title ?? 'New Multi-Agent Session'}),
    );
    if (response.statusCode == 200) {
      return ThreadSummary.fromJson(jsonDecode(response.body));
    }
    throw Exception('Failed to create session');
  }
}
