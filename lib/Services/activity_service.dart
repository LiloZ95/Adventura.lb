import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:hive/hive.dart'; // ✅ Use Hive instead of StorageService
import 'package:adventura/config.dart'; // ✅ Import the global config file

class ActivityService {
  /// ✅ Create Activity
  static Future<bool> createActivity(Map<String, dynamic> activityData) async {
    final url = Uri.parse('$baseUrl/activities/create');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(activityData),
    );

    if (response.statusCode == 201) {
      return true;
    } else {
      print('❌ Failed to create activity: ${response.body}');
      return false;
    }
  }

  /// ✅ Fetch Categories
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
  static Future<List<Map<String, dynamic>>> fetchActivities() async {
    Box storageBox = await Hive.openBox('authBox'); // ✅ Open Hive
    String? accessToken = storageBox.get("accessToken");

    print("🔍 Debugging Hive Storage...");
    print("🔑 Stored Access Token: $accessToken");

    if (accessToken == null) {
      print("❌ No access token found in Hive.");
      return [];
    }

    try {
      final response = await http.get(
        Uri.parse("$baseUrl/activities"),
        headers: {
          "Authorization": "Bearer $accessToken",
          "Content-Type": "application/json",
        },
      );

      print("🔍 API Response Code: ${response.statusCode}");
      print("🔍 API Response Body: ${response.body}");

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data is Map && data.containsKey("activities")) {
          print("✅ Successfully fetched activities.");
          return List<Map<String, dynamic>>.from(data["activities"]);
        }

        if (data is List) {
          print("✅ Successfully fetched activities (List format).");
          return data
              .map<Map<String, dynamic>>((activity) => parseActivity(activity))
              .toList();
        }

        print("❌ Unexpected API response format.");
      } else {
        print("❌ Failed to fetch activities. Error: ${response.body}");
      }
    } catch (e) {
      print("❌ Error fetching activities: $e");
    }

    return [];
  }

  /// ✅ Fetch All Events from API
  static Future<List<Map<String, dynamic>>> fetchEvents() async {
    Box storageBox = await Hive.openBox('authBox');
    String? accessToken = storageBox.get("accessToken");

    if (accessToken == null) {
      print("❌ No access token found.");
      return [];
    }

    try {
      final response = await http.get(
        Uri.parse("$baseUrl/events"),
        headers: {
          "Authorization": "Bearer $accessToken",
          "Content-Type": "application/json",
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data.containsKey("events")) {
          return List<Map<String, dynamic>>.from(data["events"]);
        }
      }

      throw Exception("Failed to fetch events");
    } catch (e) {
      print("❌ Error fetching events: $e");
      return [];
    }
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
      print("🔍 API Response Body: ${response.body}");

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

          // 🔍 Debugging image URLs for each activity
          // for (var activity in activities) {
          //   print("🔍 Checking activity: ${activity["name"]}");

          //   if (activity.containsKey("activity_images")) {
          //     print(
          //         "🖼 Found images for '${activity["name"]}': ${activity["activity_images"]}");
          //   } else {
          //     print(
          //         "❌ No 'activity_images' field found for '${activity["name"]}'");
          //   }
          // }

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
}
