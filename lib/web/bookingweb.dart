import 'package:flutter/material.dart';
import 'package:adventura/widgets/bookingContent_web.dart';

class WebBookingsPage extends StatefulWidget {
  const WebBookingsPage({Key? key}) : super(key: key);

  @override
  State<WebBookingsPage> createState() => _WebBookingsPageState();
}

class _WebBookingsPageState extends State<WebBookingsPage> {
  bool isUpcomingSelected = true;

  List<Map<String, dynamic>> bookings = [

  ];

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final bool isMobile = screenWidth < 768;
    final bool isTablet = screenWidth >= 768 && screenWidth < 1200;
    final bool isDesktop = screenWidth >= 1200;

    return BookingContentWidget(
      isUpcomingSelected: isUpcomingSelected,
      onToggleBookingType: (value) {
        setState(() {
          isUpcomingSelected = value;
        });
      },
      bookings: bookings,
      isMobile: isMobile,
      isTablet: isTablet,
      isDesktop: isDesktop,
    );
  }
}
