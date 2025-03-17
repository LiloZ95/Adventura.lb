import 'package:adventura/Booking/CancelBooking.dart';
import 'package:adventura/search%20screen/eventDetailsScreen.dart';
import 'package:flutter/material.dart';
import 'package:adventura/provider/ticketScanner.dart';

void main() {
  runApp(MyApp());
}

/// The root widget of the application.
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My Bookings',
      debugShowCheckedModeBanner: false,
      home: MyBookingsPage(),
    );
  }
}

/// The MyBookingsPage displays the list of bookings.
/// Tapping the Cancel button on a booking opens the CancelBookingScreen
/// as a responsive modal that covers about 80% of the screen height.
class MyBookingsPage extends StatefulWidget {
  const MyBookingsPage({Key? key}) : super(key: key);

  @override
  _MyBookingsPageState createState() => _MyBookingsPageState();
}

int selectedRating = 0;
bool isUpcomingSelected = true;

class _MyBookingsPageState extends State<MyBookingsPage> {
  // Temporary dummy bookings
  List<Map<String, dynamic>> bookings = [
    {
      "activity": {
        "name": "Saint Moritz",
        "location": "Switzerland",
        "date": "May 22, 2024 - May 26, 2024",
        "price": "45",
        "description": "A luxury mountain resort.",
        "activity_images": ["assets/Pictures/island.jpg"]
      },
      "bookingId": "#UI891827BHY",
      "guests": "3 Guests",
      "status": "Upcoming",
    },
    {
      "activity": {
        "name": "Addu Atoll",
        "location": "Maldives",
        "date": "May 22, 2024 - May 26, 2024",
        "price": "60",
        "description": "Enjoy a tropical getaway.",
        "activity_images": ["assets/Pictures/picnic.webp"]
      },
      "bookingId": "#TY671829BUI",
      "guests": "2 Guests",
      "status": "Upcoming",
    },
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white, // Matches the page background
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'My Bookings',
          style: TextStyle(
            fontFamily: "Poppins",
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Tab Selector for Upcoming & Past
            // Container(
            //   height: 40,
            //   width: double.infinity,
            //   decoration: BoxDecoration(
            //     color: const Color(0xFFF2F3F4), // Background color for toggle
            //     borderRadius: BorderRadius.circular(12),
            //   ),
            //   child: Row(
            //     children: [
            //       // Upcoming Button
            //       Expanded(
            //         child: GestureDetector(
            //           onTap: () {
            //             setState(() {
            //               isUpcomingSelected = true;
            //             });
            //           },
            //           child: Container(
            //             decoration: BoxDecoration(
            //               color: isUpcomingSelected
            //                   ? Colors.white
            //                   : Colors.transparent,
            //               borderRadius: BorderRadius.circular(12),
            //             ),
            //             alignment: Alignment.center,
            //             child: Text(
            //               'Upcoming',
            //               style: TextStyle(
            //                 fontSize: 16,
            //                 fontWeight: FontWeight.bold,
            //                 fontFamily: 'Poppins',
            //                 color: isUpcomingSelected
            //                     ? Colors.black
            //                     : Colors.grey[600],
            //               ),
            //             ),
            //           ),
            //         ),
            //       ),
            //       // Past Button
            //       Expanded(
            //         child: GestureDetector(
            //           onTap: () {
            //             setState(() {
            //               isUpcomingSelected = false;
            //             });
            //           },
            //           child: Container(
            //             decoration: BoxDecoration(
            //               color: !isUpcomingSelected
            //                   ? Colors.white
            //                   : Colors.transparent,
            //               borderRadius: BorderRadius.circular(12),
            //             ),
            //             alignment: Alignment.center,
            //             child: Text(
            //               'Past',
            //               style: TextStyle(
            //                 fontSize: 16,
            //                 fontWeight: FontWeight.bold,
            //                 fontFamily: 'Poppins',
            //                 color: !isUpcomingSelected
            //                     ? Colors.black
            //                     : Colors.grey[600],
            //               ),
            //             ),
            //           ),
            //         ),
            //       ),
            //     ],
            //   ),
            // ),
            // const SizedBox(height: 20), // Spacing below toggle buttons
            Container(
              height: 40,
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFFF2F3F4),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Expanded(child: bookingTab("Upcoming", true)),
                  Expanded(child: bookingTab("Past", false)),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // Dynamic Title
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                isUpcomingSelected ? 'Upcoming Bookings' : 'Past Bookings',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Poppins',
                ),
              ),
            ),
            const SizedBox(height: 10),
            // Dynamic Booking List
            Expanded(
              child: ListView.builder(
                itemCount: bookings.length,
                itemBuilder: (context, index) {
                  final booking = bookings[index];
                  return BookingCard(
                    activity: booking["activity"],
                    bookingId: booking["bookingId"],
                    guests: booking["guests"],
                    status: booking["status"],
                    onCancel: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.vertical(top: Radius.circular(16)),
                        ),
                        builder: (context) {
                          return FractionallySizedBox(
                            heightFactor: 0.8,
                            child: CancelBookingScreen(),
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
  Widget bookingTab(String label, bool isUpcoming) {
    bool isSelected = isUpcomingSelected == isUpcoming;
    return GestureDetector(
      onTap: () {
        setState(() {
          isUpcomingSelected = isUpcoming;
        });
      },
      child: Container(
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            fontFamily: 'Poppins',
            color: isSelected ? Colors.black : Colors.grey[600],
          ),
        ),
      ),
    );
  }
}


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
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: isUpcomingSelected ? onCancel : () => navigateToDetails(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        isUpcomingSelected ? Colors.red : Colors.blue,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  child: Text(
                    isUpcomingSelected ? 'Cancel' : 'View Booking',
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
