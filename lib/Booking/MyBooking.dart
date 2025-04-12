import 'package:adventura/Booking/CancelBooking.dart';
import 'package:adventura/Main%20screen%20components/MainScreen.dart';
import 'package:adventura/colors.dart';
import 'package:adventura/search%20screen/searchScreen.dart';
import 'package:flutter/material.dart';
import 'package:adventura/widgets/booking_card.dart';
import 'package:adventura/Services/booking_service.dart';
import 'package:hive/hive.dart';

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

class MyBookingsPage extends StatefulWidget {
  const MyBookingsPage({Key? key}) : super(key: key);

  @override
  _MyBookingsPageState createState() => _MyBookingsPageState();
}

int selectedRating = 0;
bool isUpcomingSelected = true;

class _MyBookingsPageState extends State<MyBookingsPage> {
  bool isLoading = false;

  List<Map<String, dynamic>> bookings = [];

  @override
  void initState() {
    super.initState();
    _fetchBookings();
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
                "raw_status": b["status"], // 👈 for actual status badge display
              })
          .toList();
    });

    print("🎯 Final bookings: $bookings");
  }

  @override
  Widget build(BuildContext context) {
    double statusBarHeight = MediaQuery.of(context).padding.top;
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
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
                  child: isLoading
                      ? Center(child: CircularProgressIndicator())
                      : bookings.isEmpty
                          ? Center(
                              child: Text(
                                "No bookings found.",
                                style: TextStyle(
                                    fontSize: 16, fontFamily: 'Poppins'),
                              ),
                            )
                          : ListView.builder(
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
                                  // still used for coloring
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
                )
              ],
            ),
          ),

          // 🔥 Bottom Nav Bar — Positioned same as MainScreen
          Positioned(
            bottom: 25,
            left: (screenWidth * 0.035),
            child: Container(
              width: screenWidth * 0.93,
              height: 65,
              decoration: BoxDecoration(
                color: const Color(0xFF1B1B1B),
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.70),
                    offset: Offset(0, 1),
                    blurRadius: 5,
                    spreadRadius: 0,
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => MainScreen()));
                    },
                    icon: Image.asset(
                      'assets/Icons/home.png',
                      width: 35,
                      height: 35,
                      color: Colors.grey,
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => SearchScreen()));
                    },
                    icon: Image.asset(
                      'assets/Icons/search.png',
                      width: 35,
                      height: 35,
                      color: Colors.grey,
                    ),
                  ),
                  IconButton(
                    onPressed: () {},
                    icon: Image.asset(
                      'assets/Icons/ticket.png',
                      width: 35,
                      height: 35,
                      color: Colors.white, // Active Icon
                    ),
                  ),
                  IconButton(
                    onPressed: () {},
                    icon: Image.asset(
                      'assets/Icons/bookmark.png',
                      width: 35,
                      height: 35,
                      color: Colors.grey,
                    ),
                  ),
                  IconButton(
                    onPressed: () {},
                    icon: Image.asset(
                      'assets/Icons/paper-plane.png',
                      width: 35,
                      height: 35,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
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
        _fetchBookings(); // 💡 Refetch filtered data
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
