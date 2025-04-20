import 'dart:ui';
import 'package:adventura/Services/interaction_service.dart';
import 'package:adventura/event_cards/eventDetailsScreen.dart';
import 'package:adventura/Services/activity_service.dart';
import 'package:flutter/material.dart';
import 'package:adventura/utils.dart';
import 'package:hive/hive.dart';

// ignore: non_constant_identifier_names
Widget EventCard({
  required BuildContext context,
  required Map<String, dynamic> activity,
}) {
  String imagePath = getImageUrl(activity);
  final duration = ActivityService.getDurationDisplay(activity);

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
  final isDarkMode = Theme.of(context).brightness == Brightness.dark;

  return GestureDetector(
    onTap: () async {
      try {
        var box = await Hive.openBox('authBox');
        int? userId;
        final storedUserId = box.get('userId');
        if (storedUserId != null) {
          userId = int.tryParse(storedUserId.toString()); // 👈 safely convert
        }

        if (userId != null) {
          await InteractionService.logInteraction(
            userId: userId,
            activityId: activity["activity_id"],
            type: "view",
          );
          print("🟢 Success interaction");
        }
      } catch (e) {
        print("🔴 Failed to log view interaction: $e");
      }
      print("🧪 Activity data: ${activity}");

      Navigator.of(context).push(
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 800),
          reverseTransitionDuration: const Duration(milliseconds: 300),
          pageBuilder: (_, __, ___) => EventDetailsScreen(activity: activity),
          transitionsBuilder: (_, animation, __, child) {
            final curvedAnimation = CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutExpo,
            );

            return FadeTransition(
              opacity: curvedAnimation,
              child: ScaleTransition(
                scale: Tween<double>(begin: 0.92, end: 1.0)
                    .animate(curvedAnimation),
                child: child,
              ),
            );
          },
        ),
      );
    },
    child: Builder(
      builder: (context) {
        final isDarkMode = Theme.of(context).brightness == Brightness.dark;

        return Padding(
          padding: const EdgeInsets.only(left: 16, right: 16, bottom: 10),
          child: Container(
            width: 380,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              color: isDarkMode ? const Color(0xFF1C1C1E) : Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.70),
                  offset: Offset(0, 1),
                  blurRadius: 5,
                  spreadRadius: 0,
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(15)),
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
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        height: 60,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              isDarkMode
                                  ? const Color(0xFF1C1C1E).withOpacity(0.8)
                                  : Colors.white.withOpacity(0.8),
                            ],
                          ),
                        ),
                      ),
                    ),
                    if (activity["is_trending"] == true)
                      Positioned(
                        top: 10,
                        left: 10,
                        child: Container(
                          padding:
                              EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                                colors: [Colors.orange, Colors.red]),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black26,
                                blurRadius: 4,
                                offset: Offset(2, 2),
                              )
                            ],
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.whatshot,
                                  size: 16, color: Colors.white),
                              SizedBox(width: 4),
                              Text(
                                "Trending",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                  fontFamily: 'Poppins',
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        isDarkMode
                            ? Colors.transparent
                            : Colors.white.withOpacity(0.0),
                        isDarkMode
                            ? const Color(0xFF1C1C1E).withOpacity(0.7)
                            : Colors.white.withOpacity(0.7),
                        isDarkMode ? const Color(0xFF1C1C1E) : Colors.white,
                      ],
                    ),
                    borderRadius:
                        BorderRadius.vertical(bottom: Radius.circular(15)),
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        activity["name"] ?? "Unknown Activity",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Poppins',
                          color: isDarkMode ? Colors.white : Colors.black,
                        ),
                      ),
                      SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.calendar_today,
                              size: 16, color: Colors.grey),
                          SizedBox(width: 4),
                          Text(
                            activity["date"] ?? "Ongoing",
                            style: TextStyle(
                              fontSize: 14,
                              color: isDarkMode
                                  ? Colors.grey.shade300
                                  : Colors.grey,
                              fontFamily: 'Poppins',
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Icon(Icons.location_on, size: 16, color: Colors.grey),
                          SizedBox(width: 4),
                          Text(
                            activity["location"] ?? "Unknown Location",
                            style: TextStyle(
                              fontSize: 14,
                              color: isDarkMode
                                  ? Colors.grey.shade300
                                  : Colors.grey,
                              fontFamily: 'Poppins',
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 6),
                      if (featureNames.isNotEmpty)
                        Wrap(
                          spacing: 8,
                          runSpacing: 6,
                          children: featureNames.map((tag) {
                            final isTrending = tag.toLowerCase() == "trending";
                            return Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                gradient: isTrending
                                    ? LinearGradient(
                                        colors: [Colors.orange, Colors.red])
                                    : null,
                                color: isTrending
                                    ? null
                                    : (isDarkMode
                                        ? Colors.grey.shade800
                                        : Colors.grey.shade200),
                              ),
                              child: Text(
                                tag,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isTrending
                                      ? Colors.white
                                      : (isDarkMode
                                          ? Colors.white
                                          : Colors.black87),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      SizedBox(height: 6),
                      Row(
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: isDarkMode
                                  ? Colors.blue.shade200
                                  : Colors.blue.shade50,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: activity["price"] != null
                                ? RichText(
                                    text: TextSpan(
                                      children: [
                                        TextSpan(
                                          text: "\$${activity["price"]}",
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.blue.shade800,
                                            fontFamily: 'Poppins',
                                          ),
                                        ),
                                        TextSpan(
                                          text:
                                              " / ${activity["price_type"] ?? 'person'}",
                                          style: TextStyle(
                                            fontSize: 13,
                                            color: Colors.blue.shade800,
                                            fontWeight: FontWeight.w400,
                                            fontFamily: 'Poppins',
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                : Text(
                                    "Free",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green.shade700,
                                      fontFamily: 'Poppins',
                                    ),
                                  ),
                          ),
                          if (duration != null) ...[
                            SizedBox(width: 10),
                            Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: isDarkMode
                                    ? Colors.deepPurple.shade200
                                    : Colors.deepPurple.shade50,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.av_timer,
                                      size: 16, color: Colors.deepPurple),
                                  SizedBox(width: 6),
                                  Text(
                                    duration,
                                    style: TextStyle(
                                      color: Colors.deepPurple.shade700,
                                      fontSize: 13.5,
                                      fontWeight: FontWeight.w500,
                                      fontFamily: 'Poppins',
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    ),
  );
}

Widget LimitedEventCard({
  required BuildContext context,
  required Map<String, dynamic> activity,
  required String imageUrl,
  required String name,
  required String date,
  required String location,
  required String price,
}) {
  return GestureDetector(
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => EventDetailsScreen(activity: activity),
        ),
      );
    },
    child: Builder(
      builder: (context) {
        final isDarkMode = Theme.of(context).brightness == Brightness.dark;

        return Padding(
          padding: const EdgeInsets.only(left: 16),
          child: Container(
            width: 240,
            height: 380,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              image: imageUrl.startsWith('http')
                  ? DecorationImage(
                      image: NetworkImage(imageUrl),
                      fit: BoxFit.cover,
                    )
                  : DecorationImage(
                      image: AssetImage(imageUrl),
                      fit: BoxFit.cover,
                    ),
              boxShadow: [
                BoxShadow(
                  color: isDarkMode
                      ? Colors.black.withOpacity(0.85)
                      : Colors.black.withOpacity(0.70),
                  offset: Offset(0, 1),
                  blurRadius: 5,
                  spreadRadius: 0,
                ),
              ],
            ),
            child: Align(
              alignment: Alignment.bottomLeft,
              child: Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDarkMode
                      ? Colors.black.withOpacity(0.7)
                      : Colors.black.withOpacity(0.55),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(15),
                    bottomRight: Radius.circular(15),
                  ),
                ),
                width: double.infinity,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      name,
                      style: TextStyle(
                        color: Colors.white,
                        fontFamily: 'Poppins',
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 4),
                    Text(
                      date,
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                      ),
                    ),
                    Text(
                      location,
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                      ),
                    ),
                    Row(
                      children: [
                        Spacer(),
                        Text(
                          price,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    ),
  );
}

Widget CategoryCard(String imagePath, String categoryName, String description,
    int listings, double align) {
  return Padding(
    padding: const EdgeInsets.only(left: 16),
    child: Builder(
      builder: (context) {
        final isDarkMode = Theme.of(context).brightness == Brightness.dark;

        return Container(
          width: 320,
          height: 240,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            image: DecorationImage(
              image: AssetImage('assets/Pictures/$imagePath'),
              fit: BoxFit.cover,
              alignment: Alignment(0, align),
            ),
            boxShadow: [
              BoxShadow(
                color: isDarkMode
                    ? Colors.black.withOpacity(0.85)
                    : Colors.black.withOpacity(0.70),
                offset: Offset(0, 1),
                blurRadius: 5,
                spreadRadius: 0,
              ),
            ],
          ),
          child: Stack(
            children: [
              Align(
                alignment: Alignment.bottomCenter,
                child: ClipRRect(
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(15),
                    bottomRight: Radius.circular(15),
                  ),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 2.0, sigmaY: 2.0),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: isDarkMode
                              ? [
                                  Colors.black.withOpacity(0.9),
                                  Colors.black.withOpacity(0.6),
                                ]
                              : [
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
        );
      },
    ),
  );
}
