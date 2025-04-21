import 'dart:ui';

import 'package:adventura/Booking/MyBooking.dart';
import 'package:adventura/OrderDetail/ViewTicket.dart';
import 'package:adventura/config.dart';
import 'package:adventura/event_cards/eventDetailsScreen.dart';
import 'package:flutter/material.dart';

/// The BookingCard widget displays booking details with options to cancel or view.
// DYNAMIC Booking Card
class BookingCard extends StatelessWidget {
  final Map<String, dynamic> activity;
  final String bookingId;
  final String guests;
  final String status;
  final VoidCallback onCancel;
  final bool isUpcoming; // Added this property to determine which buttons to show

  const BookingCard({
    Key? key,
    required this.activity,
    required this.bookingId,
    required this.guests,
    required this.status,
    required this.onCancel,
    this.isUpcoming = true, // Default to upcoming
  }) : super(key: key);

  void showReviewModal(
      BuildContext context, String title, String location, String imageUrl) {
    // Initialize selectedRating here
    int selectedRating = 0;
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withOpacity(0.25),
      builder: (context) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15.0, sigmaY: 15.0),
          child: FractionallySizedBox(
            heightFactor: 0.85,
            child: Material(
              color: Colors.white.withOpacity(0.95),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(24)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Leave a Review",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Poppins',
                        ),
                      ),
                      const SizedBox(height: 10),

                      // Activity Image + Details
                      Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: _getImageWidget(imageUrl),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  title,
                                  style: const TextStyle(
                                    fontSize: 16,
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
                      const SizedBox(height: 20),

                      // Rating Section
                      Column(
                        children: <Widget>[
                          const Text(
                            "Please give your rating with us",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Poppins',
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 10),
                          StatefulBuilder(
                            builder: (context, setState) {
                              return Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: List.generate(5, (index) {
                                  return IconButton(
                                    icon: Icon(
                                      index < selectedRating
                                          ? Icons.star
                                          : Icons.star_border,
                                      size: 32,
                                      color: index < selectedRating
                                          ? Colors.yellow
                                          : Colors.grey,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        selectedRating = index + 1;
                                      });
                                    },
                                  );
                                }),
                              );
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Comment Box
                      SizedBox(
                        width: double.infinity,
                        height: 230,
                        child: TextField(
                          maxLines: 10,
                          decoration: InputDecoration(
                            hintText: "Add a Comment",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 40),

                      // Buttons
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text("Cancel",
                                style: TextStyle(fontSize: 16)),
                          ),
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
                              backgroundColor: const Color(0xFF007AFF), // Using your main blue color
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
          ),
        );
      },
    );
  }

  // Helper method to handle different image formats/sources
  Widget _getImageWidget(String imageUrl) {
    if (imageUrl.startsWith('assets/')) {
      return Image.asset(
        imageUrl,
        width: 80,
        height: 80,
        fit: BoxFit.cover,
      );
    } else if (imageUrl.startsWith('http')) {
      return Image.network(
        imageUrl,
        width: 80,
        height: 80,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => Image.asset(
          'assets/Pictures/island.jpg',
          width: 80,
          height: 80,
          fit: BoxFit.cover,
        ),
      );
    } else {
      return Image.network(
        "$baseUrl$imageUrl",
        width: 80,
        height: 80,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => Image.asset(
          'assets/Pictures/island.jpg',
          width: 80,
          height: 80,
          fit: BoxFit.cover,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 5,
            spreadRadius: 2,
            offset: const Offset(1, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image & title
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: (activity["activity_images"] != null &&
                        activity["activity_images"] is List &&
                        activity["activity_images"].isNotEmpty)
                    ? Image.network(
                        activity["activity_images"][0].toString().startsWith("http")
                            ? activity["activity_images"][0]
                            : "$baseUrl${activity["activity_images"][0]}",
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
                      activity["name"] ?? "Unknown Activity",
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
                            activity["location"] ?? "Unknown Location",
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
                        color: _getStatusColor(status),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        status[0].toUpperCase() +
                            status.substring(1), // e.g. "confirmed"
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
          Text('Booking ID: $bookingId',
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.bold,
              )),
          Text(guests,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
                fontFamily: 'Poppins',
              )),
          const Divider(color: Colors.grey),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Text(
              activity["date"] ?? activity["booking_date"] ?? "",
              style: const TextStyle(
                fontSize: 18,
                color: Colors.black,
                fontFamily: 'Poppins',
              ),
            ),
          ),
          Row(
            children: isUpcoming
                ? [
                    // 🔴 Cancel Button
                    Expanded(
                      child: ElevatedButton(
                        onPressed: onCancel,
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
                    // 🟢 View Ticket Button
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ViewTicketPage(
                                eventTitle: activity["name"] ?? "",
                                clientName:
                                    "John Doe", // You can pass actual clientName here
                                eventTime: activity["date"] ?? activity["booking_date"] ?? "",
                                numberOfAttendees:
                                    int.tryParse(guests.split(' ')[0]) ?? 1,
                                ticketId: bookingId,
                                status: status,
                              ),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF007AFF), // Using your main blue color
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
                    // 🟠 Write a Review
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          // Handle case where activity_images might be null or empty
                          String imageUrl = 'assets/Pictures/island.jpg';
                          if (activity["activity_images"] != null && 
                              activity["activity_images"] is List && 
                              activity["activity_images"].isNotEmpty) {
                            imageUrl = activity["activity_images"][0].toString();
                          }
                          
                          showReviewModal(
                            context,
                            activity["name"] ?? "Activity",
                            activity["location"] ?? "Location",
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
                    // 🔵 View Booking Button
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
      ),
    );
  }

  void navigateToDetails(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EventDetailsScreen(activity: activity),
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