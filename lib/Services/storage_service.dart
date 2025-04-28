import 'dart:convert';
import 'package:adventura/login/login.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'auth_service.dart';
import 'package:hive/hive.dart';
import 'package:adventura/config.dart';

class StorageService {
  // static const String baseUrl = 'http://localhost:3000';

  /// ✅ **Save Authentication Tokens**
  static Future<void> saveAuthTokens(
      String accessToken, String refreshToken, String userId) async {
    Box box = await Hive.openBox('authBox');

    await box.put("accessToken", accessToken);
    await box.put("refreshToken", refreshToken);
    await box.put("userId", userId);
    await box.put("isLoggedIn", true);

    print("✅ Tokens & User ID saved: userID=$userId, accessToken=$accessToken");
  }

  /// ✅ **Save User Data Securely**
  static Future<void> saveUserData(
      String userId, String accessToken, String refreshToken) async {
    print(
        "✅ Storing User Data: ID=$userId, Access Token=$accessToken, Refresh Token=$refreshToken");

    Box box = await Hive.openBox('authBox');

    await box.put("accessToken", accessToken);
    await box.put("refreshToken", refreshToken);
    await box.put("userId", userId);
    await box.put("isLoggedIn", true);

    // Verify if data is saved correctly
    String? savedUserId = box.get("userId");
    String? savedAccessToken = box.get("accessToken");

    if (savedUserId == null || savedAccessToken == null) {
      print(
          "❌ Failed to save user data! Debug: UserId=$savedUserId, Token=$savedAccessToken");
    } else {
      print("✅ User Data Saved Successfully!");
    }
  }

  /// ✅ **Fetch Access Token**
  static Future<String?> getAccessToken() async {
    Box box = await Hive.openBox('authBox');
    String? token = box.get("accessToken");

    if (token == null) {
      print(
          "❌ No token found in secure storage. Checking SharedPreferences...");
      token = box.get("accessToken");
    }

    // ✅ Check if token is expired
    if (token != null && await isTokenExpired(token)) {
      print("🔄 Token expired, attempting to refresh...");
      bool refreshed = await AuthService.refreshToken();
      if (refreshed) {
        return await box.get("accessToken"); // Return new token
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
    Box box = await Hive.openBox('authBox');
    bool? isLoggedIn = box.get("isLoggedIn", defaultValue: false);

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
    Box box = await Hive.openBox('authBox');
    return box.get("userId", defaultValue: "");
  }

  static Future<String> getFirstName() async {
    Box box = await Hive.openBox('authBox');
    return box.get("firstName", defaultValue: "");
  }

  static Future<String> getLastName() async {
    Box box = await Hive.openBox('authBox');
    return box.get("lastName", defaultValue: "");
  }

  /// ✅ **Logout & Clear Data**
  static Future<void> logout(BuildContext context) async {
    Box box = await Hive.openBox('authBox');
    String userId = box.get('userId');
    bool hasSeenOnboarding = true;

    print("🚪 Logging out user...");

    // ✅ Clear stored credentials
    await box.delete("accessToken");
    await box.delete("refreshToken");
    await box.delete("userId");
    await box.delete('profileImageBytes_$userId');
    await box.delete('profilePictureUrl_$userId');
    await box.delete("providerId");
    await box.delete("userType");

    await box.put("isLoggedIn", false);

    // Clear Shared Preferences

    await box.put(
        "hasSeenOnboarding", hasSeenOnboarding); // Restore onboarding status
    print("hasSeenOnboarding: $hasSeenOnboarding");

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
