import 'dart:convert';
import 'package:adventura/Services/storage_service.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:hive/hive.dart';
import 'package:adventura/config.dart'; // ✅ Import the global config file

class UserService {

  /// ✅ **Fetch User Profile**
  static Future<Map<String, dynamic>?> fetchUserProfile() async {               
    Box storageBox = await Hive.openBox('authBox');
    String? userId = storageBox.get("userId");

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

        // ✅ Store user data in Hive
        storageBox.put("userProfile", data);
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
    Box storageBox = await Hive.openBox('authBox');
    String? userId = storageBox.get("userId");

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

        // ✅ Update user data in Hive
        storageBox.put("userProfile", updatedData);
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
      Box storageBox = await Hive.openBox('authBox');
      String? accessToken = storageBox.get("accessToken");
      String? userId = storageBox.get("userId");

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

        // ✅ Remove user data but preserve onboarding flag
        bool hasSeenOnboarding = storageBox.get("hasSeenOnboarding") ?? false;
        storageBox.clear();
        storageBox.put("hasSeenOnboarding", hasSeenOnboarding);

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
