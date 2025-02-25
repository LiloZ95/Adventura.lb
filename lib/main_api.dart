import 'dart:convert';

import 'package:adventura/Main%20screen%20components/MainScreen.dart';
import 'package:adventura/login/login.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:adventura/intro/intro.dart';
import 'package:adventura/Services/api_service.dart';

class MainApi extends ChangeNotifier {
  static const String baseUrl = 'http://192.168.2.193:3000';
  final FlutterSecureStorage storage = FlutterSecureStorage();
  Widget _initialScreen =
      Scaffold(body: Center(child: CircularProgressIndicator()));

  Widget get initialScreen => _initialScreen; // Getter to access _initialScreen

  MainApi() {
    initializeApp(); // ✅ Automatically check first-time user on creation
  }

  Future<void> initializeApp() async {
    print("🚀 Initializing app...");
    await checkFirstTimeUser();
  }

  Future<void> checkFirstTimeUser() async {
    final prefs = await SharedPreferences.getInstance();
    bool isFirstTime = prefs.getBool("isFirstTime") ?? true;

    if (isFirstTime) {
      print("🎉 First time launching the app! Showing onboarding.");
      await prefs.setBool("isFirstTime", false);
      _initialScreen = DynamicOnboarding();
    } else {
      print("🔍 Checking login status...");
      await checkLoginStatus(); // ✅ Call checkLoginStatus()
    }

    notifyListeners(); // ✅ Notify UI to update
  }

  static Future<bool> validateAccessToken(String token) async {
    try {
      final response = await http.get(
        Uri.parse("$baseUrl/users/validate-token"),
        headers: {"Authorization": "Bearer $token"},
      );

      if (response.statusCode == 200) {
        print("✅ Token is still valid.");
        return true;
      } else {
        print("❌ Token is invalid. Response: ${response.body}");
        return false;
      }
    } catch (e) {
      print("❌ Error validating token: $e");
      return false;
    }
  }

  Future<void> checkLoginStatus() async {
    String? accessToken = await storage.read(key: "accessToken");
    String? userId = await storage.read(key: "userId");

    if (accessToken != null && accessToken.isNotEmpty) {
      bool isValid = await validateAccessToken(accessToken);

      if (isValid) {
        if (userId == null || userId.isEmpty) {
          print("❌ User ID is missing. Fetching from server...");
          await fetchUserData(); // ✅ Fetch user data if missing
        }
        print("✅ Token is valid! Redirecting to MainScreen.");
        _initialScreen = MainScreen();
      } else {
        print("❌ Token is invalid. Redirecting to Login.");
        await storage.delete(key: "accessToken");
        await storage.delete(key: "refreshToken");
        _initialScreen = LoginPage();
      }
    } else {
      print("❌ No token found. Redirecting to Login.");
      _initialScreen = LoginPage();
    }

    notifyListeners();
  }

  Future<void> fetchUserData() async {
    final storage = FlutterSecureStorage();
    String? accessToken = await storage.read(key: "accessToken");

    if (accessToken == null || accessToken.isEmpty) {
      print("❌ No access token found. Cannot fetch user data.");
      return;
    }

    try {
      final response = await http.get(
        Uri.parse("$baseUrl/users/get-user-info"),
        headers: {
          "Authorization": "Bearer $accessToken",
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data["success"] == true && data.containsKey("user")) {
          Map<String, dynamic> user = data["user"];

          // ✅ Ensure user_id is present
          if (!user.containsKey("user_id") || user["user_id"] == null) {
            print("❌ User ID is missing in response!");
            return;
          }

          String userId = user["user_id"].toString();
          String firstName = user["first_name"] ?? "";
          String lastName = user["last_name"] ?? "";
          String profilePicture = user["profilePicture"] ?? "";

          final prefs = await SharedPreferences.getInstance();
          await prefs.setString("userId", userId);
          await prefs.setString("firstName", firstName);
          await prefs.setString("lastName", lastName);
          await prefs.setString("profilePicture", profilePicture);

          print(
              "✅ Fetched and stored user data: ID=$userId, Name=$firstName $lastName, ProfilePicture=$profilePicture");
        } else {
          print(
              "❌ Failed to fetch user data: ${data["error"] ?? "Unknown error"}");
        }
      } else {
        print("❌ Server error: ${response.statusCode}");
      }
    } catch (e) {
      print("❌ Error fetching user data: $e");
    }
  }

  Future<void> logout() async {
    print("🚪 Logging out...");
    await storage.delete(key: "accessToken");
    await storage.delete(key: "refreshToken");
    _initialScreen = LoginPage();
    notifyListeners();
  }
}
