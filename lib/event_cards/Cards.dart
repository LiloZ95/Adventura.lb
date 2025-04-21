import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:adventura/event_cards/eventDetailsScreen.dart';
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

// Web-optimized event card with responsive design and hover effects
// ignore: non_constant_identifier_names
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

  return LayoutBuilder(
    builder: (context, constraints) {
      // Determine if we're in a narrow layout
      final isNarrow = constraints.maxWidth < 600;
      final double cardWidth = isNarrow ? constraints.maxWidth : 380.0;
      
      return StatefulBuilder(
        builder: (context, setState) {
          bool isHovering = false;
          
          return MouseRegion(
            onEnter: kIsWeb ? (_) => setState(() => isHovering = true) : null,
            onExit: kIsWeb ? (_) => setState(() => isHovering = false) : null,
            child: GestureDetector(
              onTap: () {
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
              child: Padding(
                padding: const EdgeInsets.only(left: 16, right: 16, bottom: 10),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: cardWidth,
                  transform: isHovering && kIsWeb 
                      ? (Matrix4.identity()..translate(0.0, -5.0, 0.0))
                      : Matrix4.identity(),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(isHovering && kIsWeb ? 0.25 : 0.15),
                        offset: Offset(0, isHovering && kIsWeb ? 8 : 1),
                        blurRadius: isHovering && kIsWeb ? 12 : 5,
                        spreadRadius: isHovering && kIsWeb ? 2 : 0,
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Image with bottom gradient fade + duration badge
                      Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
                            child: Hero(
                              tag: 'event-image-${activity["id"] ?? ""}',
                              child: imagePath.isNotEmpty
                                  ? Image.network(
                                      imagePath,
                                      width: cardWidth,
                                      height: 208,
                                      fit: BoxFit.cover,
                                      // Use fadeInDuration for smooth loading on web
                                      // Web-optimized error handling
                                      errorBuilder: (context, error, stackTrace) {
                                        return Image.asset(
                                          "assets/Pictures/island.jpg",
                                          width: cardWidth,
                                          height: 208,
                                          fit: BoxFit.cover,
                                        );
                                      },
                                    )
                                  : Image.asset(
                                      "assets/Pictures/island.jpg",
                                      width: cardWidth,
                                      height: 208,
                                      fit: BoxFit.cover,
                                    ),
                            ),
                          ),

                          // Subtle Bottom Gradient (image overlay)
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
                                    Colors.white.withOpacity(0.8),
                                  ],
                                ),
                              ),
                            ),
                          ),

                          // Duration Badge (commented out in original, but re-enabled for web)
                          if (duration != null && kIsWeb)
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
                        ],
                      ),

                      // Content below the image with soft white gradient background
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.white.withOpacity(0.0),
                              Colors.white.withOpacity(0.7),
                              Colors.white,
                            ],
                          ),
                          borderRadius: BorderRadius.vertical(bottom: Radius.circular(15)),
                        ),
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Title
                            SelectableText(
                              activity["name"] ?? "Unknown Activity",
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Poppins',
                              ),
                            ),
                            SizedBox(height: 4),

                            // Date
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

                            // Location
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

                            // Features (Wrapped)
                            if (featureNames.isNotEmpty)
                              Wrap(
                                spacing: 8,
                                runSpacing: 6,
                                children: featureNames.map((tag) {
                                  final isTrending = tag.toLowerCase() == "trending";
                                  return Container(
                                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(20),
                                      gradient: isTrending
                                          ? LinearGradient(colors: [Colors.orange, Colors.red])
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

                            SizedBox(height: 6),

                            // Price + Duration row
                            Wrap(
                              spacing: 10,
                              runSpacing: 10,
                              children: [
                                Container(
                                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: Colors.blue.shade50,
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
                                                text: " / ${activity["price_type"] ?? 'person'}",
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
                                // if (duration != null)
                                //   Container(
                                //     padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                //     decoration: BoxDecoration(
                                //       color: Colors.deepPurple.shade50,
                                //       borderRadius: BorderRadius.circular(20),
                                //     ),
                                //     child: Row(
                                //       mainAxisSize: MainAxisSize.min,
                                //       children: [
                                //         Icon(Icons.av_timer,
                                //             size: 16, color: Colors.deepPurple),
                                //         SizedBox(width: 6),
                                //         Text(
                                //           duration,
                                //           style: TextStyle(
                                //             color: Colors.deepPurple.shade700,
                                //             fontSize: 13.5,
                                //             fontWeight: FontWeight.w500,
                                //             fontFamily: 'Poppins',
                                //           ),
                                //         ),
                                //       ],
                                //     ),
                                //   ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }
      );
    },
  );
}

// Web-optimized limited event card
// ignore: non_constant_identifier_names
Widget LimitedEventCard({
  required BuildContext context,
  required Map<String, dynamic> activity,
  required String imageUrl,
  required String name,
  required String date,
  required String location,
  required String price,
}) {
  return LayoutBuilder(
    builder: (context, constraints) {
      final isNarrow = constraints.maxWidth < 450;
      final double cardWidth = isNarrow ? constraints.maxWidth * 0.8 : 240.0;
      
      return StatefulBuilder(
        builder: (context, setState) {
          bool isHovering = false;
          
          return MouseRegion(
            onEnter: kIsWeb ? (_) => setState(() => isHovering = true) : null,
            onExit: kIsWeb ? (_) => setState(() => isHovering = false) : null,
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  kIsWeb
                      ? PageRouteBuilder(
                          pageBuilder: (_, __, ___) => EventDetailsScreen(activity: activity),
                          transitionsBuilder: (_, animation, __, child) {
                            return FadeTransition(
                              opacity: animation,
                              child: child,
                            );
                          },
                        )
                      : MaterialPageRoute(
                          builder: (context) => EventDetailsScreen(activity: activity),
                        ),
                );
              },
              child: Padding(
                padding: const EdgeInsets.only(left: 16),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: cardWidth,
                  height: 380,
                  transform: isHovering && kIsWeb
                      ? (Matrix4.identity()..translate(0.0, -5.0, 0.0))
                      : Matrix4.identity(),
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
                        color: Colors.black.withOpacity(isHovering && kIsWeb ? 0.25 : 0.15),
                        offset: Offset(0, isHovering && kIsWeb ? 8 : 1),
                        blurRadius: isHovering && kIsWeb ? 12 : 5,
                        spreadRadius: isHovering && kIsWeb ? 2 : 0,
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      // Add a light hover overlay for web
                      if (isHovering && kIsWeb)
                        Positioned.fill(
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15),
                              color: Colors.white.withOpacity(0.05),
                            ),
                          ),
                        ),
                        
                      Align(
                        alignment: Alignment.bottomLeft,
                        child: Container(
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.6),
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
                    ],
                  ),
                ),
              ),
            ),
          );
        }
      );
    },
  );
}

// Web-optimized category card
// ignore: non_constant_identifier_names
Widget CategoryCard(String imagePath, String categoryName, String description,
    int listings, double align) {
  return StatefulBuilder(
    builder: (context, setState) {
      bool isHovering = false;
      
      return MouseRegion(
        onEnter: kIsWeb ? (_) => setState(() => isHovering = true) : null,
        onExit: kIsWeb ? (_) => setState(() => isHovering = false) : null,
        child: Padding(
          padding: const EdgeInsets.only(left: 16),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 320,
            height: 240,
            transform: isHovering && kIsWeb
                ? (Matrix4.identity()..translate(0.0, -5.0, 0.0))
                : Matrix4.identity(),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              image: DecorationImage(
                image: AssetImage('assets/Pictures/$imagePath'),
                fit: BoxFit.cover,
                alignment: Alignment(0, align),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(isHovering && kIsWeb ? 0.25 : 0.15),
                  offset: Offset(0, isHovering && kIsWeb ? 8 : 1),
                  blurRadius: isHovering && kIsWeb ? 12 : 5,
                  spreadRadius: isHovering && kIsWeb ? 2 : 0,
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
                      filter: ImageFilter.blur(sigmaX: 2.0, sigmaY: 2.0),
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

                // Add an interactive button for web
                if (isHovering && kIsWeb)
                  Positioned(
                    right: 10,
                    top: 10,
                    child: Material(
                      color: Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(30),
                      child: InkWell(
                        onTap: () {},
                        borderRadius: BorderRadius.circular(30),
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          child: Text(
                            'Explore',
                            style: TextStyle(
                              color: Colors.black87,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      );
    }
  );
}

// Responsive grid layout helper for web
// ignore: non_constant_identifier_names
Widget ResponsiveGrid({
  required BuildContext context,
  required List<Widget> children,
  double spacing = 16,
  double runSpacing = 16,
  int minCrossAxisCount = 1,
  int maxCrossAxisCount = 4,
}) {
  return LayoutBuilder(
    builder: (context, constraints) {
      final width = constraints.maxWidth;
      
      // Calculate how many items per row based on screen width
      int crossAxisCount = (width / 360).floor();
      crossAxisCount = crossAxisCount.clamp(minCrossAxisCount, maxCrossAxisCount);
      
      return Wrap(
        spacing: spacing,
        runSpacing: runSpacing,
        alignment: WrapAlignment.start,
        children: children.map((child) {
          if (kIsWeb) {
            // For web, we want consistent sizes 
            final childWidth = (width - (spacing * (crossAxisCount - 1))) / crossAxisCount;
            return SizedBox(width: childWidth, child: child);
          } else {
            // For mobile, use the child as is
            return child;
          }
        }).toList(),
      );
    },
  );
}