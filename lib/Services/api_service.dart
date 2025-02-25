// lib/services/api_service.dart
import 'package:adventura/login/login.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import 'dart:ui';
import 'dart:convert';
import 'package:flutter/material.dart'; // ✅ This includes ChangeNotifier
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:path/path.dart'; // Required for filename extraction

class ApiService extends ChangeNotifier {
  static const String baseUrl =
      // 'http://localhost:3000'; // Replace with your backend URL
      'http://192.168.2.193:3000'; // Adjust for platform
  static final FlutterSecureStorage storage = FlutterSecureStorage();

  String? _userId;
  String? _firstName;
  String? _lastName;
  String? _profileImageUrl;
  File? _selectedImage;
  String? _errorMessage; // Store error message for UI
  String? fullName; // ✅ Store full name

  // Getters
  String? get userId => _userId ?? "";
  // String get fullName => "${_firstName ?? ""} ${_lastName ?? ""}".trim();
  String get firstName => _firstName ?? "";
  String get lastName => _lastName ?? "";
  String? get profileImageUrl => _profileImageUrl;
  File? get selectedImage => _selectedImage;
  String? get errorMessage => _errorMessage;

  // ✅ Setter to update profile picture URL and notify UI
  set profileImageUrl(String? value) {
    _profileImageUrl = value;
    notifyListeners(); // ✅ Notify UI to refresh
  }

  ApiService() {
    _initializeUser(); // Automatically fetch user data when ApiService is created
  }

  static Future<Map<String, dynamic>> signupUser({
    required String first_name,
    required String last_name,
    required String email,
    required String phoneNumber,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/users/signup'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'first_name': first_name,
          'last_name': last_name,
          'email': email,
          'phoneNumber': phoneNumber,
          'password': password,
        }),
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {"success": true, "message": responseData["message"]};
      } else {
        return {
          "success": false,
          "error": responseData["error"] ?? "Signup failed"
        };
      }
    } catch (e) {
      return {"success": false, "error": "Failed to connect to server"};
    }
  }

  // Check if user is logged in
  Future<bool> isUserLoggedIn() async {
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

  Future<Map<String, dynamic>> loginUser(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/users/login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': email,
          'password': password,
        }),
      );

      print("🔍 Raw API Response: ${response.body}");
      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data is Map) {
        SharedPreferences prefs = await SharedPreferences.getInstance();

        // ✅ Ensure the response contains tokens and user info before storing
        String? accessToken = data["accessToken"];
        String? refreshToken = data["refreshToken"];
        Map<String, dynamic>? user = data["user"];

        if (accessToken == null || refreshToken == null || user == null) {
          print("❌ API response missing required fields.");
          return {
            "success": false,
            "error": "Invalid server response. Please try again.",
          };
        }

        // ✅ Store login state
        await prefs.setBool("isLoggedIn", true);
        await prefs.setString("userId", user["user_id"].toString()); // 🛠 FIXED
        await prefs.setString(
            "firstName", user["name"].split(" ")[0]); // 🛠 FIXED
        await prefs.setString(
            "lastName", user["name"].split(" ")[1]); // 🛠 FIXED
        await prefs.setString("accessToken", accessToken);
        await prefs.setString("refreshToken", refreshToken);

        // ✅ Store profile picture if available
        if (user["profilePicture"] != null &&
            user["profilePicture"].isNotEmpty) {
          await prefs.setString(
              "profilePicture", user["profilePicture"]); // 🛠 FIXED
          print("✅ Profile picture saved: ${user["profilePicture"]}");
        } else {
          print("⚠️ No profile picture found.");
        }

        print("✅ Login successful. User details saved.");

        // ✅ Load profile data after storing it
        await loadUserProfile();

        return {
          "success": true,
          "user": user,
        };
      } else {
        print("❌ Login failed. API Error: ${data["error"] ?? "Unknown error"}");
        return {
          "success": false,
          "error": data["error"] ?? "Invalid credentials",
        };
      }
    } catch (e) {
      print("❌ Login Error: $e");
      return {
        "success": false,
        "error": "Failed to connect to server",
      };
    }
  }

  // Delete user
  Future<bool> deleteUser(BuildContext context) async {
    try {
      // ✅ Get User ID from Storage
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? userId = prefs.getString("userId");

      if (userId == null) {
        print("❌ Error: User ID not found.");
        showSnackbar(context, "❌ Error: User ID not found.", Colors.red);
        return false;
      }

      print("🗑 Attempting to delete user with ID: $userId");

      // ✅ Send DELETE request
      final response = await http.delete(
        Uri.parse("$baseUrl/users/$userId"),
        headers: {"Content-Type": "application/json"},
      );

      print("🔍 Delete User API Response: ${response.body}");

      if (response.statusCode == 200) {
        print("✅ User Deleted Successfully!");

        // ✅ Clear Stored User Data
        await prefs.clear();

        showSnackbar(context, "✅ Account deleted successfully!", Colors.green);

        return true;
      } else {
        print("❌ Failed to delete user: ${response.body}");
        showSnackbar(context, "❌ Failed to delete account.", Colors.red);
        return false;
      }
    } catch (e) {
      print("❌ Error deleting user: $e");
      showSnackbar(context, "❌ Server error. Try again.", Colors.red);
      return false;
    }
  }

  // Fetch API with JWT Authentication
  Future<http.Response> getProtectedData(String endpoint) async {
    String? accessToken = await storage.read(key: "accessToken");

    final response = await http.get(
      Uri.parse('$baseUrl/$endpoint'),
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 401) {
      // Token expired, try refreshing
      print("🔄 Access token expired, refreshing...");
      bool refreshed = await refreshToken();
      if (refreshed) {
        accessToken = await storage.read(key: "accessToken");
        return await http.get(
          Uri.parse('$baseUrl/$endpoint'),
          headers: {
            'Authorization': 'Bearer $accessToken',
            'Content-Type': 'application/json',
          },
        );
      }
    }
    return response;
  }

  // Refresh JWT Token
  static Future<bool> refreshToken() async {
    final storage = FlutterSecureStorage();
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
        await storage.write(
            key: "accessToken", value: responseData["accessToken"]);
        return true;
      } else {
        return false;
      }
    } catch (e) {
      print("❌ Token refresh failed: $e");
      return false;
    }
  }

  Future<Map<String, dynamic>> makeAuthenticatedRequest(String endpoint) async {
    final storage = FlutterSecureStorage();
    String? accessToken = await storage.read(key: "accessToken");

    final response = await http.get(
      Uri.parse('$baseUrl/$endpoint'),
      headers: {
        "Authorization": "Bearer $accessToken",
        "Content-Type": "application/json",
      },
    );

    if (response.statusCode == 401) {
      // Token expired, refresh it
      bool refreshed = await refreshToken();
      if (refreshed) {
        return makeAuthenticatedRequest(endpoint); // Retry the request
      } else {
        return {
          "success": false,
          "error": "Unauthorized. Please log in again."
        };
      }
    }

    return jsonDecode(response.body);
  }

// 🔹 Function to send OTP for password reset
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

  // Logout (Clear Tokens)
  static Future<void> logout(BuildContext context) async {
    final storage = FlutterSecureStorage();

    print("🚨 Logging out user...");

    // ✅ Debug print before logout
    // bool beforeLogout = prefs.getBool("hasSeenOnboarding") ?? false;
    // print("Onboarding status before logout: $beforeLogout");

    // ✅ Clear stored credentials, but keep onboarding status
    // Remove tokens
    await storage.delete(key: "accessToken");
    await storage.delete(key: "refreshToken");

    print("✅ User logged out. Tokens removed.");

    // Redirect to login screen
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
          builder: (context) => LoginPage()), // Replace with your login screen
      (route) => false,
    );
  }

  /// **Verify OTP for Signup or Forgot Password**
  static Future<Map<String, dynamic>> verifyOtp(
    String email,
    String otp, {
    bool isForSignup = false,
    String? firstName,
    String? lastName,
    String? phoneNumber,
    String? password,
  }) async {
    final storage = FlutterSecureStorage(); // Secure storage for tokens

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
        print("✅ Parsed API Response: $data");

        if (!data.containsKey("user") || data["user"] == null) {
          print("❌ Missing user data in API response.");
          return {
            "success": false,
            "error": "User data is missing in response"
          };
        }

        return data; // ✅ Return parsed data including the "user" field
      } else {
        print("❌ API Error: ${data["error"] ?? "Unknown error"}");
        return {
          "success": false,
          "error": data["error"] ?? "Invalid OTP or server error",
        };
      }
    } catch (e) {
      print("❌ Exception in verifyOtp: $e");
      return {"success": false, "error": "Failed to connect to server"};
    }
  }

  // ✅ Initialize User & Fetch Name
  Future<void> _initializeUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _userId = prefs.getString("userId");

    if (_userId != null) {
      await fetchUserProfile(); // Fetch user details
    }
    notifyListeners();
  }

  // ✅ Get Logged-In User ID
  Future<void> getUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? storedUserId = await storage.read(key: "userId");

    if (storedUserId == null) {
      storedUserId = prefs.getString("userId");
    }

    if (storedUserId != null) {
      _userId = storedUserId;
      notifyListeners();
      print("✅ Retrieved User ID: $_userId");

      // ✅ Fetch user profile picture after getting userId
      await fetchProfilePicture();
    } else {
      print("❌ No User ID Found in Storage!");
    }
  }

  Future<void> loadUserProfile() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    _userId = prefs.getString("userId");
    _firstName = prefs.getString("firstName");
    _lastName = prefs.getString("lastName");
    _profileImageUrl = prefs.getString("profilePicture");

    print("📡 Loaded User ID: $_userId");
    print("📡 Loaded Name: ${_firstName ?? ''} ${_lastName ?? ''}");
    print("📡 Loaded Profile Picture: $_profileImageUrl");

    notifyListeners();
  }

  // ✅ Fetch User Profile (First & Last Name)
  Future<void> fetchUserProfile() async {
    if (_userId == null) return;

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/users/$_userId'),
        headers: {"Content-Type": "application/json"},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _firstName = data["first_name"]; // ✅ Adjust based on API response
        _lastName = data["last_name"];
        notifyListeners(); // Update UI
      } else {
        print("❌ Failed to fetch user profile");
      }
    } catch (e) {
      print("❌ Error fetching user profile: $e");
    }
  }

  // ✅ Fetch Profile Picture from Backend
  Future<void> fetchProfilePicture() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString("userId");

    if (userId == null || userId.isEmpty) {
      print("❌ User ID is missing.");
      return;
    }

    String apiUrl = "$baseUrl/users/get-profile-picture/$userId";
    print("📡 Fetching profile picture from: $apiUrl");

    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data["image"] != null && data["image"].isNotEmpty) {
          _profileImageUrl = data["image"]; // ✅ Use "image"

          // ✅ Store in SharedPreferences for persistence
          await prefs.setString("profilePicture", _profileImageUrl!);
          print("✅ Profile picture updated!");
        } else {
          print("❌ Response did not contain image.");
        }
      } else {
        print(
            "❌ Failed to fetch profile picture. Server responded with: ${response.statusCode}");
      }
    } catch (e) {
      print("❌ Error fetching profile picture: $e");
    }
  }

  // ✅ Pick Image & Upload
  Future<void> pickImage(BuildContext context, String userId) async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      File imageFile = File(pickedFile.path);
      int fileSize = await imageFile.length();
      double imageSizeInMB = fileSize / (1024 * 1024);

      // ✅ Check if the image exceeds 3MB
      if (imageSizeInMB > 3) {
        _errorMessage = "❌ Image size must be less than 3MB.";
        notifyListeners();

        // ✅ Show Snackbar for large file size
        Future.delayed(Duration.zero, () {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text(_errorMessage!), backgroundColor: Colors.red),
            );
          }
        });

        return;
      }
      // ✅ If size is valid, update state and proceed with upload
      _selectedImage = imageFile;
      _errorMessage = null;
      notifyListeners();

      // ✅ Show Snackbar before uploading
      Future.delayed(Duration.zero, () {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text("✅ Uploading new profile picture..."),
                backgroundColor: Colors.blue),
          );
        }
      });

      // ✅ Upload Image
      await uploadProfilePicture(context, userId, imageFile);

      // ✅ Show success message after upload
      // Future.delayed(Duration.zero, () {
      //   if (context.mounted) {
      //     ScaffoldMessenger.of(context).showSnackBar(
      //       SnackBar(
      //           content: Text("✅ Profile picture updated successfully!"),
      //           backgroundColor: Colors.green),
      //     );
      //   }
      // });
    }
  }

  // ✅ Upload Profile Picture with Size Validation
  Future<void> uploadProfilePicture(
      BuildContext context, String userId, File imageFile) async {
    if (userId == null || userId.isEmpty) {
      print("❌ No user ID found. Cannot upload profile picture.");
      return;
    }

    if (imageFile == null) {
      print("❌ No image selected.");
      return;
    }

    // ✅ Check Image Size (3MB Max)
    int imageSizeInBytes = await imageFile.length();
    double imageSizeInMB = imageSizeInBytes / (1024 * 1024);
    if (imageSizeInMB > 3) {
      print(
          "❌ Image is too large (${imageSizeInMB.toStringAsFixed(2)} MB). Max: 3MB");

      // ✅ Run inside a post-frame callback to ensure context is valid
      Future.delayed(Duration.zero, () {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text("❌ Image size must be less than 3MB."),
                backgroundColor: Colors.red),
          );
        }
      });
      return;
    }

    try {
      // ✅ Correct API URL (Ensure this matches your `userRoutes.js`)
      String apiUrl = '$baseUrl/users/upload-profile-picture';

      print(
          "📤 Uploading image: ${imageFile.path} (${imageSizeInMB.toStringAsFixed(2)} MB)");
      print("📡 Sending request to: $apiUrl");

      var request = http.MultipartRequest('POST', Uri.parse(apiUrl));

      // ✅ Attach the user ID
      request.fields['user_id'] = userId;

      // ✅ Attach the image file
      request.files.add(
        await http.MultipartFile.fromPath(
          'image',
          imageFile.path,
          filename: basename(imageFile.path), // Ensures correct filename
        ),
      );

      // ✅ Send the request
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      print("🔍 Server Response Code: ${response.statusCode}");
      print("🔍 Response Body: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        // ✅ Ensure response is valid JSON before decoding
        Map<String, dynamic>? responseData;
        try {
          responseData = jsonDecode(response.body);
        } catch (e) {
          print("❌ Failed to parse response JSON: $e");
        }

        if (responseData != null && responseData["success"] == true) {
          // ✅ Update profile image URL if available
          if (responseData.containsKey("image") &&
              responseData["image"].isNotEmpty) {
            _profileImageUrl = responseData["image"];
            print("✅ New profile picture URL: $_profileImageUrl");

            // ✅ Store updated profile picture in SharedPreferences
            SharedPreferences prefs = await SharedPreferences.getInstance();
            await prefs.setString("profilePicture", _profileImageUrl!);
          }

          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text(responseData["message"] ??
                      "✅ Profile updated successfully!"),
                  backgroundColor: Colors.green),
            );
          }

          print("✅ Profile picture uploaded successfully!");

          // ✅ Refresh profile image after upload
          await fetchProfilePicture();
        } else {
          print(
              "❌ Failed to upload profile picture: ${responseData?["error"] ?? "Unknown error"}");

          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text("❌ Failed to upload profile picture."),
                  backgroundColor: Colors.red),
            );
          }
        }
      } else {
        print("❌ Upload failed. Response: ${response.body}");

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text("❌ Failed to upload profile picture."),
                backgroundColor: Colors.red),
          );
        }
      }
    } catch (e) {
      print("❌ Error uploading profile picture: $e");

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text("❌ An error occurred while uploading."),
              backgroundColor: Colors.red),
        );
      }
    }
  }

  /// ✅ Show Snackbar Messages
  void showSnackbar(BuildContext context, String message, Color color) {
    Future.delayed(Duration.zero, () {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message), backgroundColor: color),
        );
      }
    });
  }
}
