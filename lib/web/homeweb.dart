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

  @override
  void initState() {
    super.initState();
    _loadUserData();
    loadActivities();
  }
  
  @override
  void dispose() {
    _pageController.dispose();
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

      List<dynamic> fetchedActivities = await ActivityService.fetchActivities();
      List<dynamic> fetchedRecommended =
          await ActivityService.fetchRecommendedActivities(userIdInt);

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

    return Scaffold(
      backgroundColor: Colors.white,
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
                      child: Column(
                        children: [
                          // Pass the search tap handler to the hero section
                          HeroSectionWidget(
                            isLoading: isLoading,
                            onSearchTap: handleSearchTap,
                          ),
                          if (!isLoading) LimitedTimeActivitiesWeb(),
                          if (!isLoading) CategoriesWebWidget(),
                          if (!isLoading)
                            RecommendationsWidget(
                              title: "You Might Like",
                              activities: recommendedActivities,
                              isMobile: isMobile,
                              isTablet: isTablet,
                            ),
                          const FooterWidget(),
                        ],
                      ),
                    ),

                    // Discover/Search Page Content
                   SearchScreen(onScrollChanged: (bool) { },),

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
                  color: Colors.white.withOpacity(0.8),
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