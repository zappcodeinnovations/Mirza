import 'dart:convert';
import '../core/api_client.dart';
import '../core/api_endpoints.dart';

class ChatService {
  final ApiClient _apiClient = ApiClient();

  // Send message to the chatbot
  Future<String> askChatbot({
    required String question,
    String context = '',
    List<Map<String, dynamic>> history = const [],
  }) async {
    try {
      final body = {
        'question': question,
        'context': context,
        'history': history,
      };

      final response = await _apiClient.post(
        ApiEndpoints.chatbot,
        body: body,
        requireAuth: true,
      );

      if (response.statusCode == 200) {
        try {
          final data = jsonDecode(response.body);
          if (data is Map) {
            // Try extracting the actual message from common keys
            final answer = data['answer'] ?? data['response'] ?? data['reply'] ?? data['message'];
            if (answer != null) {
              return answer.toString();
            }
          }
          // If we can't find a known key, return the raw JSON to show what the backend actually responded with
          return response.body;
        } catch (_) {
          // If it's not valid JSON, just return the raw text
          return response.body;
        }
      }
      return 'Server returned error: ${response.statusCode}\\nBody: ${response.body}';
    } catch (e) {
      return 'Network connection issue: $e';
    }
  }
}
