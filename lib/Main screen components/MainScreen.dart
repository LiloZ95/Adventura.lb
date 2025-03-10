import 'dart:ui';
import 'package:adventura/Booking/MyBooking.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:adventura/Main%20screen%20components/Cards.dart';
import 'package:adventura/colors.dart';
import 'package:adventura/search%20screen/searchScreen.dart';
import 'package:flutter/material.dart';
import 'package:adventura/userinformation/UserInfo.dart';
import 'package:adventura/Notification/NotificationPage.dart';

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int currentIndex = 0;
  final FlutterSecureStorage storage = FlutterSecureStorage();

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    double statusBarHeight = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          SingleChildScrollView(
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
                                fontSize:
                                    screenWidth * 0.08, // Dynamic font size
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Poppins',
                                color: Colors.black,
                              ),
                            ),
                            SizedBox(height: 10.0),
                            Text(
                              "Navigate through the suggested activities and categories or search on your own.",
                              style: TextStyle(
                                fontSize:
                                    screenWidth * 0.04, // Dynamic font size
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
                                      builder: (context) =>
                                          NotificationScreen()),
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
                                        builder: (context) => UserInfo()),
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
                  height: screenHeight * 0.37, // Dynamic height
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
                  height: screenHeight * 0.28, // Dynamic height
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
                SizedBox(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(0, 12, 0, 0),
                    child: Column(
                      children: [
                        EventCard(
                          context: context,
                          imagePath: 'assets/Pictures/cars.webp',
                          title: 'Aaqoura Night Hike',
                          providerName: 'Lebanon Explorers',
                          date: 'Saturday, 29th Sep',
                          location: 'Aaqoura, Hadath',
                          rating: 4.8,
                          totalReviews: 125,
                          price: 'Free',
                        ),
                        EventCard(
                          context: context,
                          imagePath: 'assets/Pictures/sea1.webp',
                          title: 'Aaqoura Night Hike',
                          providerName: 'Lebanon Explorers',
                          date: 'Saturday, 29th Sep',
                          location: 'Aaqoura, Hadath',
                          rating: 4.8,
                          totalReviews: 125,
                          price: '\$20',
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Bottom Navigation Bar
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
                      onPressed: () {},
                      icon: Image.asset(
                        'assets/Icons/home.png',
                        width: 35,
                        height: 35,
                        color: currentIndex == 0 ? Colors.white : Colors.grey,
                      )),
                  IconButton(
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => SearchScreen()));
                      },
                      icon: Image.asset(
                        'assets/Icons/search.png',
                        width: 35,
                        height: 35,
                        color: currentIndex == 1 ? Colors.white : Colors.grey,
                      )),
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
                        color: currentIndex == 2 ? Colors.white : Colors.grey,
                      )),
                  IconButton(
                      onPressed: () {},
                      icon: Image.asset(
                        'assets/Icons/bookmark.png',
                        width: 35,
                        height: 35,
                        color: currentIndex == 3 ? Colors.white : Colors.grey,
                      )),
                  IconButton(
                      onPressed: () {},
                      icon: Image.asset(
                        'assets/Icons/paper-plane.png',
                        width: 35,
                        height: 35,
                        color: currentIndex == 4 ? Colors.white : Colors.grey,
                      )),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
