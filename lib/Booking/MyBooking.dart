import 'dart:async';
import 'dart:ui';
import 'package:adventura/Booking/CancelBooking.dart';
import 'package:adventura/colors.dart';
import 'package:flutter/material.dart';
import 'package:adventura/widgets/booking_card.dart';
import 'package:adventura/Services/booking_service.dart';
import 'package:flutter/rendering.dart';
import 'package:hive/hive.dart';

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My Bookings',
      debugShowCheckedModeBanner: false,
      home: MyBookingsPage(onScrollChanged: (_) {}),
    );
  }
}

class MyBookingsPage extends StatefulWidget {
  final Function(bool) onScrollChanged;
  const MyBookingsPage({Key? key, required this.onScrollChanged})
      : super(key: key);

  @override
  _MyBookingsPageState createState() => _MyBookingsPageState();
}

int selectedRating = 0;
bool isUpcomingSelected = true;

class _MyBookingsPageState extends State<MyBookingsPage> {
  late final ScrollController _scrollController;
  Timer? _scrollStopTimer;

  bool isLoading = false;
  List<Map<String, dynamic>> bookings = [];

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();

    _scrollController.addListener(() {
      final direction = _scrollController.position.userScrollDirection;

      _scrollStopTimer?.cancel();

      if (direction == ScrollDirection.reverse) {
        widget.onScrollChanged(false); // 👈 hide nav bar
      } else if (direction == ScrollDirection.forward) {
        widget.onScrollChanged(true); // 👈 show nav bar
      }

      _scrollStopTimer = Timer(Duration(milliseconds: 300), () {
        widget.onScrollChanged(true); // 👈 auto-show after scroll stops
      });
    });

    _fetchBookings();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _scrollStopTimer?.cancel();
    super.dispose();
  }

  Future<void> _fetchBookings() async {
    final box = await Hive.openBox('authBox');
    final clientId = int.tryParse(box.get('userId') ?? '');
    print("📦 Logged-in client ID: $clientId");

    if (clientId == null) {
      print("❌ No valid user ID");
      return;
    }

    final fetched = await BookingService.getUserBookings(clientId);
    print("📥 Bookings fetched: $fetched");

    setState(() {
      bookings = fetched
          .map((b) => {
                "activity": {
                  "name": b["activity"]["name"],
                  "location": b["activity"]["location"],
                  "date": b["booking_date"],
                  "price": b["total_price"].toString(),
                  "description": b["activity"]["description"],
                  "activity_images": (b["activity"]["activity_images"] ?? [])
                      .map<String>((img) => img.toString())
                      .toList(),
                },
                "bookingId": "#${b["booking_id"]}",
                "guests": "1 Guest",
                "status": (() {
                  final s = b["status"]?.toLowerCase();
                  if (s == "pending") return "Upcoming";
                  return "Past";
                })(),
                "raw_status": b["status"], // 👈 Used for badge coloring
              })
          .toList();
    });

    print("🎯 Final bookings: $bookings");
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDarkMode ? Color(0xFF1F1F1F) : Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(16, 6, 16, 6),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top divider + title
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Divider(
                          thickness: 1,
                          color:
                              isDarkMode ? Colors.grey.shade700 : Colors.grey,
                        ),
                      ),
                      SizedBox(width: 12),
                      Text(
                        "Reservations",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Poppins',
                          color: isDarkMode ? Colors.white : Colors.black,
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Divider(
                          thickness: 1,
                          color:
                              isDarkMode ? Colors.grey.shade700 : Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 25),

                  // Booking tab
                  Container(
                    height: 40,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: isDarkMode ? Color(0xFF2C2C2C) : Color(0xFFF2F3F4),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Expanded(child: bookingTab("Upcoming", true)),
                        Expanded(child: bookingTab("Past", false)),
                      ],
                    ),
                  ),
                  SizedBox(height: 20),

                  // Section title
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      isUpcomingSelected
                          ? 'Upcoming Bookings'
                          : 'Past Bookings',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Poppins',
                        color: isDarkMode ? Colors.white : Colors.black,
                      ),
                    ),
                  ),
                  SizedBox(height: 10),

                  // Booking list
                  Expanded(
                    child: isLoading
                        ? Center(child: CircularProgressIndicator())
                        : bookings.isEmpty
                            ? Center(
                                child: Text(
                                  "No bookings found.",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontFamily: 'Poppins',
                                    color: isDarkMode
                                        ? Colors.white
                                        : Colors.black,
                                  ),
                                ),
                              )
                            : ListView.builder(
                                controller: _scrollController, 
                                padding: EdgeInsets.only(bottom: 120),
                                itemCount: bookings
                                    .where((b) => isUpcomingSelected
                                        ? b["status"] == "Upcoming"
                                        : b["status"] == "Past")
                                    .length,
                                itemBuilder: (context, index) {
                                  final filtered = bookings
                                      .where((b) => isUpcomingSelected
                                          ? b["status"] == "Upcoming"
                                          : b["status"] == "Past")
                                      .toList();

                                  final booking = filtered[index];
                                  return BookingCard(
                                    activity: booking["activity"],
                                    bookingId: booking["bookingId"],
                                    guests: booking["guests"],
                                    status: booking["raw_status"],
                                    onCancel: () {
                                      showModalBottomSheet(
                                        context: context,
                                        isScrollControlled: true,
                                        backgroundColor: Colors.transparent,
                                        barrierColor:
                                            Colors.black.withOpacity(0.25),
                                        builder: (context) {
                                          return BackdropFilter(
                                            filter: ImageFilter.blur(
                                                sigmaX: 15.0, sigmaY: 15.0),
                                            child: Material(
                                              color: Colors.white
                                                  .withOpacity(0.95),
                                              borderRadius:
                                                  BorderRadius.vertical(
                                                      top: Radius.circular(16)),
                                              child: FractionallySizedBox(
                                                heightFactor: 0.8,
                                                child: CancelBookingScreen(
                                                  bookingId:
                                                      booking["bookingId"]
                                                          .replaceAll("#", ""),
                                                ),
                                              ),
                                            ),
                                          );
                                        },
                                      );
                                    },
                                  );
                                },
                              ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget bookingTab(String label, bool isUpcoming) {
    final isSelected = isUpcomingSelected == isUpcoming;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: () {
        setState(() {
          isUpcomingSelected = isUpcoming;
        });
        _fetchBookings(); // Refresh bookings
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
                ? Colors.white
                : (isDarkMode ? Colors.grey[400] : Colors.grey[600]),
          ),
        ),
      ),
    );
  }
}
