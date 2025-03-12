import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart'; // For filename extraction
// import 'package:shared_preferences/shared_preferences.dart';
import 'package:hive/hive.dart'; // ✅ Replace SharedPreferences with Hive

class ProfileService {
  static const String baseUrl = 'http://localhost:3000';

  /// ✅ Fetch Profile Picture
  static Future<String> fetchProfilePicture(String userId) async {
    final response =
        await http.get(Uri.parse("$baseUrl/users/get-profile-picture/$userId"));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data["image"] != null && data["image"].isNotEmpty) {
        print("✅ Profile picture updated: ${data["image"]}");

        // ✅ Save in Hive
        Box storageBox = await Hive.openBox('authBox');
        storageBox.put("profilePicture", data["image"]);

        return data["image"];
      } else {
        print("❌ Response did not contain an image.");
        return "";
      }
    } else {
      print(
          "❌ Failed to fetch profile picture. Server responded with: ${response.statusCode}");
      return "";
    }
  }

  /// ✅ Pick an Image from Gallery
  static Future<File?> pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    return pickedFile != null ? File(pickedFile.path) : null;
  }

  /// ✅ Upload Profile Picture
  static Future<bool> uploadProfilePicture(
      BuildContext context, String userId, File imageFile) async {
    if (userId.isEmpty) {
      print("❌ No user ID found. Cannot upload profile picture.");
      return false;
    }

    int imageSizeInBytes = await imageFile.length();
    double imageSizeInMB = imageSizeInBytes / (1024 * 1024);
    if (imageSizeInMB > 3) {
      print(
          "❌ Image is too large (${imageSizeInMB.toStringAsFixed(2)} MB). Max: 3MB");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text("❌ Image size must be less than 3MB."),
            backgroundColor: Colors.red),
      );
      return false;
    }

    try {
      String apiUrl = '$baseUrl/users/upload-profile-picture';
      print(
          "📤 Uploading image: ${imageFile.path} (${imageSizeInMB.toStringAsFixed(2)} MB)");
      print("📡 Sending request to: $apiUrl");

      var request = http.MultipartRequest('POST', Uri.parse(apiUrl));
      request.fields['user_id'] = userId;
      request.files.add(await http.MultipartFile.fromPath(
        'image',
        imageFile.path,
        filename: basename(imageFile.path),
      ));

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      print("🔍 Server Response Code: ${response.statusCode}");
      print("🔍 Response Body: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        if (responseData["success"] == true) {
          String? profileImageUrl = responseData["image"];
          if (profileImageUrl != null && profileImageUrl.isNotEmpty) {
            Box storageBox = await Hive.openBox('authBox');
            storageBox.put("profilePicture", profileImageUrl);

            print("✅ Profile picture updated successfully!");
            return true;
          }
        }
      }

      print("❌ Failed to upload profile picture.");
      return false;
    } catch (e) {
      print("❌ Error uploading profile picture: $e");
      return false;
    }
  }
}
