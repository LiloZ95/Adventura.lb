import 'package:adventura/colors.dart';
import 'package:flutter/material.dart';

class EventDetailsScreen extends StatefulWidget {
  final String title;
  final String date;
  final String location;
  final List<String> imagePaths; // List of image paths for swipeable images
  final List<Map<String, String>> tripPlan;
  final String description;

  EventDetailsScreen({
    required this.title,
    required this.date,
    required this.location,
    required this.imagePaths,
    required this.tripPlan,
    required this.description,
  });

  @override
  _EventDetailsScreenState createState() => _EventDetailsScreenState();
}//random comment to push 

class _EventDetailsScreenState extends State<EventDetailsScreen> {
  bool isFavorite = false; // State variable for the favorite button

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.share,
              color: Colors.black,
              size: 30,
            ),
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(
              isFavorite ? Icons.favorite : Icons.favorite_border,
              size: 30,
              color: isFavorite ? Colors.red : Colors.black,
            ),
            onPressed: () {
              setState(() {
                isFavorite = !isFavorite; // Toggle the favorite state
              });
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Swipeable image container
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Container(
                height: 250,
                width: screenWidth * 0.96,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 4,
                      spreadRadius: 1,
                      offset: Offset(0, 4), // Shadow position
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Stack(
                    children: [
                      PageView.builder(
                        itemCount: widget.imagePaths.length,
                        itemBuilder: (context, index) {
                          return Image.asset(
                            widget.imagePaths[index],
                            width: double.infinity,
                            fit: BoxFit.cover,
                          );
                        },
                      ),
                      Positioned(
                        bottom: 10,
                        right: 10,
                        child: Container(
                          padding:
                              EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '1/${widget.imagePaths.length}',
                            style: TextStyle(color: Colors.white, fontSize: 12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    widget.title,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Poppins',
                    ),
                  ),
                  SizedBox(height: 8),
                  // Date & Location
                  Row(
                    children: [
                      Icon(Icons.calendar_today, size: 18, color: Colors.grey),
                      SizedBox(width: 5),
                      Text(widget.date,
                          style: TextStyle(fontSize: 16, color: Colors.grey)),
                    ],
                  ),
                  SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.location_on, size: 18, color: Colors.grey),
                      SizedBox(width: 5),
                      Text(widget.location,
                          style: TextStyle(fontSize: 16, color: Colors.grey)),
                    ],
                  ),
                  SizedBox(height: 10),
                  Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(0, 0, 8, 0),
                        child: Text(
                          "Trip plan",
                          style: TextStyle(
                              color: Colors.black,
                              fontFamily: 'Poppins',
                              fontSize: 22,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                      Expanded(
                        child: Divider(
                          color: Colors.grey,
                          thickness: 1,
                        ),
                      ),
                    ],
                  ),
                  // Trip plan
                  SizedBox(height: 4),
                  Container(
                    height: 80,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: widget.tripPlan.length,
                      itemBuilder: (context, index) {
                        return Row(
                          children: [
                            Container(
                              margin: EdgeInsets.symmetric(vertical: 12),
                              padding: EdgeInsets.symmetric(horizontal: 12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Color.fromARGB(255, 108, 108, 108),
                                  width: 1, // Thin border
                                ),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '• ' + widget.tripPlan[index]['time']!,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Color.fromARGB(255, 108, 108, 108),
                                      fontFamily: 'Poppins',
                                    ),
                                  ),
                                  Text(
                                    widget.tripPlan[index]['event']!,
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.black,
                                      fontFamily: 'Poppins',
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (index < widget.tripPlan.length - 1)
                              Image.asset(
                                'assets/Icons/arrow-right.png',
                                width: 35,
                                height: 35,
                                color: Colors
                                    .grey, // Adjust color if the image is an SVG or supports tint
                              ),
                          ],
                        );
                      },
                    ),
                  ),
                  // Description
                  SizedBox(height: 6),
                  Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(0, 0, 8, 0),
                        child: Text(
                          "Description",
                          style: TextStyle(
                              color: Colors.black,
                              fontFamily: 'Poppins',
                              fontSize: 22,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                      Expanded(
                        child: Divider(
                          color: Colors.grey,
                          thickness: 1,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    widget.description,
                    style: TextStyle(
                        fontSize: 15,
                        color: Colors.black87,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.normal),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Wrap(
                      spacing: 6.0,
                      runSpacing: 4.0,
                      children: [
                        _buildFeatureTag("Trending"),
                        _buildFeatureTag("All ages"),
                        _buildFeatureTag("Fundraising"),
                        _buildFeatureTag("Music"),
                        _buildFeatureTag("Burnouts"),
                        _buildFeatureTag("Food Trucks"),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureTag(String text) {
    bool isTrending = text == "Trending";

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: isTrending
            ? LinearGradient(
                colors: [Colors.orange, Colors.red],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : null,
        color: isTrending ? null : AppColors.blue,
      ),
      child: Text(
        text,
        style: TextStyle(
          color: Colors.white,
          fontFamily: 'Poppins',
          fontSize: 14,
          fontWeight: isTrending ? FontWeight.bold : null,
        ),
      ),
    );
  }
}
