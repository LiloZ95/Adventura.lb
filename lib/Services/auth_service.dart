import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:hive/hive.dart'; // ✅ Use Hive for local storage
import 'package:adventura/config.dart'; // ✅ Import the global config file

class AuthService {
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

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data is Map) {
        Box storageBox = await Hive.openBox('authBox');

        String? accessToken = data["accessToken"];
        String? refreshToken = data["refreshToken"];
        Map<String, dynamic>? user = data["user"];

        // ✅ Check if the API response is valid
        if (accessToken == null || refreshToken == null || user == null) {
          print("❌ API response missing required fields.");
          return {
            "success": false,
            "error": "Invalid server response. Please try again."
          };
        }

        // ✅ Store tokens & login state in Hive
        await storageBox.put("accessToken", accessToken);
        await storageBox.put("refreshToken", refreshToken);
        await storageBox.put("isLoggedIn", true); // ✅ Store login state
        await storageBox.put("userId", user["user_id"].toString());

        try {
          // ✅ Store user details
          await storageBox.put("firstName", user["first_name"]);
          await storageBox.put("lastName", user["last_name"]);
          await storageBox.put("profilePicture", user["profilePicture"] ?? "");

          print("✅ User details saved: ID=${user["user_id"]}");
        } catch (e) {
          print("❌ Error storing user data: $e");
          return {"success": false, "error": "Failed to store user data."};
        }

        print("✅ Signup Successful: ${data["message"]}");

        return {"success": true, "message": data["message"]};
      } else {
        print("❌ Signup Failed: ${data["error"] ?? "Unknown error"}");
        return {"success": false, "error": data["error"] ?? "Signup failed"};
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

      if (response.statusCode == 200 && data is Map) {
        Box storageBox = await Hive.openBox('authBox');

        String? accessToken = data["accessToken"];
        String? refreshToken = data["refreshToken"];
        Map<String, dynamic>? user = data["user"];

        print("📦 Received user object: $user");

        print("🔑 Received Access Token: $accessToken");
        print("🔑 Received Refresh Token: $refreshToken");

        if (accessToken == null || refreshToken == null || user == null) {
          print("❌ API response missing required fields.");
          return {
            "success": false,
            "error": "Invalid server response. Please try again."
          };
        }

        // ✅ Store tokens
        await storageBox.put("accessToken", accessToken);
        await storageBox.put("refreshToken", refreshToken);
        await storageBox.put("isLoggedIn", true);

        // ✅ Store user_id only if valid
        if (user.containsKey("user_id") && user["user_id"] != null) {
          await storageBox.put("userId", user["user_id"].toString());
          print("✅ Saved userId to Hive: ${user["user_id"]}");
        } else {
          print("❌ Failed to save userId: user_id missing or null");
        }

        try {
          // ✅ Save user details
          await storageBox.put("firstName", user["first_name"]);
          await storageBox.put("lastName", user["last_name"]);
          await storageBox.put("userEmail", user["email"]);
          await storageBox.put("profilePicture", user["profilePicture"] ?? "");

          String userType = user["user_type"] ?? "client";
          await storageBox.put("userType", userType);
          print("✅ Stored userType: $userType");

          if (userType == "provider" && user["provider_id"] != null) {
            await storageBox.put("providerId", user["provider_id"]);
            print("🏢 Stored providerId: ${user["provider_id"]}");
          }

          print("✅ User details saved: ID=${user["user_id"]}");
        } catch (e) {
          print("❌ Error storing user data: $e");
          return {"success": false, "error": "Failed to store user data."};
        }

        return {
          "success": true,
          "user": user,
          "isProvider": user["user_type"] == "provider",
        };
      } else {
        print("❌ Login failed. API Error: ${data["error"] ?? "Unknown error"}");
        return {
          "success": false,
          "error": data["error"] ?? "Invalid credentials"
        };
      }
    } catch (e) {
      print("❌ Login Exception: $e");
      return {"success": false, "error": "Failed to connect to server"};
    }
  }

  static Future<Map<String, String>> getAuthHeaders() async {
    Box storageBox = await Hive.openBox('authBox'); // ✅ Use Hive
    String? accessToken = storageBox.get("accessToken");

    if (accessToken == null) {
      print("❌ No access token found.");
      return {
        "Content-Type": "application/json"
      }; // No token, send empty headers
    }

    return {
      "Authorization": "Bearer $accessToken",
      "Content-Type": "application/json",
    };
  }

  /// ✅ **Refresh JWT Token**
  static Future<bool> refreshToken() async {
    try {
      Box storageBox = await Hive.openBox('authBox'); // ✅ Open Hive
      String? refreshToken = storageBox.get("refreshToken");

      if (refreshToken == null) {
        print("❌ No refresh token found. User must log in again.");
        return false;
      }

      final response = await http.post(
        Uri.parse('$baseUrl/users/refresh-token'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"refreshToken": refreshToken}),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        String newAccessToken = responseData["accessToken"];
        String newRefreshToken = responseData["refreshToken"];

        await storageBox.put("accessToken", newAccessToken);
        await storageBox.put("refreshToken", newRefreshToken);

        print("✅ Token refreshed successfully.");
        return true;
      } else {
        print("❌ Refresh token request failed: ${response.body}");
        return false;
      }
    } catch (e) {
      print("❌ Error refreshing token: $e");
      return false;
    }
  }

  /// ✅ **Check if User is Logged In**
  static Future<bool> isUserLoggedIn() async {
    Box storageBox = await Hive.openBox('authBox'); // ✅ Use Hive
    String? accessToken = storageBox.get("accessToken");

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
