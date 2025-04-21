import 'package:adventura/Booking/MyBooking.dart';
import 'package:adventura/search%20screen/searchScreen.dart';
import 'package:flutter/material.dart';
import 'package:adventura/widgets/activitiess_web.dart';
import 'package:adventura/widgets/categories-web.dart';
import 'package:adventura/widgets/footer_web.dart';
import 'package:adventura/widgets/herosection_web.dart';
import 'package:adventura/widgets/navbar_web.dart';
import 'package:adventura/widgets/recommendation_web.dart';
import 'package:adventura/widgets/sidebar_web.dart';
import 'package:adventura/colors.dart';
import 'package:adventura/Services/activity_service.dart';
import 'package:adventura/web/bookingweb.dart';
import 'package:hive/hive.dart';
import 'dart:convert';
import 'package:scroll_to_index/scroll_to_index.dart'; // Add this import

class AdventuraWebHomee extends StatefulWidget {
  const AdventuraWebHomee({Key? key}) : super(key: key);

  @override
  State<AdventuraWebHomee> createState() => _AdventuraWebHomeState();
}

class _AdventuraWebHomeState extends State<AdventuraWebHomee> {
  String userId = ''; // Initialize with empty string instead of using late
  List<dynamic> activities = [];
  List<dynamic> recommendedActivities = [];
  String selectedLocation = "Tripoli";
  String firstName = "";
  String lastName = "";
  bool isLoading = true;
  bool showSidebar = false;
  int selectedIndex = 0; // For Navbar Pages switching
  
  // Controller for the page navigation
  final PageController _pageController = PageController();
  
  // Add AutoScrollController for vertical scrolling
  late AutoScrollController _scrollController;

  // Define index constants for auto-scrolling
  static const int ACTIVITIES_SECTION_INDEX = 1;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    loadActivities();
    
    // Initialize the auto scroll controller
    _scrollController = AutoScrollController(
      viewportBoundaryGetter: () => 
          Rect.fromLTRB(0, 0, 0, MediaQuery.of(context).padding.bottom),
      axis: Axis.vertical,
    );
  }
  
  @override
  void dispose() {
    _pageController.dispose();
    _scrollController.dispose(); // Dispose the scroll controller
    super.dispose();
  }

  Future<void> _loadUserData() async {
    try {
      Box box = await Hive.openBox('authBox');
      final userIdFromStorage = box.get('userId');
      
      setState(() {
        userId = userIdFromStorage?.toString() ?? '';
        firstName = box.get('firstName') ?? '';
        lastName = box.get('lastName') ?? '';
        isLoading = false;
      });
    } catch (e) {
      print('Error loading user data: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  void loadActivities() async {
    try {
      final box = await Hive.openBox('cacheBox');
      
      // Clear existing recommendations to force a fresh fetch
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

      Box storageBox = await Hive.openBox('authBox');
      String? userIdString = storageBox.get("userId");

      if (userIdString == null || userIdString.isEmpty) {
        setState(() => isLoading = false);
        return;
      }

      int userIdInt = int.tryParse(userIdString) ?? 0;
      print("🔍 Fetching recommended activities for user ID: $userIdInt");

      List<dynamic> fetchedActivities = await ActivityService.fetchActivities();
      List<dynamic> fetchedRecommended =
          await ActivityService.fetchRecommendedActivities(userIdInt);

      print("✅ Fetched Activities: ${fetchedActivities.length}");
      print("✅ Fetched Recommendations: ${fetchedRecommended.length}");

      setState(() {
        activities = fetchedActivities;
        recommendedActivities = fetchedRecommended;
        isLoading = false;
      });

      await box.put('activities', jsonEncode(fetchedActivities));
      await box.put('recommendations', jsonEncode(fetchedRecommended));
    } catch (error) {
      print('Error loading activities: $error');
      setState(() => isLoading = false);
    }
  }

  void toggleSidebar() {
    setState(() {
      showSidebar = !showSidebar;
    });
  }
  
  // Function to navigate to a specific tab
  void navigateToTab(int index) {
    setState(() {
      selectedIndex = index;
    });
    
    // Use the PageController to animate to the selected page
    if (_pageController.hasClients) {
      _pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }
  
  // Function to handle search tap from hero section
  void handleSearchTap() {
    // Navigate to the discover tab (index 1)
    navigateToTab(1);
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final bool isMobile = screenWidth < 768;
    final bool isTablet = screenWidth >= 768 && screenWidth < 1200;
    final bool isDesktop = screenWidth >= 1200;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDarkMode ? const Color(0xFF121212) : Colors.white,
      body: Stack(
        children: [
          Column(
            children: [
              // Navbar remains fixed at the top
              NavbarWidget(
                firstName: firstName,
                userId: userId,
                onMenuTap: toggleSidebar,
                selectedLocation: selectedLocation,
                onLocationChanged: (location) {
                  setState(() {
                    selectedLocation = location;
                  });
                },
                selectedIndex: selectedIndex,
                onTapNavItem: navigateToTab, // Use the navigation function here
              ),
              
              // Main content with PageView to handle tab navigation
              Expanded(
                child: PageView(
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(), // Disable swiping to maintain control
                  onPageChanged: (index) {
                    setState(() {
                      selectedIndex = index;
                    });
                  },
                  children: [
                    // Home Page Content
                    SingleChildScrollView(
                      controller: _scrollController, // Use the AutoScrollController here
                      child: Column(
                        children: [
                          // Pass the scroll controller to the hero section
                          HeroSectionWidget(
                            isLoading: isLoading,
                            onSearchTap: handleSearchTap,
                            scrollController: _scrollController, // Pass the controller here
                          ),
                          
                          // Wrap LimitedTimeActivitiesWeb with AutoScrollTag
                          if (!isLoading) 
                            AutoScrollTag(
                              key: ValueKey(ACTIVITIES_SECTION_INDEX),
                              controller: _scrollController,
                              index: ACTIVITIES_SECTION_INDEX,
                              child: LimitedTimeActivitiesWeb(),
                            ),
                            
                          if (!isLoading) CategoriesWebWidget(),
                          if (!isLoading) 
                            Padding(
                              padding: const EdgeInsets.fromLTRB(16, 32, 16, 16),
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment: CrossAxisAlignment.baseline,
                                    textBaseline: TextBaseline.alphabetic,
                                    children: [
                                      Text(
                                        "You Might Like",
                                        style: TextStyle(
                                          fontSize: isMobile ? 20 : 24,
                                          fontFamily: 'Poppins',
                                          fontWeight: FontWeight.bold,
                                          color: isDarkMode ? Colors.white : Colors.black,
                                        ),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          // Navigate to the discover tab
                                          navigateToTab(1);
                                        },
                                        child: Text(
                                          "See All",
                                          style: TextStyle(
                                            color: AppColors.blue,
                                            fontFamily: 'Poppins',
                                            fontSize: isMobile ? 14 : 16,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 16),
                                  recommendedActivities.isEmpty
                                    ? Padding(
                                        padding: EdgeInsets.all(32),
                                        child: Column(
                                          children: [
                                            Icon(
                                              Icons.warning,
                                              size: 48,
                                              color: isDarkMode
                                                  ? Colors.grey.shade400
                                                  : Colors.grey,
                                            ),
                                            SizedBox(height: 10),
                                            Text(
                                              "No recommendations found.",
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontFamily: 'Poppins',
                                                color: isDarkMode
                                                    ? Colors.grey.shade400
                                                    : Colors.grey,
                                              ),
                                            ),
                                          ],
                                        ),
                                      )
                                    : RecommendationsWidget(
                                        title: "",  // Empty title since we're adding our own
                                        activities: recommendedActivities.where((activity) => 
                                            activity['availability_status'] == true).toList(),
                                        isMobile: isMobile,
                                        isTablet: isTablet,
                                      ),
                                ],
                              ),
                            ),
                          const FooterWidget(),
                        ],
                      ),
                    ),

                    // Discover/Search Page Content
                    SearchScreen(onScrollChanged: (bool) { },),
                    MyBookingsPage(onScrollChanged: (bool) { }),

                    // Saved Page
                    const Center(child: Text("Saved Page")),
                  ],
                ),
              ),
            ],
          ),

          // Sidebar
          if (showSidebar)
            SidebarWidget(
              userId: userId,
              onClose: toggleSidebar,
              isProvider: true,
            ),
          
          // Back button
          Positioned(
            top: 60,
            left: 10,
            child: InkWell(
              onTap: () {
                Navigator.pop(context);
              },
              child: Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: (isDarkMode ? Colors.grey.shade800 : Colors.white).withOpacity(0.8),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.arrow_back,
                  color: AppColors.blue,
                  size: 24,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}