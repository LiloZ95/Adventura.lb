import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class NotificationScreen extends StatelessWidget {
  // Sample notifications data
  final List<Map<String, dynamic>> todayNotifications = [
    {
      "icon": Icons.receipt_long,
      "title": "Booking Successfully",
      "description": "Your trip has been booked successfully."
    },
    {
      "icon": Icons.lock,
      "title": "Password Update Successful",
      "description": "Your password has been placed successfully."
    },
    {
      "icon": Icons.person,
      "title": "Account Setup Successfully",
      "description": "Your account has been created."
    },
    {
      "icon": Icons.local_offer,
      "title": "Best Deal of the Day",
      "description": "Buy 1 Get 1 Offer on selected product... hurry up"
    },
  ];

  final List<Map<String, dynamic>> yesterdayNotifications = [
    {
      "icon": Icons.credit_card,
      "title": "Debit Card Added Successfully",
      "description": "Your debit card has been added."
    },
    {
      "icon": Icons.confirmation_num,
      "title": "Get 20% Off On First Trip",
      "description": "Your order has been placed successfully."
    },
  ];

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final bool isWeb = kIsWeb;
    
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Header with back arrow (for both web and mobile)
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: 16.0, 
                vertical: isWeb ? 20.0 : 16.0
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: isWeb ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: Offset(0, 4)
                  )
                ] : null,
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(
                      isWeb ? Icons.arrow_back : Icons.arrow_back_ios_new, 
                      color: Colors.black
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        "Notifications",
                        style: TextStyle(
                          fontSize: isWeb ? 26 : 24,
                          fontWeight: FontWeight.bold,
                          fontFamily: "Poppins",
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 48), // Balance the layout
                ],
              ),
            ),
            
            // Notifications Content
            Expanded(
              child: isWeb
                ? _buildWebLayout(screenWidth)
                : _buildMobileLayout(),
            ),
          ],
        ),
      ),
    );
  }

  // Web-optimized layout using full width
  Widget _buildWebLayout(double screenWidth) {
    // Determine grid columns based on screen width
    int columns = screenWidth > 1400 ? 3 : (screenWidth > 900 ? 2 : 1);
    
    return Container(
      width: double.infinity,
      color: Colors.grey.shade50, // Subtle background color for contrast
      padding: EdgeInsets.all(24.0),
      child: ListView(
        children: [
          _buildSectionTitle("Today"),
          SizedBox(height: 16),
          
          // Grid layout for today's notifications
          GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: columns,
              childAspectRatio: 4.0,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: todayNotifications.length,
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemBuilder: (context, index) {
              return _buildWebNotificationItem(todayNotifications[index]);
            },
          ),
          
          SizedBox(height: 32),
          
          _buildSectionTitle("Yesterday"),
          SizedBox(height: 16),
          
          // Grid layout for yesterday's notifications
          GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: columns,
              childAspectRatio: 4.0,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: yesterdayNotifications.length,
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemBuilder: (context, index) {
              return _buildWebNotificationItem(yesterdayNotifications[index]);
            },
          ),
        ],
      ),
    );
  }

  // Original mobile layout with small enhancements
  Widget _buildMobileLayout() {
    return ListView(
      padding: EdgeInsets.all(16.0),
      children: [
        _buildSectionTitle("Today"),
        SizedBox(height: 12),
        ...todayNotifications.map((notification) => 
          _buildMobileNotificationItem(notification)
        ).toList(),
        
        SizedBox(height: 24),
        
        _buildSectionTitle("Yesterday"),
        SizedBox(height: 12),
        ...yesterdayNotifications.map((notification) => 
          _buildMobileNotificationItem(notification)
        ).toList(),
      ],
    );
  }

  // Attractive web notification item
  Widget _buildWebNotificationItem(Map<String, dynamic> notification) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            spreadRadius: 1,
            offset: Offset(0, 2),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias, // For the InkWell effect
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {},
          splashColor: Color.fromARGB(255, 134, 124, 224).withOpacity(0.1),
          highlightColor: Color.fromARGB(255, 134, 124, 224).withOpacity(0.05),
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                // Circular Icon with improved styling
                Container(
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(
                    color: Color.fromARGB(255, 134, 124, 224),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Color.fromARGB(255, 134, 124, 224).withOpacity(0.3),
                        blurRadius: 8,
                        spreadRadius: 0,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Icon(
                    notification["icon"], 
                    color: Colors.white, 
                    size: 26
                  ),
                ),
                SizedBox(width: 18),

                // Notification Text
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        notification["title"]!,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 17,
                          fontFamily: "Poppins",
                          color: Colors.black87,
                        ),
                      ),
                      SizedBox(height: 5),
                      Text(
                        notification["description"]!,
                        style: TextStyle(
                          fontSize: 15, 
                          fontFamily: "Poppins", 
                          color: Colors.black54
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                
                // Arrow icon
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  padding: EdgeInsets.all(8),
                  child: Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.grey.shade600,
                    size: 18,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Enhanced mobile notification item
  Widget _buildMobileNotificationItem(Map<String, dynamic> notification) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      child: Column(
        children: [
          Row(
            children: [
              // Circular Icon with subtle shadow
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: Color.fromARGB(255, 134, 124, 224),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Color.fromARGB(255, 134, 124, 224).withOpacity(0.2),
                      blurRadius: 6,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(notification["icon"], color: Colors.white, size: 24),
              ),
              SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      notification["title"]!,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        fontFamily: "Poppins",
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      notification["description"]!,
                      style: TextStyle(fontSize: 14, fontFamily: "Poppins", color: Colors.black54),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 12),

          // Enhanced divider with gradient
          Container(
            height: 1.5,
            margin: EdgeInsets.only(left: 30, right: 16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.grey.shade300.withOpacity(0.1),
                  Colors.grey.shade300,
                  Colors.grey.shade300,
                  Colors.grey.shade300.withOpacity(0.1),
                ],
                stops: [0.0, 0.2, 0.8, 1.0],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Section Title Widget with enhanced styling
  Widget _buildSectionTitle(String title) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 20,
          decoration: BoxDecoration(
            color: Color.fromARGB(255, 134, 124, 224),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: kIsWeb ? 20 : 18,
            fontWeight: FontWeight.bold,
            fontFamily: "Poppins",
            color: Colors.black87,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }
}