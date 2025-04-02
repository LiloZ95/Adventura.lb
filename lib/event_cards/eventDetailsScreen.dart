// Final version matching Figma layout exactly + polished bottom nav
import 'dart:math';

import 'package:adventura/colors.dart';
import 'package:adventura/config.dart';
import 'package:flutter/material.dart';
import 'package:adventura/OrderDetail/Order.dart';
import 'package:adventura/widgets/availability_modal.dart';
import 'package:adventura/event_cards/widgets/readonly_location_map.dart';

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
  List<Map<String, String>> tripSteps = [];
  String? activityDuration;

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

  String _calculateDuration(String from, String to) {
    try {
      TimeOfDay fromTime = _parseTime(from);
      TimeOfDay toTime = _parseTime(to);

      final now = DateTime.now();
      final fromDateTime = DateTime(
          now.year, now.month, now.day, fromTime.hour, fromTime.minute);
      final toDateTime =
          DateTime(now.year, now.month, now.day, toTime.hour, toTime.minute);

      Duration difference = toDateTime.difference(fromDateTime);

      if (difference.inMinutes <= 0) {
        return "Invalid duration";
      }

      int hours = difference.inHours;
      int minutes = difference.inMinutes % 60;

      if (hours > 0 && minutes > 0) return "$hours h $minutes min";
      if (hours > 0) return "$hours hour${hours == 1 ? '' : 's'}";
      return "$minutes min";
    } catch (e) {
      return "Invalid time format";
    }
  }

  TimeOfDay _parseTime(String timeStr) {
    final regex = RegExp(r'^(\d{1,2}):(\d{2}) (AM|PM)$');
    final match = regex.firstMatch(timeStr.trim());

    if (match == null) throw FormatException("Invalid time format");

    int hour = int.parse(match.group(1)!);
    int minute = int.parse(match.group(2)!);
    final meridian = match.group(3);

    if (meridian == "PM" && hour < 12) hour += 12;
    if (meridian == "AM" && hour == 12) hour = 0;

    return TimeOfDay(hour: hour, minute: minute);
  }

  @override
  void initState() {
    super.initState();

    final rawTripPlan = widget.activity["trip_plans"];

    if (rawTripPlan != null && rawTripPlan is List) {
      tripSteps = rawTripPlan
          .where((step) =>
              step["time"] != null &&
              step["description"] != null &&
              step["time"].toString().isNotEmpty &&
              step["description"].toString().isNotEmpty)
          .map<Map<String, String>>((step) => {
                "time": step["time"].toString(),
                "title": step["description"].toString(),
              })
          .toList();
    }

    final String? from = widget.activity["from_time"];
    final String? to = widget.activity["to_time"];

    if (from != null && to != null) {
      final duration = _calculateDuration(from, to);
      setState(() {
        activityDuration = duration;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    final double lat = widget.activity["latitude"] ?? 34.4381;
    final double lng = widget.activity["longitude"] ?? 35.8308;

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
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 8),
              _buildImageCarousel(images, screenWidth, screenHeight),
              SizedBox(height: 16),
              Text(
                widget.activity["name"] ?? "Unknown Activity",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Poppins',
                ),
              ),
              if (activityDuration != null) ...[
                SizedBox(height: 6),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.schedule, size: 16, color: Colors.blue),
                      SizedBox(width: 6),
                      Text(
                        activityDuration!,
                        style: TextStyle(
                          color: Colors.blue.shade800,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              SizedBox(height: 8),
              _buildAvailabilitySection(),
              SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.location_on, size: 18, color: Colors.grey),
                  SizedBox(width: 4),
                  Text(
                    widget.activity["location"] ?? "Unknown Location",
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ],
              ),
              SizedBox(height: 20),
              _buildTripPlan(tripSteps),
              SizedBox(height: 16),
              _buildSectionTitle("Description"),
              SizedBox(height: 4),
              Text(
                widget.activity["description"] ?? "No description provided",
                style: TextStyle(fontSize: 14, color: Colors.black87),
              ),
              SizedBox(height: 12),
              _buildTagsSection(),
              SizedBox(height: 16),
              _buildSectionTitle("Location"),
              SizedBox(height: 4),
              Text(widget.activity["location"] ?? "Unknown Location",
                  style: TextStyle(fontSize: 14, color: Colors.black87)),
              SizedBox(height: 8),
              ReadOnlyLocationMap(latitude: lat, longitude: lng),
              SizedBox(height: 16),
              _buildSectionTitle("Organizer"),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: CircleAvatar(
                  radius: 24,
                  backgroundColor: Colors.grey.shade200,
                  child: ClipOval(
                    child: Image.network(
                      "https://example.com/organizer_logo.png",
                      fit: BoxFit.cover,
                      width: 48,
                      height: 48,
                      errorBuilder: (context, error, stackTrace) {
                        return Center(
                          child:
                              Icon(Icons.person, color: Colors.grey, size: 28),
                        );
                      },
                    ),
                  ),
                ),
                title: Text("We tour Lebanon"),
                subtitle: Text("Joined since 2024 · 94+ Listings · 4.5 Rating"),
                trailing: ConstrainedBox(
                  constraints: BoxConstraints(maxHeight: 56),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue.shade50,
                          elevation: 0,
                          padding:
                              EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          minimumSize: Size(0, 32),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: Text("Rate",
                            style: TextStyle(color: Colors.blue, fontSize: 13)),
                      ),
                      TextButton(
                        onPressed: () {},
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: Size(0, 22),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: Text("Report",
                            style: TextStyle(color: Colors.red, fontSize: 11)),
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomBar(screenWidth, images),
    );
  }

  Widget _buildTripPlan(List<Map<String, String>> tripSteps) {
    if (tripSteps.isEmpty) {
      return SizedBox(); // or Text("No trip plan available")
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text("Trip plan",
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Poppins')),
            SizedBox(width: 8),
            Expanded(child: Divider(color: Colors.grey.shade400, thickness: 1)),
          ],
        ),
        SizedBox(height: 12),
        SizedBox(
          height: 80,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: max(0, tripSteps.length * 2 - 1),
            separatorBuilder: (context, index) => SizedBox(width: 4),
            itemBuilder: (context, index) {
              if (index.isOdd) {
                return _arrowConnector();
              } else {
                final step = tripSteps[index ~/ 2];
                return _tripCard(step["time"]!, step["title"]!);
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _tripCard(String time, String title) {
    return Container(
      margin: EdgeInsets.only(right: 8, left: 8),
      padding: EdgeInsets.only(left: 10, right: 30, top: 12, bottom: 12),
      decoration: BoxDecoration(
        border: Border.all(
            color: const Color.fromARGB(255, 51, 51, 51), width: 0.8),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text("• $time",
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
          SizedBox(height: 4),
          Text(title,
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: Colors.black)),
        ],
      ),
    );
  }

  Widget _arrowConnector() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4),
      padding: EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 84, 84, 84),
        shape: BoxShape.circle,
      ),
      child: Icon(Icons.chevron_right, color: Colors.white, size: 16),
    );
  }

  Widget _buildSectionTitle(String text) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(text,
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Poppins')),
            SizedBox(width: 8),
            Expanded(child: Divider(color: Colors.grey.shade400, thickness: 1)),
          ],
        ),
      ],
    );
  }

  Widget _buildTagsSection() {
    final rawFeatures = widget.activity["features"];
    if (rawFeatures == null || rawFeatures is! List) return SizedBox();

    List<String> tags = rawFeatures
        .map((f) => f["name"]?.toString())
        .where((f) => f != null && f.isNotEmpty)
        .cast<String>()
        .toList();

    return Wrap(
      spacing: 8,
      runSpacing: 4,
      children: tags.map((tag) {
        if (tag.toLowerCase() == "trending") {
          return _tag(tag, gradient: [Colors.orange, Colors.red]);
        } else {
          return _tag(tag);
        }
      }).toList(),
    );
  }

  Widget _tag(String text, {List<Color>? gradient}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: gradient != null ? LinearGradient(colors: gradient) : null,
        color: gradient == null ? Colors.grey.shade300 : null,
      ),
      child: Text(
        text,
        style: TextStyle(
            color: gradient != null ? Colors.white : Colors.black,
            fontWeight: FontWeight.w500),
      ),
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
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Stack(
        children: [
          Container(
            height: screenHeight * 0.3,
            width: screenWidth,
            child: PageView.builder(
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
          ),
          Positioned(
            bottom: 8,
            right: 12,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${_currentImageIndex + 1}/${images.length}',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvailabilitySection() {
    return confirmedDate != null && confirmedSlot != null
        ? Row(
            children: [
              Icon(Icons.calendar_today, size: 18, color: Colors.grey),
              SizedBox(width: 4),
              Text(
                "$confirmedDate at $confirmedSlot",
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
              SizedBox(width: 6),
              TextButton(
                onPressed: _openAvailabilityModal,
                child: Text("Change time",
                    style: TextStyle(
                        fontSize: 13,
                        color: Colors.blue,
                        fontWeight: FontWeight.w500)),
              ),
            ],
          )
        : ElevatedButton(
            onPressed: _openAvailabilityModal,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.blue,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: Text("Check Availability",
                style: TextStyle(color: Colors.white)),
          );
  }

  Widget _buildBottomBar(double screenWidth, List<String> images) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 15,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        child: Container(
          color: Colors.white,
          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Price", style: TextStyle(color: Colors.black54)),
                  SizedBox(height: 2),
                  Row(
                    children: [
                      Text(
                        widget.activity["price"] != null
                            ? "\$${widget.activity["price"]}"
                            : "Free",
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue),
                      ),
                      SizedBox(width: 4),
                      Text("/Person",
                          style: TextStyle(color: Colors.black54, fontSize: 14))
                    ],
                  ),
                ],
              ),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => OrderDetailsPage(
                        selectedImage: images[_currentImageIndex],
                        eventTitle: widget.activity["name"] ?? "Event",
                        eventDate:
                            confirmedDate ?? widget.activity["date"] ?? "Date",
                        eventLocation:
                            widget.activity["location"] ?? "Location",
                      ),
                    ),
                  );
                },
                icon: Icon(Icons.local_activity_outlined,
                    color: Colors.white, size: 20),
                label:
                    Text("Book Ticket", style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.blue,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  padding: EdgeInsets.symmetric(horizontal: 25, vertical: 18),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
