import 'dart:convert';
import 'package:adventura/Services/storage_service.dart';
import 'package:flutter/material.dart';
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
  static Future<bool> deleteUser(BuildContext context) async {
    try {
      final String? accessToken = await StorageService.getAccessToken();
      final String? userId = await StorageService.getUserId();

      if (accessToken == null || userId == null) {
        print("❌ No user ID or token found!");
        return false;
      }

      final response = await http.delete(
        Uri.parse('$baseUrl/users/delete-account/$userId'),
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        print("✅ Account deleted successfully");

        // Preserve onboarding status
        SharedPreferences prefs = await SharedPreferences.getInstance();
        bool hasSeenOnboarding = prefs.getBool("hasSeenOnboarding") ?? false;

        // ✅ ONLY remove user data (DO NOT clear onboarding flag)
        await prefs.remove("accessToken");
        await prefs.remove("refreshToken");
        await prefs.remove("userId");

        await prefs.setBool("hasSeenOnboarding", hasSeenOnboarding);

        await StorageService.logout(context); // Clear storage after deletion
        return true;
      } else {
        print("❌ Failed to delete account: ${response.body}");
        return false;
      }
    } catch (e) {
      print("❌ Error deleting account: $e");
      return false;
    }
  }
}
