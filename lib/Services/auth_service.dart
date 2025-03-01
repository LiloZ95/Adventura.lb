import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const String baseUrl = 'http://localhost:3000';
  static final FlutterSecureStorage storage = FlutterSecureStorage();

  /// ✅ **Signup User**
  static Future<Map<String, dynamic>> signupUser({
    required String firstName,
    required String lastName,
    required String email,
    required String phoneNumber,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/users/signup'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'first_name': firstName,
          'last_name': lastName,
          'email': email,
          'phoneNumber': phoneNumber,
          'password': password,
        }),
      );

      final responseData = jsonDecode(response.body);
      if (response.statusCode == 200) {
        print("✅ Signup Successful: ${responseData["message"]}");
        return {"success": true, "message": responseData["message"]};
      } else {
        print("❌ Signup Failed: ${responseData["error"] ?? "Unknown error"}");
        return {"success": false, "error": responseData["error"] ?? "Signup failed"};
      }
    } catch (e) {
      print("❌ Exception in Signup: $e");
      return {"success": false, "error": "Failed to connect to server"};
    }
  }

  /// ✅ **Login User**
Future<Map<String, dynamic>> loginUser(String email, String password) async {
  try {
    final response = await http.post(
      Uri.parse('$baseUrl/users/login'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'email': email, 'password': password}),
    );

    final data = jsonDecode(response.body);
    print("🔍 Login API Response: $data");

    if (response.statusCode == 200 && data is Map) {
      SharedPreferences prefs = await SharedPreferences.getInstance();

      String? accessToken = data["accessToken"];
      String? refreshToken = data["refreshToken"];
      Map<String, dynamic>? user = data["user"];

      print("🔑 Received Access Token: $accessToken");
      print("🔑 Received Refresh Token: $refreshToken");

      // ✅ Check if the API response is valid
      if (accessToken == null || refreshToken == null || user == null) {
        print("❌ API response missing required fields.");
        return {"success": false, "error": "Invalid server response. Please try again."};
      }

      // ✅ Securely store tokens
      await storage.write(key: "accessToken", value: accessToken);
      await storage.write(key: "refreshToken", value: refreshToken);

      // ✅ Verify tokens were saved correctly
      String? storedAccessToken = await storage.read(key: "accessToken");
      String? storedRefreshToken = await storage.read(key: "refreshToken");

      if (storedAccessToken == null || storedRefreshToken == null) {
        print("❌ Token storage failed. Check storage permissions.");
        return {"success": false, "error": "Failed to store authentication tokens."};
      }

      print("✅ Tokens successfully stored!");

      try {
        // ✅ Store user details in SharedPreferences
        await prefs.setBool("isLoggedIn", true);
        await prefs.setString("userId", user["user_id"].toString());
        await prefs.setString("firstName", user["first_name"] ?? "");
        await prefs.setString("lastName", user["last_name"] ?? "");
        await prefs.setString("profilePicture", user["profilePicture"] ?? "");

        print("✅ User details saved: ID=${user["user_id"]}, Name=${user["first_name"]} ${user["last_name"]}");
      } catch (e) {
        print("❌ Error storing user data: $e");
        return {"success": false, "error": "Failed to store user data."};
      }

      return {"success": true, "user": user};
    } else {
      print("❌ Login failed. API Error: ${data["error"] ?? "Unknown error"}");
      return {"success": false, "error": data["error"] ?? "Invalid credentials"};
    }
  } catch (e) {
    print("❌ Login Exception: $e");
    return {"success": false, "error": "Failed to connect to server"};
  }
}


  /// ✅ **Refresh JWT Token**
  static Future<bool> refreshToken() async {
    String? refreshToken = await storage.read(key: "refreshToken");

    if (refreshToken == null) {
      print("❌ No refresh token found. User must log in again.");
      return false;
    }

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/users/refresh-token'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"refreshToken": refreshToken}),
      );

      final responseData = jsonDecode(response.body);
      if (response.statusCode == 200) {
        await storage.write(key: "accessToken", value: responseData["accessToken"]);
        print("✅ Token refreshed successfully.");
        return true;
      } else {
        print("❌ Failed to refresh token: ${responseData["error"] ?? "Unknown error"}");
        return false;
      }
    } catch (e) {
      print("❌ Token refresh failed: $e");
      return false;
    }
  }

  /// ✅ **Check if User is Logged In**
  static Future<bool> isUserLoggedIn() async {
    String? accessToken = await storage.read(key: "accessToken");
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
      return await refreshToken(); // Try refreshing token
    } else {
      return false;
    }
  }
}
