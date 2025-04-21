import 'package:adventura/Services/activity_service.dart';
import 'package:adventura/event_cards/eventDetailsScreen.dart';
import 'package:adventura/search%20screen/searchScreen.dart';
import 'package:flutter/material.dart';
import 'package:adventura/colors.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';

class LimitedTimeActivitiesWeb extends StatefulWidget {
  final Function? onLoginRequired;

  const LimitedTimeActivitiesWeb({
    Key? key,
    this.onLoginRequired,
  }) : super(key: key);

  @override
  _LimitedTimeActivitiesWebState createState() =>
      _LimitedTimeActivitiesWebState();
}

class _LimitedTimeActivitiesWebState extends State<LimitedTimeActivitiesWeb> {
  int _hoveredIndex = -1;
  final List<Map<String, dynamic>> limitedTimeActivities = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadActivities();
  }

  Future<void> _loadActivities() async {
    try {
      // Replace with your actual API call
      final activities = await ActivityService.fetchEvents();
      setState(() {
        limitedTimeActivities.addAll(activities);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print('Error loading activities: $e');
    }
  }

  // Calculate days left until the event
  int calculateDaysLeft(Map<String, dynamic> activity) {
    if (activity['event_date'] != null) {
      // If event_date is available, use it
      final DateTime eventDate = DateTime.parse(activity['event_date']);
      return eventDate.difference(DateTime.now()).inDays;
    } else if (activity['end_date'] != null && activity['end_date'] != '[null]') {
      // If end_date is available, use it
      final DateTime endDate = DateTime.parse(activity['end_date']);
      return endDate.difference(DateTime.now()).inDays;
    } else {
      // Default value if no date information is available
      return 30; // Default to 30 days
    }
  }

  // Get number of seats from the activity data
  int getNumberOfSeats(Map<String, dynamic> activity) {
    if (activity.containsKey('nb_seats') && activity['nb_seats'] != null) {
      // Try to parse the nb_seats as an integer
      try {
        return int.parse(activity['nb_seats'].toString());
      } catch (e) {
        print('Error parsing nb_seats: $e');
      }
    }
    
    // Default value if nb_seats is not available or cannot be parsed
    return activity['spotsLeft'] ?? 0;
  }

  // Get event image URL function with URL fixing
  String getEventImageUrl(Map<String, dynamic> activity) {
    print('Getting image URL for event: ${activity['name'] ?? 'Unknown'}');
    
    String? imageUrl;
    
    // Try to get image URL from various possible fields
    if (activity.containsKey('image_url') && activity['image_url'] != null) {
      imageUrl = activity['image_url'].toString();
      print('Found image_url: $imageUrl');
    } else if (activity.containsKey('images') && activity['images'] is List && (activity['images'] as List).isNotEmpty) {
      imageUrl = (activity['images'] as List).first.toString();
      print('Found image in images array: $imageUrl');
    } else if (activity.containsKey('image') && activity['image'] != null) {
      imageUrl = activity['image'].toString();
      print('Found image: $imageUrl');
    }
    
    // Fix common URL format problems
    if (imageUrl != null && imageUrl.isNotEmpty) {
      // Fix missing protocol
      if (imageUrl.startsWith('//')) {
        imageUrl = 'https:$imageUrl';
        print('Fixed missing protocol: $imageUrl');
      } 
      // Add protocol if missing
      else if (!imageUrl.startsWith('http://') && 
               !imageUrl.startsWith('https://') && 
               !imageUrl.startsWith('data:') &&
               !imageUrl.startsWith('asset:') &&
               !imageUrl.startsWith('/')) {
        imageUrl = 'https://$imageUrl';
        print('Added https protocol: $imageUrl');
      }
      
      // Fix spaces in URLs
      if (imageUrl.contains(' ')) {
        imageUrl = imageUrl.replaceAll(' ', '%20');
        print('Fixed spaces in URL: $imageUrl');
      }
      
      return imageUrl;
    }
    
    // Default placeholder
    print('No image found, using placeholder');
    return 'https://via.placeholder.com/400x300?text=No+Image';
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final bool isDesktop = screenWidth >= 1024;
    final double cardWidth = isDesktop ? 380.0 : 300.0;
    final double cardHeight = isDesktop ? 420.0 : 380.0;
    final double horizontalPadding = isDesktop ? 64.0 : 32.0;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: horizontalPadding,
        vertical: 48,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeaderSection(isDesktop),
          const SizedBox(height: 32),
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _buildActivitiesGrid(cardWidth, cardHeight),
        ],
      ),
    );
  }

  Widget _buildHeaderSection(bool isDesktop) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 4,
                  height: 24,
                  decoration: BoxDecoration(
                    color: AppColors.mainBlue,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  "Limited Time Activities",
                  style: TextStyle(
                    fontSize: isDesktop ? 32 : 24,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Poppins',
                    letterSpacing: -0.5,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.only(left: 16.0),
              child: Text(
                "Unique experiences available for a short time only",
                style: TextStyle(
                  fontSize: isDesktop ? 16 : 14,
                  color: Colors.grey.shade600,
                  fontFamily: 'Poppins',
                ),
              ),
            ),
          ],
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>SearchScreen(onScrollChanged:(bool) {})
          ),
        );
          },
          style: ElevatedButton.styleFrom(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
              side: BorderSide(
                  color: AppColors.mainBlue.withOpacity(0.5), width: 1),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Explore all",
                style: TextStyle(
                  color: AppColors.mainBlue,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              SizedBox(width: 4),
              Icon(Icons.arrow_forward, size: 16, color: AppColors.mainBlue),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActivitiesGrid(double cardWidth, double cardHeight) {
    return SizedBox(
      height: cardHeight,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: limitedTimeActivities.length,
        itemBuilder: (context, index) {
          final activity = limitedTimeActivities[index];
          
          // Calculate days left using the new method
          final daysLeft = calculateDaysLeft(activity);
          
          // Get the number of seats using the new method
          final seats = getNumberOfSeats(activity);

          // Get the image URL using the same function as MainScreen
          final imageUrl = getEventImageUrl(activity);

          return MouseRegion(
            onEnter: (_) => setState(() => _hoveredIndex = index),
            onExit: (_) => setState(() => _hoveredIndex = -1),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              margin: const EdgeInsets.only(right: 24),
              width: cardWidth,
              height: cardHeight,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: _hoveredIndex == index
                        ? Colors.black.withOpacity(0.2)
                        : Colors.black.withOpacity(0.1),
                    blurRadius: _hoveredIndex == index ? 20 : 10,
                    offset: _hoveredIndex == index
                        ? const Offset(0, 10)
                        : const Offset(0, 5),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Stack(
                  children: [
                    // Image background with either network image or local asset
                    Positioned.fill(
                      child: imageUrl.startsWith('assets/') 
                        ? Image.asset(
                            imageUrl,
                            fit: BoxFit.cover,
                          )
                        : CachedNetworkImage(
                            imageUrl: imageUrl,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Container(
                              color: Colors.grey[200],
                              child: Center(
                                child: CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.mainBlue),
                                ),
                              ),
                            ),
                            errorWidget: (context, url, error) {
                              print('Error loading image: $error for URL: $imageUrl');
                              // Fall back to local asset image on error
                              return Image.asset(
                                'assets/Pictures/island.jpg',
                                fit: BoxFit.cover,
                              );
                            },
                          ),
                    ),

                    // Gradient overlay
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withOpacity(0.3),
                              Colors.black.withOpacity(0.8),
                            ],
                            stops: [0.4, 0.75, 1.0],
                          ),
                        ),
                      ),
                    ),

                    // Activity info
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    activity['name'] ?? activity['title'] ?? 'Activity',
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                      fontFamily: 'Poppins',
                                    ),
                                  ),
                                ),
                                Row(
                                  children: [
                                    const Icon(Icons.star,
                                        color: Colors.amber, size: 16),
                                    const SizedBox(width: 4),
                                    Text(
                                      activity['rating']?.toString() ?? '4.5',
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Icon(Icons.location_on,
                                    color: Colors.white70, size: 14),
                                const SizedBox(width: 4),
                                Text(
                                  activity['location'] ?? 'Location',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.white70,
                                    fontFamily: 'Poppins',
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                _buildInfoChip(
                                  icon: Icons.timer,
                                  text: "$daysLeft days left",
                                  color: Colors.red.withOpacity(0.8),
                                ),
                                const SizedBox(width: 8),
                                _buildInfoChip(
                                  icon: Icons.people,
                                  text: "$seats seats available",
                                  color: Colors.black.withOpacity(0.5),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "\$${activity['price'] ?? '0'}",
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                ElevatedButton(
                                  onPressed: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => EventDetailsScreen(
                                          activity: activity),
                                    ),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 10),
                                  ),
                                  child: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        "Book Now",
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.mainBlue,
                                        ),
                                      ),
                                      SizedBox(width: 4),
                                      Icon(Icons.arrow_forward,
                                          size: 16, color: AppColors.mainBlue),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Date ribbon
                    if (activity['event_date'] != null && activity['event_date'] != '[null]')
                      Positioned(
                        top: 0,
                        left: 20,
                        child: Container(
                          width: 35,
                          height: 90,
                          decoration: BoxDecoration(
                            color: AppColors.mainBlue,
                            borderRadius: const BorderRadius.only(
                              bottomLeft: Radius.circular(10),
                              bottomRight: Radius.circular(10),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.3),
                                blurRadius: 5,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                DateFormat('MMM').format(DateTime.parse(activity['event_date'])),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                DateTime.parse(activity['event_date']).day.toString(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoChip(
      {required IconData icon, required String text, required Color color}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 12),
          const SizedBox(width: 4),
          Text(
            text,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  void _handleBooking(BuildContext context) async {
    Box box = await Hive.openBox('authBox');
    String? userId = box.get('userId');

    if (userId == null) {
      _showLoginDialog(context);
    } else {
      _showBookingConfirmation(context);
    }
  }

  void _showLoginDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Login Required"),
        content: const Text("You need to login to book this activity."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              if (widget.onLoginRequired != null) {
                widget.onLoginRequired!();
              }
            },
            child: const Text("Login"),
          ),
        ],
      ),
    );
  }

  void _showBookingConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Booking Confirmed"),
        content: const Text("Your booking has been successfully created."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }
}