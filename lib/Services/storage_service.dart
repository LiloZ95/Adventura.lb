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
  static Future<void> saveAuthTokens(
      String accessToken, String refreshToken, String userId) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    await storage.write(key: "accessToken", value: accessToken);
    await storage.write(key: "refreshToken", value: refreshToken);
    await prefs.setString(
        "userId", userId); // ✅ Ensure User ID is stored properly
    await prefs.setBool("isLoggedIn", true); // ✅ Save login status

    print("✅ Tokens & User ID saved: userID=$userId, accessToken=$accessToken");
  }

  /// ✅ **Save User Data Securely**
  static Future<void> saveUserData(
      String userId, String accessToken, String refreshToken) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    print(
        "✅ Storing User Data: ID=$userId, Access Token=$accessToken, Refresh Token=$refreshToken");

    await prefs.setString("userId", userId);
    await prefs.setString("accessToken", accessToken);
    await prefs.setString("refreshToken", refreshToken);
    await prefs.setBool("isLoggedIn", true); // ✅ Ensure login persistence

    // Verify if data is saved correctly
    String? savedUserId = prefs.getString("userId");
    String? savedAccessToken = prefs.getString("accessToken");

    if (savedUserId == null || savedAccessToken == null) {
      print(
          "❌ Failed to save user data! Debug: UserId=$savedUserId, Token=$savedAccessToken");
    } else {
      print("✅ User Data Saved Successfully!");
    }
  }

  /// ✅ **Fetch Access Token**
  static Future<String?> getAccessToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = await storage.read(key: "accessToken") ??
        prefs.getString("accessToken");

    if (token == null) {
      print(
          "❌ No token found in secure storage. Checking SharedPreferences...");
    }

    if (token != null && await isTokenExpired(token)) {
      print("🔄 Token expired, attempting to refresh...");
      bool refreshed = await AuthService.refreshToken();
      if (refreshed) {
        return await storage.read(key: "accessToken"); // Return new token
      } else {
        print("❌ Failed to refresh token.");
        return null;
      }
    }

    return token;
  }

  // ✅ Function to check if token is expired
  static Future<bool> isTokenExpired(String token) async {
    try {
      List<String> parts = token.split('.');
      if (parts.length != 3) return true; // Invalid token

      String payload =
          utf8.decode(base64Url.decode(base64Url.normalize(parts[1])));
      Map<String, dynamic> decodedToken = jsonDecode(payload);

      int exp = decodedToken['exp'] ?? 0;
      int now = DateTime.now().millisecondsSinceEpoch ~/ 1000;

      return now >= exp;
    } catch (e) {
      print("❌ Error checking token expiration: $e");
      return true; // Assume expired if error occurs
    }
  }

  /// ✅ **Make Authenticated API Request**
  static Future<Map<String, dynamic>> makeAuthenticatedRequest(
      String endpoint) async {
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
        return {
          "success": false,
          "error": "Unauthorized. Please log in again."
        };
      }
    }

    return jsonDecode(response.body);
  }

  /// ✅ **Check If User Is Logged In**
  static Future<bool> isUserLoggedIn() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool? isLoggedIn = prefs.getBool("isLoggedIn");

    if (isLoggedIn == null || !isLoggedIn) {
      print("❌ No stored login state found. User is not logged in.");
      return false;
    }

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
    final storage = FlutterSecureStorage();

    print("🚪 Logging out user...");

    // ✅ Clear stored credentials, but keep onboarding status
    // Remove tokens
    await storage.delete(key: "accessToken");
    await storage.delete(key: "refreshToken");

    // Clear Shared Preferences
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool hasSeenOnboarding = prefs.getBool("hasSeenOnboarding") ?? false;

    // ✅ ONLY remove user data (DO NOT clear onboarding flag)
    await prefs.remove("accessToken");
    await prefs.remove("refreshToken");
    await prefs.remove("userId");

    await prefs.setBool(
        "hasSeenOnboarding", hasSeenOnboarding); // Restore onboarding status

    print("✅ User logged out. All data cleared.");

    // Redirect to login screen
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
          builder: (context) => LoginPage()), // Replace with your login screen
      (route) => false,
    );
  }
}
