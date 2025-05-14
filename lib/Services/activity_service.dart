import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:hive/hive.dart'; // ✅ Use Hive instead of StorageService
import 'package:adventura/config.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import 'package:http_parser/http_parser.dart';

class ActivityService {
  /// ✅ Create Activity
  static Future<bool> createActivity(
    Map<String, dynamic> activityData, {
    List<XFile>? images,
  }) async {
    Box authBox = await Hive.openBox('authBox');
    String? accessToken = authBox.get("accessToken");

    try {
      // 1. Create activity
      final activityResponse = await http.post(
        Uri.parse('$baseUrl/activities/create'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode(activityData),
      );

      print("🔑 Token being sent: $accessToken");

      if (activityResponse.statusCode < 200 ||
          activityResponse.statusCode >= 300) {
        print(
            "❌ Activity creation failed (Status ${activityResponse.statusCode}): ${activityResponse.body}");
        return false;
      }

      final decoded = jsonDecode(activityResponse.body);
      final activityId = decoded?['activity']?['activity_id'];

      if (activityId == null) {
        print("❌ Activity ID not returned from backend.");
        return false;
      }

      // 2. Upload images if provided
      if (images != null && images.isNotEmpty) {
        var request = http.MultipartRequest(
          'POST',
          Uri.parse(
            '$baseUrl/activities/activity-images/upload/$activityId?listing_type=${activityData["listing_type"]}',
          ),
        );

        request.headers['Authorization'] = 'Bearer $accessToken';

        for (var image in images) {
          final ext = path.extension(image.path).toLowerCase();
          String mimeType = 'jpeg'; // default

          if (ext == '.png')
            mimeType = 'png';
          else if (ext == '.gif')
            mimeType = 'gif';
          else if (ext == '.webp')
            mimeType = 'webp';
          else if (ext == '.heic') mimeType = 'heic';

          print("Uploading image: ${image.path}");

          request.files.add(await http.MultipartFile.fromPath(
            'images',
            image.path,
            filename: path.basename(image.path),
            contentType: MediaType('image', mimeType),
          ));
        }

        final response = await request.send();

        if (response.statusCode != 200) {
          final responseBody = await response.stream.bytesToString();
          print(
              "❌ Image upload failed → Status: ${response.statusCode}, Body: $responseBody");
          return false;
        }

        print("✅ Images uploaded successfully.");
      }

      return true;
    } catch (e) {
      print("❌ Error creating activity: $e");
      return false;
    }
  }

  static Future<bool> deleteActivity(String activityId) async {
    final box = await Hive.openBox('authBox');
    String? accessToken = box.get("accessToken");

    if (accessToken == null) {
      throw Exception("No access token found.");
    }

    final url = Uri.parse('$baseUrl/activities/$activityId');

    final response = await http.delete(
      url,
      headers: {
        "Authorization": "Bearer $accessToken",
        "Content-Type": "application/json",
      },
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      print("❌ Failed to delete activity: ${response.body}");
      return false;
    }
  }

  static Future<List<Map<String, dynamic>>> fetchProviderListings(
      int providerId) async {
    Box storageBox = await Hive.openBox('authBox');
    String? accessToken = storageBox.get("accessToken");

    if (accessToken == null) return [];

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/activities/by-provider/$providerId?available=true'),
        headers: {
          "Authorization": "Bearer $accessToken",
          "Content-Type": "application/json",
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return List<Map<String, dynamic>>.from(data["activities"]);
      } else {
        print("❌ Failed to fetch listings: ${response.body}");
      }
    } catch (e) {
      print("❌ Error fetching listings: $e");
    }

    return [];
  }

  static Future<Map<String, List<Map<String, dynamic>>>> fetchExpiredListings(
      int providerId) async {
    final url = Uri.parse('$baseUrl/activities/expired/$providerId');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      if (body["success"]) {
        return {
          "oneTime": List<Map<String, dynamic>>.from(body["oneTime"] ?? []),
          "recurrent": List<Map<String, dynamic>>.from(body["recurrent"] ?? []),
        };
      }
    }

    return {
      "oneTime": [],
      "recurrent": [],
    };
  }

  static Future<bool> uploadActivityImages({
    required int activityId,
    required List<File> imageFiles,
  }) async {
    Box storageBox = await Hive.openBox('authBox');
    String? accessToken = storageBox.get("accessToken");

    if (accessToken == null) {
      print("❌ No access token found.");
      return false;
    }

    var uri = Uri.parse('$baseUrl/activity-images/upload/$activityId');
    var request = http.MultipartRequest('POST', uri);

    request.headers['Authorization'] = 'Bearer $accessToken';

    try {
      for (var file in imageFiles) {
        var multipartFile =
            await http.MultipartFile.fromPath('images', file.path);
        request.files.add(multipartFile);
      }

      var response = await request.send();

      if (response.statusCode == 200) {
        print("✅ Images uploaded successfully.");
        return true;
      } else {
        print("❌ Failed to upload images. Status: ${response.statusCode}");
        return false;
      }
    } catch (e) {
      print("❌ Exception during image upload: $e");
      return false;
    }
  }

  /// ✅ Fetch Categories (used in CategorySelector)
  static Future<List<Map<String, dynamic>>> fetchCategories() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/categories'));

      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(jsonDecode(response.body));
      }
    } catch (e) {
      print("❌ Error fetching categories: $e");
    }
    return [];
  }

  /// ✅ Fetch Activities with Images
  static Future<List<Map<String, dynamic>>> fetchActivities({
    String? search,
    String? category,
    String? location,
    double? minPrice,
    double? maxPrice,
    int? rating,
  }) async {
    Box storageBox = await Hive.openBox('authBox');
    String? accessToken = storageBox.get("accessToken");

    if (accessToken == null) return [];

    final queryParams = <String, String>{};
    if (search != null && search.isNotEmpty) queryParams['search'] = search;
    if (category != null) queryParams['category'] = category;
    if (location != null) queryParams['location'] = location;
    if (minPrice != null) queryParams['min_price'] = minPrice.toString();
    if (maxPrice != null) queryParams['max_price'] = maxPrice.toString();
    if (rating != null) queryParams['rating'] = rating.toString();

    final uri =
        Uri.parse("$baseUrl/activities").replace(queryParameters: queryParams);
    try {
      final response = await http.get(
        uri,
        headers: {
          "Authorization": "Bearer $accessToken",
          "Content-Type": "application/json",
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data is Map && data.containsKey("activities")) {
          return List<Map<String, dynamic>>.from(data["activities"]);
        }

        if (data is List) {
          return data
              .map<Map<String, dynamic>>((activity) => parseActivity(activity))
              .toList();
        }
      } else {
        print("❌ Failed to fetch activities: ${response.body}");
      }
    } catch (e) {
      print("❌ Error fetching activities: $e");
    }

    return [];
  }

  /// ✅ Fetch Events with Filtering Support
  static Future<List<Map<String, dynamic>>> fetchEvents({
    String? search,
    String? category,
    String? location,
    double? minPrice,
    double? maxPrice,
    int? rating,
    String? listingType, // ✅ Add this line
  }) async {
    Box storageBox = await Hive.openBox('authBox');
    String? accessToken = storageBox.get("accessToken");

    if (accessToken == null) {
      print("❌ No access token found.");
      return [];
    }

    final queryParams = <String, String>{};
    if (listingType != null) queryParams['type'] = listingType;
    if (search != null && search.isNotEmpty) queryParams['search'] = search;
    if (category != null) queryParams['category'] = category;
    if (location != null) queryParams['location'] = location;
    if (minPrice != null) queryParams['min_price'] = minPrice.toString();
    if (maxPrice != null) queryParams['max_price'] = maxPrice.toString();
    if (rating != null) queryParams['rating'] = rating.toString();
    queryParams['type'] = 'event'; // 🔥 THIS IS MISSING

    final uri =
        Uri.parse("$baseUrl/activities").replace(queryParameters: queryParams);

    try {
      final response = await http.get(
        uri,
        headers: {
          "Authorization": "Bearer $accessToken",
          "Content-Type": "application/json",
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data is Map && data.containsKey("activities")) {
          return List<Map<String, dynamic>>.from(data["activities"]);
        }
      } else {
        print("❌ Failed to fetch events: ${response.body}");
      }
    } catch (e) {
      print("❌ Error fetching events: $e");
    }

    return [];
  }

  /// ✅ Fetch Recommended Activities for a User
  static Future<List<Map<String, dynamic>>> fetchRecommendedActivities(
      int userId) async {
    Box storageBox = await Hive.openBox('authBox');
    String? accessToken = storageBox.get("accessToken");

    if (accessToken == null) {
      print("❌ No access token found in Hive.");
      return [];
    }

    try {
      final response = await http.get(
        Uri.parse("$recommendationsUrl?user_id=$userId"),
        headers: {
          "Authorization": "Bearer $accessToken",
          "Content-Type": "application/json",
        },
      );

      print("🔍 API Response Code: ${response.statusCode}");

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data["success"] == true && data["recommendations"] is List) {
          List<int> recommendedIds = [];
          for (var rec in data["recommendations"]) {
            if (rec is Map<String, dynamic> && rec.containsKey("id")) {
              recommendedIds.add(rec["id"]);
            }
          }

          print("✅ Recommended Activity IDs: $recommendedIds");

          // ✅ Fetch detailed activity data from backend
          return await fetchActivitiesByIds(recommendedIds);
        } else {
          print("❌ Unexpected API Response Structure: $data");
        }
      } else {
        print("❌ API Error ${response.statusCode}: ${response.body}");
      }
    } catch (e) {
      print("❌ Error fetching recommendations: $e");
    }

    return [];
  }

  static Future<List<Map<String, dynamic>>> fetchActivitiesByIds(
      List<int> activityIds) async {
    if (activityIds.isEmpty) {
      return [];
    }

    try {
      final response = await http.post(
        Uri.parse("$baseUrl/activities/details"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"activity_ids": activityIds}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data is Map<String, dynamic> && data.containsKey("activities")) {
          List<Map<String, dynamic>> activities =
              List<Map<String, dynamic>>.from(data["activities"]);

          // 🔍 Debugging Print (Right After Receiving API Response)
          print("🔍 activitie Response: ${activities}");

          // 🔍 Ensure the correct order of activities and proper image processing
          List<Map<String, dynamic>> orderedActivities = activityIds
              .map((id) => activities.firstWhere(
                    (activity) => activity["activity_id"] == id,
                    orElse: () => {}, // Return empty map if not found
                  ))
              .where((activity) => activity.isNotEmpty) // Remove empty results
              .map((activity) {
            // ✅ Ensure images are properly extracted as a list of URLs
            if (activity.containsKey("activity_images") &&
                activity["activity_images"] is List) {
              activity["activity_images"] = activity["activity_images"]
                  .map((img) => img["image_url"])
                  .toList();
            } else {
              activity["activity_images"] = [];
            }
            return activity;
          }).toList();

          return orderedActivities;
        }
      } else {
        print("❌ Error fetching activity details: ${response.statusCode}");
      }
    } catch (e) {
      print("❌ Error in fetchActivitiesByIds: $e");
    }

    return [];
  }

  /// ✅ Fetch Event Details by ID
  static Future<Map<String, dynamic>?> fetchEventById(int eventId) async {
    Box storageBox = await Hive.openBox('authBox');
    String? accessToken = storageBox.get("accessToken");

    try {
      final response = await http.get(
        Uri.parse("$baseUrl/events/$eventId"),
        headers: {
          "Authorization": "Bearer $accessToken",
          "Content-Type": "application/json",
        },
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
    } catch (e) {
      print("❌ Error fetching event details: $e");
    }

    return null;
  }

  // ✅ Function to Set an Image as Primary
  static Future<bool> setPrimaryImage(int activityId, int imageId) async {
    try {
      final response = await http.put(
        Uri.parse("$baseUrl/activities/set-primary"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"activity_id": activityId, "image_id": imageId}),
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        print("❌ Error setting primary image: ${response.body}");
        return false;
      }
    } catch (e) {
      print("❌ API Error: $e");
      return false;
    }
  }

  /// ✅ Helper function to parse activity data safely
  static Map<String, dynamic> parseActivity(Map<String, dynamic> json) {
    int parseInt(dynamic value) {
      if (value is int) return value;
      if (value is String) return int.tryParse(value) ?? 0;
      return 0;
    }

    return {
      "activity_id": parseInt(json["activity_id"]),
      "name": json["name"] ?? "Unknown Activity",
      "description": json["description"] ?? "No description available",
      "location": json["location"] ?? "Unknown Location",
      "price": parseInt(json["price"]),
      "duration": parseInt(json["duration"]),
      "availability_status": json["availability_status"] ?? true,
      "nb_seats": parseInt(json["nb_seats"]),
      "category_id": parseInt(json["category_id"]),
      "images": (json["activity_images"] is List &&
              json["activity_images"].isNotEmpty)
          ? List<String>.from(json["activity_images"]
              .map((img) => img["image_url"] ?? "assets/Pictures/island.jpg"))
          : ["assets/Pictures/island.jpg"],
    };
  }

  static String? getDurationDisplay(Map<String, dynamic> activity) {
    final from = activity['from_time'];
    final to = activity['to_time'];

    // print("🧪 getDurationDisplay → from_time: $from, to_time: $to");

    if (from == null || to == null) {
      print("⚠️ One of the times is null. Skipping duration display.");
      return null;
    }

    try {
      final regex = RegExp(r'^(\d{1,2}):(\d{2}) (AM|PM)$');

      TimeOfDay parse(String timeStr) {
        final match = regex.firstMatch(timeStr.trim());
        if (match == null)
          throw FormatException("Invalid time format → $timeStr");
        int hour = int.parse(match.group(1)!);
        int minute = int.parse(match.group(2)!);
        final meridian = match.group(3);
        if (meridian == "PM" && hour < 12) hour += 12;
        if (meridian == "AM" && hour == 12) hour = 0;
        return TimeOfDay(hour: hour, minute: minute);
      }

      final now = DateTime.now();
      final fromTime = parse(from);
      final toTime = parse(to);

      final start = DateTime(
          now.year, now.month, now.day, fromTime.hour, fromTime.minute);
      final end =
          DateTime(now.year, now.month, now.day, toTime.hour, toTime.minute);
      final diff = end.difference(start);

      if (diff.inMinutes <= 0) {
        print("❌ Duration is non-positive. Skipping badge.");
        return null;
      }

      final h = diff.inHours;
      final m = diff.inMinutes % 60;
      if (h > 0 && m > 0) return "$h h $m min";
      if (h > 0) return "$h hour${h == 1 ? '' : 's'}";
      return "$m min";
    } catch (e) {
      print("❌ Error parsing duration: $e");
      return null;
    }
  }
}
