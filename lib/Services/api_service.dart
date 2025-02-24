// lib/services/api_service.dart
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
      'http://192.168.1.28:3000'; // Adjust for platform
  static final FlutterSecureStorage storage = FlutterSecureStorage();

  String? _userId;
  String? _firstName;
  String? _lastName;
  String? _profileImageUrl;
  File? _selectedImage;
  String? _errorMessage; // Store error message for UI

  // Getters
  String? get userId => _userId;
  String get fullName => "${_firstName ?? ""} ${_lastName ?? ""}".trim();
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

  // Login User
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
        await prefs.setString("userId", user["user_id"].toString());
        await prefs.setString("accessToken", accessToken);
        await prefs.setString("refreshToken", refreshToken);

        // ✅ Store profile picture if available
        if (user["profilePicture"] != null &&
            user["profilePicture"].isNotEmpty) {
          profileImageUrl = user["profilePicture"];
          prefs.setString("profilePicture", _profileImageUrl!);
          print("✅ Profile picture saved: $_profileImageUrl");
        }

        print("✅ Login successful. Token & User ID saved.");

        // ✅ Fetch the profile picture if not available
        fetchProfilePicture();
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
  Future<bool> deleteUser() async {
    if (_userId == null) return false; // Ensure userId exists

    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/delete-user/$_userId'),
      );

      if (response.statusCode == 200) {
        await storage.deleteAll();
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.remove("userId");
        _userId = null; // Clear the stored userId
        notifyListeners(); // Update UI
        return true;
      }
    } catch (e) {
      print("❌ Error deleting user: $e");
    }

    return false;
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
  Future<bool> refreshToken() async {
    String? refreshToken = await storage.read(key: "refreshToken");
    if (refreshToken == null) return false;

    final response = await http.post(
      Uri.parse('$baseUrl/users/refresh'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'refreshToken': refreshToken}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      await storage.write(key: "accessToken", value: data["accessToken"]);
      print("✅ Token refreshed successfully.");
      return true;
    } else {
      print("❌ Failed to refresh token.");
      return false;
    }
  }

  Future<void> getDashboard() async {
    // Retrieve the access token from secure storage
    String? accessToken = await storage.read(key: 'accessToken');

    if (accessToken == null) {
      // Handle the case when the user is not logged in or token is expired
      print('No token found!');
      return;
    }

    final response = await http.get(
      Uri.parse('$baseUrl/users/dashboard'),
      headers: {
        'Authorization':
            'Bearer $accessToken', // Add token to the Authorization header
      },
    );

    if (response.statusCode == 200) {
      // Successfully received the dashboard data
      print('Dashboard: ${response.body}');
    } else if (response.statusCode == 401) {
      // Token expired or invalid; handle refreshing the token
      print('Token expired. Refreshing...');
      await refreshToken();
    } else {
      // Handle other errors
      print('Failed to load dashboard');
    }
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
  Future<void> logout() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    print("🚨 Logging out user...");

    // ✅ Debug print before logout
    bool beforeLogout = prefs.getBool("hasSeenOnboarding") ?? false;
    print("Onboarding status before logout: $beforeLogout");

    // ✅ Clear stored credentials, but keep onboarding status
    await prefs.setBool("isLoggedIn", false);
    await prefs.remove("userId");
    await prefs.remove("accessToken");

    // ✅ Debug print after logout
    bool afterLogout = prefs.getBool("hasSeenOnboarding") ?? false;
    print("Onboarding status after logout: $afterLogout");
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

      print("🔍 Sent Data to Backend: ${jsonEncode({
            "email": email,
            "otp": otp,
            "isForSignup": isForSignup,
            "firstName": firstName,
            "lastName": lastName,
            "phoneNumber": phoneNumber,
            "password": password,
          })}");

      final responseData = jsonDecode(response.body);
      print("🔍 Received API Response: $responseData");

      if (response.statusCode == 200) {
        return {"success": true, "message": responseData["message"]};
      } else {
        return {
          "success": false,
          "error": responseData["error"] ?? "Invalid OTP"
        };
      }
    } catch (e) {
      print("❌ Error in verifyOtp: $e");
      return {"success": false, "error": "Failed to verify OTP"};
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
    print("📡 Loaded Name: $fullName");
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
    if (_userId == null) {
      print("❌ No user ID found in storage.");
      return;
    }

    try {
      String apiUrl = "$baseUrl/users/get-profile-picture/$_userId";
      print("📡 Fetching profile picture for User ID: $_userId from $apiUrl");

      final response = await http.get(Uri.parse(apiUrl));

      print("🔍 Server Response Code: ${response.statusCode}");
      print("🔍 Raw Response Body: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // ✅ Ensure response contains the expected keys
        if (data["success"] == true && data.containsKey("image")) {
          _profileImageUrl = data["image"];
          notifyListeners(); // ✅ Only update UI if response is valid
          print("✅ Profile picture loaded successfully!");
        } else {
          print("❌ No profile picture found.");
        }
      } else {
        print("❌ Error fetching profile picture: ${response.body}");
      }
    } catch (e) {
      print("❌ Error fetching profile picture: $e");
    }

    notifyListeners();
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
      Future.delayed(Duration.zero, () {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text("✅ Profile picture updated successfully!"),
                backgroundColor: Colors.green),
          );
        }
      });
    }
  }

  // ✅ Upload Profile Picture with Size Validation
  Future<void> uploadProfilePicture(
      BuildContext context, String userId, File imageFile) async {
    if (imageFile == null || userId.isEmpty) {
      print("❌ No image selected or user ID is missing.");
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

      final responseData = jsonDecode(response.body);
      if (response.statusCode == 200) {
        // ✅ Extract new profile image URL from response
        final data = jsonDecode(response.body);
        if (data.containsKey("image_url")) {
          _profileImageUrl = data["image_url"];

          // ✅ Show Snackbar inside a Future.delayed to ensure context is valid
          Future.delayed(Duration.zero, () {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                    content: Text(responseData["message"]),
                    backgroundColor: Colors.green),
              );
            }
          });

          print("✅ Profile picture uploaded successfully!");
          // ✅ Show Snackbar based on Response Message

          // ✅ Refresh profile image
          await fetchProfilePicture();
        }
      } else {
        print("❌ Failed to upload profile picture: ${response.reasonPhrase}");

        // ✅ Ensure Snackbar only runs if context is still valid
        Future.delayed(Duration.zero, () {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text("❌ Failed to upload profile picture."),
                  backgroundColor: Colors.red),
            );
          }
        });
      }
    } catch (e) {
      print("❌ Error uploading profile picture: $e");

      // ✅ Ensure Snackbar only runs if context is still valid
      Future.delayed(Duration.zero, () {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text("❌ An error occurred while uploading."),
                backgroundColor: Colors.red),
          );
        }
      });
    }
  }
}
