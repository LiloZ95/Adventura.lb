import 'package:adventura/HomeControllerScreen.dart';
import 'package:adventura/OrderDetail/ViewTicket.dart';
import 'package:flutter/material.dart';

class PurchaseConfirmationPage extends StatefulWidget {
  final String eventTitle;
  final String clientName;
  final String eventTime;
  final int numberOfAttendees;
  final String ticketId;
  final String status;

  const PurchaseConfirmationPage({
    Key? key,
    required this.eventTitle,
    required this.clientName,
    required this.eventTime,
    required this.numberOfAttendees,
    required this.ticketId,
    required this.status,
  }) : super(key: key);

  @override
  State<PurchaseConfirmationPage> createState() =>
      _PurchaseConfirmationPageState();
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
      duration: Duration(milliseconds: 800),
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
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDarkMode ? const Color(0xFF121212) : const Color(0xFFF6F6F6),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Center(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.08),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ScaleTransition(
                  scale: _scaleAnimation,
                  child: Container(
                    width: screenWidth * 0.25,
                    height: screenWidth * 0.25,
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
                          offset: Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.check_rounded,
                      color: Colors.white,
                      size: screenWidth * 0.15,
                    ),
                  ),
                ),
                SizedBox(height: screenHeight * 0.04),
                Text(
                  "Purchase Successful!",
                  style: TextStyle(
                    fontSize: screenWidth * 0.07,
                    fontWeight: FontWeight.bold,
                    fontFamily: "Poppins",
                    color: isDarkMode ? Colors.white : Colors.black,
                  ),
                ),
                SizedBox(height: screenHeight * 0.015),
                Text(
                  "Your tickets are confirmed.\nGet ready for an amazing experience!",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: screenWidth * 0.042,
                    fontFamily: "Poppins",
                    color: isDarkMode ? Colors.grey.shade300 : Colors.grey.shade700,
                  ),
                ),
                SizedBox(height: screenHeight * 0.05),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: Icon(
                      Icons.qr_code_rounded,
                      size: screenWidth * 0.06,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ViewTicketPage(
                            eventTitle: widget.eventTitle,
                            clientName: widget.clientName,
                            eventTime: widget.eventTime,
                            numberOfAttendees: widget.numberOfAttendees,
                            ticketId: widget.ticketId,
                            status: widget.status,
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      padding:
                          EdgeInsets.symmetric(vertical: screenHeight * 0.02),
                    ),
                    label: Text(
                      "View E-Ticket",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: screenWidth * 0.045,
                        fontFamily: "Poppins",
                      ),
                    ),
                  ),
                ),
                SizedBox(height: screenHeight * 0.02),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    icon: Icon(Icons.home_rounded,
                        color: Colors.blue, size: screenWidth * 0.06),
                    onPressed: () {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                            builder: (_) => HomeControllerScreen()),
                        (route) => false,
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Colors.blue, width: 2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      padding:
                          EdgeInsets.symmetric(vertical: screenHeight * 0.02),
                    ),
                    label: Text(
                      "Go To Home",
                      style: TextStyle(
                        color: Colors.blue,
                        fontSize: screenWidth * 0.045,
                        fontFamily: "Poppins",
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
