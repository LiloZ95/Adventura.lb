import 'dart:ui';

import 'package:adventura/Booking/MyBooking.dart';
import 'package:adventura/OrderDetail/ViewTicket.dart';
import 'package:adventura/config.dart';
import 'package:adventura/event_cards/eventDetailsScreen.dart';
import 'package:flutter/material.dart';

/// The BookingCard widget displays booking details with options to cancel or view.
/// Redesigned for responsive web layouts
class BookingCard extends StatefulWidget {
  final Map<String, dynamic> activity;
  final String bookingId;
  final String guests;
  final String status;
  final VoidCallback onCancel;
  final bool isUpcoming;

  const BookingCard({
    Key? key,
    required this.activity,
    required this.bookingId,
    required this.guests,
    required this.status,
    required this.onCancel,
    this.isUpcoming = true,
  }) : super(key: key);

  @override
  _BookingCardState createState() => _BookingCardState();
}

class _BookingCardState extends State<BookingCard> {
  bool isHovered = false;

  void showReviewModal(
      BuildContext context, String title, String location, String imageUrl) {
    // Initialize selectedRating here
    int selectedRating = 0;
    
    // Determine if we're on a large screen for proper modal sizing
    final isLargeScreen = MediaQuery.of(context).size.width > 1000;
    
    showDialog(
      context: context,
      builder: (context) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15.0, sigmaY: 15.0),
          child: Dialog(
            backgroundColor: Colors.white.withOpacity(0.95),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            // Make dialog responsive
            child: Container(
              width: isLargeScreen ? 600 : MediaQuery.of(context).size.width * 0.9,
              padding: EdgeInsets.all(24),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Leave a Review",
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Poppins',
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.close),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Activity Image + Details
                    Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: _getImageWidget(imageUrl, width: 100, height: 100),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                title,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Poppins',
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(Icons.location_on,
                                      size: 16, color: Colors.grey),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      location,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey,
                                        fontFamily: 'Poppins',
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Rating Section
                    Column(
                      children: <Widget>[
                        const Text(
                          "Please give your rating with us",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Poppins',
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        StatefulBuilder(
                          builder: (context, setState) {
                            return Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: List.generate(5, (index) {
                                return MouseRegion(
                                  cursor: SystemMouseCursors.click,
                                  child: IconButton(
                                    icon: Icon(
                                      index < selectedRating
                                          ? Icons.star
                                          : Icons.star_border,
                                      size: 36,
                                      color: index < selectedRating
                                          ? Colors.amber
                                          : Colors.grey,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        selectedRating = index + 1;
                                      });
                                    },
                                  ),
                                );
                              }),
                            );
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Comment Box
                    SizedBox(
                      width: double.infinity,
                      child: TextField(
                        maxLines: 6,
                        decoration: InputDecoration(
                          hintText: "Add a Comment",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Color(0xFF007AFF), width: 2),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          ),
                          child: const Text("Cancel",
                              style: TextStyle(fontSize: 16)),
                        ),
                        const SizedBox(width: 16),
                        ElevatedButton(
                          onPressed: () {
                            // Here you would submit the review data to your backend
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Review submitted successfully!"),
                                backgroundColor: Colors.green,
                              ),
                            );
                            Navigator.pop(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF007AFF),
                            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text("Submit",
                              style: TextStyle(fontSize: 16, color: Colors.white)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // Helper method to handle different image formats/sources
  Widget _getImageWidget(String imageUrl, {double width = 120, double height = 120}) {
    if (imageUrl.startsWith('assets/')) {
      return Image.asset(
        imageUrl,
        width: width,
        height: height,
        fit: BoxFit.cover,
      );
    } else if (imageUrl.startsWith('http')) {
      return Image.network(
        imageUrl,
        width: width,
        height: height,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => Image.asset(
          'assets/Pictures/island.jpg',
          width: width,
          height: height,
          fit: BoxFit.cover,
        ),
      );
    } else {
      return Image.network(
        "$baseUrl$imageUrl",
        width: width,
        height: height,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => Image.asset(
          'assets/Pictures/island.jpg',
          width: width,
          height: height,
          fit: BoxFit.cover,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLargeScreen = MediaQuery.of(context).size.width > 1000;
    final isMediumScreen = MediaQuery.of(context).size.width > 600 && MediaQuery.of(context).size.width <= 1000;
    
    return MouseRegion(
      onEnter: (_) => setState(() => isHovered = true),
      onExit: (_) => setState(() => isHovered = false),
      child: AnimatedContainer(
        duration: Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 12),
        padding: EdgeInsets.all(isLargeScreen ? 20 : 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: isHovered 
                  ? Colors.black.withOpacity(0.25)
                  : Colors.black.withOpacity(0.15),
              blurRadius: isHovered ? 10 : 5,
              spreadRadius: isHovered ? 3 : 2,
              offset: isHovered ? Offset(2, 5) : Offset(1, 3),
            ),
          ],
          border: isHovered 
              ? Border.all(color: Color(0xFF007AFF), width: 1)
              : null,
        ),
        child: isLargeScreen
            ? _buildHorizontalLayout()
            : _buildVerticalLayout(),
      ),
    );
  }

  Widget _buildHorizontalLayout() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Image
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: (widget.activity["activity_images"] != null &&
                  widget.activity["activity_images"] is List &&
                  widget.activity["activity_images"].isNotEmpty)
              ? Image.network(
                  widget.activity["activity_images"][0].toString().startsWith("http")
                      ? widget.activity["activity_images"][0]
                      : "$baseUrl${widget.activity["activity_images"][0]}",
                  width: 180,
                  height: 180,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      Image.asset(
                    'assets/Pictures/island.jpg',
                    width: 180,
                    height: 180,
                    fit: BoxFit.cover,
                  ),
                )
              : Image.asset(
                  'assets/Pictures/island.jpg',
                  width: 180,
                  height: 180,
                  fit: BoxFit.cover,
                ),
        ),
        const SizedBox(width: 24),
        
        // Content
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Row - Title and Status Badge
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Title
                  Expanded(
                    child: Text(
                      widget.activity["name"] ?? "Unknown Activity",
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Poppins',
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  
                  // Status Badge
                  Container(
                    margin: const EdgeInsets.only(left: 12),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: _getStatusColor(widget.status),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      widget.status[0].toUpperCase() +
                          widget.status.substring(1),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Poppins',
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // Location
              Row(
                children: [
                  const Icon(Icons.location_on,
                      size: 16, color: Colors.grey),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      widget.activity["location"] ?? "Unknown Location",
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                        fontFamily: 'Poppins',
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 8),
              
              // Booking Details
              Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Booking ID:',
                        style: TextStyle(
                          fontSize: 14, 
                          color: Colors.grey[600],
                          fontFamily: 'Poppins',
                        ),
                      ),
                      Text(
                        widget.bookingId,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ],
                  ),
                  SizedBox(width: 32),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Guests:',
                        style: TextStyle(
                          fontSize: 14, 
                          color: Colors.grey[600],
                          fontFamily: 'Poppins',
                        ),
                      ),
                      Text(
                        widget.guests,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ],
                  ),
                  SizedBox(width: 32),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Date:',
                        style: TextStyle(
                          fontSize: 14, 
                          color: Colors.grey[600],
                          fontFamily: 'Poppins',
                        ),
                      ),
                      Text(
                        widget.activity["date"] ?? widget.activity["booking_date"] ?? "",
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              
              const SizedBox(height: 24),
              
              // Action Buttons
              Row(
                children: widget.isUpcoming
                    ? [
                        // Cancel Button
                        Expanded(
                          child: OutlinedButton.icon(
                            icon: Icon(Icons.close, color: Colors.red),
                            label: Text(
                              'Cancel Booking',
                              style: TextStyle(
                                color: Colors.red[700],
                                fontFamily: 'Poppins',
                                fontSize: 16,
                              ),
                            ),
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(color: Colors.red),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8)),
                              padding: EdgeInsets.symmetric(vertical: 14),
                            ),
                            onPressed: widget.onCancel,
                          ),
                        ),
                        const SizedBox(width: 16),
                        // View Ticket Button
                        Expanded(
                          child: ElevatedButton.icon(
                            icon: Icon(Icons.confirmation_number, color: Colors.white),
                            label: Text(
                              'View Ticket',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontFamily: 'Poppins',
                                  fontSize: 16),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF007AFF),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8)),
                              padding: EdgeInsets.symmetric(vertical: 14),
                            ),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ViewTicketPage(
                                    eventTitle: widget.activity["name"] ?? "",
                                    clientName:
                                        "John Doe", // You can pass actual clientName here
                                    eventTime: widget.activity["date"] ?? widget.activity["booking_date"] ?? "",
                                    numberOfAttendees:
                                        int.tryParse(widget.guests.split(' ')[0]) ?? 1,
                                    ticketId: widget.bookingId,
                                    status: widget.status,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ]
                    : [
                        // Write a Review
                        Expanded(
                          child: OutlinedButton.icon(
                            icon: Icon(Icons.rate_review, color: Color(0xFF007AFF)),
                            label: Text(
                              'Write a Review',
                              style: TextStyle(
                                color: Color(0xFF007AFF),
                                fontFamily: 'Poppins',
                                fontSize: 16,
                              ),
                            ),
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(color: Color(0xFF007AFF), width: 1),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              padding: EdgeInsets.symmetric(vertical: 14),
                            ),
                            onPressed: () {
                              // Handle case where activity_images might be null or empty
                              String imageUrl = 'assets/Pictures/island.jpg';
                              if (widget.activity["activity_images"] != null && 
                                  widget.activity["activity_images"] is List && 
                                  widget.activity["activity_images"].isNotEmpty) {
                                imageUrl = widget.activity["activity_images"][0].toString();
                              }
                              
                              showReviewModal(
                                context,
                                widget.activity["name"] ?? "Activity",
                                widget.activity["location"] ?? "Location",
                                imageUrl,
                              );
                            },
                          ),
                        ),

                        const SizedBox(width: 16),
                        // View Booking Button
                        Expanded(
                          child: ElevatedButton.icon(
                            icon: Icon(Icons.visibility, color: Colors.white),
                            label: Text(
                              'View Details',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontFamily: 'Poppins',
                                  fontSize: 16),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF007AFF),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8)),
                              padding: EdgeInsets.symmetric(vertical: 14),
                            ),
                            onPressed: () => navigateToDetails(context),
                          ),
                        ),
                      ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildVerticalLayout() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Image & title
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: (widget.activity["activity_images"] != null &&
                      widget.activity["activity_images"] is List &&
                      widget.activity["activity_images"].isNotEmpty)
                  ? Image.network(
                      widget.activity["activity_images"][0].toString().startsWith("http")
                          ? widget.activity["activity_images"][0]
                          : "$baseUrl${widget.activity["activity_images"][0]}",
                      width: 120,
                      height: 120,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          Image.asset(
                        'assets/Pictures/island.jpg',
                        width: 120,
                        height: 120,
                        fit: BoxFit.cover,
                      ),
                    )
                  : Image.asset(
                      'assets/Pictures/island.jpg',
                      width: 120,
                      height: 120,
                      fit: BoxFit.cover,
                    ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.activity["name"] ?? "Unknown Activity",
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Poppins',
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Row(
                    children: [
                      const Icon(Icons.location_on,
                          size: 14, color: Colors.grey),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          widget.activity["location"] ?? "Unknown Location",
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                            fontFamily: 'Poppins',
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getStatusColor(widget.status),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      widget.status[0].toUpperCase() +
                          widget.status.substring(1),
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Poppins',
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Text('Booking ID: ${widget.bookingId}',
            style: const TextStyle(
              fontSize: 16,
              color: Colors.black,
              fontFamily: 'Poppins',
              fontWeight: FontWeight.bold,
            )),
        Text(widget.guests,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.grey,
              fontFamily: 'Poppins',
            )),
        const Divider(color: Colors.grey),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Text(
            widget.activity["date"] ?? widget.activity["booking_date"] ?? "",
            style: const TextStyle(
              fontSize: 18,
              color: Colors.black,
              fontFamily: 'Poppins',
            ),
          ),
        ),
        Row(
          children: widget.isUpcoming
              ? [
                  // Cancel Button
                  Expanded(
                    child: ElevatedButton(
                      onPressed: widget.onCancel,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(
                            color: Colors.white,
                            fontFamily: 'Poppins',
                            fontSize: 14),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  // View Ticket Button
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ViewTicketPage(
                              eventTitle: widget.activity["name"] ?? "",
                              clientName:
                                  "John Doe", // You can pass actual clientName here
                              eventTime: widget.activity["date"] ?? widget.activity["booking_date"] ?? "",
                              numberOfAttendees:
                                  int.tryParse(widget.guests.split(' ')[0]) ?? 1,
                              ticketId: widget.bookingId,
                              status: widget.status,
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF007AFF),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text(
                        'View Ticket',
                        style: TextStyle(
                            color: Colors.white,
                            fontFamily: 'Poppins',
                            fontSize: 14),
                      ),
                    ),
                  ),
                ]
              : [
                  // Write a Review
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        // Handle case where activity_images might be null or empty
                        String imageUrl = 'assets/Pictures/island.jpg';
                        if (widget.activity["activity_images"] != null && 
                            widget.activity["activity_images"] is List && 
                            widget.activity["activity_images"].isNotEmpty) {
                          imageUrl = widget.activity["activity_images"][0].toString();
                        }
                        
                        showReviewModal(
                          context,
                          widget.activity["name"] ?? "Activity",
                          widget.activity["location"] ?? "Location",
                          imageUrl,
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFF007AFF), width: 1),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text(
                        'Write a Review',
                        style: TextStyle(
                          color: Color(0xFF007AFF),
                          fontFamily: 'Poppins',
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 10),
                  // View Booking Button
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => navigateToDetails(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF007AFF),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text(
                        'View Booking',
                        style: TextStyle(
                            color: Colors.white,
                            fontFamily: 'Poppins',
                            fontSize: 14),
                      ),
                    ),
                  ),
                ],
        ),
      ],
    );
  }

  void navigateToDetails(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EventDetailsScreen(activity: widget.activity),
      ),
    );
  }
}

Color _getStatusColor(String status) {
  switch (status.toLowerCase()) {
    case "pending":
      return Colors.orange;
    case "confirmed":
      return Colors.green;
    case "cancelled":
      return Colors.red;
    case "completed":
      return Colors.blueGrey;
    default:
      return Colors.grey;
  }
}