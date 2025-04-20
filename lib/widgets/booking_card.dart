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

  const BookingCard({
    Key? key,
    required this.activity,
    required this.bookingId,
    required this.guests,
    required this.status,
    required this.onCancel,
  }) : super(key: key);

  void showReviewModal(
      BuildContext context, String title, String location, String imageUrl) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

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
              color: isDarkMode
                  ? const Color.fromARGB(230, 33, 33, 33)
                  : Colors.white.withOpacity(0.95),
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
                          color: isDarkMode ? Colors.white : Colors.black,
                        ),
                      ),
                      const SizedBox(height: 10),

                      // Activity Image + Details
                      Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.asset(
                              imageUrl,
                              width: 80,
                              height: 80,
                              fit: BoxFit.cover,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                title,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color:
                                      isDarkMode ? Colors.white : Colors.black,
                                ),
                              ),
                              Row(
                                children: [
                                  Icon(Icons.location_on,
                                      size: 14,
                                      color: isDarkMode
                                          ? Colors.grey[400]
                                          : Colors.grey),
                                  const SizedBox(width: 4),
                                  Text(
                                    location,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: isDarkMode
                                          ? Colors.grey[400]
                                          : Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          )
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Rating Section
                      Column(
                        children: <Widget>[
                          Text(
                            "Please give your rating with us",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Poppins',
                              color: isDarkMode ? Colors.white : Colors.black,
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
                                          : isDarkMode
                                              ? Colors.grey[600]
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
                          style: TextStyle(
                            color: isDarkMode ? Colors.white : Colors.black,
                          ),
                          decoration: InputDecoration(
                            hintText: "Add a Comment",
                            hintStyle: TextStyle(
                              color: isDarkMode
                                  ? Colors.grey[500]
                                  : Colors.grey[600],
                            ),
                            filled: true,
                            fillColor: isDarkMode
                                ? const Color(0xFF2A2A2A)
                                : Colors.grey[100],
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(
                                color: isDarkMode
                                    ? Colors.grey[600]!
                                    : Colors.grey[300]!,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(
                                color: Colors.pink,
                                width: 1.5,
                              ),
                            ),
                            contentPadding: const EdgeInsets.all(12),
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
                            child: Text(
                              "Cancel",
                              style: TextStyle(
                                fontSize: 16,
                                color:
                                    isDarkMode ? Colors.white : Colors.black87,
                              ),
                            ),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.pink,
                            ),
                            child: const Text(
                              "Submit",
                              style: TextStyle(fontSize: 16),
                            ),
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

  @override
  Widget build(BuildContext context) {
     final isDarkMode = Theme.of(context).brightness == Brightness.dark;

return Container(
  margin: const EdgeInsets.only(bottom: 12),
  padding: const EdgeInsets.all(12),
  decoration: BoxDecoration(
    color: isDarkMode ? const Color(0xFF2B2B2B) : Colors.white,
    borderRadius: BorderRadius.circular(12),
    boxShadow: [
      BoxShadow(
        color: isDarkMode
            ? Colors.black.withOpacity(0.1)
            : Colors.black.withOpacity(0.2),
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
                    activity["activity_images"].isNotEmpty)
                ? Image.network(
                    activity["activity_images"][0].startsWith("http")
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
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Poppins',
                    color: isDarkMode ? Colors.white : Colors.black,
                  ),
                ),
                Row(
                  children: [
                    Icon(Icons.location_on,
                        size: 14,
                        color:
                            isDarkMode ? Colors.grey[400] : Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(
                      activity["location"] ?? "Unknown Location",
                      style: TextStyle(
                        fontSize: 14,
                        color: isDarkMode ? Colors.grey[400] : Colors.grey,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ],
                ),
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getStatusColor(status),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text(
                    // Assume status is already capitalized
                    'Confirmed',
                    style: TextStyle(
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
          style: TextStyle(
            fontSize: 16,
            color: isDarkMode ? Colors.white : Colors.black,
            fontFamily: 'Poppins',
            fontWeight: FontWeight.bold,
          )),
      Text(guests,
          style: TextStyle(
            fontSize: 14,
            color: isDarkMode ? Colors.grey[400] : Colors.grey,
            fontFamily: 'Poppins',
          )),
      Align(
        alignment: Alignment.centerLeft,
        child: Divider(
          color: isDarkMode ? Colors.grey[700] : Colors.grey[300],
        ),
      ),
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Text(activity["date"] ?? "",
            style: TextStyle(
              fontSize: 18,
              color: isDarkMode ? Colors.white : Colors.black,
              fontFamily: 'Poppins',
            )),
      ),

      // Buttons
      Row(
        children: isUpcomingSelected
            ? [
                // Cancel Button
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
                // View Ticket
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ViewTicketPage(
                            eventTitle: activity["name"] ?? "",
                            clientName: "John Doe",
                            eventTime: activity["date"] ?? "",
                            numberOfAttendees:
                                int.tryParse(guests.split(' ')[0]) ?? 1,
                            ticketId: bookingId,
                            status: status,
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
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
                // Review Button
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => showReviewModal(
                      context,
                      activity["name"] ?? "",
                      activity["location"] ?? "",
                      activity["activity_images"][0] ?? "",
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.blue, width: 1),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text(
                      'Write a Review',
                      style: TextStyle(
                        color: Colors.blue,
                        fontFamily: 'Poppins',
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                // View Booking
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => navigateToDetails(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
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
