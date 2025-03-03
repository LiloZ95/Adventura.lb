import 'dart:convert';
import 'package:adventura/Main%20screen%20components/MainScreen.dart';
import 'package:adventura/login/login.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:adventura/intro/intro.dart';

class MainApi extends ChangeNotifier {
  static const String baseUrl = 'http://localhost:3000';
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
    bool isLoggedIn = prefs.getBool("isLoggedIn") ?? false;

    if (isLoggedIn) {
      print("🔍 User is already logged in! Checking token...");
      await checkLoginStatus();
    } else if (isFirstTime) {
      print("🎉 First time launching the app! Showing onboarding.");
      await prefs.setBool("isFirstTime", false);
      _initialScreen = DynamicOnboarding();
    } else {
      print("🔍 User is NOT logged in. Redirecting to Login.");
      _initialScreen = LoginPage();
    }

    notifyListeners();
  }

  Future<bool> validateAccessToken(String token) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString("userId"); // ✅ Get user ID

    if (userId == null) {
      print("❌ No user ID found in storage.");
      return false;
    }

    print("🔍 Validating token for user: $userId");

    final response = await http.post(
      Uri.parse("http://localhost:3000/users/validate-token"),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
      body: jsonEncode({"user_id": userId}), // ✅ Include user_id in the request
    );

    if (response.statusCode == 200) {
      print("✅ Token is valid.");
      return true;
    } else {
      print("❌ Token is invalid. Response: ${response.body}");
      return false;
    }
  }

  Future<void> checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    String? accessToken = await storage.read(key: "accessToken");
    String? refreshToken = await storage.read(key: "refreshToken");
    bool isLoggedIn = prefs.getBool("isLoggedIn") ?? false;

    print("🔍 Stored Access Token: $accessToken");
    print("🔍 Stored Refresh Token: $refreshToken");

    if (isLoggedIn && accessToken != null && accessToken.isNotEmpty) {
      bool isValid = await validateAccessToken(accessToken);

      if (isValid) {
        print("✅ User is already logged in. Redirecting to MainScreen...");
        _initialScreen = MainScreen(); // ✅ Redirect to MainScreen
      } else {
        print("❌ Token expired. Logging out.");
        await logout();
        _initialScreen = LoginPage(); // ✅ Redirect to Login
      }
    } else {
      print("❌ No valid session found. Redirecting to Login...");
      _initialScreen = LoginPage();
    }

    notifyListeners(); // ✅ Update UI
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
