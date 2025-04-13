import 'package:adventura/colors.dart';
import 'package:flutter/material.dart';

class BookingContentWidget extends StatelessWidget {
  final bool isUpcomingSelected;
  final Function(bool) onToggleBookingType;
  final List<Map<String, dynamic>> bookings;
  final bool isMobile;
  final bool isTablet;
  final bool isDesktop;

  const BookingContentWidget({
    Key? key,
    required this.isUpcomingSelected,
    required this.onToggleBookingType,
    required this.bookings,
    required this.isMobile,
    required this.isTablet, 
    required this.isDesktop,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 16 : isTablet ? 32 : 64,
        vertical: 32,
      ),
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Center(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: 1200,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Your Reservations",
                    style: TextStyle(
                      height: 0.96,
                      fontSize: isMobile ? 28 : 36,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Poppins',
                      color: Colors.black,
                    ),
                  ),
                  
                  SizedBox(height: 24),
                  
                  // Toggle Section (Upcoming / Past)
                  Container(
                    height: 40,
                    width: isDesktop ? 300 : isMobile ? double.infinity : 400,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF2F3F4),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: _buildBookingTab("Upcoming", true),
                        ),
                        Expanded(
                          child: _buildBookingTab("Past", false),
                        ),
                      ],
                    ),
                  ),
                  
                  SizedBox(height: 20),
                  
                  Text(
                    isUpcomingSelected ? 'Upcoming Bookings' : 'Past Bookings',
                    style: TextStyle(
                      fontSize: isMobile ? 16 : 18,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Poppins',
                    ),
                  ),
                  
                  SizedBox(height: 20),
                  
                  // Booking List
                  isDesktop 
                      ? _buildDesktopBookingList()
                      : isTablet 
                          ? _buildTabletBookingList()
                          : _buildMobileBookingList(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookingTab(String label, bool isUpcoming) {
    bool isSelected = isUpcomingSelected == isUpcoming;
    return GestureDetector(
      onTap: () {
        onToggleBookingType(isUpcoming);
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

  Widget _buildDesktopBookingList() {
    return Container(
      constraints: BoxConstraints(maxWidth: 1200),
      child: Column(
        children: [
          for (var booking in bookings)
            _buildWebBookingCard(booking, true),
        ],
      ),
    );
  }

  Widget _buildTabletBookingList() {
    return Container(
      width: double.infinity,
      child: Column(
        children: [
          for (var booking in bookings)
            _buildWebBookingCard(booking, false),
        ],
      ),
    );
  }

  Widget _buildMobileBookingList() {
    return Container(
      width: double.infinity,
      child: Column(
        children: [
          for (var booking in bookings)
            _buildMobileBookingCard(booking),
        ],
      ),
    );
  }

  Widget _buildWebBookingCard(Map<String, dynamic> booking, bool isDesktop) {
    return Container(
      margin: EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 1,
          ),
        ],
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Image
            ClipRRect(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16),
                bottomLeft: Radius.circular(16),
              ),
              child: Image.asset(
                booking["activity"]["activity_images"][0],
                width: isDesktop ? 300 : 200,
                height: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            
            // Content
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                booking["activity"]["name"],
                                style: TextStyle(
                                  fontSize: isDesktop ? 24 : 20,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Poppins',
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                booking["activity"]["location"],
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey[700],
                                  fontFamily: 'Poppins',
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.blue.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            booking["bookingId"],
                            style: TextStyle(
                              color: AppColors.blue,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Poppins',
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    Row(
                      children: [
                        Icon(Icons.calendar_today, size: 18, color: Colors.grey[600]),
                        SizedBox(width: 8),
                        Text(
                          booking["activity"]["date"],
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            color: Colors.grey[800],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.people, size: 18, color: Colors.grey[600]),
                        SizedBox(width: 8),
                        Text(
                          booking["guests"],
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            color: Colors.grey[800],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.attach_money, size: 18, color: Colors.grey[600]),
                        SizedBox(width: 8),
                        Text(
                          "\$${booking["activity"]["price"]} per person",
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            color: Colors.grey[800],
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        OutlinedButton(
                          onPressed: () {
                            // View details logic
                          },
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: AppColors.blue),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          ),
                          child: Text(
                            "View Details",
                            style: TextStyle(
                              color: AppColors.blue,
                              fontFamily: 'Poppins',
                            ),
                          ),
                        ),
                        SizedBox(width: 12),
                        ElevatedButton(
                          onPressed: () {
                            // Show cancel booking modal
                            _showCancelBookingModal(booking);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          ),
                          child: Text(
                            "Cancel Booking",
                            style: TextStyle(
                              color: Colors.white,
                              fontFamily: 'Poppins',
                            ),
                          ),
                        ),
                      ],
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

  Widget _buildMobileBookingCard(Map<String, dynamic> booking) {
    return Container(
      margin: EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Image
          ClipRRect(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
            ),
            child: Image.asset(
              booking["activity"]["activity_images"][0],
              height: 180,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          
          // Content
          Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            booking["activity"]["name"],
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Poppins',
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            booking["activity"]["location"],
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[700],
                              fontFamily: 'Poppins',
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.blue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        booking["bookingId"],
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.blue,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12),
                Row(
                  children: [
                    Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
                    SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        booking["activity"]["date"],
                        style: TextStyle(
                          fontSize: 13,
                          fontFamily: 'Poppins',
                          color: Colors.grey[800],
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 6),
                Row(
                  children: [
                    Icon(Icons.people, size: 16, color: Colors.grey[600]),
                    SizedBox(width: 6),
                    Text(
                      booking["guests"],
                      style: TextStyle(
                        fontSize: 13,
                        fontFamily: 'Poppins',
                        color: Colors.grey[800],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 6),
                Row(
                  children: [
                    Icon(Icons.attach_money, size: 16, color: Colors.grey[600]),
                    SizedBox(width: 6),
                    Text(
                      "\$${booking["activity"]["price"]} per person",
                      style: TextStyle(
                        fontSize: 13,
                        fontFamily: 'Poppins',
                        color: Colors.grey[800],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          // View details logic
                        },
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: AppColors.blue),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: EdgeInsets.symmetric(vertical: 10),
                        ),
                        child: Text(
                          "View Details",
                          style: TextStyle(
                            color: AppColors.blue,
                            fontFamily: 'Poppins',
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          // Show cancel booking modal
                          _showCancelBookingModal(booking);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: EdgeInsets.symmetric(vertical: 10),
                        ),
                        child: Text(
                          "Cancel",
                          style: TextStyle(
                            color: Colors.white,
                            fontFamily: 'Poppins',
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showCancelBookingModal(Map<String, dynamic> booking) {
    // We will just define this method signature here
    // Implementation would use context which we don't have direct access to
    // You would implement this in the actual page widget
  }
}