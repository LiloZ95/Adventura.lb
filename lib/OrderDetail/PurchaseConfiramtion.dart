import 'package:adventura/OrderDetail/ViewTicket.dart';
import 'package:adventura/web/homeweb.dart';
import 'package:flutter/material.dart';
import 'package:adventura/Main%20screen%20components/MainScreen.dart';

class PurchaseConfirmationPage extends StatefulWidget {
  const PurchaseConfirmationPage({Key? key, required bookingId}) : super(key: key);

  @override
  State<PurchaseConfirmationPage> createState() => _PurchaseConfirmationPageState();
}

class _PurchaseConfirmationPageState extends State<PurchaseConfirmationPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _scaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Using MediaQuery to make the UI responsive for web
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isDesktop = screenWidth > 1024;
    final bool isTablet = screenWidth > 768 && screenWidth <= 1024;
    
    // Calculate container width based on screen size
    final double containerWidth = isDesktop 
        ? 500 
        : isTablet 
            ? screenWidth * 0.7 
            : screenWidth * 0.9;

    // Calculate appropriate font and icon sizes for web
    final double headingSize = isDesktop ? 32 : isTablet ? 28 : 24;
    final double subtitleSize = isDesktop ? 16 : isTablet ? 14 : 13;
    final double buttonTextSize = isDesktop ? 16 : isTablet ? 15 : 14;
    final double iconSize = isDesktop ? 64 : isTablet ? 56 : 48;
    final double successIconSize = isDesktop ? 100 : isTablet ? 90 : 80;

    return Scaffold(
      backgroundColor: Colors.white,
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Center(
          child: Container(
            width: containerWidth,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ScaleTransition(
                  scale: _scaleAnimation,
                  child: Container(
                    width: successIconSize,
                    height: successIconSize,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.green.shade400, Colors.green.shade600],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.green.withOpacity(0.4),
                          blurRadius: 12,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.check_rounded,
                      color: Colors.white,
                      size: iconSize,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  "Purchase Successful!",
                  style: TextStyle(
                    fontSize: headingSize,
                    fontWeight: FontWeight.bold,
                    fontFamily: "Poppins",
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  "Your tickets are confirmed.\nGet ready for an amazing experience!",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: subtitleSize,
                    fontFamily: "Poppins",
                    color: Colors.grey.shade700,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 36),
                // Web-optimized buttons with hover effects
                MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: Icon(
                        Icons.qr_code_rounded,
                        size: buttonTextSize + 4,
                        color: Colors.white,
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ViewTicketPage(
                              eventTitle: "Hardine Village Hike",
                              clientName: "Khalil Kurdi",
                              eventTime: "08:30 AM",
                              numberOfAttendees: 3,
                              ticketId: "20025PP296",
                              status: "Pending",
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      label: Text(
                        "View E-Ticket",
                        style: TextStyle(
                          fontSize: buttonTextSize,
                          fontFamily: "Poppins",
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      icon: Icon(
                        Icons.home_rounded,
                        color: Colors.blue,
                        size: buttonTextSize + 4,
                      ),
                      onPressed: () {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AdventuraWebHomee()
                          ),
                          (route) => false,
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.blue, width: 2),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      label: Text(
                        "Go To Home",
                        style: TextStyle(
                          color: Colors.blue,
                          fontSize: buttonTextSize,
                          fontFamily: "Poppins",
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}