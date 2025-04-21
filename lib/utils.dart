// utils.dart
import 'package:adventura/config.dart';

String? getImageUrl(Map<String, dynamic> activity) {
  if (activity.containsKey("activity_images") &&
      activity["activity_images"] is List) {
    List<dynamic> images = activity["activity_images"];

    if (images.isNotEmpty) {
      var first = images[0];
      if (first is String && first.isNotEmpty) {
        return first.startsWith("http") ? first : "$baseUrl$first";
      } else if (first is Map && first.containsKey("image_url")) {
        final url = first["image_url"];
        if (url != null && url.toString().isNotEmpty) {
          return url.toString().startsWith("http")
              ? url
              : "$baseUrl${url.toString()}";
        }
      }
    }
  }

  // ⛔️ Return null instead of default asset — so we know it's missing!
  return null;
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
