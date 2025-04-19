import 'dart:convert';
import 'dart:io'; // ✅ Import dart:io for platform detection
import 'package:adventura/Main%20screen%20components/MainScreen.dart';
import 'package:adventura/login/login.dart';
import 'package:adventura/web/homeweb.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:adventura/intro/intro.dart';
import 'package:adventura/config.dart'; // ✅ Import the global config file
import 'package:flutter/foundation.dart'
    show kIsWeb; // ✅ Detect if running on Web

class MainApi extends ChangeNotifier {
  late Box storageBox;

  Widget _initialScreen =
      const Scaffold(body: Center(child: CircularProgressIndicator()));

  Widget get initialScreen => _initialScreen; // Getter to access _initialScreen

  MainApi() {
    _initHive();
    // initializeApp(); // ✅ Automatically check first-time user on creation
  }

  // ✅ App Startup Logic
  Future<void> initializeApp() async {
    print("🚀 Initializing app...");
    await _ensureStorageBoxReady(); // Ensure Hive is ready
    await checkFirstTimeUser(); // Check if it's the first time launching the app
  }

  // ✅ Initialize Hive Storage
  Future<void> _initHive() async {
    if (!kIsWeb) {
      final appDocumentDir = await getApplicationDocumentsDirectory();
      await Hive.initFlutter(appDocumentDir.path);
    }
    storageBox = await Hive.openBox('authBox');

    print(
        "🟢 Hive Initialized. Current Storage: ${storageBox.toMap()}"); // Debugging
    await initializeApp();
  }

  // ✅ Check if it's the first time launching the app
  Future<void> checkFirstTimeUser() async {
    await _ensureStorageBoxReady();

    bool isFirstTime = storageBox.get("isFirstTime", defaultValue: true);
    bool isLoggedIn = storageBox.get("isLoggedIn", defaultValue: false);

    if (isLoggedIn) {
      print("🔍 User is already logged in! Checking token...");
      await checkLoginStatus();
    } else if (isFirstTime) {
      print("🎉 First time launching the app! Showing onboarding.");
      storageBox.put("isFirstTime", false);
      _initialScreen = DynamicOnboarding();
    } else {
      print("🔍 User is NOT logged in. Redirecting to Login.");
      _initialScreen = LoginPage();
    }

    notifyListeners();
  }

  // ✅ Ensure `storageBox` is initialized before use
  Future<void> _ensureStorageBoxReady() async {
    if (!Hive.isBoxOpen('authBox')) {
      storageBox = await Hive.openBox('authBox');
    }
  }

  // ✅ Validate Access Token
  Future<bool> validateAccessToken(String token) async {
    await _ensureStorageBoxReady();

    String? userId = storageBox.get("userId");

    if (userId == null) {
      print("❌ No user ID found in storage.");
      return false;
    }

    print("🔍 Validating token for user: $userId");

    final response = await http.post(
      Uri.parse("$baseUrl/users/validate-token"),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
      body: jsonEncode({"user_id": userId}),
    );

    if (response.statusCode == 200) {
      print("✅ Token is valid.");
      return true;
    } else {
      print("❌ Token is invalid. Response: ${response.body}");
      return false;
    }
  }

  // ✅ Check Login Status
  Future<void> checkLoginStatus() async {
    await _ensureStorageBoxReady();

    Box storageBox = await Hive.openBox('authBox'); // ✅ Open Hive

    String? accessToken = storageBox.get("accessToken");
    String? refreshToken = storageBox.get("refreshToken");
    bool isLoggedIn = storageBox.get("isLoggedIn", defaultValue: false);

    print("🔍 Checking Login Status...");
    print("🔍 Stored Access Token: $accessToken");
    print("🔍 Stored Refresh Token: $refreshToken");
    print("🔍 Stored isLoggedIn: $isLoggedIn");

    if (isLoggedIn && accessToken != null && accessToken.isNotEmpty) {
      print("🔍 Checking if stored token is still valid...");

      bool isValid = await validateAccessToken(accessToken);

      if (isValid) {
        print("✅ User is already logged in. Redirecting to MainScreen...");
        _initialScreen =  AdventuraWebHomee();
      } else {
        print("❌ Token expired. Trying refresh...");
        bool refreshed = await refreshTokens();

        if (refreshed) {
          print("✅ Tokens refreshed. Redirecting to MainScreen...");
          _initialScreen =  AdventuraWebHomee();
        } else {
          print("❌ Token refresh failed. Logging out.");
          await logout();
        }
      }
    } else {
      print("❌ No valid session found. Setting isLoggedIn = false.");
      await storageBox.put("isLoggedIn", false);
      _initialScreen = LoginPage();
    }

    print("🔍 Final Hive Storage State: ${storageBox.toMap()}");
    notifyListeners();
  }

  Future<bool> refreshTokens() async {
    await _ensureStorageBoxReady();

    String? refreshToken = storageBox.get("refreshToken");

    if (refreshToken == null || refreshToken.isEmpty) {
      print("❌ No refresh token available.");
      return false;
    }

    try {
      final response = await http.post(
        Uri.parse("$baseUrl/users/refresh-token"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"refreshToken": refreshToken}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data["success"] == true) {
          await storageBox.put("accessToken", data["accessToken"]);
          await storageBox.put("refreshToken", data["refreshToken"]);
          await storageBox.put("isLoggedIn", true);
          print("✅ Tokens refreshed successfully.");
          return true;
        }
      }

      print("❌ Failed to refresh token.");
      return false;
    } catch (e) {
      print("❌ Error refreshing token: $e");
      return false;
    }
  }

  // ✅ Fetch User Data
  Future<void> fetchUserData() async {
    await _ensureStorageBoxReady();

    String? accessToken = storageBox.get("accessToken");

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

          if (!user.containsKey("user_id") || user["user_id"] == null) {
            print("❌ User ID is missing in response!");
            return;
          }

          storageBox.put("userId", user["user_id"].toString());
          storageBox.put("firstName", user["first_name"] ?? "");
          storageBox.put("lastName", user["last_name"] ?? "");
          storageBox.put("profilePicture", user["profilePicture"] ?? "");

          print("✅ User data saved in Hive storage.");
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

  // ✅ Logout Function
  Future<void> logout() async {
    await _ensureStorageBoxReady();

    print("🚪 Logging out...");
    await storageBox.clear();
    _initialScreen = LoginPage();
    notifyListeners();
  }
}
