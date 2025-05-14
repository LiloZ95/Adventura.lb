import 'dart:convert';
import 'package:adventura/config.dart';
import 'package:adventura/utils.dart';
import 'package:flutter/material.dart';
import 'package:adventura/Chatbot/circularGlow.dart';
import 'package:http/http.dart' as http;

class ActivityCard extends StatefulWidget {
  final Map<String, dynamic> card;
  const ActivityCard({Key? key, required this.card}) : super(key: key);

  @override
  State<ActivityCard> createState() => _ActivityCardState();
}

class _ActivityCardState extends State<ActivityCard> {
  late Future<String?> _imageUrlFuture;

  @override
  void initState() {
    super.initState();
    _imageUrlFuture = _fetchImageUrl();
  }

  Future<String?> _fetchImageUrl() async {
    final int? activityId = widget.card['cardId'];
    if (activityId == null) return null;

    final url = '$baseUrl/activities/$activityId/thumbnail';
    print("📤 Fetching thumbnail: $url");

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print("📥 Got image URL: ${data['image_url']}");
        return data['image_url'];
      } else {
        print("❌ Failed to load image: ${response.statusCode}");
      }
    } catch (e) {
      print("❌ Exception fetching image: $e");
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    final bool isTrending = widget.card['is_trending'] ?? false;

    return isTrending
        ? CircularGlowBorder(child: _buildCardWithImage())
        : _buildCardWithImage();
  }

  Widget _buildCardWithImage() {
    return FutureBuilder<String?>(
      future: _imageUrlFuture,
      builder: (context, snapshot) {
        Widget imageWidget;

        if (snapshot.connectionState == ConnectionState.waiting) {
          imageWidget = Container(
            width: 120,
            height: 130,
            color: Colors.grey.shade200,
            child: const Center(
                child: CircularProgressIndicator(strokeWidth: 1.5)),
          );
        } else if (snapshot.hasData && snapshot.data != null) {
          imageWidget = Image.network(
            snapshot.data!,
            width: 120,
            height: 130,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Image.asset(
                'assets/Pictures/sunset.jpg',
                width: 120,
                height: 130,
                fit: BoxFit.cover,
              );
            },
          );
        } else {
          imageWidget = Image.asset(
            'assets/Pictures/sunset.jpg',
            width: 120,
            height: 130,
            fit: BoxFit.cover,
          );
        }

        return _buildCard(imageWidget);
      },
    );
  }

  Widget _buildCard(Widget image) {
    final card = widget.card;
    final String name = card['name'] ?? 'Unnamed';
    final String location = card['location'] ?? 'Unknown';
    final int seats = card['seats'] ?? 0;
    final double price = (card['price'] ?? 0).toDouble();
    final String dateLabel = card['date_label'] ?? 'TBA';

    return Card(
      color: Colors.white,
      margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        padding: const EdgeInsets.all(8),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: image,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// Title
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'poppins',
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),

                  /// Date
                  Row(
                    children: [
                      const Icon(Icons.calendar_today,
                          size: 14, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(
                        dateLabel,
                        style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                            fontFamily: "poppins"),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),

                  /// Location
                  Row(
                    children: [
                      const Icon(Icons.location_on,
                          size: 14, color: Colors.grey),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          location,
                          style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                              fontFamily: "poppins"),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),

                  /// Tags
                  Row(
                    children: [
                      _infoTag(Icons.group, '$seats'),
                      const SizedBox(width: 6),
                      _infoTag(null, '+16'),
                    ],
                  ),
                  const SizedBox(height: 12),

                  /// Price
                  Row(
                    children: [
                      Text(
                        "\$$price",
                        style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                            fontFamily: "poppins"),
                      ),
                      const Text(
                        "/person",
                        style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                            fontFamily: "poppins"),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoTag(IconData? icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade400, width: 0.5),
      ),
      child: Row(
        children: [
          if (icon != null) Icon(icon, size: 14, color: Colors.black),
          if (icon != null) const SizedBox(width: 4),
          Text(
            text,
            style: const TextStyle(fontSize: 12, fontFamily: "poppins"),
          ),
        ],
      ),
    );
  }
}
