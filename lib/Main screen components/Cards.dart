import 'dart:ui';
import 'package:adventura/search%20screen/modalActivityView.dart';
import 'package:flutter/material.dart';
import 'package:adventura/utils.dart';

Widget EventCard({
  required BuildContext context,
  required Map<String, dynamic> activity,
}) {
  String imagePath = getImageUrl(activity);

  return GestureDetector(
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => EventDetailsScreen(
            activity: activity, // Now pass full object!
          ),
        ),
      );
    },
    child: Padding(
      padding: const EdgeInsets.only(left: 16, right: 16, bottom: 10),
      child: Container(
        width: 380,
        height: 280,
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
            Positioned(
              bottom: 52,
              left: 0,
              right: 0,
              child: Container(
                height: 100,
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
            Positioned(
              bottom: 12,
              left: 16,
              right: 16,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        activity["name"] ?? "Unknown Activity",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                      SizedBox(width: 4),
                      Text(activity["date"] ?? "Ongoing",
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                            fontFamily: 'Poppins',
                          )),
                    ],
                  ),
                  Row(
                    children: [
                      Icon(Icons.location_on, size: 16, color: Colors.grey),
                      SizedBox(width: 4),
                      Text(activity["location"] ?? "Unknown Location",
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                            fontFamily: 'Poppins',
                          )),
                    ],
                  ),
                ],
              ),
            ),
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
