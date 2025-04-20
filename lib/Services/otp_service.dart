import 'dart:convert';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'package:adventura/config.dart'; // ✅ Import the global config file

class OtpService {
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

  /// ✅ Send OTP to phone number
  static Future<bool> sendPhoneOtp(String phone) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/send-phone-otp'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"phone": phone}),
      );

      if (response.statusCode == 200) {
        print("✅ OTP sent successfully to $phone");
        return true;
      } else {
        print("❌ Failed to send OTP: ${response.body}");
        return false;
      }
    } catch (e) {
      print("❌ Error sending OTP: $e");
      return false;
    }
  }

  /// ✅ Verify phone number with OTP
  static Future<bool> verifyPhoneOtp(String phone, String otp) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/verify-phone-otp'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"phone": phone, "otp": otp}),
      );

      if (response.statusCode == 200) {
        print("✅ Phone number verified");
        return true;
      } else {
        print("❌ OTP verification failed: ${response.body}");
        return false;
      }
    } catch (e) {
      print("❌ Error verifying OTP: $e");
      return false;
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
      var box = await Hive.openBox('authBox');

      // fallback to Hive if not passed
      firstName ??= box.get('firstName', defaultValue: '');
      lastName ??= box.get('lastName', defaultValue: '');
      phoneNumber ??= box.get('phoneNumber', defaultValue: '');
      password ??= box.get('password', defaultValue: '');

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

        // ✅ Store in Hive
        await box.put("accessToken", accessToken);
        await box.put("refreshToken", refreshToken);
        await box.put("isLoggedIn", true);
        await box.put("userId", userId);
        await box.put("firstName", data["user"]["first_name"] ?? "");
        await box.put("lastName", data["user"]["last_name"] ?? "");
        await box.put("profilePicture", data["user"]["profilePicture"] ?? "");

        print("✅ Stored User Data in Hive: $firstName $lastName");

        return {"success": true, "user": data["user"]};
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
