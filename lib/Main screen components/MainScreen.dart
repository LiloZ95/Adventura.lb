import 'dart:ui';
import 'dart:typed_data';
import 'dart:convert';
import 'package:adventura/Booking/MyBooking.dart';
import 'package:adventura/Services/profile_service.dart';
import 'package:adventura/event_cards/Cards.dart';
import 'package:adventura/colors.dart';
import 'package:adventura/search%20screen/searchScreen.dart';
import 'package:flutter/material.dart';
import 'package:adventura/userinformation/UserInfo.dart';
import 'package:adventura/Notification/NotificationPage.dart';
import 'package:adventura/Services/activity_service.dart';
import 'package:hive/hive.dart';
import 'package:adventura/Reels/ReelsPlayer.dart';
import 'package:adventura/Provider%20Only/ticketScanner.dart';
import 'package:adventura/CreateListing/CreateList.dart';
import '../widgets/bouncing_dots_loader.dart';
import 'package:adventura/Chatbot/chatBot.dart';

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late String userId;
  String profilePicture = ""; // Default empty string
  bool isLoading = true;
  int currentIndex = 0;
  List<dynamic> activities = [];
  List<dynamic> recommendedActivities = [];
  String selectedLocation = "Tripoli";
  String firstName = "";
  String lastName = "";
  bool isProvider = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    loadActivities();
    fetchUserData();
  }

  Future<void> _loadUserData() async {
    Box box = await Hive.openBox('authBox');
    userId = box.get('userId') ?? '';
    firstName = box.get('firstName') ?? '';
    lastName = box.get('lastName') ?? '';

    // Load profile bytes based on userId
    Uint8List? cachedBytes = box.get('profileImageBytes_$userId');
    profilePicture = cachedBytes != null ? 'cached' : ""; // placeholder check

    setState(() => isLoading = false);
  }

  void fetchUserData() async {
    Box box = await Hive.openBox('authBox');
    String? userIdString = box.get("userId");
    if (userIdString == null) return;
    userId = userIdString;

    // Try to load cached bytes specific to this user
    Uint8List? cachedBytes = box.get('profileImageBytes_$userId');

    if (cachedBytes != null) {
      setState(() {
        profilePicture = 'cached';
      });
    } else {
      // Fetch from API as fallback
      String fetchedProfilePic =
          await ProfileService.fetchProfilePicture(userId);
      if (fetchedProfilePic.isNotEmpty) {
        // Cache by userId
        await box.put(
            'profileImageBytes_$userId', base64Decode(fetchedProfilePic));
        setState(() {
          profilePicture = 'cached';
        });
      }
    }
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

  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    double statusBarHeight = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: Colors.white,
      body: RefreshIndicator(
        color: AppColors.blue,
        onRefresh: () async {
          loadActivities();
          await ProfileService.fetchProfilePicture(userId);
          fetchUserData();
          setState(() {});
        },
        child: Stack(
          children: [
            SingleChildScrollView(
              child: Column(
                children: [
                  // Header Section
                  Padding(
                    padding:
                        EdgeInsets.fromLTRB(16, statusBarHeight + 6, 16, 6),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Text Content
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(height: 10.0),
                              Text(
                                "Welcome back, \n$firstName !",
                                style: TextStyle(
                                  height: 0.96,
                                  fontSize:
                                      screenWidth * 0.07, // Dynamic font size
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Poppins',
                                  color: Colors.black,
                                ),
                              ),
                              SizedBox(height: 10.0),
                              // **Current Location Dropdown**
                              Text(
                                "Current Location",
                                style: TextStyle(
                                  fontSize: screenWidth * 0.045,
                                  color: Colors.grey.shade400,
                                ),
                              ),
                              Container(
                                  width: 130,
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 12,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Color.fromRGBO(124, 124, 124, 0.07),
                                    border: Border.all(color: Colors.white),
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: DropdownButtonHideUnderline(
                                      child: DropdownButton<String>(
                                          value: selectedLocation,
                                          items: [
                                            "Tripoli",
                                            "Beirut",
                                            "Jbeil",
                                            "Jounieh",
                                            "Sayda"
                                          ].map((location) {
                                            return DropdownMenuItem(
                                              value: location,
                                              child: Text(
                                                location,
                                                style: TextStyle(
                                                    fontFamily: 'poppins'),
                                              ),
                                            );
                                          }).toList(),
                                          onChanged: (newValue) {
                                            setState(() {
                                              selectedLocation = newValue!;
                                            });
                                          }))),
                            ],
                          ),
                        ),
                        // Icons
                        Padding(
                          padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                          child: Row(
                            children: [
                              IconButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => AdventuraChatPage(),
                                    ),
                                  );
                                },
                                icon: Image.asset(
                                  'assets/Icons/ai.png',
                                  width: 35,
                                  height: 35,
                                ),
                              ),
                              IconButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          NotificationScreen(),
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
                              GestureDetector(
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => UserInfo()),
                                ),
                                child: FutureBuilder(
                                  future: Hive.openBox('authBox'),
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState ==
                                        ConnectionState.done) {
                                      Box box = Hive.box('authBox');
                                      Uint8List? userBytes =
                                          box.get('profileImageBytes_$userId');
                                      ImageProvider<Object> imageProvider;

                                      if (userBytes != null) {
                                        imageProvider = MemoryImage(userBytes);
                                      } else {
                                        imageProvider = AssetImage(
                                            "assets/images/default_user.png");
                                      }

                                      return CircleAvatar(
                                        backgroundColor: Colors.grey.shade300,
                                        backgroundImage: imageProvider,
                                      );
                                    }
                                    return CircleAvatar(
                                      backgroundColor: Colors.grey.shade300,
                                      child: Icon(Icons.person,
                                          color: Colors.black, size: 30),
                                    );
                                  },
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
                            child: BouncingDotsLoader(),
                          ),
                        )
                      : Column(
                          children: recommendedActivities.map((activity) {
                            return EventCard(
                              context: context,
                              activity: activity,
                            );
                          }).toList(),
                        ),
                ],
              ),
            ),

            // 🔵 TWO SQUARE BUTTONS ABOVE NAVBAR
            Positioned(
              bottom: 100, // Adjust depending on your nav bar height
              right: 20,
              child: Column(
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => TicketScanner(),
                        ),
                      );
                    },
                    child: Container(
                      width: 55,
                      height: 55,
                      decoration: BoxDecoration(
                        color: Color.fromRGBO(137, 69, 247, 1),
                        borderRadius: BorderRadius.circular(50),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.8),
                            blurRadius: 6,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Image.asset(
                          'assets/Icons/qr-code.png',
                          width: 30,
                          height: 30,
                          fit: BoxFit
                              .contain, // ✅ Forces it to stay inside the 30x30 box
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 8),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CreateListingPage(),
                        ),
                      );
                    },
                    child: Container(
                      width: 55,
                      height: 55,
                      decoration: BoxDecoration(
                        color: AppColors.blue,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.8),
                            blurRadius: 6,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Image.asset(
                          'assets/Icons/add.png',
                          width: 30,
                          height: 30,
                          fit: BoxFit
                              .contain, // ✅ Forces it to stay inside the 30x30 box
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Bottom Navigation Bar stays fixed at the bottom
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                margin: const EdgeInsets.only(bottom: 25),
                width: screenWidth * 0.93,
                height: 65,
                decoration: BoxDecoration(
                  color: const Color(0xFF1B1B1B),
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.70),
                      offset: Offset(0, 1),
                      blurRadius: 5,
                      spreadRadius: 0,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    IconButton(
                      onPressed: () {},
                      icon: Image.asset('assets/Icons/home.png',
                          width: 35, height: 35, color: Colors.white),
                    ),
                    IconButton(
                      onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => SearchScreen())),
                      icon: Image.asset('assets/Icons/search.png',
                          width: 35, height: 35, color: Colors.grey),
                    ),
                    IconButton(
                      onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => MyBookingsPage())),
                      icon: Image.asset('assets/Icons/ticket.png',
                          width: 35, height: 35, color: Colors.grey),
                    ),
                    IconButton(
                      onPressed: () {},
                      icon: Image.asset('assets/Icons/bookmark.png',
                          width: 35, height: 35, color: Colors.grey),
                    ),
                    IconButton(
                      onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ReelsPlayer())),
                      icon: Image.asset('assets/Icons/paper-plane.png',
                          width: 35, height: 35, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
