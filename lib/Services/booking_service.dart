import 'dart:convert';
import 'package:adventura/config.dart';
import 'package:http/http.dart' as http;

class BookingService {
  static Future<bool> createBooking({
    required int activityId,
    required int clientId,
    required String date,
    required String slot,
    required double totalPrice,
  }) async {
    final url = Uri.parse("$baseUrl/booking/create");

    final body = jsonEncode({
      "activity_id": activityId,
      "client_id": clientId,
      "booking_date": date,
      "slot": slot,
      "total_price": totalPrice,
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
}
