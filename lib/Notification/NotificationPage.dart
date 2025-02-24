import 'package:flutter/material.dart';

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
    return Scaffold(
      backgroundColor: Colors.white, // ✅ Full white background
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
          child: Column(
            children: [
              // ✅ Header with Back Arrow & Centered Title
              Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back_ios_new, color: Colors.black),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        "Notifications",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          fontFamily: "Poppins",
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 48), // Keeps the title centered
                ],
              ),
              SizedBox(height: 16),

              // ✅ Notifications List
              Expanded(
                child: ListView(
                  children: [
                    _buildSectionTitle("Today"),
                    SizedBox(height: 12), // ✅ Extra space after "Today"
                    ...todayNotifications.map((notification) => _buildNotificationItem(notification)).toList(),
                    
                    SizedBox(height: 20),
                    
                    _buildSectionTitle("Yesterday"),
                    SizedBox(height: 12), // ✅ Extra space after "Yesterday"
                    ...yesterdayNotifications.map((notification) => _buildNotificationItem(notification)).toList(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ✅ Section Title Widget
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          fontFamily: "Poppins",
          color: Colors.black,
        ),
      ),
    );
  }

  // ✅ Static Notification Item (No Clickable Feature)
  Widget _buildNotificationItem(Map<String, dynamic> notification) {
    return Column(
      children: [
        Row(
          children: [
            // ✅ Circular Icon with White Icon & Purple Background
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: Color.fromARGB(255, 134, 124, 224), // ✅ Dark purple background
                shape: BoxShape.circle,
              ),
              child: Icon(notification["icon"], color: Colors.white, size: 24), // ✅ White Icon
            ),
            SizedBox(width: 12),

            // ✅ Notification Text
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
        SizedBox(height: 8),

        // ✅ Grey Divider Inside Card
        Container(
          height: 2,
          color: Colors.grey[300],
          margin: EdgeInsets.only(left: 30, right: 16),
        ),
        SizedBox(height: 10),
      ],
    );
  }
}
