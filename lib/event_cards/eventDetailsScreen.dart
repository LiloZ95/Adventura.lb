import 'package:adventura/colors.dart';
import 'package:adventura/config.dart';
import 'package:flutter/material.dart';
import 'package:adventura/OrderDetail/Order.dart';
import 'package:adventura/widgets/availability_modal.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:google_maps_flutter/google_maps_flutter.dart' as gmap;
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' as leaflet;
import 'package:url_launcher/url_launcher.dart';
import 'package:google_fonts/google_fonts.dart';

// Define the mainBlue color
const Color mainBlue = Color(0xFF3D5A8E);

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

  void _openAvailabilityModal() async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
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

  // Custom web header for professional look
  Widget _buildWebHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Back button with custom styling
          InkWell(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.all(8),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.arrow_back, color: mainBlue, size: 18),
                  const SizedBox(width: 4),
                  Text(
                    "Back",
                    style: GoogleFonts.poppins(
                      color: mainBlue,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 20),
          // Activity title and location instead of website name
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  widget.activity["name"] ?? "Unknown Activity",
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.location_on, size: 14, color: Colors.grey),
                    const SizedBox(width: 2),
                    Flexible(
                      child: Text(
                        widget.activity["location"] ?? "Location not available",
                        style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Action buttons for web
          Row(
            children: [
              IconButton(
                icon: Icon(Icons.share, color: Colors.grey.shade700),
                onPressed: () {},
                tooltip: "Share",
              ),
              IconButton(
                icon: Icon(
                  isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: isFavorite ? Colors.red : Colors.grey.shade700,
                ),
                onPressed: () {
                  setState(() {
                    isFavorite = !isFavorite;
                  });
                },
                tooltip: isFavorite ? "Remove from favorites" : "Add to favorites",
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Get screen dimensions
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    
    // Determine if we're on a large screen (like desktop web)
    bool isLargeScreen = screenWidth > 1000;
    
    // REDUCED horizontal padding to take more width
    double horizontalPadding = isLargeScreen ? screenWidth * 0.03 : 12;

    List<dynamic> rawImages = widget.activity["activity_images"] ?? [];
    List<String> images = rawImages
        .whereType<String>()
        .where((img) => img.isNotEmpty)
        .map((img) => img.startsWith("http") ? img : "$baseUrl$img")
        .toList();

    if (images.isEmpty) {
      images.add("assets/Pictures/island.jpg");
    }

    // For web, we can create a different layout when screen is large
    if (kIsWeb && isLargeScreen) {
      return Scaffold(
        backgroundColor: Colors.grey.shade50,
        body: Column(
          children: [
            // Custom web header instead of AppBar
            _buildWebHeader(),
            
            // Main content in scrollable area
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // Main content with white background card - removed hero section
                    Container(
                      width: double.infinity,
                      margin: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 20),
                      padding: const EdgeInsets.all(0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          // Two column layout inside card
                          IntrinsicHeight(
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Left column - Images - MODIFIED to use rounded corners on all sides
                                Expanded(
                                  flex: 3,
                                  child: Padding(
                                    padding: const EdgeInsets.all(12),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(12), // CHANGED to round all corners
                                      child: _buildImageCarousel(images, screenWidth * 0.5, screenHeight * 0.45),
                                    ),
                                  ),
                                ),
                                
                                // Right column - Details
                                Expanded(
                                  flex: 2,
                                  child: Container(
                                    padding: const EdgeInsets.all(24),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        _buildAvailabilitySection(),
                                        const SizedBox(height: 24),
                                        
                                        Text(
                                          "Overview",
                                          style: GoogleFonts.poppins(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          widget.activity["description"] ?? "No description provided",
                                          style: GoogleFonts.poppins(
                                            fontSize: 15, 
                                            color: Colors.black87,
                                            height: 1.5,
                                          ),
                                        ),
                                        const SizedBox(height: 16),
                                        _buildTagsSection(),
                                        const SizedBox(height: 24),
                                        
                                        // Price section and booking button
                                        Container(
                                          padding: const EdgeInsets.all(16),
                                          decoration: BoxDecoration(
                                            color: Colors.grey.shade50,
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              _buildPriceSection(),
                                              const SizedBox(height: 12),
                                              _buildBookButton(images),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          
                          // Trip plan section - full width
                          Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              border: Border(
                                top: BorderSide(color: Colors.grey.shade200),
                              ),
                            ),
                            child: _buildTripPlan(),
                          ),
                        ],
                      ),
                    ),
                    
                    // Additional information cards - ADJUSTED to take more width
                    Container(
                      width: double.infinity,
                      margin: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Left card - Location
                          Expanded(
                            child: Container(
                              margin: const EdgeInsets.only(right: 12),
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    blurRadius: 10,
                                    offset: const Offset(0, 5),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Location",
                                    style: GoogleFonts.poppins(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    widget.activity["map_location"] ?? "Seht El-Nour, Tripoli",
                                    style: GoogleFonts.poppins(fontSize: 15, color: Colors.black87),
                                  ),
                                  const SizedBox(height: 12),
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: SizedBox(
                                      height: 280,
                                      child: _buildWebMap(),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          
                          // Right card - Organizer
                          Expanded(
                            child: Container(
                              margin: const EdgeInsets.only(left: 12),
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    blurRadius: 10,
                                    offset: const Offset(0, 5),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Organizer",
                                    style: GoogleFonts.poppins(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  Row(
                                    children: [
                                      CircleAvatar(
                                        radius: 24,
                                        backgroundColor: Colors.grey.shade200,
                                        child: ClipOval(
                                          child: Image.network(
                                            "https://example.com/organizer_logo.png",
                                            fit: BoxFit.cover,
                                            width: 48,
                                            height: 48,
                                            errorBuilder: (context, error, stackTrace) {
                                              return const Center(
                                                child: Icon(Icons.person, color: Colors.grey, size: 28),
                                              );
                                            },
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              "We tour Lebanon",
                                              style: GoogleFonts.poppins(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              "Joined since 2024 · 94+ Listings",
                                              style: GoogleFonts.poppins(
                                                color: Colors.grey.shade700,
                                                fontSize: 13,
                                              ),
                                            ),
                                            const SizedBox(height: 2),
                                            Row(
                                              children: [
                                                const Icon(Icons.star, color: Colors.amber, size: 14),
                                                const SizedBox(width: 4),
                                                Text(
                                                  "4.5 Rating",
                                                  style: GoogleFonts.poppins(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 13,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 20),
                                  Row(
                                    children: [
                                      // MADE RATE BUTTON SMALLER
                                      SizedBox(
                                        height: 32,
                                        child: ElevatedButton(
                                          onPressed: () {},
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: mainBlue.withOpacity(0.1),
                                            elevation: 0,
                                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                                          ),
                                          child: Text(
                                            "Rate",
                                            style: GoogleFonts.poppins(
                                              color: mainBlue,
                                              fontSize: 13,
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      TextButton(
                                        onPressed: () {},
                                        style: TextButton.styleFrom(
                                          padding: const EdgeInsets.symmetric(horizontal: 8),
                                          minimumSize: const Size(0, 32),
                                        ),
                                        child: Text(
                                          "Report",
                                          style: GoogleFonts.poppins(
                                            color: Colors.red,
                                            fontSize: 13,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // Simplified footer - just padding at bottom
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }

    // Mobile layout (original design)
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(screenWidth),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12), // REDUCED from 16 to 12
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: _buildImageCarousel(images, screenWidth, screenHeight * 0.3),
              ),
              const SizedBox(height: 16),
              Text(
                widget.activity["name"] ?? "Unknown Activity",
                style: GoogleFonts.poppins(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              _buildAvailabilitySection(),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.location_on, size: 18, color: Colors.grey),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      widget.activity["location"] ?? "Location not available",
                      style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _buildTripPlan(),
              const SizedBox(height: 16),
              _buildSectionTitle("Description"),
              const SizedBox(height: 4),
              Text(
                widget.activity["description"] ?? "No description provided",
                style: GoogleFonts.poppins(fontSize: 14, color: Colors.black87),
              ),
              const SizedBox(height: 12),
              _buildTagsSection(),
              const SizedBox(height: 16),
              _buildSectionTitle("Location"),
              const SizedBox(height: 4),
              Text(
                widget.activity["map_location"] ?? "Seht El-Nour, Tripoli",
                style: GoogleFonts.poppins(fontSize: 14, color: Colors.black87)
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: SizedBox(
                  height: 180,
                  child: kIsWeb ? _buildWebMap() : _buildNativeMap(),
                ),
              ),
              const SizedBox(height: 16),
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
                        return const Center(
                          child: Icon(Icons.person, color: Colors.grey, size: 28),
                        );
                      },
                    ),
                  ),
                ),
                title: Text("We tour Lebanon", style: GoogleFonts.poppins()),
                subtitle: Text(
                  "Joined since 2024 · 94+ Listings · 4.5 Rating",
                  style: GoogleFonts.poppins(fontSize: 12)
                ),
                trailing: ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 56),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // MADE RATE BUTTON SMALLER
                      SizedBox(
                        height: 28,
                        child: ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: mainBlue.withOpacity(0.1),
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                            minimumSize: const Size(0, 28),
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: Text(
                            "Rate", 
                            style: GoogleFonts.poppins(
                              color: mainBlue, 
                              fontSize: 12,
                            )
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () {},
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: const Size(0, 20),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: Text(
                          "Report", 
                          style: GoogleFonts.poppins(
                            color: Colors.red, 
                            fontSize: 11
                          )
                        ),
                      )
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 80), // Extra space at bottom to avoid content being hidden behind bottom bar
            ],
          ),
        ),
      ),
      bottomNavigationBar: kIsWeb && isLargeScreen ? null : _buildBottomBar(screenWidth, images),
    );
  }

  Widget _buildPriceSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Price", 
          style: GoogleFonts.poppins(color: Colors.black54)
        ),
        const SizedBox(height: 2),
        Row(
          children: [
            Text(
              widget.activity["price"] != null
                  ? "\$${widget.activity["price"]}"
                  : "Free",
              style: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: mainBlue,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              "/Person", 
              style: GoogleFonts.poppins(
                color: Colors.black54, 
                fontSize: 14
              )
            )
          ],
        ),
      ],
    );
  }

  Widget _buildBookButton(List<String> images) {
    return ElevatedButton.icon(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => OrderDetailsPage(
              selectedImage: images[_currentImageIndex],
              eventTitle: widget.activity["name"] ?? "Event",
              eventDate: confirmedDate ?? widget.activity["date"] ?? "Date",
              eventLocation: widget.activity["location"] ?? "Location", 
              selectedSlot: confirmedSlot ?? '',
            ),
          ),
        );
      },
      icon: const Icon(Icons.local_activity_outlined, color: Colors.white, size: 20),
      label: Text(
        "Book Ticket", 
        style: GoogleFonts.poppins(color: Colors.white)
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: mainBlue,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 18),
        minimumSize: const Size(double.infinity, 56), // Make button wider
      ),
    );
  }

  Widget _buildTripPlan() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              "Trip plan",
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(child: Divider(color: Colors.grey.shade400, thickness: 1)),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 80,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _tripSteps.length * 2 - 1, // account for arrows
            separatorBuilder: (context, index) => const SizedBox(width: 4),
            itemBuilder: (context, index) {
              if (index.isOdd) {
                return _arrowConnector();
              } else {
                final step = _tripSteps[index ~/ 2];
                return _tripCard(step["time"]!, step["title"]!);
              }
            },
          ),
        ),
      ],
    );
  }

  final List<Map<String, String>> _tripSteps = [
    {"time": "8:30 AM", "title": "Meet up"},
    {"time": "11:00 AM", "title": "Reaching destination"},
    {"time": "1:00 PM", "title": "Lunch Break"},
    {"time": "3:00 PM", "title": "Sunset view"},
  ];

  Widget _tripCard(String time, String title) {
    return Container(
      margin: const EdgeInsets.only(right: 8, left: 8),
      padding: const EdgeInsets.only(left: 10, right: 30, top: 12, bottom: 12),
      decoration: BoxDecoration(
        border: Border.all(color: const Color.fromARGB(255, 51, 51, 51), width: 0.8),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "• $time", 
            style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey.shade600)
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold, 
              fontSize: 14, 
              color: Colors.black
            )
          ),
        ],
      ),
    );
  }

  Widget _arrowConnector() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      padding: const EdgeInsets.all(6),
      decoration: const BoxDecoration(
        color: Color.fromARGB(255, 84, 84, 84),
        shape: BoxShape.circle,
      ),
      child: const Icon(Icons.chevron_right, color: Colors.white, size: 16),
    );
  }

  Widget _buildWebMap() {
    return FlutterMap(
      options: MapOptions(
        center: const leaflet.LatLng(34.4381, 35.8308),
        zoom: 14,
        interactiveFlags: InteractiveFlag.all,
        onTap: (_, __) async {
          final url = Uri.parse("https://www.google.com/maps/search/?api=1&query=34.4381,35.8308");
          await launchUrl(url, mode: LaunchMode.externalApplication);
        },
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
          subdomains: ['a', 'b', 'c'],
        ),
        const MarkerLayer(
          markers: [
            Marker(
              point: leaflet.LatLng(34.4381, 35.8308),
              width: 40,
              height: 40,
              child: Icon(Icons.location_pin, color: Colors.red, size: 32),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildNativeMap() {
    return GestureDetector(
      onTap: () async {
        final url = Uri.parse("https://www.google.com/maps/search/?api=1&query=34.4381,35.8308");
        await launchUrl(url, mode: LaunchMode.externalApplication);
      },
      child: gmap.GoogleMap(
        initialCameraPosition: const gmap.CameraPosition(
          target: gmap.LatLng(34.4381, 35.8308),
          zoom: 14,
        ),
        markers: {
          const gmap.Marker(
            markerId: gmap.MarkerId('location'),
            position: gmap.LatLng(34.4381, 35.8308),
            infoWindow: gmap.InfoWindow(title: "Seht El-Nour, Tripoli"),
          ),
        },
        zoomControlsEnabled: false,
        myLocationButtonEnabled: false,
      ),
    );
  }

  Widget _buildSectionTitle(String text) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              text,
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(child: Divider(color: Colors.grey.shade400, thickness: 1)),
          ],
        ),
      ],
    );
  }

  Widget _buildTagsSection() {
    return Wrap(
      spacing: 8,
      runSpacing: 4,
      children: [
        _tag("Trending", gradient: [Colors.orange, Colors.red]),
        _tag("+16"),
        _tag("Medium"),
        _tag("Entertainment"),
        _tag("BBQ"),
        _tag("Scenery"),
        _tag("Sun Set"),
      ],
    );
  }

  Widget _tag(String text, {List<Color>? gradient}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: gradient != null ? LinearGradient(colors: gradient) : null,
        color: gradient == null ? Colors.grey.shade300 : null,
      ),
      child: Text(
        text,
        style: GoogleFonts.poppins(
          color: gradient != null ? Colors.white : Colors.black,
          fontWeight: FontWeight.w500,
          fontSize: 13,
        ),
      ),
    );
  }

  AppBar _buildAppBar(double screenWidth) {
    // Scale icon sizes based on screen width
    double iconSize = kIsWeb && screenWidth > 1000 ? 24 : screenWidth * 0.07;
    
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        icon: Icon(Icons.arrow_back, color: Colors.black, size: iconSize),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.share, color: Colors.black, size: iconSize),
          onPressed: () {},
        ),
        IconButton(
          icon: Icon(
            isFavorite ? Icons.favorite : Icons.favorite_border,
            size: iconSize,
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

  Widget _buildImageCarousel(List<String> images, double width, double height) {
    return Stack(
      children: [
        Container(
          height: height,
          width: width,
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
                          Image.asset("assets/Pictures/island.jpg", fit: BoxFit.cover),
                    )
                  : Image.asset(imageUrl, width: double.infinity, fit: BoxFit.cover);
            },
          ),
        ),
        Positioned(
          bottom: 8,
          right: 12,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '${_currentImageIndex + 1}/${images.length}',
              style: GoogleFonts.poppins(color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAvailabilitySection() {
    return confirmedDate != null && confirmedSlot != null
        ? Row(
            children: [
              const Icon(Icons.calendar_today, size: 18, color: Colors.grey),
              const SizedBox(width: 4),
              Text(
                "$confirmedDate at $confirmedSlot",
                style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(width: 6),
              TextButton(
                onPressed: _openAvailabilityModal,
                child: Text(
                  "Change time",
                  style: GoogleFonts.poppins(
                    fontSize: 13, 
                    color: mainBlue, 
                    fontWeight: FontWeight.w500
                  )
                ),
              ),
            ],
          )
        : ElevatedButton(
            onPressed: _openAvailabilityModal,
            style: ElevatedButton.styleFrom(
              backgroundColor: mainBlue,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text(
              "Check Availability", 
              style: GoogleFonts.poppins(color: Colors.white)
            ),
          );
  }

  Widget _buildBottomBar(double screenWidth, List<String> images) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 15,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
        child: Container(
          color: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: SafeArea(
            top: false,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Price", 
                      style: GoogleFonts.poppins(color: Colors.black54)
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Text(
                          widget.activity["price"] != null
                              ? "\$${widget.activity["price"]}"
                              : "Free",
                          style: GoogleFonts.poppins(
                            fontSize: 20, 
                            fontWeight: FontWeight.bold, 
                            color: mainBlue
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          "/Person", 
                          style: GoogleFonts.poppins(
                            color: Colors.black54, 
                            fontSize: 14
                          )
                        )
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
                          eventDate: confirmedDate ?? widget.activity["date"] ?? "Date",
                          eventLocation: widget.activity["location"] ?? "Location",
                          selectedSlot: confirmedSlot ?? '',
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.local_activity_outlined, color: Colors.white, size: 20),
                  label: Text(
                    "Book Ticket",
                    style: GoogleFonts.poppins(color: Colors.white)
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: mainBlue,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 18),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}