import 'package:adventura/colors.dart';
import 'package:adventura/config.dart';
import 'package:flutter/material.dart';
import 'package:adventura/OrderDetail/Order.dart';
import 'package:adventura/widgets/availability_modal.dart';

class EventDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> activity;

  EventDetailsScreen({
    required this.activity,
  });

  @override
  _EventDetailsScreenState createState() => _EventDetailsScreenState();
}

class _EventDetailsScreenState extends State<EventDetailsScreen> {
  bool isFavorite = false;
  int _currentImageIndex = 0;
  final PageController _pageController = PageController();
  String? confirmedDate;
  String? confirmedSlot;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _openAvailabilityModal() async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return AvailabilityModal(
          activityId: widget.activity["activity_id"],
          onDateSlotSelected: (String date, String slot) {
            setState(() {
              confirmedDate = date;
              confirmedSlot = slot;
            });
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    double bottomPadding = MediaQuery.of(context).padding.bottom;

    List<dynamic> rawImages = widget.activity["activity_images"] ?? [];
    List<String> images = rawImages
        .whereType<String>()
        .where((img) => img.isNotEmpty)
        .map((img) => img.startsWith("http") ? img : "$baseUrl$img")
        .toList();

    if (images.isEmpty) {
      images.add("assets/Pictures/island.jpg");
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(screenWidth),
      body: SingleChildScrollView(
        padding: EdgeInsets.only(bottom: screenHeight * 0.12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildImageCarousel(images, screenWidth, screenHeight),
            _buildDetailsSection(screenWidth, screenHeight),
          ],
        ),
      ),
      bottomNavigationBar:
          _buildBottomBar(screenWidth, screenHeight, bottomPadding, images),
    );
  }

  AppBar _buildAppBar(double screenWidth) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        icon: Icon(Icons.arrow_back,
            color: Colors.black, size: screenWidth * 0.07),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        IconButton(
          icon:
              Icon(Icons.share, color: Colors.black, size: screenWidth * 0.07),
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
              isFavorite = !isFavorite;
            });
          },
        ),
      ],
    );
  }

  Widget _buildImageCarousel(
      List<String> images, double screenWidth, double screenHeight) {
    return Padding(
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
                itemCount: images.length,
                itemBuilder: (context, index) {
                  String imageUrl = images[index];
                  return imageUrl.startsWith("http")
                      ? Image.network(
                          imageUrl,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              Image.asset("assets/Pictures/island.jpg",
                                  fit: BoxFit.cover),
                        )
                      : Image.asset(imageUrl,
                          width: double.infinity, fit: BoxFit.cover);
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
                    borderRadius: BorderRadius.circular(screenWidth * 0.02),
                  ),
                  child: Text(
                    '${_currentImageIndex + 1}/${images.length}',
                    style: TextStyle(
                        color: Colors.white, fontSize: screenWidth * 0.035),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailsSection(double screenWidth, double screenHeight) {
    return Padding(
      padding: EdgeInsets.all(screenWidth * 0.04),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.activity["name"] ?? "Unknown Activity",
            style: TextStyle(
              fontSize: screenWidth * 0.06,
              fontWeight: FontWeight.bold,
              fontFamily: 'Poppins',
            ),
          ),
          SizedBox(height: screenHeight * 0.01),
          if (widget.activity["type"] == "event")
            Row(
              children: [
                Icon(Icons.calendar_today,
                    size: screenWidth * 0.045, color: Colors.grey),
                SizedBox(width: screenWidth * 0.01),
                Text(
                  widget.activity["date"] ?? "Date not available",
                  style: TextStyle(
                      fontSize: screenWidth * 0.04, color: Colors.grey),
                ),
              ],
            )
          else if (confirmedDate != null && confirmedSlot != null)
            Row(
              children: [
                Icon(Icons.calendar_today,
                    size: screenWidth * 0.045, color: Colors.grey),
                SizedBox(width: screenWidth * 0.01),
                Text(
                  "$confirmedDate at $confirmedSlot",
                  style: TextStyle(
                      fontSize: screenWidth * 0.04, color: Colors.grey),
                ),
                SizedBox(width: 6),
                TextButton(
                  onPressed: _openAvailabilityModal,
                  child: Text(
                    "Change time",
                    style: TextStyle(
                      fontSize: screenWidth * 0.035,
                      color: AppColors.blue,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            )
          else
            ElevatedButton(
              onPressed: _openAvailabilityModal,
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.blue),
              child: Text(
                "Check Availability",
                style: TextStyle(fontFamily: 'Poppins', color: Colors.white),
              ),
            ),
          SizedBox(height: screenHeight * 0.005),
          Row(
            children: [
              Icon(Icons.location_on,
                  size: screenWidth * 0.045, color: Colors.grey),
              SizedBox(width: screenWidth * 0.01),
              Text(
                widget.activity["location"] ?? "Location not available",
                style:
                    TextStyle(fontSize: screenWidth * 0.04, color: Colors.grey),
              ),
            ],
          ),
          SizedBox(height: screenHeight * 0.02),
          _buildTripPlan(screenWidth, screenHeight),
          _buildDescription(screenWidth),
          _buildTags(screenWidth, screenHeight),
        ],
      ),
    );
  }

  Widget _buildTripPlan(double screenWidth, double screenHeight) {
    if (widget.activity.containsKey("trip_plan") &&
        widget.activity["trip_plan"] is List &&
        widget.activity["trip_plan"].isNotEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Padding(
                padding: EdgeInsets.only(right: screenWidth * 0.02),
                child: Text("Trip plan",
                    style: TextStyle(
                        color: Colors.black,
                        fontFamily: 'Poppins',
                        fontSize: screenWidth * 0.055,
                        fontWeight: FontWeight.bold)),
              ),
              Expanded(child: Divider(color: Colors.grey, thickness: 1)),
            ],
          ),
          SizedBox(height: screenHeight * 0.005),
          SizedBox(
            height: screenHeight * 0.1,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: widget.activity["trip_plan"].length,
              itemBuilder: (context, index) {
                var step = widget.activity["trip_plan"][index];
                return Row(
                  children: [
                    Container(
                      margin:
                          EdgeInsets.symmetric(vertical: screenHeight * 0.015),
                      padding:
                          EdgeInsets.symmetric(horizontal: screenWidth * 0.03),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(screenWidth * 0.03),
                        border: Border.all(
                            color: const Color.fromARGB(255, 108, 108, 108),
                            width: 1),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('• ${step["time"] ?? ""}',
                              style: TextStyle(
                                  fontSize: screenWidth * 0.035,
                                  color:
                                      const Color.fromARGB(255, 108, 108, 108),
                                  fontFamily: 'Poppins')),
                          Text(step["event"] ?? "",
                              style: TextStyle(
                                  fontSize: screenWidth * 0.045,
                                  color: Colors.black,
                                  fontFamily: 'Poppins',
                                  fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                    if (index < widget.activity["trip_plan"].length - 1)
                      Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: screenWidth * 0.02),
                        child: Image.asset('assets/Icons/arrow-right.png',
                            width: screenWidth * 0.08,
                            height: screenWidth * 0.08,
                            color: Colors.grey),
                      ),
                  ],
                );
              },
            ),
          ),
        ],
      );
    }
    return SizedBox();
  }

  Widget _buildDescription(double screenWidth) {
    return Column(
      children: [
        Row(
          children: [
            Padding(
              padding: EdgeInsets.only(right: screenWidth * 0.02),
              child: Text("Description",
                  style: TextStyle(
                      color: Colors.black,
                      fontFamily: 'Poppins',
                      fontSize: screenWidth * 0.055,
                      fontWeight: FontWeight.bold)),
            ),
            Expanded(child: Divider(color: Colors.grey, thickness: 1)),
          ],
        ),
        Text(
          widget.activity["description"] ?? "No description provided",
          style: TextStyle(
              fontSize: screenWidth * 0.04,
              color: Colors.black87,
              fontFamily: 'Poppins'),
        ),
      ],
    );
  }

  Widget _buildTags(double screenWidth, double screenHeight) {
    if (widget.activity["tags"] != null &&
        widget.activity["tags"] is List &&
        widget.activity["tags"].isNotEmpty) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: screenHeight * 0.01),
        child: Wrap(
          spacing: screenWidth * 0.02,
          runSpacing: screenHeight * 0.005,
          children: List.generate(
            widget.activity["tags"].length,
            (index) => _buildFeatureTag(widget.activity["tags"][index]),
          ),
        ),
      );
    }
    return SizedBox();
  }

  Widget _buildBottomBar(double screenWidth, double screenHeight,
      double bottomPadding, List<String> images) {
    return SafeArea(
      child: Container(
        width: screenWidth,
        height: screenHeight * 0.1 + bottomPadding,
        child: BottomAppBar(
          color: Colors.transparent,
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
                _buildPriceInfo(screenWidth),
                _buildBookButton(screenWidth, screenHeight, images),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPriceInfo(double screenWidth) {
    return Expanded(
      child: Padding(
        padding: EdgeInsets.only(right: 8), // give breathing room
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Price",
              style: TextStyle(
                fontSize: screenWidth * 0.035,
                color: Colors.black,
                fontFamily: 'Poppins',
              ),
            ),
            SizedBox(height: 4),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  widget.activity["price"] != null
                      ? "\$${widget.activity["price"]}"
                      : "Free",
                  style: TextStyle(
                    fontSize: screenWidth * 0.06,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
                SizedBox(width: 6),
                Flexible(
                  child: Text(
                    "/Person",
                    style: TextStyle(
                      fontSize: screenWidth * 0.038,
                      fontFamily: 'Poppins',
                      color: Colors.black54,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBookButton(
      double screenWidth, double screenHeight, List<String> images) {
    return ElevatedButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => OrderDetailsPage(
              selectedImage: images[_currentImageIndex],
              eventTitle: widget.activity["name"] ?? "Event",
              eventDate: confirmedDate ?? widget.activity["date"] ?? "Date",
              eventLocation: widget.activity["location"] ?? "Location",
            ),
          ),
        );
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.blue,
        padding: EdgeInsets.symmetric(
          horizontal: screenWidth * 0.06, // reduced a bit
          vertical: screenHeight * 0.02,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.event, color: Colors.white, size: screenWidth * 0.045),
          SizedBox(width: screenWidth * 0.02),
          Text("Book Ticket",
              style: TextStyle(
                  fontSize: screenWidth * 0.04,
                  fontFamily: 'Poppins',
                  color: Colors.white)),
        ],
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
                end: Alignment.bottomRight)
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
