// location_utils.dart
import 'package:http/http.dart' as http;

List<double>? extractLatLng(String url) {
  final atRegex = RegExp(r'@(-?\d+\.\d+),\s*(-?\d+\.\d+)');
  final matchAt = atRegex.firstMatch(url);
  if (matchAt != null) {
    return [
      double.parse(matchAt.group(1)!),
      double.parse(matchAt.group(2)!),
    ];
  }

  final dRegex = RegExp(r'!3d(-?\d+\.\d+)!4d(-?\d+\.\d+)');
  final matchD = dRegex.firstMatch(url);
  if (matchD != null) {
    return [
      double.parse(matchD.group(1)!),
      double.parse(matchD.group(2)!),
    ];
  }

  return null;
}

String extractPlaceName(String url) {
  final uri = Uri.tryParse(url);
  if (uri == null) return "Unknown Location";
  final segments = uri.pathSegments;

  for (int i = 0; i < segments.length; i++) {
    if (segments[i] == "place" && i + 1 < segments.length) {
      return segments[i + 1].replaceAll(RegExp(r'[-+]'), ' ');
    }
  }
  return "Unknown Location";
}

Future<String?> resolveShortLink(String url) async {
  try {
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200 || response.statusCode == 302) {
      return response.request?.url.toString();
    }
  } catch (e) {
    print("Failed to resolve short link: $e");
  }
  return null;
}
