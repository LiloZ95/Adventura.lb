import 'dart:async';
import 'dart:ui';
import 'package:adventura/Booking/CancelBooking.dart';
import 'package:adventura/colors.dart';
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
  bool isLoading = false;
  List<Map<String, dynamic>> bookings = [];
  int itemsPerPage = 8; // Default for mobile
  int currentPage = 1;
  
  // Filter functionality
  String filterBy = 'pending';

  @override
  void initState() {
    super.initState();
    _fetchBookings();
  }

  Future<void> _fetchBookings() async {
    setState(() {
      isLoading = true;
    });
    
    final box = await Hive.openBox('authBox');
    final clientId = int.tryParse(box.get('userId') ?? '');
    print("📦 Logged-in client ID: $clientId");

    if (clientId == null) {
      print("❌ No valid user ID");
      setState(() {
        isLoading = false;
      });
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
      isLoading = false;
    });

    print("🎯 Final bookings: $bookings");
  }

  // Get filtered bookings based on filters
  List<Map<String, dynamic>> get filteredBookings {
    return bookings.where((booking) {
      // Filter by status
      bool matchesStatus = isUpcomingSelected 
          ? booking["status"] == "Upcoming" 
          : booking["status"] == "Past";
          
      // Apply additional filter if needed
      bool matchesFilter = booking["raw_status"].toLowerCase() == filterBy.toLowerCase();
          
      return matchesStatus && matchesFilter;
    }).toList();
  }

  // Get current page items
  List<Map<String, dynamic>> get paginatedBookings {
    final startIndex = (currentPage - 1) * itemsPerPage;
    final endIndex = startIndex + itemsPerPage;
    
    if (startIndex >= filteredBookings.length) {
      return [];
    }
    
    return filteredBookings.sublist(
      startIndex, 
      endIndex > filteredBookings.length ? filteredBookings.length : endIndex
    );
  }
  
  // Calculate total pages
  int get totalPages => (filteredBookings.length / itemsPerPage).ceil();

  @override
  Widget build(BuildContext context) {
    double statusBarHeight = MediaQuery.of(context).padding.top;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    // Determine if we're on a large screen (tablet/desktop)
    final isLargeScreen = MediaQuery.of(context).size.width > 1000;
    final isMediumScreen = MediaQuery.of(context).size.width > 600 && MediaQuery.of(context).size.width <= 1000;
    
    // Adjust items per page based on screen size
    if (isLargeScreen && itemsPerPage != 12) {
      setState(() {
        itemsPerPage = 12;
      });
    } else if (isMediumScreen && itemsPerPage != 8) {
      setState(() {
        itemsPerPage = 8;
      });
    } else if (!isLargeScreen && !isMediumScreen && itemsPerPage != 4) {
      setState(() {
        itemsPerPage = 4;
      });
    }
    
    return Scaffold(
      backgroundColor: isDarkMode ? Color(0xFF1F1F1F) : Colors.grey[50],
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // App Bar
            SliverAppBar(
              floating: true,
              pinned: true,
              elevation: 0,
              backgroundColor: isDarkMode ? Color(0xFF1F1F1F) : Colors.white,
              expandedHeight: 70,
              flexibleSpace: FlexibleSpaceBar(
                titlePadding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              ),
            ),
            
            // Main Content
            SliverPadding(
              padding: EdgeInsets.only(left: isLargeScreen ? 24 : 16, right: isLargeScreen ? 24 : 16, bottom: isLargeScreen ? 24 : 16),
              sliver: SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Create responsive layout
                    LayoutBuilder(
                      builder: (context, constraints) {
                        return Container(
                          width: isLargeScreen 
                              ? constraints.maxWidth * 0.8
                              : constraints.maxWidth,
                          margin: isLargeScreen 
                              ? EdgeInsets.symmetric(horizontal: constraints.maxWidth * 0.1)
                              : EdgeInsets.zero,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              
                              // Booking tab
                              Container(
                                height: 50,
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
                              SizedBox(height: 24),
                              
                              // Section title with count
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    isUpcomingSelected
                                        ? 'Upcoming Bookings'
                                        : 'Past Bookings',
                                    style: TextStyle(
                                      fontSize: isLargeScreen ? 24 : 20,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'Poppins',
                                      color: isDarkMode ? Colors.white : Colors.black,
                                    ),
                                  ),
                                  Text(
                                    '${filteredBookings.length} ${filteredBookings.length == 1 ? 'booking' : 'bookings'}',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 16),
                              
                              // Booking Grid/List
                              isLoading
                                  ? Center(
                                      child: CircularProgressIndicator(),
                                    )
                                  : filteredBookings.isEmpty
                                      ? _buildEmptyState(isDarkMode)
                                      : _buildBookingsList(isLargeScreen, isMediumScreen, isDarkMode),
                              
                              // Pagination controls
                              if (filteredBookings.isNotEmpty)
                                _buildPaginationControls(isDarkMode),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool isDarkMode) {
    return Container(
      height: 300,
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.event_busy,
            size: 80,
            color: isDarkMode ? Colors.grey[600] : Colors.grey[400],
          ),
          SizedBox(height: 24),
          Text(
            "No bookings found",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              fontFamily: 'Poppins',
              color: isDarkMode ? Colors.white : Colors.black,
            ),
          ),
          SizedBox(height: 8),
          Text(
            filterBy != 'pending'
                ? "Try adjusting your filters"
                : "You don't have any ${isUpcomingSelected ? 'upcoming' : 'past'} bookings yet",
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
              fontFamily: 'Poppins',
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 24),
          if (filterBy != 'pending')
            ElevatedButton.icon(
              icon: Icon(Icons.clear),
              label: Text("Clear Filters"),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.blue,
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () {
                setState(() {
                  filterBy = 'pending';
                });
              },
            ),
        ],
      ),
    );
  }

  Widget _buildBookingsList(bool isLargeScreen, bool isMediumScreen, bool isDarkMode) {
    return Container(
      child: isLargeScreen || isMediumScreen
          ? GridView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: isLargeScreen ? 2 : 1,
                childAspectRatio: isLargeScreen ? 2.2 : 1.8,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: paginatedBookings.length,
              itemBuilder: (context, index) {
                final booking = paginatedBookings[index];
                return _buildBookingCard(booking, isDarkMode);
              },
            )
          : ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: paginatedBookings.length,
              itemBuilder: (context, index) {
                final booking = paginatedBookings[index];
                return Padding(
                  padding: EdgeInsets.only(bottom: 16),
                  child: _buildBookingCard(booking, isDarkMode),
                );
              },
            ),
    );
  }

  Widget _buildBookingCard(Map<String, dynamic> booking, bool isDarkMode) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: BookingCard(
        activity: booking["activity"],
        bookingId: booking["bookingId"],
        guests: booking["guests"],
        status: booking["raw_status"],
        isUpcoming: booking["status"] == "Upcoming",
        onCancel: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            barrierColor: Colors.black.withOpacity(0.25),
            builder: (context) {
              return BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 15.0, sigmaY: 15.0),
                child: Dialog(
                  backgroundColor: Colors.white.withOpacity(0.95),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Container(
                    width: MediaQuery.of(context).size.width > 600 
                        ? 500 
                        : MediaQuery.of(context).size.width * 0.9,
                    child: CancelBookingScreen(
                      bookingId: booking["bookingId"].replaceAll("#", ""),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildPaginationControls(bool isDarkMode) {
    return Container(
      margin: EdgeInsets.only(top: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
        
          ...List.generate(
            totalPages,
            (index) => Container(
              margin: EdgeInsets.symmetric(horizontal: 4),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: currentPage == index + 1
                      ? AppColors.blue
                      : (isDarkMode ? Color(0xFF2C2C2C) : Colors.grey[200]),
                  shape: CircleBorder(),
                  minimumSize: Size(40, 40),
                ),
                onPressed: () {
                  setState(() {
                    currentPage = index + 1;
                  });
                },
                child: Text(
                  '${index + 1}',
                  style: TextStyle(
                    color: currentPage == index + 1
                        ? Colors.white
                        : (isDarkMode ? Colors.white : Colors.black),
                  ),
                ),
              ),
            ),
          ),
          IconButton(
            icon: Icon(Icons.arrow_forward_ios),
            onPressed: currentPage < totalPages
                ? () {
                    setState(() {
                      currentPage++;
                    });
                  }
                : null,
            color: currentPage < totalPages
                ? (isDarkMode ? Colors.white : Colors.black)
                : Colors.grey,
          ),
        ],
      ),
    );
  }

  Widget bookingTab(String label, bool isUpcoming) {
    final isSelected = isUpcomingSelected == isUpcoming;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {
          setState(() {
            isUpcomingSelected = isUpcoming;
            currentPage = 1; // Reset to first page when changing tabs
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
              fontSize: 18,
              fontWeight: FontWeight.w600,
              fontFamily: 'Poppins',
              color: isSelected
                  ? Colors.white
                  : (isDarkMode ? Colors.grey[400] : Colors.grey[600]),
            ),
          ),
        ),
      ),
    );
  }
}