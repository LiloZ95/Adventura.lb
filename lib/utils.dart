// utils.dart
import 'package:adventura/config.dart';

String getImageUrl(Map<String, dynamic> activity) {
  if (activity.containsKey("activity_images") &&
      activity["activity_images"] is List) {
    List<dynamic> images = activity["activity_images"];

    // ✅ If the list contains strings directly, return the first valid URL
    if (images.isNotEmpty && images[0] is String) {
      String imageUrl = images[0];

      if (imageUrl.isNotEmpty) {
        print("🟢 Valid Image URL: $imageUrl"); // Debugging

        // ✅ Ensure the URL is complete (handles both absolute and relative paths)
        return imageUrl.startsWith("http") ? imageUrl : "$baseUrl$imageUrl";
      }
    }
  }

  print("❌ No valid image found, using default.");
  return "assets/Pictures/island.jpg"; // ✅ Default image
}

String getEventImageUrl(Map<String, dynamic> event) {
  if (event.containsKey("activity_images") &&
      event["activity_images"] is List &&
      event["activity_images"].isNotEmpty) {
    final image = event["activity_images"][0];
    final imageUrl = image["image_url"];

    if (imageUrl != null && imageUrl.isNotEmpty) {
      return imageUrl.startsWith("http") ? imageUrl : "$baseUrl/$imageUrl";
    }
  }

  // 🛟 Fallback to asset image if no valid image was found
  return 'assets/Pictures/island.jpg';
}
