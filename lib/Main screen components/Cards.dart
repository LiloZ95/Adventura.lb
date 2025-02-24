import 'dart:ui';
import 'package:adventura/search%20screen/modalActivityView.dart';
import 'package:flutter/material.dart';

Widget EventCard({
  required BuildContext context,
  required String imagePath,
  required String title,
  required String providerName,
  required String date,
  required String location,
  required double rating,
  required int totalReviews,
  required String price,
}) {
  return GestureDetector(
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => EventDetailsScreen(
                  title: "Muscle Cars Meet Up",
                  date: "SUN 4 Dec, 03:00 PM",
                  location: "Beirut, CityMall Parking",
                  imagePaths: [
                    'assets/Pictures/Cars/car1.webp',
                    'assets/Pictures/Cars/car2.webp',
                    'assets/Pictures/Cars/car3.webp',
                    'assets/Pictures/Cars/car4.webp',
                  ],
                  tripPlan: [
                    {'time': "3:00 PM", 'event': "Meet up"},
                    {'time': "4:30 PM", 'event': "Ride around"},
                    {'time': "5:30 PM", 'event': "Conclude"},
                  ],
                  description:
                      'Rev up for Beirut’s Ultimate Muscle Car Meetup! Feel the power, hear the roar, and witness the adrenaline-fueled showdown as Beirut’s streets come alive with the baddest muscle cars in the region. Get up close with iconic machines from classic cars to modern.',
                )),
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
              color: Colors.black.withOpacity(0.50),
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
              child: Image.asset(
                imagePath,
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
                        title,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Poppins',
                        ),
                      ),
                      // SizedBox(width: 6),
                      // Text(
                      //   '-$providerName',
                      //   style: TextStyle(
                      //     fontSize: 10,
                      //     color: Colors.grey,
                      //     fontFamily: 'Poppins',
                      //   ),
                      // ),
                    ],
                  ),
                  SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                      SizedBox(width: 4),
                      Text(date,
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
                      Text(location,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                            fontFamily: 'Poppins',
                          )),
                    ],
                  ),
                  Row(
                    children: [
                      Icon(Icons.star, size: 16, color: Colors.amber),
                      SizedBox(width: 4),
                      Text(
                        '$rating ',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Poppins',
                        ),
                      ),
                      Text('($totalReviews reviews)',
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
                price,
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
            color: Colors.black.withOpacity(0.90), // Semi-transparent black
            offset: Offset(0, 3), // x = 0, y = 3
            blurRadius: 10, // Blur = 10
            spreadRadius: 0, // Spread = 0
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
            color: Colors.black.withOpacity(0.90), // Semi-transparent black
            offset: Offset(0, 3), // x = 0, y = 3
            blurRadius: 10, // Blur = 10
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
