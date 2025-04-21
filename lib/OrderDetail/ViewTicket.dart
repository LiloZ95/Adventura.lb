import 'package:adventura/web/homeweb.dart';
import 'package:flutter/material.dart';
import 'package:adventura/Main%20screen%20components/MainScreen.dart';
import 'package:barcode_widget/barcode_widget.dart';

/// A page to display a ticket with a QR code (using barcode_widget) and relevant details.
/// Optimized for web display.
class ViewTicketPage extends StatelessWidget {
  final String eventTitle;
  final String clientName;
  final String eventTime;
  final int numberOfAttendees;
  final String ticketId;
  final String status;

  const ViewTicketPage({
    Key? key,
    required this.eventTitle,
    required this.clientName,
    required this.eventTime,
    required this.numberOfAttendees,
    required this.ticketId,
    required this.status,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Using MediaQuery to make the UI responsive for web
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isDesktop = screenWidth > 1024;
    final bool isTablet = screenWidth > 768 && screenWidth <= 1024;
    
    // Calculate appropriate container width based on screen size
    final double containerWidth = isDesktop 
        ? 600 
        : isTablet 
            ? screenWidth * 0.8 
            : screenWidth * 0.95;
    
    // Calculate appropriate font and element sizes for web
    final double titleSize = isDesktop ? 24 : isTablet ? 22 : 20;
    final double subtitleSize = isDesktop ? 16 : isTablet ? 14 : 13;
    final double labelSize = isDesktop ? 16 : isTablet ? 15 : 14;
    final double valueSize = isDesktop ? 16 : isTablet ? 15 : 14;
    final double buttonTextSize = isDesktop ? 16 : isTablet ? 15 : 14;
    
    // QR code size based on screen type
    final double qrSize = isDesktop ? 220 : isTablet ? 180 : 150;
    final double qrContainerSize = qrSize * 1.25;

    return Scaffold(
      backgroundColor: Colors.white,
      
      // AppBar with a centered title
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          "View Ticket",
          style: TextStyle(
            color: Colors.black,
            fontFamily: "Poppins",
            fontSize: titleSize,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),

      // Main content
      body: Center(
        child: Container(
          width: containerWidth,
          padding: const EdgeInsets.all(24),
          decoration: isDesktop ? BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ) : null,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Title
                Text(
                  "Scan this QR code",
                  style: TextStyle(
                    fontSize: titleSize,
                    fontWeight: FontWeight.bold,
                    fontFamily: "Poppins",
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 8),

                // Subtitle
                Text(
                  "Point this QR to the provider's\nQR device to admit ticket",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: subtitleSize,
                    color: Colors.grey,
                    fontFamily: "Poppins",
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 24),

                // Container wrapping BarcodeWidget
                Container(
                  width: qrContainerSize,
                  height: qrContainerSize,
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Center(
                    // BarcodeWidget from the barcode_widget package
                    child: BarcodeWidget(
                      barcode: Barcode.qrCode(),
                      data: ticketId,
                      width: qrSize,
                      height: qrSize,
                      drawText: false,
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                // Ticket Details Container
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Column(
                    children: [
                      _buildInfoRow("Event", eventTitle, labelSize, valueSize),
                      _buildInfoRow("Client name", clientName, labelSize, valueSize),
                      _buildInfoRow("Event time", eventTime, labelSize, valueSize),
                      _buildInfoRow("Number of attendees", "$numberOfAttendees", labelSize, valueSize),
                      _buildInfoRow("Ticket ID", ticketId, labelSize, valueSize),

                      // Status row with colored background
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Status",
                            style: TextStyle(
                              fontSize: labelSize,
                              fontWeight: FontWeight.bold,
                              fontFamily: "Poppins",
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: (status == "Pending")
                                  ? Colors.orange[100]
                                  : Colors.green[100],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              status,
                              style: TextStyle(
                                fontSize: valueSize,
                                fontFamily: "Poppins",
                                fontWeight: FontWeight.bold,
                                color: (status == "Pending") ? Colors.orange[700] : Colors.green[700],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 32),

                // Bottom Buttons: "Cancel Booking" & "Go To Home"
                Row(
                  children: [
                    // Cancel Booking Button (Outlined)
                    Expanded(
                      child: MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: OutlinedButton(
                          onPressed: () {
                            // TODO: Implement cancel booking logic
                          },
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Colors.red, width: 2),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: Text(
                            "Cancel Booking",
                            style: TextStyle(
                              color: Colors.red,
                              fontSize: buttonTextSize,
                              fontFamily: "Poppins",
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),

                    // Go To Home Button (Filled)
                    Expanded(
                      child: MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: ElevatedButton(
                          onPressed: () {
                            // Navigate to home screen
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                builder: (context) => AdventuraWebHomee()
                              ),
                              (route) => false,
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
                          child: Text(
                            "Go To Home",
                            style: TextStyle(
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
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Helper method to build a row of info (label on the left, value on the right)
  Widget _buildInfoRow(String label, String value, double labelSize, double valueSize) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Label
          Text(
            label,
            style: TextStyle(
              fontSize: labelSize,
              fontWeight: FontWeight.bold,
              fontFamily: "Poppins",
              color: Colors.black87,
            ),
          ),
          // Value (right-aligned)
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: valueSize,
                fontFamily: "Poppins",
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }
}