import 'package:adventura/Booking/CancelBooking.dart';
import 'package:adventura/Booking/MyBooking.dart';
import 'package:adventura/OrderDetail/ViewTicket.dart';
import 'package:adventura/search%20screen/eventDetailsScreen.dart';
import 'package:flutter/material.dart';
import 'package:adventura/Provider%20Only/ticketScanner.dart';

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
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Leave a Review",
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Poppins')),
              SizedBox(height: 10),
              // Activity Image + Details
              Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.asset(imageUrl,
                        width: 80, height: 80, fit: BoxFit.cover),
                  ),
                  SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title,
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold)),
                      Row(
                        children: [
                          Icon(Icons.location_on, size: 14, color: Colors.grey),
                          SizedBox(width: 4),
                          Text(location,
                              style:
                                  TextStyle(fontSize: 14, color: Colors.grey)),
                        ],
                      ),
                    ],
                  )
                ],
              ),
              SizedBox(height: 10),
              // Rating Section
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  SizedBox(
                    width: double.infinity,
                    child: Text(
                      "Please give your rating with us",
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Poppins'),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  SizedBox(height: 10),
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
              SizedBox(height: 10),
              // Comment Box
              SizedBox(
                width: double.infinity,
                height: 230,
                child: TextField(
                  maxLines: 10,
                  decoration: InputDecoration(
                    hintText: "Add a Comment",
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
              SizedBox(height: 40),
              // Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text("Cancel", style: TextStyle(fontSize: 16)),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text("Submit", style: TextStyle(fontSize: 16)),
                    style:
                        ElevatedButton.styleFrom(backgroundColor: Colors.pink),
                  )
                ],
              )
            ],
          ),
        );
      },
    );
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
                child: Image.asset(
                  activity["activity_images"][0],
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
                    ),
                    Row(
                      children: [
                        const Icon(Icons.location_on,
                            size: 14, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text(
                          activity["location"] ?? "Unknown Location",
                          style: const TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                              fontFamily: 'Poppins'),
                        ),
                      ],
                    ),
                    Container(
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.yellow,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        status,
                        style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'poppins'),
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
          const Align(
            alignment: Alignment.centerLeft,
            child: Divider(color: Colors.grey),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Text(activity["date"] ?? "",
                style: const TextStyle(
                  fontSize: 18,
                  color: Colors.black,
                  fontFamily: 'Poppins',
                )),
          ),
          Row(
            children: isUpcomingSelected
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
                        child: Text(
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
                        child: Text(
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
                    // 🔵 View Booking Button
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => navigateToDetails(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8)),
                        ),
                        child: Text(
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
