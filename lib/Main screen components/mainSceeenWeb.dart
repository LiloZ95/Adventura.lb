import 'dart:ui';
import 'dart:typed_data';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:cached_network_image/cached_network_image.dart';

class AdventuraWebHome extends StatefulWidget {
  @override
  _AdventuraWebHomeState createState() => _AdventuraWebHomeState();
}

class _AdventuraWebHomeState extends State<AdventuraWebHome> {
  late String userId;
  String profilePicture = "";
  bool isLoading = true;
  List<dynamic> activities = [];
  List<dynamic> recommendedActivities = [];
  String selectedLocation = "Tripoli";
  String firstName = "";
  String lastName = "";
  List<String> categories = ["Hikes", "Boats", "Sunsets", "Tours", "Paragliding", "Jetski", "Island Trips", "Picnics", "Car Events"];
  String selectedCategory = "Hikes";

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
    // Simplified for example - you would fetch these from your API
    setState(() {
      activities = [
        {
          "id": 1,
          "title": "Hiking Trip",
          "location": "Batroun",
          "price": "60",
          "rating": 4.5,
          "description": "Experience the beauty of Lebanon's mountains",
          "image": "Hikes/batroun.jpg",
          "date": "2025-04-15"
        },
        {
          "id": 2,
          "title": "Sunset Hike",
          "location": "Jbeil",
          "price": "50",
          "rating": 4.8,
          "description": "Watch the sunset from Lebanon's beautiful trails",
          "image": "Hikes/sunsethike.webp",
          "date": "2025-04-20"
        },
        {
          "id": 3,
          "title": "Night Hike Adventure",
          "location": "Beirut",
          "price": "70",
          "rating": 4.2,
          "description": "Explore nature under the stars",
          "image": "Hikes/nighthike.webp",
          "date": "2025-04-25"
        }
      ];
      recommendedActivities = [
        {
          "id": 4,
          "title": "Paragliding Experience",
          "location": "Jounieh",
          "price": "150",
          "rating": 4.9,
          "description": "Soar above the stunning bay of Jounieh",
          "image": "paragliding.webp",
          "date": "2025-05-05"
        },
        {
          "id": 5,
          "title": "Jetski Adventure",
          "location": "Tripoli",
          "price": "120",
          "rating": 4.0,
          "description": "Speed across the Mediterranean waves",
          "image": "jetski.jpeg",
          "date": "2025-05-10"
        },
        {
          "id": 6,
          "title": "Island Trip",
          "location": "Tyre",
          "price": "200",
          "rating": 5.0,
          "description": "Visit Lebanon's beautiful islands",
          "image": "island.jpg",
          "date": "2025-05-15"
        }
      ];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            // Responsive layout based on screen width
            bool isDesktop = constraints.maxWidth > 1200;
            bool isTablet = constraints.maxWidth > 800 && constraints.maxWidth <= 1200;
            
            return CustomScrollView(
              slivers: [
                // App Bar
                SliverAppBar(
                  floating: false,
                  pinned: true,
                  backgroundColor: Colors.white,
                  expandedHeight: 100,
                  flexibleSpace: FlexibleSpaceBar(
                    background: Container(
                      color: Colors.white,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Logo and Welcome Message
                            Row(
                              children: [
                                Image.asset(
                                  'assets/Icons/logo.png', // Replace with your logo
                                  width: 40,
                                  height: 40,
                                ),
                                SizedBox(width: 16),
                                Text(
                                  "Adventura",
                                  style: TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'Poppins',
                                  ),
                                ),
                              ],
                            ),
                            
                            // Navigation Links - Only show on desktop and tablet
                            if (isDesktop || isTablet)
                              Row(
                                children: [
                                  _buildNavItem("Home", true),
                                  _buildNavItem("Explore", false),
                                  _buildNavItem("Bookings", false),
                                  _buildNavItem("Favorites", false),
                                  _buildNavItem("Messages", false),
                                ],
                              ),
                            
                            // User Profile and Actions
                            Row(
                              children: [
                                if (isDesktop || isTablet)
                                  Container(
                                    width: 280,
                                    height: 50,
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade100,
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                    child: TextField(
                                      decoration: InputDecoration(
                                        contentPadding: EdgeInsets.symmetric(vertical: 15),
                                        border: InputBorder.none,
                                        hintText: "Search adventures...",
                                        prefixIcon: Icon(Icons.search),
                                      ),
                                    ),
                                  ),
                                SizedBox(width: 16),
                                IconButton(
                                  icon: Icon(Icons.notifications_none_outlined, size: 28),
                                  onPressed: () {},
                                ),
                                IconButton(
                                  icon: Icon(Icons.person_outline, size: 28),
                                  onPressed: () {},
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                
                // Categories
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Explore Categories",
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Poppins',
                          ),
                        ),
                        SizedBox(height: 16),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: categories.map((category) {
                              bool isSelected = category == selectedCategory;
                              return Padding(
                                padding: EdgeInsets.only(right: 12),
                                child: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      selectedCategory = category;
                                    });
                                  },
                                  child: Container(
                                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                    decoration: BoxDecoration(
                                      color: isSelected ? Color(0xFF0078FF) : Colors.white,
                                      borderRadius: BorderRadius.circular(30),
                                      border: Border.all(
                                        color: isSelected ? Color(0xFF0078FF) : Colors.grey.shade300,
                                      ),
                                    ),
                                    child: Text(
                                      category,
                                      style: TextStyle(
                                        color: isSelected ? Colors.white : Colors.black87,
                                        fontWeight: FontWeight.w500,
                                        fontFamily: 'Poppins',
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                // Main Content Area - Responsive Grid Layout
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Left Section - Limited Time Activities
                        Expanded(
                          flex: isDesktop ? 7 : 6,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Featured Activities
                              Padding(
                                padding: const EdgeInsets.only(bottom: 16),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "Limited Time Activities",
                                      style: TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: 'Poppins',
                                      ),
                                    ),
                                    TextButton(
                                      onPressed: () {},
                                      child: Text(
                                        "See All",
                                        style: TextStyle(
                                          color: Color(0xFF0078FF),
                                          fontFamily: 'Poppins',
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              
                              // Featured Card
                              Container(
                                height: 320,
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade200,
                                  borderRadius: BorderRadius.circular(16),
                                  image: DecorationImage(
                                    image: AssetImage("assets/Hikes/assirafting.webp"),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                child: Stack(
                                  children: [
                                    Positioned(
                                      bottom: 0,
                                      left: 0,
                                      right: 0,
                                      child: Container(
                                        padding: EdgeInsets.all(16),
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.only(
                                            bottomLeft: Radius.circular(16),
                                            bottomRight: Radius.circular(16),
                                          ),
                                          gradient: LinearGradient(
                                            begin: Alignment.topCenter,
                                            end: Alignment.bottomCenter,
                                            colors: [
                                              Colors.transparent,
                                              Colors.black.withOpacity(0.8),
                                            ],
                                          ),
                                        ),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              "Assi River White Water Rafting",
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 22,
                                                fontWeight: FontWeight.bold,
                                                fontFamily: 'Poppins',
                                              ),
                                            ),
                                            SizedBox(height: 8),
                                            Row(
                                              children: [
                                                Icon(Icons.location_on, color: Colors.white, size: 16),
                                                SizedBox(width: 4),
                                                Text(
                                                  "Hermel, Lebanon",
                                                  style: TextStyle(color: Colors.white70),
                                                ),
                                                Spacer(),
                                                Container(
                                                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                                  decoration: BoxDecoration(
                                                    color: Color(0xFF0078FF),
                                                    borderRadius: BorderRadius.circular(20),
                                                  ),
                                                  child: Text(
                                                    "\$120",
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      top: 16,
                                      right: 16,
                                      child: Container(
                                        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                        decoration: BoxDecoration(
                                          color: Colors.red,
                                          borderRadius: BorderRadius.circular(20),
                                        ),
                                        child: Text(
                                          "Limited Time",
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              
                              SizedBox(height: 24),
                              
                              // Activities Grid
                              GridView.builder(
                                shrinkWrap: true,
                                physics: NeverScrollableScrollPhysics(),
                                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: isDesktop ? 3 : (isTablet ? 2 : 1),
                                  childAspectRatio: 0.8,
                                  crossAxisSpacing: 16,
                                  mainAxisSpacing: 16,
                                ),
                                itemCount: activities.length,
                                itemBuilder: (context, index) {
                                  return _buildActivityCard(activities[index]);
                                },
                              ),
                            ],
                          ),
                        ),
                        
                        SizedBox(width: 24),
                        
                        // Right Section - Popular Categories and Recommendations
                        if (isDesktop || isTablet)
                          Expanded(
                            flex: isDesktop ? 3 : 4,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 16),
                                  child: Text(
                                    "You Might Like",
                                    style: TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'Poppins',
                                    ),
                                  ),
                                ),
                                
                                // Recommendations List
                                ...recommendedActivities.map((activity) => Padding(
                                  padding: const EdgeInsets.only(bottom: 16),
                                  child: _buildHorizontalActivityCard(activity),
                                )).toList(),
                                
                                SizedBox(height: 24),
                                
                                // Stats Section
                                Container(
                                  padding: EdgeInsets.all(20),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade100,
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Your Activity",
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          fontFamily: 'Poppins',
                                        ),
                                      ),
                                      SizedBox(height: 16),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          _buildStatItem("Booked", "23"),
                                          _buildStatItem("Completed", "18"),
                                          _buildStatItem("Reviewed", "15"),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                
                                SizedBox(height: 24),
                                
                                // Create Listing Button (for providers)
                                Container(
                                  width: double.infinity,
                                  padding: EdgeInsets.symmetric(vertical: 16),
                                  decoration: BoxDecoration(
                                    color: Color(0xFF0078FF),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Center(
                                    child: Text(
                                      "Create a New Listing",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: 'Poppins',
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                
                // Footer
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
                    child: Column(
                      children: [
                        Divider(),
                        SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Company Info
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Adventura",
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'Poppins',
                                  ),
                                ),
                                SizedBox(height: 12),
                                Text(
                                  "Discover Lebanon's hidden gems\nand unforgettable experiences.",
                                  style: TextStyle(
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                            
                            // Quick Links
                            if (isDesktop)
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Quick Links",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'Poppins',
                                    ),
                                  ),
                                  SizedBox(height: 12),
                                  _buildFooterLink("About Us"),
                                  _buildFooterLink("Contact Us"),
                                  _buildFooterLink("Terms of Service"),
                                  _buildFooterLink("Privacy Policy"),
                                ],
                              ),
                            
                            // Categories
                            if (isDesktop)
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Categories",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'Poppins',
                                    ),
                                  ),
                                  SizedBox(height: 12),
                                  _buildFooterLink("Hiking"),
                                  _buildFooterLink("Watersports"),
                                  _buildFooterLink("City Tours"),
                                  _buildFooterLink("Adventure Sports"),
                                ],
                              ),
                            
                            // Contact
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Contact",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'Poppins',
                                  ),
                                ),
                                SizedBox(height: 12),
                                _buildContactItem(Icons.email_outlined, "info@adventura.com"),
                                _buildContactItem(Icons.phone_outlined, "+961 1 234 567"),
                                _buildContactItem(Icons.location_on_outlined, "Beirut, Lebanon"),
                              ],
                            ),
                          ],
                        ),
                        SizedBox(height: 24),
                        Text(
                          "© 2025 Adventura. All Rights Reserved.",
                          style: TextStyle(
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
  
  Widget _buildNavItem(String title, bool isActive) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            style: TextStyle(
              color: isActive ? Color(0xFF0078FF) : Colors.black87,
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              fontFamily: 'Poppins',
            ),
          ),
          SizedBox(height: 4),
          if (isActive)
            Container(
              width: 24,
              height: 2,
              color: Color(0xFF0078FF),
            ),
        ],
      ),
    );
  }
  
  Widget _buildActivityCard(Map<String, dynamic> activity) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            spreadRadius: 0,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            Container(
              height: 180,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage("assets/${activity['image']}"),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            
            // Content
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          activity['date'],
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ),
                      Spacer(),
                      Icon(Icons.star, color: Colors.amber, size: 16),
                      SizedBox(width: 4),
                      Text(
                        "${activity['rating']}",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text(
                    activity['title'],
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Poppins',
                    ),
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.location_on, color: Colors.grey, size: 16),
                      SizedBox(width: 4),
                      Text(
                        activity['location'],
                        style: TextStyle(color: Colors.grey.shade700),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "\$${activity['price']}",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0078FF),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: Color(0xFF0078FF),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          "Book Now",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildHorizontalActivityCard(Map<String, dynamic> activity) {
    return Container(
      height: 100,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Row(
        children: [
          // Image
          ClipRRect(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(12),
              bottomLeft: Radius.circular(12),
            ),
            child: Image.asset(
              "assets/${activity['image']}",
              width: 100,
              height: 100,
              fit: BoxFit.cover,
            ),
          ),
          
          // Content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    activity['title'],
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Poppins',
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.location_on, color: Colors.grey, size: 14),
                      SizedBox(width: 4),
                      Text(
                        activity['location'],
                        style: TextStyle(
                          color: Colors.grey.shade700,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "\$${activity['price']}",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0078FF),
                        ),
                      ),
                      Row(
                        children: [
                          Icon(Icons.star, color: Colors.amber, size: 14),
                          SizedBox(width: 2),
                          Text(
                            "${activity['rating']}",
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildStatItem(String title, String value) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFF0078FF),
          ),
        ),
        SizedBox(height: 4),
        Text(
          title,
          style: TextStyle(
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }
  
  Widget _buildFooterLink(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: TextStyle(
          color: Colors.grey.shade600,
        ),
      ),
    );
  }
  
  Widget _buildContactItem(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey.shade600),
          SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }
}