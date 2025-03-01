import 'dart:convert';
import 'package:adventura/login/login.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'auth_service.dart';

class StorageService {
  static const String baseUrl = 'http://localhost:3000';
  static final FlutterSecureStorage storage = FlutterSecureStorage();

  /// ✅ **Save Authentication Tokens**
  static Future<void> saveAuthTokens(String accessToken, String refreshToken) async {
    await storage.write(key: "accessToken", value: accessToken);
    await storage.write(key: "refreshToken", value: refreshToken);
  }

  /// ✅ **Save User Data Securely**
  static Future<void> saveUserData(Map<String, dynamic> user) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    
    // Ensure all fields exist to prevent crashes
    await prefs.setString("userId", user["user_id"]?.toString() ?? "");
    await prefs.setString("firstName", user["first_name"] ?? "");
    await prefs.setString("lastName", user["last_name"] ?? "");
    await prefs.setString("profilePicture", user["profilePicture"] ?? "");

    print("✅ User data saved: ID=${user["user_id"]}, Name=${user["first_name"]} ${user["last_name"]}");
  }

  /// ✅ **Fetch Access Token**
  static Future<String?> getAccessToken() async {
    return await storage.read(key: "accessToken");
  }

  /// ✅ **Make Authenticated API Request**
  static Future<Map<String, dynamic>> makeAuthenticatedRequest(String endpoint) async {
    String? accessToken = await getAccessToken();
    if (accessToken == null) {
      print("❌ No access token found.");
      return {"success": false, "error": "Unauthorized. Please log in again."};
    }

    final response = await http.get(
      Uri.parse('$baseUrl/$endpoint'),
      headers: {
        "Authorization": "Bearer $accessToken",
        "Content-Type": "application/json",
      },
    );

    if (response.statusCode == 401) {
      // Token expired, try refreshing
      bool refreshed = await AuthService.refreshToken();
      if (refreshed) {
        return makeAuthenticatedRequest(endpoint); // Retry request
      } else {
        return {"success": false, "error": "Unauthorized. Please log in again."};
      }
    }

    return jsonDecode(response.body);
  }

  /// ✅ **Check If User Is Logged In**
  static Future<bool> isUserLoggedIn() async {
    String? accessToken = await getAccessToken();
    if (accessToken == null) return false;

    final response = await http.get(
      Uri.parse('$baseUrl/users/dashboard'),
      headers: {'Authorization': 'Bearer $accessToken'},
    );

    if (response.statusCode == 200) {
      print("✅ User is still logged in.");
      return true;
    } else if (response.statusCode == 401) {
      print("🔄 Access token expired, refreshing...");
      return await AuthService.refreshToken(); // Try refreshing token
    } else {
      return false;
    }
  }

  static Future<String> getUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString("userId") ?? "";
  }

  static Future<String> getFirstName() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString("firstName") ?? "";
  }

  static Future<String> getLastName() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString("lastName") ?? "";
  }

  /// ✅ **Logout & Clear Data**
  static Future<void> logout(BuildContext context) async {
    print("🚨 Logging out user...");

    // Clear Secure Storage
    await storage.delete(key: "accessToken");
    await storage.delete(key: "refreshToken");

    // Clear Shared Preferences
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    print("✅ User logged out. All data cleared.");

    // Redirect to login screen
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
      (route) => false,
    );
  }
}
