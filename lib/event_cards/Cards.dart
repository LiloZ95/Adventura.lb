import 'dart:ui';
import 'package:adventura/event_cards/eventDetailsScreen.dart';
import 'package:flutter/material.dart';
import 'package:adventura/utils.dart';

String? _calculateDuration(String? from, String? to) {
  if (from == null || to == null) return null;

  final regex = RegExp(r'^(\d{1,2}):(\d{2}) (AM|PM)$');

  TimeOfDay parse(String timeStr) {
    final match = regex.firstMatch(timeStr.trim());
    if (match == null) throw FormatException("Invalid time format");
    int hour = int.parse(match.group(1)!);
    int minute = int.parse(match.group(2)!);
    final meridian = match.group(3);
    if (meridian == "PM" && hour < 12) hour += 12;
    if (meridian == "AM" && hour == 12) hour = 0;
    return TimeOfDay(hour: hour, minute: minute);
  }

  try {
    final now = DateTime.now();
    final fromTime = parse(from);
    final toTime = parse(to);
    final start =
        DateTime(now.year, now.month, now.day, fromTime.hour, fromTime.minute);
    final end =
        DateTime(now.year, now.month, now.day, toTime.hour, toTime.minute);
    final diff = end.difference(start);

    if (diff.inMinutes <= 0) return null;
    final h = diff.inHours;
    final m = diff.inMinutes % 60;
    if (h > 0 && m > 0) return "$h h $m min";
    if (h > 0) return "$h hour${h == 1 ? '' : 's'}";
    return "$m min";
  } catch (_) {
    return null;
  }
}

Widget EventCard({
  required BuildContext context,
  required Map<String, dynamic> activity,
}) {
  String imagePath = getImageUrl(activity);
  String? duration =
      _calculateDuration(activity["from_time"], activity["to_time"]);

  final List<dynamic> rawFeatures = activity["features"] ?? [];
  List<String> featureNames = rawFeatures
      .map((f) => f["name"]?.toString())
      .where((f) => f != null && f.isNotEmpty)
      .cast<String>()
      .toList();

  // Prioritize "Trending" (or any colored tags later)
  featureNames.sort((a, b) {
    if (a.toLowerCase() == "trending") return -1;
    if (b.toLowerCase() == "trending") return 1;
    return 0;
  });

  return GestureDetector(
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => EventDetailsScreen(activity: activity),
        ),
      );
    },
    child: Padding(
      padding: const EdgeInsets.only(left: 16, right: 16, bottom: 10),
      child: Container(
        width: 380,
        height: 300,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.70),
              offset: Offset(0, 1),
              blurRadius: 5,
              spreadRadius: 0,
            ),
          ],
        ),
        child: Stack(
          children: [
            // 📷 Image
            ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: imagePath.isNotEmpty
                  ? Image.network(
                      imagePath,
                      width: 380,
                      height: 208,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Image.asset(
                          "assets/Pictures/island.jpg",
                          width: 380,
                          height: 208,
                          fit: BoxFit.cover,
                        );
                      },
                    )
                  : Image.asset(
                      "assets/Pictures/island.jpg",
                      width: 380,
                      height: 208,
                      fit: BoxFit.cover,
                    ),
            ),

            // 🕒 Duration Badge (Top Right)
            if (duration != null)
              Positioned(
                top: 10,
                right: 10,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.schedule, size: 14, color: Colors.white),
                      SizedBox(width: 4),
                      Text(
                        duration,
                        style: TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ),

            // 🌅 Gradient Overlay at Bottom
            Positioned(
              bottom: 72,
              left: 0,
              right: 0,
              child: Container(
                height: 120,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.white.withOpacity(0),
                      Colors.white,
                      Colors.white,
                    ],
                  ),
                ),
              ),
            ),

            // 📋 Info + Tags
            Positioned(
              bottom: 12,
              left: 16,
              right: 16,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 🔠 Title
                  Text(
                    activity["name"] ?? "Unknown Activity",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Poppins',
                    ),
                  ),
                  SizedBox(height: 4),

                  // 📅 Date
                  Row(
                    children: [
                      Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                      SizedBox(width: 4),
                      Text(
                        activity["date"] ?? "Ongoing",
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ],
                  ),

                  // 📍 Location
                  Row(
                    children: [
                      Icon(Icons.location_on, size: 16, color: Colors.grey),
                      SizedBox(width: 4),
                      Text(
                        activity["location"] ?? "Unknown Location",
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 6),

                  // 🏷️ Features (Wrapped)
                  if (featureNames.isNotEmpty)
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      children: featureNames.map((tag) {
                        final isTrending = tag.toLowerCase() == "trending";
                        return Container(
                          padding:
                              EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            gradient: isTrending
                                ? LinearGradient(
                                    colors: [Colors.orange, Colors.red])
                                : null,
                            color: isTrending ? null : Colors.grey.shade200,
                          ),
                          child: Text(
                            tag,
                            style: TextStyle(
                              fontSize: 12,
                              color: isTrending ? Colors.white : Colors.black87,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                ],
              ),
            ),

            // 💰 Price
            Positioned(
              bottom: 12,
              right: 16,
              child: Text(
                activity["price"] != null ? "\$${activity["price"]}" : "Free",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                  fontFamily: 'Poppins',
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

Widget card(String imagePath) {
  return Padding(
    padding: const EdgeInsets.only(left: 16),
    child: Container(
      width: 240,
      height: 320,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        image: DecorationImage(
          image: AssetImage('assets/Pictures/$imagePath'),
          fit: BoxFit.cover, // Ensures the image covers the container
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.70),
            offset: Offset(0, 1),
            blurRadius: 5,
            spreadRadius: 0,
          ),
        ],
      ),
    ),
  );
}

Widget card2(String imagePath, String categoryName, String description,
    int listings, double align) {
  return Padding(
    padding: const EdgeInsets.only(left: 16),
    child: Container(
      width: 320,
      height: 240,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        image: DecorationImage(
          image: AssetImage('assets/Pictures/$imagePath'),
          fit: BoxFit.cover,
          alignment: Alignment(0, align),
          // Ensures the image covers the container
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.70),
            offset: Offset(0, 1),
            blurRadius: 5,
            spreadRadius: 0, // Spread = 0
          ),
        ],
      ),
      child: Stack(
        children: [
          // Gradient and blur overlay
          Align(
            alignment: Alignment.bottomCenter,
            child: ClipRRect(
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(15),
                bottomRight: Radius.circular(15),
              ),
              child: BackdropFilter(
                filter:
                    ImageFilter.blur(sigmaX: 2.0, sigmaY: 2.0), // Blur effect
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.black.withOpacity(0.7),
                        Colors.black.withOpacity(0.5),
                      ],
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                    ),
                  ),
                  padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            categoryName,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Poppins',
                            ),
                          ),
                          Text(
                            '($listings listings)',
                            style: TextStyle(
                              color: Colors.blueAccent,
                              fontSize: 12,
                              fontFamily: 'Poppins',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        description,
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 10,
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
