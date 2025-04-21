import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:adventura/OrganizerProfile/OrganizerProfile.dart';
import 'package:adventura/Services/activity_service.dart';
import 'package:adventura/Services/interaction_service.dart';
import 'package:adventura/colors.dart';
import 'package:adventura/config.dart';
import 'package:adventura/OrderDetail/Order.dart';
import 'package:adventura/widgets/availability_modal.dart';
import 'package:adventura/event_cards/widgets/readonly_location_map.dart';
import 'package:hive/hive.dart';
import 'package:google_fonts/google_fonts.dart';


const Color mainBlue = Color(0xFF007AFF);

class EventDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> activity;

  const EventDetailsScreen({
    Key? key,
    required this.activity,
  }) : super(key: key);

  @override
  State<EventDetailsScreen> createState() => _EventDetailsScreenState();
}

class _EventDetailsScreenState extends State<EventDetailsScreen> {
  bool isFavorite = false;
  int _currentImageIndex = 0;
  final PageController _pageController = PageController();
  String? confirmedDate;
  String? confirmedSlot;
  List<Map<String, String>> tripSteps = [];
  String? activityDuration;

  @override
  void initState() {
    super.initState();
    _setupTripSteps();
    activityDuration = ActivityService.getDurationDisplay(widget.activity);
  }

  void _setupTripSteps() {
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

    
    if (tripSteps.isEmpty) {
      tripSteps = [
        {"time": "8:30 AM", "title": "Meet up"},
        {"time": "11:00 AM", "title": "Reaching destination"},
        {"time": "1:00 PM", "title": "Lunch Break"},
        {"time": "3:00 PM", "title": "Sunset view"},
      ];
    }
  }

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
          
          InkWell(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.all(8),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.arrow_back, color: mainBlue, size: 18),
                  const SizedBox(width: 4),
                ],
              ),
            ),
          ),
          const SizedBox(width: 20),
          
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
                        style: GoogleFonts.poppins(
                            fontSize: 14, color: Colors.grey),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          Row(
            children: [
              IconButton(
                icon: Icon(Icons.share, color: Colors.grey.shade700),
                onPressed: () async {
                  final box = await Hive.openBox('authBox');
                  final userId = int.tryParse(box.get('userId').toString());
                  final activityId = widget.activity["activity_id"];
                  if (userId != null) {
                    await InteractionService.logInteraction(
                      userId: userId,
                      activityId: activityId,
                      type: "share",
                    );
                  }
                },
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
                tooltip:
                    isFavorite ? "Remove from favorites" : "Add to favorites",
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    
    bool isLargeScreen = screenWidth > 1000;

    
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

    
    if (kIsWeb && isLargeScreen) {
      return Scaffold(
        backgroundColor: Colors.grey.shade50,
        body: Column(
          children: [
            
            _buildWebHeader(),

            
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    
                    Container(
                      width: double.infinity,
                      margin: EdgeInsets.symmetric(
                          horizontal: horizontalPadding, vertical: 20),
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
                          
                          IntrinsicHeight(
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                
                                Expanded(
                                  flex: 3,
                                  child: Padding(
                                    padding: const EdgeInsets.all(12),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(
                                          12), 
                                      child: _buildImageCarousel(
                                          images,
                                          screenWidth * 0.5,
                                          screenHeight * 0.45),
                                    ),
                                  ),
                                ),

                                
                                Expanded(
                                  flex: 2,
                                  child: Container(
                                    padding: const EdgeInsets.all(24),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
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
                                          widget.activity["description"] ??
                                              "No description provided",
                                          style: GoogleFonts.poppins(
                                            fontSize: 15,
                                            color: Colors.black87,
                                            height: 1.5,
                                          ),
                                        ),
                                        const SizedBox(height: 16),
                                        _buildTagsSection(),
                                        const SizedBox(height: 24),

                                        
                                        Container(
                                          padding: const EdgeInsets.all(16),
                                          decoration: BoxDecoration(
                                            color: Colors.grey.shade50,
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
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

                    
                    Container(
                      width: double.infinity,
                      margin: EdgeInsets.symmetric(
                          horizontal: horizontalPadding, vertical: 0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          
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
                                    widget.activity["map_location"] ??
                                        widget.activity["location"] ??
                                        "Seht El-Nour, Tripoli",
                                    style: GoogleFonts.poppins(
                                        fontSize: 15, color: Colors.black87),
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
                                  _buildOrganizerSection(false),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }

    
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(screenWidth),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(
              horizontal: 12), 
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: _buildImageCarousel(
                    images, screenWidth, screenHeight * 0.3),
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
                      style:
                          GoogleFonts.poppins(fontSize: 14, color: Colors.grey),
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
                  widget.activity["map_location"] ??
                      widget.activity["location"] ??
                      "Seht El-Nour, Tripoli",
                  style:
                      GoogleFonts.poppins(fontSize: 14, color: Colors.black87)),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: SizedBox(
                  height: 180,
                  child: _buildWebMap(),
                ),
              ),
              const SizedBox(height: 16),
              _buildSectionTitle("Organizer"),
              _buildOrganizerSection(true),
              const SizedBox(
                  height:
                      80), 
            ],
          ),
        ),
      ),
      bottomNavigationBar:
          kIsWeb && isLargeScreen ? null : _buildBottomBar(screenWidth, images),
    );
  }

  Widget _buildPriceSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Price", style: GoogleFonts.poppins(color: Colors.black54)),
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
            Text("/Person",
                style: GoogleFonts.poppins(color: Colors.black54, fontSize: 14))
          ],
        ),
      ],
    );
  }

  Widget _buildOrganizerSection(bool isMobile) {
    return isMobile
        ? ListTile(
            contentPadding: EdgeInsets.zero,
            leading: _buildOrganizerAvatar(),
            title: Text("We tour Lebanon", style: GoogleFonts.poppins()),
            subtitle: Text("Joined since 2024 · 94+ Listings · 4.5 Rating",
                style: GoogleFonts.poppins(fontSize: 12)),
            trailing: ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 56),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  
                  SizedBox(
                    height: 28,
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: mainBlue.withOpacity(0.1),
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 0),
                        minimumSize: const Size(0, 28),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Text("Rate",
                          style: GoogleFonts.poppins(
                            color: mainBlue,
                            fontSize: 12,
                          )),
                    ),
                  ),
                  TextButton(
                    onPressed: () {},
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: const Size(0, 20),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text("Report",
                        style: GoogleFonts.poppins(
                            color: Colors.red, fontSize: 11)),
                  )
                ],
              ),
            ),
          )
        : Row(
            children: [
              _buildOrganizerAvatar(),
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
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  
                  SizedBox(
                    height: 32,
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: mainBlue.withOpacity(0.1),
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 0),
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
                  const SizedBox(height: 8),
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
          );
  }

  Widget _buildOrganizerAvatar() {
    return GestureDetector(
      onTap: () async {
        final box = await Hive.openBox('authBox');
        int? providerId = int.tryParse(box.get("providerId")?.toString() ?? "");
        if (providerId == null) return;

        String organizerName = "${box.get("firstName")} ${box.get("lastName")}";
        String organizerImage =
            "${box.get("profilePictureUrl_$providerId") ?? ""}";
        String bio = "Adventure provider";

        final activities =
            await ActivityService.fetchProviderListings(providerId);

        if (!context.mounted) return;

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => OrganizerProfilePage(
              organizerId: providerId.toString(),
              organizerName: organizerName,
              organizerImage: organizerImage,
              bio: bio,
              activities: activities,
            ),
          ),
        );
      },
      child: CircleAvatar(
        radius: 24,
        backgroundColor: Colors.grey.shade200,
        child: ClipOval(
          child: Builder(
            builder: (context) {
              try {
                final box = Hive.box('authBox');
                final profileImage =
                    "${box.get("profilePictureUrl_${box.get("providerId")}") ?? ""}";

                if (profileImage.isNotEmpty) {
                  return Image.network(
                    profileImage,
                    width: 48,
                    height: 48,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => const Icon(
                      Icons.person,
                      color: Colors.grey,
                      size: 28,
                    ),
                  );
                }
              } catch (e) {
                
              }

              return const Center(
                child: Icon(Icons.person, color: Colors.grey, size: 28),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildBookButton(List<String> images) {
    final box = Hive.box('authBox');
    final userType = box.get("userType");
    final providerId = box.get("providerId");
    final isOwnActivity = userType == 'provider' &&
        providerId != null &&
        widget.activity["provider_id"].toString() == providerId.toString();

    return ElevatedButton.icon(
      onPressed: isOwnActivity
          ? null
          : () {
              if (confirmedDate != null && confirmedSlot != null) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => OrderDetailsPage(
                      activityId: widget.activity["activity_id"],
                      selectedImage: images[_currentImageIndex],
                      eventTitle: widget.activity["name"] ?? "Event",
                      eventDate: confirmedDate!,
                      eventLocation: widget.activity["location"] ?? "Location",
                      selectedSlot: confirmedSlot!,
                    ),
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("⚠️ Please select a date and time first."),
                    backgroundColor: Colors.orange,
                  ),
                );
              }
            },
      icon: Icon(isOwnActivity ? Icons.block : Icons.local_activity_outlined,
          color: Colors.white, size: 20),
      label: Text(isOwnActivity ? "Your Listing" : "Book Ticket",
          style: GoogleFonts.poppins(color: Colors.white)),
      style: ElevatedButton.styleFrom(
        backgroundColor: isOwnActivity ? Colors.grey : mainBlue,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 18),
        minimumSize: const Size(double.infinity, 56), 
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
            itemCount: tripSteps.length * 2 - 1, 
            separatorBuilder: (context, index) => const SizedBox(width: 4),
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
      margin: const EdgeInsets.only(right: 8, left: 8),
      padding: const EdgeInsets.only(left: 10, right: 30, top: 12, bottom: 12),
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
              style: GoogleFonts.poppins(
                  fontSize: 12, color: Colors.grey.shade600)),
          const SizedBox(height: 4),
          Text(title,
              style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: Colors.black)),
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
    final double lat = widget.activity["latitude"] ?? 34.4381;
    final double lng = widget.activity["longitude"] ?? 35.8308;

    return ReadOnlyLocationMap(latitude: lat, longitude: lng);
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
    final rawFeatures = widget.activity["features"];
    List<String> tags = [];

    if (rawFeatures != null && rawFeatures is List) {
      tags = rawFeatures
          .map((f) => f["name"]?.toString())
          .where((f) => f != null && f.isNotEmpty)
          .cast<String>()
          .toList();
    }

    
    if (tags.isEmpty) {
      tags = [
        "Trending",
        "+16",
        "Medium",
        "Entertainment",
        "BBQ",
        "Scenery",
        "Sun Set"
      ];
    }

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
          onPressed: () async {
            final box = await Hive.openBox('authBox');
            final userId = int.tryParse(box.get('userId').toString());
            final activityId = widget.activity["activity_id"];
            if (userId != null) {
              await InteractionService.logInteraction(
                userId: userId,
                activityId: activityId,
                type: "share",
              );
            }
          },
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
        SizedBox(
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
                      errorBuilder: (context, error, stackTrace) => Image.asset(
                          "assets/Pictures/island.jpg",
                          fit: BoxFit.cover),
                    )
                  : Image.asset(imageUrl,
                      width: double.infinity, fit: BoxFit.cover);
            },
          ),
        ),

        
        if (images.length > 1)
          Positioned.fill(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                
                InkWell(
                  onTap: () {
                    if (_currentImageIndex > 0) {
                      _pageController.previousPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    }
                  },
                  child: Container(
                    width: 40,
                    height: 40,
                    margin: const EdgeInsets.only(left: 16),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.3),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                ),
                
                InkWell(
                  onTap: () {
                    if (_currentImageIndex < images.length - 1) {
                      _pageController.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    }
                  },
                  child: Container(
                    width: 40,
                    height: 40,
                    margin: const EdgeInsets.only(right: 16),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.3),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.arrow_forward_ios_rounded,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                ),
              ],
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
    final type = widget.activity["listing_type"];
    final startDate = widget.activity["start_date"];

    
    if (confirmedDate != null && confirmedSlot != null) {
      return Row(
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
            child: Text("Change time",
                style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: mainBlue,
                    fontWeight: FontWeight.w500)),
          ),
        ],
      );
    }

    
    if (type == "oneTime" && startDate != null) {
      try {
        final parsed = DateTime.tryParse(startDate);
        final formatted = parsed != null
            ? "Event Date: ${DateFormat.yMMMd().format(parsed)}"
            : "Event Date: $startDate";

        return Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.event, size: 20, color: Colors.grey.shade700),
              const SizedBox(width: 10),
              Text(
                formatted,
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey.shade700,
                ),
              ),
            ],
          ),
        );
      } catch (e) {
        print("❌ Error parsing date: $e");
      }
    }

    
    return ElevatedButton(
      onPressed: _openAvailabilityModal,
      style: ElevatedButton.styleFrom(
        backgroundColor: mainBlue,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: Text("Check Availability",
          style: GoogleFonts.poppins(color: Colors.white)),
    );
  }

  Widget _buildBottomBar(double screenWidth, List<String> images) {
    final box = Hive.box('authBox');
    final userType = box.get("userType");
    final providerId = box.get("providerId");
    final isOwnActivity = userType == 'provider' &&
        providerId != null &&
        widget.activity["provider_id"].toString() == providerId.toString();

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
                    Text("Price",
                        style: GoogleFonts.poppins(color: Colors.black54)),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Text(
                          widget.activity["price"] != null
                              ? "${widget.activity["price"]}"
                              : "Free",
                          style: GoogleFonts.poppins(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: mainBlue),
                        ),
                        const SizedBox(width: 4),
                        Text("/Person",
                            style: GoogleFonts.poppins(
                                color: Colors.black54, fontSize: 14))
                      ],
                    ),
                  ],
                ),
                ElevatedButton.icon(
                  onPressed: isOwnActivity
                      ? null
                      : () {
                          if (confirmedDate != null && confirmedSlot != null) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => OrderDetailsPage(
                                  activityId: widget.activity["activity_id"],
                                  selectedImage: images[_currentImageIndex],
                                  eventTitle:
                                      widget.activity["name"] ?? "Event",
                                  eventDate: confirmedDate!,
                                  eventLocation:
                                      widget.activity["location"] ?? "Location",
                                  selectedSlot: confirmedSlot!,
                                ),
                              ),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                    "⚠️ Please select a date and time first."),
                                backgroundColor: Colors.orange,
                              ),
                            );
                          }
                        },
                  icon: Icon(
                      isOwnActivity
                          ? Icons.block
                          : Icons.local_activity_outlined,
                      color: Colors.white,
                      size: 20),
                  label: Text(isOwnActivity ? "Your Listing" : "Book Ticket",
                      style: GoogleFonts.poppins(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isOwnActivity ? Colors.grey : mainBlue,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 25, vertical: 18),
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
