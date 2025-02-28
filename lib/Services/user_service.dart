import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class UserService {
  static const String baseUrl = 'http://localhost:3000';

  /// ✅ **Fetch User Profile**
  static Future<Map<String, dynamic>?> fetchUserProfile() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString("userId");

    if (userId == null) {
      print("❌ Error: No user ID found in storage.");
      return null;
    }

    try {
      final response = await http.get(
        Uri.parse("$baseUrl/users/$userId"),
        headers: {"Content-Type": "application/json"},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print("✅ User profile fetched successfully: $data");
        return data;
      } else {
        print("❌ Failed to fetch user profile. Response: ${response.body}");
        return null;
      }
    } catch (e) {
      print("❌ Error fetching user profile: $e");
      return null;
    }
  }

  /// ✅ **Update User Details (e.g., Name, Phone)**
  static Future<bool> updateUserDetails(Map<String, String> updatedData) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString("userId");

    if (userId == null) {
      print("❌ Error: No user ID found in storage.");
      return false;
    }

    try {
      final response = await http.put(
        Uri.parse("$baseUrl/users/$userId"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(updatedData),
      );

      if (response.statusCode == 200) {
        print("✅ User details updated successfully.");
        return true;
      } else {
        print("❌ Failed to update user details. Response: ${response.body}");
        return false;
      }
    } catch (e) {
      print("❌ Error updating user details: $e");
      return false;
    }
  }

  /// ✅ **Delete User Account**
  static Future<bool> deleteUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString("userId");

    if (userId == null) {
      print("❌ Error: User ID not found.");
      return false;
    }

    try {
      final response = await http.delete(
        Uri.parse("$baseUrl/users/$userId"),
        headers: {"Content-Type": "application/json"},
      );

      if (response.statusCode == 200) {
        print("✅ User deleted successfully. Clearing stored data...");
        await prefs.clear(); // ✅ Clear local storage after deletion
        return true;
      } else {
        print("❌ Failed to delete user: ${response.body}");
        return false;
      }
    } catch (e) {
      print("❌ Error deleting user: $e");
      return false;
    }
  }
}
