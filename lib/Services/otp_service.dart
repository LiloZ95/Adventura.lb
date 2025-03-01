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
  static Future<Map<String, dynamic>> sendOtp(String email, {required bool isForSignup}) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/users/send-otp'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'isForSignup': isForSignup}),
      );

      final responseData = jsonDecode(response.body);
      if (response.statusCode == 200) {
        print("✅ OTP Sent Successfully!");
        return {"success": true, "message": responseData["message"]};
      } else {
        print("❌ Failed to send OTP: ${responseData["error"] ?? "Unknown error"}");
        return {"success": false, "error": responseData["error"] ?? "Failed to send OTP"};
      }
    } catch (e) {
      print("❌ ERROR: Failed to send OTP -> $e");
      return {"success": false, "error": "Failed to connect to server"};
    }
  }

  /// ✅ **Resend OTP**
  static Future<Map<String, dynamic>> resendOtp(String email, {required bool isForSignup}) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/users/resend-otp'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'isForSignup': isForSignup}),
      );

      final responseData = jsonDecode(response.body);
      if (response.statusCode == 200) {
        print("✅ OTP Resent Successfully!");
        return {"success": true, "message": responseData["message"]};
      } else {
        print("❌ Failed to resend OTP: ${responseData["error"] ?? "Unknown error"}");
        return {"success": false, "error": responseData["error"] ?? "Failed to resend OTP"};
      }
    } catch (e) {
      print("❌ ERROR: Failed to resend OTP -> $e");
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

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data is Map<String, dynamic>) {
        print("✅ OTP Verified Successfully!");

        // 🛠 **Ensure user data is returned**
        if (!data.containsKey("user") || data["user"] == null) {
          print("❌ Missing user data in API response.");
          return {"success": false, "error": "User data is missing in response"};
        }

        // ✅ **Save user data after OTP verification**
        await StorageService.saveAuthTokens(data["accessToken"], data["refreshToken"]);
        await StorageService.saveUserData(data["user"]);

        print("✅ User data saved successfully after OTP verification.");
        return data; // ✅ Return full response
      } else {
        print("❌ OTP Verification Failed: ${data["error"] ?? "Unknown error"}");
        return {"success": false, "error": data["error"] ?? "Invalid OTP or server error"};
      }
    } catch (e) {
      print("❌ Exception in verifyOtp: $e");
      return {"success": false, "error": "Failed to connect to server"};
    }
  }
}
