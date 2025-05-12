import 'dart:convert';
import 'dart:io';
import 'package:adventura/Reels/widgets/comment_sheet.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:adventura/config.dart';
import 'package:http_parser/http_parser.dart';

class ReelService {
  static Future<Map<String, dynamic>> uploadReelToServer({
    required XFile? videoFile,
    required String description,
  }) async {
    if (videoFile == null || description.isEmpty) {
      return {"success": false, "error": "Missing video or description."};
    }

    try {
      final accessToken = Hive.box('authBox').get("accessToken");
      if (accessToken == null) {
        return {"success": false, "error": "User not authenticated."};
      }

      final uri = Uri.parse('$baseUrl/reels/upload');

      final request = http.MultipartRequest('POST', uri)
        ..headers['Authorization'] = 'Bearer $accessToken'
        ..fields['description'] = description
        ..files.add(await http.MultipartFile.fromPath(
          'video',
          videoFile.path,
          contentType: MediaType('video', 'mp4'),
        ));

      final response = await request.send();
      final respStr = await response.stream.bytesToString();

      if (response.statusCode == 201) {
        return {"success": true, "message": "Reel uploaded successfully"};
      } else {
        print("❌ Backend error: $respStr");
        return {
          "success": false,
          "error": jsonDecode(respStr)['error'] ?? 'Upload failed'
        };
      }
    } catch (e) {
      print("❌ Exception during upload: $e");
      return {"success": false, "error": "Unexpected error during upload"};
    }
  }

  static Future<List<Map<String, dynamic>>> fetchReelsFromServer() async {
    try {
      final accessToken = Hive.box('authBox').get("accessToken");
      final response = await http.get(
        Uri.parse('$baseUrl/reels'),
        headers: {
          "Authorization": "Bearer $accessToken",
          "Content-Type": "application/json"
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return List<Map<String, dynamic>>.from(data);
      } else {
        print("❌ Failed to fetch reels: ${response.body}");
        return [];
      }
    } catch (e) {
      print("❌ Exception while fetching reels: $e");
      return [];
    }
  }

  static Future<Map<String, dynamic>> toggleReelLike(int reelId) async {
    try {
      final accessToken = Hive.box('authBox').get("accessToken");
      final response = await http.post(
        Uri.parse('$baseUrl/reels/$reelId/like'),
        headers: {"Authorization": "Bearer $accessToken"},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {"success": true, "liked": data["liked"]};
      }
      return {"success": false, "error": "Failed to toggle like"};
    } catch (e) {
      return {"success": false, "error": e.toString()};
    }
  }

  static Future<int> getReelLikes(int reelId) async {
    try {
      final response =
          await http.get(Uri.parse('$baseUrl/reels/$reelId/likes'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data["likes"] ?? 0;
      }
      return 0;
    } catch (e) {
      return 0;
    }
  }

  static Future<bool> didUserLikeReel(
      {required String userId, required int reelId}) async {
    // (Optional: implement if your backend supports this. Otherwise always false.)
    return false;
  }

  static void openCommentsSheet(BuildContext context, {required int reelId}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.grey[900],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (context) => CommentSheet(reelId: reelId),
    );
  }
}
