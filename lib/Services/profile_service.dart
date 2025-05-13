import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart';
import 'package:hive/hive.dart';
import 'package:adventura/config.dart';

class ProfileService {
  /// ✅ Fetch Profile Picture
  static Future<String> fetchProfilePicture(String userId) async {
    final response =
        await http.get(Uri.parse("$baseUrl/users/get-profile-picture/$userId"));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data["image"] == null || data["image"].isEmpty) {
        print("ℹ️ No profile picture found, using default.");
        return "default";
      }

      await _cacheProfileImage(userId, data["image"]);
      return data["image"];
    }
    print("❌ Failed to fetch or decode profile picture.");
    return "";
  }

  /// ✅ Cache profile image (base64 or URL)
  static Future<void> _cacheProfileImage(
      String userId, String imageData) async {
    Box storageBox = await Hive.openBox('authBox');

    if (imageData.startsWith("data:image")) {
      try {
        final parts = imageData.split(',');
        if (parts.length != 2) {
          print("❌ Malformed base64 image data.");
          return;
        }

        String base64String = parts[1];
        Uint8List imageBytes = base64Decode(base64String);

        await storageBox.put("profileImageBytes_$userId", imageBytes);
        await storageBox.delete("profilePictureUrl_$userId");
        print("✅ Base64 image cached in Hive for user $userId.");
      } catch (e) {
        print("❌ Error decoding base64 image: $e");
      }
    } else if (imageData.startsWith("http")) {
      await storageBox.put("profilePictureUrl_$userId", imageData);
      await storageBox.delete("profileImageBytes_$userId");
      print("✅ URL cached in Hive for user $userId.");
    }
  }

  /// ✅ Pick an Image from Gallery
  static Future<File?> pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    return pickedFile != null ? File(pickedFile.path) : null;
  }

  /// ✅ Upload Image + Clear Old Cache
  static Future<bool> uploadProfilePicture(
      BuildContext context, String userId, File imageFile) async {
    if (userId.isEmpty) {
      print("❌ No user ID found.");
      return false;
    }

    int imageSizeInBytes = await imageFile.length();
    double imageSizeInMB = imageSizeInBytes / (1024 * 1024);
    if (imageSizeInMB > 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text("❌ Image size must be less than 3MB."),
            backgroundColor: Colors.red),
      );
      return false;
    }

    try {
      var request = http.MultipartRequest(
          'POST', Uri.parse('$baseUrl/users/upload-profile-picture'));
      request.fields['user_id'] = userId;
      request.files.add(await http.MultipartFile.fromPath(
          'image', imageFile.path,
          filename: basename(imageFile.path)));

      var response = await http.Response.fromStream(await request.send());

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        if (responseData["success"] == true) {
          await clearUserProfileCache(userId);
          print("✅ Cleared old image cache for user $userId.");
          return true;
        }
      }
      return false;
    } catch (e) {
      print("❌ Upload error: $e");
      return false;
    }
  }

  /// ✅ Clear profile image cache for a specific user
  static Future<void> clearUserProfileCache(String userId) async {
    Box storageBox = await Hive.openBox('authBox');
    await storageBox.delete("profileImageBytes_$userId");
    await storageBox.delete("profilePictureUrl_$userId");
  }
}
