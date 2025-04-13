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
import 'package:adventura/web/bookingweb.dart'; // Add this
import 'package:hive/hive.dart';
import 'dart:convert';

class AdventuraWebHomee extends StatefulWidget {
  const AdventuraWebHomee({Key? key}) : super(key: key);

  @override
  State<AdventuraWebHomee> createState() => _AdventuraWebHomeState();
}

class _AdventuraWebHomeState extends State<AdventuraWebHomee> {
  late String userId;
  List<dynamic> activities = [];
  List<dynamic> recommendedActivities = [];
  String selectedLocation = "Tripoli";
  String firstName = "";
  String lastName = "";
  bool isLoading = true;
  bool showSidebar = false;
  int selectedIndex = 0; // For Navbar Pages switching

  @override
  void initState() {
    super.initState();
    _loadUserData();
    loadActivities();
  }

  Future<void> _loadUserData() async {
    Box box = await Hive.openBox('authBox');
    userId = box.get('userId') ?? '';
    firstName = box.get('firstName') ?? '';
    lastName = box.get('lastName') ?? '';
    setState(() => isLoading = false);
  }

  void loadActivities() async {
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

    try {
      Box storageBox = await Hive.openBox('authBox');
      String? userIdString = storageBox.get("userId");

      if (userIdString == null) return;

      int userId = int.tryParse(userIdString) ?? 0;

      List<dynamic> fetchedActivities = await ActivityService.fetchActivities();
      List<dynamic> fetchedRecommended =
          await ActivityService.fetchRecommendedActivities(userId);

      setState(() {
        activities = fetchedActivities;
        recommendedActivities = fetchedRecommended;
        isLoading = false;
      });

      await box.put('activities', jsonEncode(fetchedActivities));
      await box.put('recommendations', jsonEncode(fetchedRecommended));
    } catch (error) {
      setState(() => isLoading = false);
    }
  }

  void toggleSidebar() {
    setState(() {
      showSidebar = !showSidebar;
    });
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
                onTapNavItem: (index) {
                  setState(() {
                    selectedIndex = index;
                  });
                },
              ),
Expanded(
  child: IndexedStack(
    index: selectedIndex,
    children: [
      // Home Page Content
      SingleChildScrollView(
        child: Column(
          children: [
            HeroSectionWidget(isLoading: isLoading),
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

      // Booking Page Content
      const WebBookingsPage(),

      // Saved Page
      const Center(child: Text("Saved Page")),
    ],
  ),
)

            ],
          ),

          // Sidebar
          if (showSidebar)
            SidebarWidget(
              userId: userId,
              onClose: toggleSidebar,
              isProvider: true,
            ),
        ],
      ),
    );
  }
}
