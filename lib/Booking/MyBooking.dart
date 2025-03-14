import 'package:adventura/Booking/CancelBooking.dart';
import 'package:adventura/search%20screen/modalActivityView.dart';
import 'package:flutter/material.dart';

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
            Container(
              height: 40,
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFFF2F3F4), // Background color for toggle
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  // Upcoming Button
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          isUpcomingSelected = true;
                        });
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: isUpcomingSelected
                              ? Colors.white
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          'Upcoming',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Poppins',
                            color: isUpcomingSelected
                                ? Colors.black
                                : Colors.grey[600],
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Past Button
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          isUpcomingSelected = false;
                        });
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: !isUpcomingSelected
                              ? Colors.white
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          'Past',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Poppins',
                            color: !isUpcomingSelected
                                ? Colors.black
                                : Colors.grey[600],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20), // Spacing below toggle buttons
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
            // Booking List
            Expanded(
              child: ListView(
                children: [
                  BookingCard(
                    imageUrl: 'assets/Pictures/island.jpg',
                    title: 'Saint Moritz',
                    location: 'Switzerland',
                    bookingId: '#UI891827BHY',
                    date: 'May 22, 2024 - May 26, 2024',
                    guests: '3 Guests',
                    status: 'Upcoming',
                    onCancel: () {
                      // Show CancelBookingScreen as a responsive modal with rounded top corners.
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(16),
                            topRight: Radius.circular(16),
                          ),
                        ),
                        builder: (context) {
                          return FractionallySizedBox(
                            heightFactor:
                                0.8, // Modal takes 80% of screen height
                            child: CancelBookingScreen(),
                          );
                        },
                      );
                    },
                    onView: () {
                      // Replace with your view booking functionality.
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => Scaffold(
                            appBar: AppBar(title: Text("View Booking")),
                            body: Center(child: Text("Booking details here")),
                          ),
                        ),
                      );
                    },
                  ),
                  BookingCard(
                    imageUrl: 'assets/Pictures/picnic.webp',
                    title: 'Addu Atoll',
                    location: 'Maldives',
                    bookingId: '#TY671829BUI',
                    date: 'May 22, 2024 - May 26, 2024',
                    guests: '2 Guests',
                    status: 'Upcoming',
                    onCancel: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(16),
                            topRight: Radius.circular(16),
                          ),
                        ),
                        builder: (context) {
                          return FractionallySizedBox(
                            heightFactor: 0.8,
                            child: CancelBookingScreen(),
                          );
                        },
                      );
                    },
                    onView: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EventDetailsScreen(
                            title: 'Addu Atoll',
                            date: 'May 22, 2024 - May 26, 2024',
                            location: 'Maldives',
                            imagePaths: [
                              'assets/Pictures/picnic.webp'
                            ], // Assuming only one image, add more if available
                            tripPlan: [
                              {
                                'time': '10:00 AM',
                                'event': 'Arrival at Resort'
                              },
                              {
                                'time': '12:00 PM',
                                'event': 'Lunch by the Beach'
                              },
                              {
                                'time': '3:00 PM',
                                'event': 'Snorkeling Adventure'
                              },
                            ], // Add trip plan details
                            description:
                                'Experience a luxurious getaway in the Maldives with breathtaking ocean views, premium dining, and exciting activities like snorkeling and sunset cruises.',
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// The BookingCard widget displays booking details with options to cancel or view.
class BookingCard extends StatelessWidget {
  final String imageUrl;
  final String title;
  final String location;
  final String bookingId;
  final String date;
  final String guests;
  final String status;
  final VoidCallback onCancel;
  final VoidCallback onView;

  const BookingCard({
    Key? key,
    required this.imageUrl,
    required this.title,
    required this.location,
    required this.bookingId,
    required this.date,
    required this.guests,
    required this.status,
    required this.onCancel,
    required this.onView,
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
          // Image and Details
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.asset(
                  imageUrl,
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
                      title,
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
                          location,
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
            child: SizedBox(
              width: double.infinity,
              child: Divider(
                color: Colors.grey,
                thickness: 1,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Text(date,
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
                  onPressed: isUpcomingSelected ? onCancel : onView,
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
              SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: isUpcomingSelected
                      ? onView
                      : () =>
                          showReviewModal(context, title, location, imageUrl),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  child: Text(
                    isUpcomingSelected ? 'View Booking' : 'Write a Review',
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
}
