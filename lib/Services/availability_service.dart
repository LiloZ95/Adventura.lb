import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config.dart';
import 'storage_service.dart';

class AvailabilityService {
  static Future<List<String>> fetchAvailableSlots(int activityId, String date) async {
    final url = Uri.parse('$baseUrl/availability?activityId=$activityId&date=$date');

    try {
      final response = await http.get(url).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        if (json != null && json is Map<String, dynamic> && json['availableSlots'] != null) {
          return List<String>.from(json['availableSlots']);
        } else {
          print('⚠️ Unexpected API response structure: $json');
        }
      } else {
        print('❌ Failed to fetch slots. Status: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error fetching available slots: $e');
    }

    return [];
  }

  static Future<bool> bookActivity({
    required int activityId,
    required String date,
    required String slot,
  }) async {
    final clientId = await StorageService.getUserId();

    if (clientId.isEmpty) {
      print('❌ Client ID not found in local storage');
      return false;
    }

    final url = Uri.parse('$baseUrl/book');
    final body = jsonEncode({
      "activityId": activityId,
      "clientId": int.parse(clientId),
      "bookingDate": date,
      "slot": slot,
    });

    try {
      final response = await http
          .post(
            url,
            headers: {'Content-Type': 'application/json'},
            body: body,
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        print('✅ Booking successful');
        return true;
      } else {
        print('❌ Booking failed: ${response.statusCode} -> ${response.body}');
        return false;
      }
    } catch (e) {
      print('❌ Exception during booking: $e');
      return false;
    }
  }
}
