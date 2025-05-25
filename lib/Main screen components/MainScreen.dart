import 'dart:async';
import 'dart:ui';
import 'dart:typed_data';
import 'dart:convert';
import 'package:adventura/Reels/reels_pg.dart';
import 'package:adventura/Reels/uploadReel.dart';
import 'package:adventura/Reels/upload_reel_pg.dart';
import 'package:adventura/config.dart';
import 'package:http/http.dart' as http;
import 'package:lucide_icons/lucide_icons.dart';
import 'package:adventura/Services/profile_service.dart';
import 'package:adventura/colors.dart';
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
import 'package:flutter/foundation.dart'; // for listEquals

import 'widgets/limited_time_section.dart';
import 'widgets/popular_categories_section.dart';
import 'widgets/recommended_activities_section.dart';

class MainScreen extends StatefulWidget {
  final Function(bool) onScrollChanged;
  final Function(int) onTabSwitch;
  final Function(String) setSearchFilterMode;
  final Function(String) onCategorySelected;

  const MainScreen({
    Key? key,
    required this.onScrollChanged,
    required this.onTabSwitch,
    required this.setSearchFilterMode,
    required this.onCategorySelected,
  }) : super(key: key);

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
  List<Map<String, dynamic>> popularCategories = [];
  ImageProvider? profileImageProvider;
  bool _isFabOpen = false;
  double _fabScale = 1.0;
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
    loadPopularCategories();
  }

  Future<void> _loadLimitedEvents() async {
    final events = await ActivityService.fetchEvents();
    if (!listEquals(limitedEvents, events)) {
      setState(() {
        limitedEvents = events;
      });
    }
  }

  void loadPopularCategories() async {
    try {
      final categories = await fetchCategoriesWithCounts();
      setState(() {
        popularCategories = categories;
      });
    } catch (e) {
      print("Error fetching categories: $e");
    }
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

    if (isLoading) {
      setState(() => isLoading = false);
    }
  }

  void fetchUserData() async {
    Box box = await Hive.openBox('authBox');
    String? userIdString = box.get("userId");

    if (userIdString == null) return;
    userId = userIdString;

    Uint8List? cachedBytes = box.get('profileImageBytes_$userId');

    if (cachedBytes != null) {
      if (profileImageProvider == null) {
        setState(() {
          profileImageProvider = MemoryImage(cachedBytes);
        });
      }
    } else {
      try {
        String fetchedProfilePic =
            await ProfileService.fetchProfilePicture(userId);

        if (fetchedProfilePic.isNotEmpty) {
          Uint8List decodedBytes = base64Decode(fetchedProfilePic);
          await box.put('profileImageBytes_$userId', decodedBytes);

          setState(() {
            profileImageProvider = MemoryImage(decodedBytes);
          });
        }
      } catch (e) {
        print("⚠️ Failed to load profile picture: $e");
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
      final decodedActivities = jsonDecode(cachedActivities);
      final decodedRecommendations = jsonDecode(cachedRecommendations);

      if (!listEquals(activities, decodedActivities) ||
          !listEquals(recommendedActivities, decodedRecommendations)) {
        setState(() {
          activities = decodedActivities;
          recommendedActivities = decodedRecommendations;
        });
      }

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

      if (!listEquals(activities, fetchedActivities) ||
          !listEquals(recommendedActivities, fetchedRecommended)) {
        setState(() {
          activities = fetchedActivities;
          recommendedActivities = fetchedRecommended;
        });
      }

      await box.put('activities', jsonEncode(fetchedActivities));
      await box.put('recommendations', jsonEncode(fetchedRecommended));
    } catch (error) {
      print("❌ Error fetching activities: $error");
    }
  }

  Future<List<Map<String, dynamic>>> fetchCategoriesWithCounts() async {
    final response =
        await http.get(Uri.parse("$baseUrl/categories/with-counts"));

    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(json.decode(response.body));
    } else {
      throw Exception("Failed to load categories with counts");
    }
  }

  void _toggleFab() {
    setState(() {
      _fabScale = 0.9;
    });
    Future.delayed(Duration(milliseconds: 100), () {
      setState(() {
        _fabScale = 1.0;
        _isFabOpen = !_isFabOpen;
      });
    });
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

    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor:
          isDarkMode ? const Color(0xFF121212) : const Color(0xFFF6F6F6),
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
                              padding: EdgeInsets.fromLTRB(16, 10, 0, 6),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Text Content
                                  Expanded(
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
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

                                                if (userBytes != null) {
                                                  return CircleAvatar(
                                                    radius: 22,
                                                    backgroundColor:
                                                        Colors.transparent,
                                                    backgroundImage:
                                                        profileImageProvider ??
                                                            const AssetImage(
                                                                "assets/images/default_user.png"),
                                                  );
                                                } else {
                                                  return Container(
                                                    width: 40,
                                                    height: 40,
                                                    decoration: BoxDecoration(
                                                      shape: BoxShape.circle,
                                                      color: isDarkMode
                                                          ? Colors.grey.shade900
                                                          : Colors
                                                              .white, // ✅ dynamic background
                                                      border: Border.all(
                                                        color: isDarkMode
                                                            ? Colors
                                                                .grey.shade700
                                                            : Colors.grey
                                                                .shade300, // ✅ dynamic border
                                                        width: 1.2,
                                                      ),
                                                      boxShadow: [
                                                        BoxShadow(
                                                          color: isDarkMode
                                                              ? Colors.black
                                                                  .withOpacity(
                                                                      0.3)
                                                              : Colors
                                                                  .black12, // ✅ dynamic shadow
                                                          blurRadius: 2,
                                                          offset:
                                                              Offset(0, 1.5),
                                                        ),
                                                      ],
                                                    ),
                                                    child: Center(
                                                      child: Icon(
                                                        LucideIcons.user,
                                                        size: 30,
                                                        color: isDarkMode
                                                            ? Colors.white
                                                            : Colors
                                                                .black, // ✅ dynamic icon
                                                      ),
                                                    ),
                                                  );
                                                }
                                              }

                                              // While loading the box
                                              return Container(
                                                width: 40,
                                                height: 40,
                                                decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  color: Colors.transparent,
                                                ),
                                                child: Icon(
                                                  Icons.person,
                                                  size: 30,
                                                  color: Colors.grey.shade400,
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.fromLTRB(
                                              10, 13, 0, 0),
                                          child: Text(
                                            "Welcome , $firstName !",
                                            style: TextStyle(
                                              height: 0.96,
                                              fontSize: screenWidth * 0.055,
                                              fontWeight: FontWeight.bold,
                                              fontFamily: 'Poppins',
                                              color: isDarkMode
                                                  ? Colors.white
                                                  : Colors.black,
                                            ),
                                          ),
                                        ),
                                        SizedBox(height: 10.0),
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
                                          icon: Icon(
                                            Icons
                                                .notifications, // or Icons.notifications
                                            size: screenWidth * 0.07,
                                            color: Theme.of(context)
                                                .iconTheme
                                                .color,
                                          ),
                                        ),
                                        SizedBox(width: 4),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              child: Divider(
                                thickness: 1,
                                color: isDarkMode
                                    ? Colors.grey.shade700
                                    : Colors.grey,
                              ),
                            ),

                            // Limited Time Activities Section
                            LimitedTimeActivitiesSection(
                              events: limitedEvents,
                              isDarkMode: isDarkMode,
                              screenWidth: screenWidth,
                              screenHeight: screenHeight,
                              onSeeAll: () {
                                widget
                                    .setSearchFilterMode("limited_events_only");
                                widget.onTabSwitch(1); // switch to Search tab
                              },
                            ),

                            // Popular Categories Section
                            PopularCategoriesSection(
                              categories: popularCategories,
                              screenWidth: screenWidth,
                              screenHeight: screenHeight,
                              isDarkMode: isDarkMode,
                              onCategorySelected: widget.onCategorySelected,
                            ),

                            // You Might Like Section
                            RecommendedActivitiesSection(
                              recommendedActivities: recommendedActivities,
                              screenWidth: screenWidth,
                              screenHeight: screenHeight,
                              isDarkMode: isDarkMode,
                              onSeeAll: () {
                                widget.onTabSwitch(1); // go to search tab
                              },
                            ),
                          ],
                        ),
                      ),

                      // 🔵 TWO BLUE BUTTONS ABOVE NAVBAR
                      // Wrap this in a Stack to use Positioned and AnimatedPositioned
                      Stack(
                        children: [
                          // Your screen content...

                          if (!isLoading && isProvider) ...[
                            // 🔹 Create Listing (Widest)
                            AnimatedPositioned(
                              duration: Duration(milliseconds: 300),
                              right: 20,
                              bottom: _isFabOpen ? 270 : 80,
                              child: AnimatedOpacity(
                                duration: Duration(milliseconds: 300),
                                opacity: _isFabOpen ? 1.0 : 0.0,
                                child: Container(
                                  margin: const EdgeInsets.only(bottom: 8),
                                  decoration: BoxDecoration(
                                    color: Colors.blue,
                                    borderRadius: BorderRadius.circular(16),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black26,
                                        blurRadius: 8,
                                        offset: Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: TextButton.icon(
                                    onPressed: () async {
                                      final box = await Hive.openBox('authBox');
                                      final userType = box.get('userType');
                                      final providerId = box.get('providerId');

                                      if (userType != 'provider' ||
                                          providerId == null) {
                                        showAppSnackBar(context,
                                            "Only providers can create listings.");
                                        return;
                                      }

                                      Navigator.of(context).push(
                                        PageRouteBuilder(
                                          transitionDuration:
                                              Duration(milliseconds: 450),
                                          reverseTransitionDuration:
                                              Duration(milliseconds: 300),
                                          pageBuilder: (_, __, ___) =>
                                              const CreateListingPage(),
                                          transitionsBuilder:
                                              (_, animation, __, child) {
                                            final curved = CurvedAnimation(
                                              parent: animation,
                                              curve: Curves.easeInOutCubic,
                                            );
                                            return SlideTransition(
                                              position: Tween<Offset>(
                                                begin: const Offset(0.25, 0),
                                                end: Offset.zero,
                                              ).animate(curved),
                                              child: FadeTransition(
                                                opacity: curved,
                                                child: ScaleTransition(
                                                  scale: Tween<double>(
                                                          begin: 0.97, end: 1.0)
                                                      .animate(curved),
                                                  child: child,
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                      );
                                      _toggleFab();
                                    },
                                    style: TextButton.styleFrom(
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 24, vertical: 12),
                                    ),
                                    icon: const Icon(Icons.add,
                                        color: Colors.white),
                                    label: const Text(
                                      "Create Listing",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontFamily: "poppins",
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),

                            // 🔹 Scan Barcode (Medium width)
                            AnimatedPositioned(
                              duration: Duration(milliseconds: 300),
                              right: 20,
                              bottom: _isFabOpen ? 210 : 80,
                              child: AnimatedOpacity(
                                duration: Duration(milliseconds: 300),
                                opacity: _isFabOpen ? 1.0 : 0.0,
                                child: Container(
                                  margin: const EdgeInsets.only(bottom: 8),
                                  decoration: BoxDecoration(
                                    color: Colors.blue,
                                    borderRadius: BorderRadius.circular(16),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black26,
                                        blurRadius: 8,
                                        offset: Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: TextButton.icon(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                TicketScanner()),
                                      );
                                      _toggleFab();
                                    },
                                    style: TextButton.styleFrom(
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 14, vertical: 12),
                                    ),
                                    icon: const Icon(Icons.qr_code_scanner,
                                        color: Colors.white),
                                    label: const Text(
                                      "Scan Barcode",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontFamily: "poppins",
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),

                            // 🔹 Create Reel (Shortest label)
                            AnimatedPositioned(
                              duration: Duration(milliseconds: 300),
                              right: 20,
                              bottom: _isFabOpen ? 150 : 80,
                              child: AnimatedOpacity(
                                duration: Duration(milliseconds: 300),
                                opacity: _isFabOpen ? 1.0 : 0.0,
                                child: Container(
                                  margin: const EdgeInsets.only(bottom: 8),
                                  decoration: BoxDecoration(
                                    color: Colors.blue,
                                    borderRadius: BorderRadius.circular(16),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black26,
                                        blurRadius: 8,
                                        offset: Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: TextButton.icon(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (_) => UploadReelPgPage()),
                                      );
                                      _toggleFab();
                                    },
                                    style: TextButton.styleFrom(
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12, vertical: 12),
                                    ),
                                    icon: const Icon(Icons.video_call,
                                        color: Colors.white),
                                    label: const Text(
                                      "Create Reel",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontFamily: "poppins",
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),

                            // 🔘 Main FAB Button
                            Positioned(
                              bottom: 100,
                              right: 20,
                              child: AnimatedScale(
                                scale: _fabScale,
                                duration: const Duration(milliseconds: 200),
                                curve: Curves.easeOutBack,
                                child: FloatingActionButton(
                                  backgroundColor: Colors.blue,
                                  elevation: 6,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(100)),
                                  onPressed: _toggleFab,
                                  child: AnimatedRotation(
                                    duration: const Duration(milliseconds: 300),
                                    turns: _isFabOpen ? 0.75 : 0,
                                    curve: Curves.easeInOutCubic,
                                    child: Icon(
                                      _isFabOpen ? Icons.close : Icons.add,
                                      color: Colors.white,
                                      size: 28,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ],
                      )

                      // Bottom Navigation Bar stays fixed at the bottom
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
