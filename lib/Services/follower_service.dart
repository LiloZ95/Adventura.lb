import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config.dart';

class FollowerService {
  static Future<bool> followOrganizer(String userId, String providerId) async {
    final response = await http.post(
      Uri.parse('$baseUrl/followers/follow'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "user_id": int.parse(userId),
        "provider_id": int.parse(providerId),
      }),
    );
    return response.statusCode == 201;
  }

  static Future<bool> unfollowOrganizer(
      String userId, String providerId) async {
    final response = await http.post(
      Uri.parse('$baseUrl/followers/unfollow'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "user_id": int.parse(userId),
        "provider_id": int.parse(providerId),
      }),
    );
    return response.statusCode == 200;
  }

  static Future<int> getFollowersCount(String providerId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/followers/followers-count/$providerId'),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['followersCount'] ?? 0;
    }
    return 0;
  }

  static Future<bool> isFollowing(String userId, String providerId) async {
    final response = await http.get(
      Uri.parse(
          '$baseUrl/followers/is-following?user_id=$userId&provider_id=$providerId'),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['isFollowing'];
    }
    return false;
  }
}
