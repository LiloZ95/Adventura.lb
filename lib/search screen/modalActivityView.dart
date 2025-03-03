import 'package:adventura/colors.dart';
import 'package:flutter/material.dart';
import 'package:adventura/OrderDetail/Order.dart';

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
}

class _EventDetailsScreenState extends State<EventDetailsScreen> {
  bool isFavorite = false; // State variable for the favorite button

  // Variables to track the selected image in the PageView
  int _currentImageIndex = 0;
  final PageController _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose(); // Dispose the controller when not needed
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Obtain screen dimensions and safe area padding
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    double bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back,
              color: Colors.black, size: screenWidth * 0.07),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.share,
              color: Colors.black,
              size: screenWidth * 0.07,
            ),
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(
              isFavorite ? Icons.favorite : Icons.favorite_border,
              size: screenWidth * 0.07,
              color: isFavorite ? Colors.red : Colors.black,
            ),
            onPressed: () {
              setState(() {
                isFavorite = !isFavorite; // Toggle favorite state
              });
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.only(bottom: screenHeight * 0.12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Swipeable image container
            Padding(
              padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.03),
              child: Container(
                height: screenHeight * 0.3,
                width: screenWidth * 0.96,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(screenWidth * 0.03),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: screenWidth * 0.02,
                      spreadRadius: screenWidth * 0.005,
                      offset: Offset(0, screenWidth * 0.02),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(screenWidth * 0.03),
                  child: Stack(
                    children: [
                      PageView.builder(
                        controller: _pageController,
                        onPageChanged: (index) {
                          setState(() {
                            _currentImageIndex = index;
                          });
                        },
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
                        bottom: screenHeight * 0.01,
                        right: screenWidth * 0.02,
                        child: Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: screenWidth * 0.02,
                              vertical: screenHeight * 0.005),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.5),
                            borderRadius:
                                BorderRadius.circular(screenWidth * 0.02),
                          ),
                          child: Text(
                            '${_currentImageIndex + 1}/${widget.imagePaths.length}',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: screenWidth * 0.035,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // Main content below the images (trip plan, description, etc.)
            Padding(
              padding: EdgeInsets.all(screenWidth * 0.04),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    widget.title,
                    style: TextStyle(
                      fontSize: screenWidth * 0.06,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Poppins',
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.01),
                  // Date & Location
                  Row(
                    children: [
                      Icon(Icons.calendar_today,
                          size: screenWidth * 0.045, color: Colors.grey),
                      SizedBox(width: screenWidth * 0.01),
                      Text(
                        widget.date,
                        style: TextStyle(
                            fontSize: screenWidth * 0.04, color: Colors.grey),
                      ),
                    ],
                  ),
                  SizedBox(height: screenHeight * 0.005),
                  Row(
                    children: [
                      Icon(Icons.location_on,
                          size: screenWidth * 0.045, color: Colors.grey),
                      SizedBox(width: screenWidth * 0.01),
                      Text(
                        widget.location,
                        style: TextStyle(
                            fontSize: screenWidth * 0.04, color: Colors.grey),
                      ),
                    ],
                  ),
                  SizedBox(height: screenHeight * 0.015),
                  // Trip plan and other content remain unchanged...
                  Row(
                    children: [
                      Padding(
                        padding: EdgeInsets.only(right: screenWidth * 0.02),
                        child: Text(
                          "Trip plan",
                          style: TextStyle(
                            color: Colors.black,
                            fontFamily: 'Poppins',
                            fontSize: screenWidth * 0.055,
                            fontWeight: FontWeight.bold,
                          ),
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
                  SizedBox(height: screenHeight * 0.005),
                  Container(
                    height: screenHeight * 0.1,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: widget.tripPlan.length,
                      itemBuilder: (context, index) {
                        return Row(
                          children: [
                            Container(
                              margin: EdgeInsets.symmetric(
                                  vertical: screenHeight * 0.015),
                              padding: EdgeInsets.symmetric(
                                  horizontal: screenWidth * 0.03),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius:
                                    BorderRadius.circular(screenWidth * 0.03),
                                border: Border.all(
                                  color: Color.fromARGB(255, 108, 108, 108),
                                  width: 1,
                                ),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '• ' + widget.tripPlan[index]['time']!,
                                    style: TextStyle(
                                      fontSize: screenWidth * 0.035,
                                      color: Color.fromARGB(255, 108, 108, 108),
                                      fontFamily: 'Poppins',
                                    ),
                                  ),
                                  Text(
                                    widget.tripPlan[index]['event']!,
                                    style: TextStyle(
                                      fontSize: screenWidth * 0.045,
                                      color: Colors.black,
                                      fontFamily: 'Poppins',
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (index < widget.tripPlan.length - 1)
                              Padding(
                                padding: EdgeInsets.symmetric(
                                    horizontal: screenWidth * 0.02),
                                child: Image.asset(
                                  'assets/Icons/arrow-right.png',
                                  width: screenWidth * 0.08,
                                  height: screenWidth * 0.08,
                                  color: Colors.grey,
                                ),
                              ),
                          ],
                        );
                      },
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.01),
                  // Description header and text remain (if needed) or can be removed similarly
                  Row(
                    children: [
                      Padding(
                        padding: EdgeInsets.only(right: screenWidth * 0.02),
                        child: Text(
                          "Description",
                          style: TextStyle(
                            color: Colors.black,
                            fontFamily: 'Poppins',
                            fontSize: screenWidth * 0.055,
                            fontWeight: FontWeight.bold,
                          ),
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
                      fontSize: screenWidth * 0.04,
                      color: Colors.black87,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                  Padding(
                    padding:
                        EdgeInsets.symmetric(vertical: screenHeight * 0.01),
                    child: Wrap(
                      spacing: screenWidth * 0.02,
                      runSpacing: screenHeight * 0.005,
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
                  SizedBox(height: screenHeight * 0.02),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          width: screenWidth,
          height: screenHeight * 0.1 + bottomPadding,
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
            child: BottomAppBar(
              color: Colors.transparent,
              elevation: 10,
              child: Padding(
                padding: EdgeInsets.only(
                  left: screenWidth * 0.04,
                  right: screenWidth * 0.04,
                  bottom: bottomPadding,
                  top: screenHeight * 0.005,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Price info
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Price",
                          style: TextStyle(
                            fontSize: screenWidth * 0.04,
                            fontFamily: 'Poppins',
                            color: const Color.fromARGB(255, 0, 0, 0),
                          ),
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              "\$15",
                              style: TextStyle(
                                fontSize: screenWidth * 0.06,
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.bold,
                                color: Colors.blue,
                              ),
                            ),
                            Text(
                              "/Person",
                              style: TextStyle(
                                fontSize: screenWidth * 0.04,
                                fontFamily: 'Poppins',
                                color: Colors.black54,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    // Book Ticket button with icon
                    ElevatedButton(
                      onPressed: () {
                        print("Book Ticket pressed!");
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => OrderDetailsPage(
                              selectedImage: widget.imagePaths[_currentImageIndex],
                              eventTitle: widget.title,
                              eventDate: widget.date,
                              eventLocation: widget.location,
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.blue,
                        padding: EdgeInsets.symmetric(
                          horizontal: screenWidth * 0.08,
                          vertical: screenHeight * 0.02,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.event,
                            color: Colors.white,
                            size: screenWidth * 0.045,
                          ),
                          SizedBox(width: screenWidth * 0.02),
                          Text(
                            "Book Ticket",
                            style: TextStyle(
                              fontSize: screenWidth * 0.04,
                              fontFamily: 'Poppins',
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
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
