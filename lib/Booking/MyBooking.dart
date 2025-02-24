import 'package:adventura/search%20screen/modalActivityView.dart';
import 'package:flutter/material.dart';

class MyBookingsPage extends StatefulWidget {
  @override
  _MyBookingsPageState createState() => _MyBookingsPageState();
}

class _MyBookingsPageState extends State<MyBookingsPage> {
  bool isUpcomingSelected = true; // Variable to track the selected tab

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white, // Matches the page background
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
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
                color: Color(0xFFF2F3F4), // Background color for toggle
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
            SizedBox(height: 20), // Spacing below toggle buttons

            // Dynamic Title
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                isUpcomingSelected ? 'Upcoming Bookings' : 'Past Bookings',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Poppins',
                ),
              ),
            ),
            SizedBox(height: 10),

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
                    onCancel: () {},
                    onView: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EventDetailsScreen(
                            title: 'Saint Moritz',
                            date: 'May 22, 2024 - May 26, 2024',
                            location: 'Switzerland',
                            imagePaths: [
                              'assets/Pictures/island.jpg'
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
                  BookingCard(
                    imageUrl: 'assets/Pictures/picnic.webp',
                    title: 'Addu Atoll',
                    location: 'Maldives',
                    bookingId: '#TY671829BUI',
                    date: 'May 22, 2024 - May 26, 2024',
                    guests: '2 Guests',
                    status: 'Upcoming',
                    onCancel: () {},
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
    required this.imageUrl,
    required this.title,
    required this.location,
    required this.bookingId,
    required this.date,
    required this.guests,
    required this.status,
    required this.onCancel,
    required this.onView,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 5,
            spreadRadius: 2,
            offset: Offset(1, 3),
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
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Poppins',
                      ),
                    ),
                    Row(
                      children: [
                        Icon(Icons.location_on, size: 14, color: Colors.grey),
                        SizedBox(width: 4),
                        Text(
                          location,
                          style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                              fontFamily: 'Poppins'),
                        ),
                      ],
                    ),
                    Container(
                      margin: EdgeInsets.symmetric(vertical: 4),
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.yellow,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        status,
                        style: TextStyle(
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
          SizedBox(height: 10),

          // Booking ID, Date, and Guests
          Text('Booking ID: $bookingId',
              style: TextStyle(
                fontSize: 16,
                color: Colors.black,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.bold,
              )),
          Text(guests,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
                fontFamily: 'Poppins',
              )),
          Align(
            alignment: Alignment.centerLeft, // Keeps divider aligned
            child: Container(
              width: double.infinity, // Makes divider full width
              child: Divider(
                color: Colors.grey,
                thickness: 1,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Text(date,
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.black,
                  fontFamily: 'Poppins',
                )),
          ),
          // Buttons
          Row(
            children: [
              // Cancel Button
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
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 12),
              // View Booking Button
              Expanded(
                child: ElevatedButton(
                  onPressed: onView,
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
                      fontSize: 16,
                    ),
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
