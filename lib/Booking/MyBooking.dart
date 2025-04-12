import 'dart:async';

import 'package:adventura/Booking/CancelBooking.dart';
import 'package:adventura/colors.dart';
import 'package:flutter/material.dart';
import 'package:adventura/widgets/booking_card.dart';
import 'package:flutter/rendering.dart';

/// The MyBookingsPage displays the list of bookings.
/// Tapping the Cancel button on a booking opens the CancelBookingScreen
/// as a responsive modal that covers about 80% of the screen height.
class MyBookingsPage extends StatefulWidget {
  final Function(bool) onScrollChanged;
  const MyBookingsPage({Key? key, required this.onScrollChanged})
      : super(key: key);

  @override
  _MyBookingsPageState createState() => _MyBookingsPageState();
}

int selectedRating = 0;
bool isUpcomingSelected = true;

class _MyBookingsPageState extends State<MyBookingsPage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true; // Keep this page alive when navigating
  final ScrollController _scrollController = ScrollController();
  Timer? _scrollStopTimer;

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
  void initState() {
    super.initState();

    _scrollController.addListener(() {
      final direction = _scrollController.position.userScrollDirection;

      // Cancel any running timer
      _scrollStopTimer?.cancel();

      if (direction == ScrollDirection.reverse) {
        widget.onScrollChanged(false); // hide nav bar
      } else if (direction == ScrollDirection.forward) {
        widget.onScrollChanged(true); // show nav bar
      }

      _scrollStopTimer = Timer(Duration(milliseconds: 300), () {
        widget.onScrollChanged(true);
      });
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _scrollStopTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(
        context); // Call super to ensure the widget tree is built correctly
    double statusBarHeight = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          SingleChildScrollView(
            controller: _scrollController,
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(16, statusBarHeight + 6, 16, 6),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Your Reservations",
                            style: TextStyle(
                              height: 0.96,
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Poppins',
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                      // Toggle Section (Upcoming / Past)
                      SizedBox(height: 20),
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
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          isUpcomingSelected
                              ? 'Upcoming Bookings'
                              : 'Past Bookings',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Poppins',
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      // Booking List
                      ListView.builder(
                        shrinkWrap: true, // ✅ this lets it size itself
                        physics:
                            NeverScrollableScrollPhysics(), // ✅ prevent nested scrolling conflict
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
                                  borderRadius: BorderRadius.vertical(
                                      top: Radius.circular(16)),
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
                    ],
                  ),
                ),

                // 🔥 Bottom Nav Bar — Positioned same as MainScreen
              ],
            ),
          ),
        ],
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
          color: isSelected ? AppColors.blue : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            fontFamily: 'Poppins',
            color: isSelected
                ? const Color.fromARGB(255, 255, 255, 255)
                : Colors.grey[600],
          ),
        ),
      ),
    );
  }
}
