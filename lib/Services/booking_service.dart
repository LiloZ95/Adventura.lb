import 'dart:convert';
import 'package:adventura/config.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;

class BookingService {
  static Future<bool> createBooking({
    required int activityId,
  required String date,
  required String slot,
  required double totalPrice,
  required int userId,         // 🔄 Now required
  int? providerId,
}) async {
  final url = Uri.parse("$baseUrl/booking/create");

  final body = jsonEncode({
    "activity_id": activityId,
    "booking_date": date,
    "slot": slot,
    "total_price": totalPrice,
    "user_id": userId,          // ✅ send user_id instead of client_id
    if (providerId != null) "provider_id": providerId,
  });

  print("📤 Sending booking: $body");

  final response = await http.post(
    url,
    headers: {"Content-Type": "application/json"},
    body: body,
  );

  print("📥 Status: ${response.statusCode}");
  print("📥 Response: ${response.body}");

    if (response.statusCode == 201) {
      return true;
    } else {
      return false;
    }
  }

  static Future<List<Map<String, dynamic>>> getUserBookings(
      int clientId) async {
    final url = Uri.parse('$baseUrl/booking/user/$clientId');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        return List<Map<String, dynamic>>.from(json);
      } else {
        print("❌ Error fetching bookings: ${response.body}");
      }
    } catch (e) {
      print("❌ Exception fetching bookings: $e");
    }
    return [];
  }

  static Future<List<Map<String, dynamic>>> getProviderBookings(
      int userId) async {
    Uri url = Uri.parse('$baseUrl/booking/by-provider/$userId');
    Box box = await Hive.openBox("authBox");
    final token = box.get("accessToken");

    final response = await http.get(url, headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    });

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      if (body["success"]) {
        return List<Map<String, dynamic>>.from(body["bookings"]);
      }
    } else {
      print(
          "❌ Failed to fetch provider bookings. Status: ${response.statusCode}");
      print("❌ Response: ${response.body}");
    }
    return [];
  }

  static Future<List<Map<String, dynamic>>> fetchBookings(
      int userId, String userType) async {
    try {
      Uri url;
      if (userType == "provider") {
        url = Uri.parse('$baseUrl/booking/by-provider/$userId');
      } else {
        url = Uri.parse('$baseUrl/booking/user/$userId');
      }

      Box box = await Hive.openBox("authBox");
      final token = box.get("accessToken");

      final response = await http.get(url, headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      });

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        if (decoded is List) {
          return List<Map<String, dynamic>>.from(decoded);
        } else {
          print("❌ Unexpected response type: ${decoded.runtimeType}");
        }
      } else {
        print("❌ Failed to fetch bookings. Status: ${response.statusCode}");
      }
    } catch (e) {
      print("❌ Error fetching bookings: $e");
    }

    return [];
  }
}
