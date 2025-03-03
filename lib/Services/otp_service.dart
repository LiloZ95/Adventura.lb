import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'auth_service.dart';
import 'storage_service.dart';

class OtpService {
  static const String baseUrl = 'http://localhost:3000';
  static final FlutterSecureStorage storage = FlutterSecureStorage();

  /// ✅ **Send OTP for Signup or Password Reset**
  static Future<Map<String, dynamic>> sendOtp(String email,
      {required bool isForSignup}) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/users/send-otp'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'isForSignup': isForSignup
        }), // ✅ Indicate purpose of OTP
      );

      final responseData = jsonDecode(response.body);
      print("🔍 DEBUG: API Response -> ${response.body}"); // ✅ Debug response

      if (response.statusCode == 200) {
        return {"success": true, "message": responseData["message"]};
      } else {
        return {
          "success": false,
          "error": responseData["error"] ?? "Unknown error"
        };
      }
    } catch (e) {
      print("❌ ERROR: Failed to send OTP -> $e"); // ✅ Debug error
      return {"success": false, "error": "Failed to connect to server"};
    }
  }

  /// ✅ **Resend OTP**
  static Future<Map<String, dynamic>> resendOtp(String email,
      {required bool isForSignup}) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/users/resend-otp'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'isForSignup': isForSignup}),
      );

      final responseData = jsonDecode(response.body);
      print("🔍 Resend OTP API Response: ${response.body}");

      if (response.statusCode == 200) {
        return {"success": true, "message": responseData["message"]};
      } else {
        return {
          "success": false,
          "error": responseData["error"] ?? "Failed to resend OTP"
        };
      }
    } catch (e) {
      print("❌ Error in resendOtp: $e");
      return {"success": false, "error": "Failed to connect to server"};
    }
  }

  /// ✅ **Verify OTP & Handle Signup or Password Reset**
  static Future<Map<String, dynamic>> verifyOtp(
    String email,
    String otp, {
    bool isForSignup = false,
    String? firstName,
    String? lastName,
    String? phoneNumber,
    String? password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/users/verify-otp'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "email": email,
          "otp": otp,
          "isForSignup": isForSignup,
          "firstName": firstName ?? "",
          "lastName": lastName ?? "",
          "phoneNumber": phoneNumber ?? "",
          "password": password ?? "",
        }),
      );

      print("🔍 FULL API RESPONSE: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (!data.containsKey("user") ||
            !data.containsKey("accessToken") ||
            !data.containsKey("refreshToken")) {
          print("❌ Missing user or token data in response.");
          return {
            "success": false,
            "error": "User data or tokens missing in response"
          };
        }

        String userId = data["user"]["user_id"].toString();
        String accessToken = data["accessToken"];
        String refreshToken = data["refreshToken"];

        await StorageService.saveAuthTokens(accessToken, refreshToken, userId);
        await StorageService.saveUserData(userId, accessToken, refreshToken);

        print("✅ Stored User Data: ID=$userId, Name=${data["user"]["first_name"]}");
        return data;
      } else {
        final errorData = jsonDecode(response.body);
        return {
          "success": false,
          "error": errorData["error"] ?? "Invalid OTP. Please try again."
        };
      }
    } catch (e) {
      print("❌ Exception in verifyOtp: $e");
      return {
        "success": false,
        "error": "Failed to connect to server. Check internet connection."
      };
    }
  }
}
