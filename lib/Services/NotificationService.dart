import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:adventura/config.dart';

class NotificationService {
  static Future<List<Map<String, dynamic>>>
      fetchUniversalNotifications() async {
    final response =
        await http.get(Uri.parse('$baseUrl/universal-notifications'));
    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(json.decode(response.body));
    } else {
      throw Exception('Failed to fetch universal notifications');
    }
  }

  static Future<List<Map<String, dynamic>>> fetchNotifications(
      String userId) async {
    final response =
        await http.get(Uri.parse('$baseUrl/notifications/$userId'));

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.cast<Map<String, dynamic>>();
    } else {
      throw Exception("Failed to fetch notifications");
    }
  }
}
