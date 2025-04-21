import 'package:adventura/config.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class InteractionService {
  static Future<void> logInteraction({
    required int userId,
    required int activityId,
    required String type,
    int? rating,
  }) async {
    final url = Uri.parse('$baseUrl/api/interactions');

    final body = {
      "user_id": userId,
      "activity_id": activityId,
      "interaction_type": type,
      if (rating != null) "rating": rating,
    };

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(body),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      print("🟢 Interaction ($type) logged");
    } else {
      print("❌ Failed to log $type interaction: ${response.body}");
    }
  }
}