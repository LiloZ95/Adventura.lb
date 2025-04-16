import 'dart:async';
import 'dart:ui';
import 'dart:typed_data';
import 'dart:convert';
import 'package:adventura/Services/profile_service.dart';
import 'package:adventura/event_cards/Cards.dart';
import 'package:adventura/colors.dart';
import 'package:adventura/search%20screen/searchScreen.dart';
import 'package:adventura/utils.dart';
import 'package:adventura/utils/snackbars.dart';
import 'package:flutter/material.dart';
import 'package:adventura/userinformation/UserInfo.dart';
import 'package:adventura/Notification/NotificationPage.dart';
import 'package:adventura/Services/activity_service.dart';
import 'package:flutter/rendering.dart';
import 'package:hive/hive.dart';
import 'package:adventura/Provider%20Only/ticketScanner.dart';
import 'package:adventura/CreateListing/CreateList.dart';
import 'package:adventura/Chatbot/chatBot.dart';
import 'package:intl/intl.dart';

class MainScreen extends StatefulWidget {
  final Function(bool) onScrollChanged;

  const MainScreen({Key? key, required this.onScrollChanged}) : super(key: key);

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;
  late String userId;
  String profilePicture = ""; // Default empty string
  bool isLoading = true;
  int currentIndex = 0;
  List<dynamic> activities = [];
  List<dynamic> recommendedActivities = [];
  String selectedLocation = "Tripoli";
  String firstName = "";
  String lastName = "";
  bool isProvider = false;
  List<Map<String, dynamic>> limitedEvents = [];
  final ScrollController _scrollController = ScrollController();
  Timer? _scrollStopTimer;

  @override
  void initState() {
    super.initState();

    _scrollController.addListener(() {
      final direction = _scrollController.position.userScrollDirection;

      // Cancel timer to debounce
      _scrollStopTimer?.cancel();

      if (direction == ScrollDirection.reverse) {
        widget.onScrollChanged(false); // Hide nav bar
      } else if (direction == ScrollDirection.forward) {
        widget.onScrollChanged(true); // Show nav bar
      }

      _scrollStopTimer = Timer(Duration(milliseconds: 300), () {
        widget.onScrollChanged(true); // Reset when scrolling stops
      });
    });

    _loadUserData();
    loadActivities();
    fetchUserData();
    _loadLimitedEvents();
  }

  Future<void> _loadLimitedEvents() async {
    final events = await ActivityService.fetchEvents();
    setState(() {
      limitedEvents = events;
    });
  }

  Future<void> _loadUserData() async {
    Box box = await Hive.openBox('authBox');
    userId = box.get('userId') ?? '';
    firstName = box.get('firstName') ?? '';
    lastName = box.get('lastName') ?? '';
    isProvider =
        box.get('userType') == 'provider' && box.get('providerId') != null;

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

  @override
  void dispose() {
    _scrollController.dispose();
    _scrollStopTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    print("✅ MainScreen build() called");
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : SafeArea(
              child: RefreshIndicator(
                color: AppColors.blue,
                onRefresh: () async {
                  await _loadLimitedEvents(); // ✅ Refresh limited events
                  loadActivities(); // (if this loads all activities)
                  await ProfileService.fetchProfilePicture(userId);
                  fetchUserData();
                  setState(() {}); // 🔁 Trigger UI update
                },
                child: Container(
                  height: MediaQuery.of(context).size.height,
                  child: Stack(
                    children: [
                      SingleChildScrollView(
                        controller: _scrollController,
                        child: Column(
                          children: [
                            // Header Section
                            Padding(
                              padding: EdgeInsets.fromLTRB(16, 10, 16, 6),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Text Content
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "Welcome \nback, $firstName !",
                                          style: TextStyle(
                                            height: 0.96,
                                            fontSize: screenWidth *
                                                0.075, // Dynamic font size
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
                                              color: Color.fromRGBO(
                                                  124, 124, 124, 0.07),
                                              border: Border.all(
                                                  color: Colors.white),
                                              borderRadius:
                                                  BorderRadius.circular(14),
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
                                                              fontFamily:
                                                                  'poppins'),
                                                        ),
                                                      );
                                                    }).toList(),
                                                    onChanged: (newValue) {
                                                      setState(() {
                                                        selectedLocation =
                                                            newValue!;
                                                      });
                                                    }))),
                                      ],
                                    ),
                                  ),
                                  // Icons
                                  Padding(
                                    padding:
                                        const EdgeInsets.fromLTRB(0, 0, 0, 0),
                                    child: Row(
                                      children: [
                                        IconButton(
                                          onPressed: () {
                                            Navigator.push(
                                              context,
                                              PageRouteBuilder(
                                                transitionDuration:
                                                    Duration(milliseconds: 250),
                                                pageBuilder: (context,
                                                        animation,
                                                        secondaryAnimation) =>
                                                    AdventuraChatPage(
                                                  userName: firstName,
                                                  userId: userId,
                                                ),
                                                transitionsBuilder: (context,
                                                    animation,
                                                    secondaryAnimation,
                                                    child) {
                                                  return FadeTransition(
                                                    opacity: animation,
                                                    child: child,
                                                  );
                                                },
                                              ),
                                            );
                                          },
                                          icon: Image.asset(
                                            'assets/Icons/ai.png',
                                            width: screenWidth * 0.075,
                                            height: screenWidth * 0.075,
                                          ),
                                        ),
                                        IconButton(
                                          onPressed: () {
                                            Navigator.push(
                                              context,
                                              PageRouteBuilder(
                                                transitionDuration:
                                                    Duration(milliseconds: 250),
                                                pageBuilder: (context,
                                                        animation,
                                                        secondaryAnimation) =>
                                                    NotificationScreen(),
                                                transitionsBuilder: (context,
                                                    animation,
                                                    secondaryAnimation,
                                                    child) {
                                                  return FadeTransition(
                                                    opacity: animation,
                                                    child: child,
                                                  );
                                                },
                                              ),
                                            );
                                          },
                                          icon: Image.asset(
                                            'assets/Icons/bell-Bold.png',
                                            width: screenWidth * 0.07,
                                            height: screenWidth * 0.07,
                                          ),
                                        ),
                                        SizedBox(width: 4),
                                        GestureDetector(
                                          onTap: () => Navigator.push(
                                            context,
                                            PageRouteBuilder(
                                              transitionDuration:
                                                  Duration(milliseconds: 250),
                                              pageBuilder: (context, animation,
                                                      secondaryAnimation) =>
                                                  UserInfo(),
                                              transitionsBuilder: (context,
                                                  animation,
                                                  secondaryAnimation,
                                                  child) {
                                                return FadeTransition(
                                                  opacity: animation,
                                                  child: child,
                                                );
                                              },
                                            ),
                                          ),
                                          child: FutureBuilder(
                                            future: Hive.openBox('authBox'),
                                            builder: (context, snapshot) {
                                              if (snapshot.connectionState ==
                                                  ConnectionState.done) {
                                                Box box = Hive.box('authBox');
                                                Uint8List? userBytes = box.get(
                                                    'profileImageBytes_$userId');
                                                ImageProvider<Object>
                                                    imageProvider;

                                                if (userBytes != null) {
                                                  imageProvider =
                                                      MemoryImage(userBytes);
                                                } else {
                                                  imageProvider = AssetImage(
                                                      "assets/images/default_user.png");
                                                }

                                                return CircleAvatar(
                                                  backgroundColor:
                                                      Colors.grey.shade300,
                                                  backgroundImage:
                                                      imageProvider,
                                                );
                                              }
                                              return CircleAvatar(
                                                backgroundColor:
                                                    Colors.grey.shade300,
                                                child: Icon(Icons.person,
                                                    color: Colors.black,
                                                    size: 30),
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
                              padding: const EdgeInsets.fromLTRB(16, 0, 0, 0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.baseline,
                                textBaseline: TextBaseline.alphabetic,
                                children: [
                                  Text(
                                    "Limited Time Activities",
                                    style: TextStyle(
                                      fontSize: screenWidth *
                                          0.06, // Dynamic font size
                                      fontFamily: 'Poppins',
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => SearchScreen(
                                            filterMode: "limited_events_only",
                                            onScrollChanged:
                                                widget.onScrollChanged,
                                          ),
                                        ),
                                      );
                                    },
                                    child: Text(
                                      "See All",
                                      style: TextStyle(
                                        color: AppColors.blue,
                                        fontFamily: 'Poppins',
                                        fontSize: screenWidth * 0.035,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(
                              height: MediaQuery.of(context).size.height * 0.4,
                              child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(0, 0, 16, 0),
                                  child: Row(
                                    children: limitedEvents.map((event) {
                                      // print("🧠 Event object: $event");

                                      return LimitedEventCard(
                                        context: context,
                                        activity: event,
                                        imageUrl: getEventImageUrl(event),
                                        name: event["name"] ?? "Unnamed Event",
                                        date: event["event_date"] != null
                                            ? DateFormat('MMM d, yyyy').format(
                                                DateTime.parse(
                                                    event["event_date"]))
                                            : "No date",
                                        location:
                                            event["location"] ?? "No location",
                                        price: event["price"] != null
                                            ? "\$${event["price"]}"
                                            : "Free",
                                      );
                                    }).toList(),
                                  ),
                                ),
                              ),
                            ),

                            // Popular Categories Section
                            Padding(
                              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "Popular Categories",
                                    style: TextStyle(
                                      fontSize: screenWidth *
                                          0.06, // Dynamic font size
                                      fontFamily: 'Poppins',
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // SizedBox(height: 6),
                            SizedBox(
                              height: screenHeight * 0.27, // Dynamic height
                              child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(0, 0, 16, 0),
                                  child: Row(
                                    children: [
                                      CategoryCard(
                                          'paragliding.webp',
                                          'Paragliding',
                                          'Soar above the stunning bay of Jounieh and enjoy breath-taking aerial views of the Lebanese coast.',
                                          9,
                                          0),
                                      CategoryCard(
                                          'jetski.jpeg',
                                          'Jetski Rentals',
                                          'Experience the thrill of jetskiing along Lebanon’s shores, available at various coastal locations.',
                                          2,
                                          0.8),
                                      CategoryCard(
                                          'island.jpg',
                                          'Island Trips',
                                          'Explore Lebanon’s coastline with private boat rentals, island hopping, and unforgettable sea adventures.',
                                          5,
                                          0.0),
                                      CategoryCard(
                                          'picnic.webp',
                                          'Picnic Spots',
                                          'Relax and unwind at scenic picnic spots, options available for a perfect day out.',
                                          5,
                                          0.0),
                                      CategoryCard(
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
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.baseline,
                                textBaseline: TextBaseline
                                    .alphabetic, // This is required for baseline alignment
                                children: [
                                  Text(
                                    "You Might Like",
                                    style: TextStyle(
                                      fontSize: screenWidth * 0.06,
                                      fontFamily: 'Poppins',
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => SearchScreen(
                                            onScrollChanged:
                                                widget.onScrollChanged,
                                          ),
                                        ),
                                      );
                                    },
                                    child: Text(
                                      "See All",
                                      style: TextStyle(
                                        color: AppColors.blue,
                                        fontFamily: 'Poppins',
                                        fontSize: screenWidth * 0.035,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 6),

                            // ✅ Activity List (Dynamically Loaded)
                            recommendedActivities.isEmpty
                                ? Padding(
                                    padding: EdgeInsets.all(32),
                                    child: Column(
                                      children: [
                                        Icon(Icons.warning,
                                            size: 48, color: Colors.grey),
                                        SizedBox(height: 10),
                                        Text(
                                          "No recommendations found.",
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontFamily: 'Poppins',
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                : Column(
                                    children: [
                                      ...recommendedActivities.map((activity) {
                                        return EventCard(
                                          context: context,
                                          activity: activity,
                                        );
                                      }).toList(),
                                      SizedBox(
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              0.12),
                                      // 👈 this avoids getting covered
                                    ],
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
                            if (!isLoading && isProvider) ...[
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
                                  width: screenWidth * 0.14,
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
                                      width: screenWidth * 0.08,
                                      height: screenWidth * 0.08,
                                      fit: BoxFit
                                          .contain, // ✅ Forces it to stay inside the 30x30 box
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(height: 8),
                              GestureDetector(
                                onTap: () async {
                                  final box = await Hive.openBox('authBox');
                                  final userType = box.get('userType');
                                  final providerId = box.get('providerId');

                                  if (userType != 'provider' ||
                                      providerId == null) {
                                    showAppSnackBar(context,
                                        "Only providers can create listings.");
                                    return;
                                  }

                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            CreateListingPage()),
                                  );
                                },
                                child: Container(
                                  width: screenWidth * 0.14,
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
                                      width: screenWidth * 0.08,
                                      height: screenWidth * 0.08,
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                ),
                              ),
                            ]
                          ],
                        ),
                      ),

                      // Bottom Navigation Bar stays fixed at the bottom
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
