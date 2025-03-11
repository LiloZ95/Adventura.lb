import 'dart:ui';
import 'package:adventura/Booking/MyBooking.dart';
import 'package:adventura/Services/storage_service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:adventura/Main%20screen%20components/Cards.dart';
import 'package:adventura/colors.dart';
import 'package:adventura/search%20screen/searchScreen.dart';
import 'package:flutter/material.dart';
import 'package:adventura/userinformation/UserInfo.dart';
import 'package:adventura/Notification/NotificationPage.dart';
import 'package:adventura/Services/activity_service.dart';
import 'package:hive/hive.dart'; // Add this for local caching
import 'dart:convert'; // Add this for JSON encoding/decoding

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  static const String baseUrl = 'http://localhost:3000';
  int currentIndex = 0;
  List<dynamic> activities = [];
  List<dynamic> recommendedActivities = [];

  @override
  void initState() {
    super.initState();
    loadActivities();
  }

  // ✅ Load Activities from API
  void loadActivities() async {
    final box = await Hive.openBox('cacheBox');
    await box.delete('recommendations');
    final String? cachedActivities = box.get('activities');
    final String? cachedRecommendations = box.get('recommendations');

    if (cachedActivities != null && cachedRecommendations != null) {
      setState(() {
        activities = jsonDecode(cachedActivities);
        recommendedActivities = jsonDecode(cachedRecommendations);
      });
      return;
    }

    try {
      Box storageBox = await Hive.openBox('authBox');
      String? userIdString = storageBox.get("userId");

      if (userIdString == null) {
        print("❌ User ID not found in Hive.");
        return;
      }

      int userId = int.tryParse(userIdString) ?? 0;
      print("🔍 Fetching recommended activities for user ID: $userId");

      List<dynamic> fetchedActivities = await ActivityService.fetchActivities();
      List<dynamic> fetchedRecommended =
          await ActivityService.fetchRecommendedActivities(userId);

      print("✅ Fetched Activities: ${fetchedActivities.length}");
      print("✅ Fetched Recommendations: ${fetchedRecommended.length}");

      setState(() {
        activities = fetchedActivities;
        recommendedActivities = fetchedRecommended;
      });

      await box.put('activities', jsonEncode(fetchedActivities));
      await box.put('recommendations', jsonEncode(fetchedRecommended));
    } catch (error) {
      print("❌ Error fetching activities: $error");
    }
  }

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

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    double statusBarHeight = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: Colors.white,
      body: RefreshIndicator(
        onRefresh: () async {
          loadActivities();
        },
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Header Section
              Padding(
                padding: EdgeInsets.fromLTRB(16, statusBarHeight + 6, 16, 6),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Text Content
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Let's Plan Your\nActivity",
                            style: TextStyle(
                              height: 0.96,
                              fontSize: screenWidth * 0.08, // Dynamic font size
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Poppins',
                              color: Colors.black,
                            ),
                          ),
                          SizedBox(height: 10.0),
                          Text(
                            "Navigate through the suggested activities and categories or search on your own.",
                            style: TextStyle(
                              fontSize: screenWidth * 0.04, // Dynamic font size
                              height: 0.98,
                              color: Colors.grey,
                              fontFamily: 'Poppins',
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Icons
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0, 20, 0, 0),
                      child: Row(
                        children: [
                          IconButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => NotificationScreen(),
                                ),
                              );
                            },
                            icon: Image.asset(
                              'assets/Icons/bell-Bold.png',
                              width: 30,
                              height: 30,
                            ),
                          ),
                          SizedBox(width: 8),
                          CircleAvatar(
                            backgroundColor: Colors.grey.shade300,
                            child: IconButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => UserInfo(),
                                  ),
                                );
                              },
                              icon: Icon(Icons.person),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              // Limited Time Activities Section
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Limited Time Activities",
                      style: TextStyle(
                        fontSize: screenWidth * 0.06, // Dynamic font size
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {},
                      child: Text(
                        "see all",
                        style: TextStyle(
                          fontSize: screenWidth * 0.04, // Dynamic font size
                          fontFamily: 'Poppins',
                          color: AppColors.blue,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: screenHeight * 0.35, // Dynamic height
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(0, 0, 16, 0),
                    child: Row(
                      children: [
                        card('Hikes/assirafting.webp'),
                        card('Hikes/nighthike.webp'),
                        card('Hikes/mechwarna.webp'),
                        card('Hikes/batroun.jpg'),
                        card('Hikes/sunsethike.webp'),
                      ],
                    ),
                  ),
                ),
              ),
              // Popular Categories Section
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 6, 16, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Popular Categories",
                      style: TextStyle(
                        fontSize: screenWidth * 0.06, // Dynamic font size
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {},
                      child: Text(
                        "see all",
                        style: TextStyle(
                          fontSize: screenWidth * 0.04, // Dynamic font size
                          fontFamily: 'Poppins',
                          color: AppColors.blue,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: screenHeight * 0.27, // Dynamic height
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(0, 0, 16, 0),
                    child: Row(
                      children: [
                        card2(
                            'paragliding.webp',
                            'Paragliding',
                            'Soar above the stunning bay of Jounieh and enjoy breath-taking aerial views of the Lebanese coast.',
                            9,
                            0),
                        card2(
                            'jetski.jpeg',
                            'Jetski Rentals',
                            'Experience the thrill of jetskiing along Lebanon’s shores, available at various coastal locations.',
                            2,
                            0.8),
                        card2(
                            'island.jpg',
                            'Island Trips',
                            'Explore Lebanon’s coastline with private boat rentals, island hopping, and unforgettable sea adventures.',
                            5,
                            0.0),
                        card2(
                            'picnic.webp',
                            'Picnic Spots',
                            'Relax and unwind at scenic picnic spots, options available for a perfect day out.',
                            5,
                            0.0),
                        card2(
                            'cars.webp',
                            'Car Events',
                            'Join Lebanon’s car enthusiasts at exciting car meets and events.',
                            5,
                            1),
                      ],
                    ),
                  ),
                ),
              ),
              // You Might Like Section
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 6, 16, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "You Might Like",
                      style: TextStyle(
                        fontSize: screenWidth * 0.06, // Dynamic font size
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {},
                      child: Text(
                        "see all",
                        style: TextStyle(
                          fontSize: screenWidth * 0.04, // Dynamic font size
                          fontFamily: 'Poppins',
                          color: AppColors.blue,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // ✅ Activity List (Dynamically Loaded)
              recommendedActivities.isEmpty
                  ? Center(
                      child: Padding(
                        padding: EdgeInsets.all(20),
                        child: CircularProgressIndicator(),
                      ),
                    )
                  : Column(
                      children: recommendedActivities.map((activity) {
                        return EventCard(
                          context: context,
                          imagePath:
                              getImageUrl(activity), // ✅ Safe image fetching
                          title: activity["name"] ??
                              "Unknown Activity", // ✅ Handle missing name
                          providerName:
                              activity["provider_name"] ?? "Unknown Provider",
                          date: activity["date"] ?? "Ongoing",
                          location: activity["location"] ?? "Unknown Location",
                          rating: activity["rating"] != null
                              ? double.tryParse(
                                      activity["rating"].toString()) ??
                                  0.0
                              : 0.0,
                          totalReviews: activity["total_reviews"] ?? 0,
                          price: activity["price"] != null
                              ? "\$${activity["price"]}"
                              : "Free",
                        );
                      }).toList(),
                    ),
              // ✅ Bottom Navigation Bar
              Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  margin: const EdgeInsets.only(bottom: 25),
                  width: screenWidth * 0.93,
                  height: 65,
                  decoration: BoxDecoration(
                    color: Color(0xFF1B1B1B),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      IconButton(
                        onPressed: () {
                          // Navigate to Main Screen
                          Navigator.pop(context);
                        },
                        icon: Image.asset(
                          'assets/Icons/home.png',
                          width: 35,
                          height: 35,
                          color: Colors.grey, // Adjust based on the screen
                        ),
                      ),
                      IconButton(
                        onPressed: () {},
                        icon: Image.asset(
                          'assets/Icons/search.png',
                          width: 35,
                          height: 35,
                          color: Colors.white, // Active
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => MyBookingsPage()));
                        },
                        icon: Image.asset(
                          'assets/Icons/ticket.png',
                          width: 35,
                          height: 35,
                          color: Colors.grey,
                        ),
                      ),
                      IconButton(
                        onPressed: () {},
                        icon: Image.asset(
                          'assets/Icons/bookmark.png',
                          width: 35,
                          height: 35,
                          color: Colors.grey,
                        ),
                      ),
                      IconButton(
                        onPressed: () {},
                        icon: Image.asset(
                          'assets/Icons/paper-plane.png',
                          width: 35,
                          height: 35,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
