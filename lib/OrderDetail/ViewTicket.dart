import 'package:adventura/HomeControllerScreen.dart';
import 'package:flutter/material.dart';
// Import the barcode_widget package
import 'package:barcode_widget/barcode_widget.dart';

/// A page to display a ticket with a QR code (using barcode_widget) and relevant details.
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
  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDarkMode ? const Color(0xFF1F1F1F) : Colors.white,
      appBar: AppBar(
        backgroundColor: isDarkMode ? const Color(0xFF1F1F1F) : Colors.white,
        elevation: 0,
        title: Text(
          "View Ticket",
          style: TextStyle(
            color: isDarkMode ? Colors.white : Colors.black,
            fontFamily: "Poppins",
            fontSize: screenWidth * 0.05,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back,
              color: isDarkMode ? Colors.white : Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(screenWidth * 0.05),
        child: Column(
          children: [
            // Title
            Text(
              "Scan this QR code",
              style: TextStyle(
                fontSize: screenWidth * 0.05,
                fontWeight: FontWeight.bold,
                fontFamily: "Poppins",
                color: isDarkMode ? Colors.white : Colors.black,
              ),
            ),
            SizedBox(height: screenHeight * 0.005),

            // Subtitle
            Text(
              "Point this QR to the provider's\nQR device to admit ticket",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: screenWidth * 0.035,
                color: isDarkMode ? Colors.grey[400] : Colors.grey,
                fontFamily: "Poppins",
              ),
            ),
            SizedBox(height: screenHeight * 0.03),

            // QR Code Container
            Container(
              width: screenWidth * 0.6,
              height: screenWidth * 0.6,
              decoration: BoxDecoration(
                color: isDarkMode ? const Color(0xFF2A2A2A) : Colors.grey[200],
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: isDarkMode
                        ? Colors.black.withOpacity(0.2)
                        : Colors.black12,
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Center(
                child: BarcodeWidget(
                  barcode: Barcode.qrCode(),
                  data: ticketId,
                  width: screenWidth * 0.45,
                  height: screenWidth * 0.45,
                ),
              ),
            ),

            SizedBox(height: screenHeight * 0.03),

            _buildInfoRow("Event", eventTitle, screenWidth, isDarkMode),
            _buildInfoRow("Client name", clientName, screenWidth, isDarkMode),
            _buildInfoRow("Event time", eventTime, screenWidth, isDarkMode),
            _buildInfoRow("Number of attendees", "$numberOfAttendees",
                screenWidth, isDarkMode),
            _buildInfoRow("Ticket ID", ticketId, screenWidth, isDarkMode),

            SizedBox(height: screenHeight * 0.01),

            // Status Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Status",
                  style: TextStyle(
                    fontSize: screenWidth * 0.04,
                    fontWeight: FontWeight.bold,
                    fontFamily: "Poppins",
                    color: isDarkMode ? Colors.white : Colors.black,
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: (status == "Pending")
                        ? Colors.orange[100]
                        : Colors.green[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    status,
                    style: TextStyle(
                      fontSize: screenWidth * 0.04,
                      fontFamily: "Poppins",
                      fontWeight: FontWeight.bold,
                      color:
                          (status == "Pending") ? Colors.orange : Colors.green,
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: screenHeight * 0.03),

            // Buttons
            Row(
              children: [
                // Cancel Booking
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      // TODO: Implement cancel logic
                    },
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.red, width: 2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding:
                          EdgeInsets.symmetric(vertical: screenHeight * 0.02),
                    ),
                    child: Text(
                      "Cancel Booking",
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: screenWidth * 0.04,
                        fontFamily: "Poppins",
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 12),

                // Go to Home
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                            builder: (context) => HomeControllerScreen()),
                        (route) => false,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding:
                          EdgeInsets.symmetric(vertical: screenHeight * 0.02),
                    ),
                    child: Text(
                      "Go To Home",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: screenWidth * 0.04,
                        fontFamily: "Poppins",
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
  /// Helper method to build a row of info (label on the left, value on the right)
  Widget _buildInfoRow(String label, String value, double screenWidth, bool isDarkMode) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Label
          Text(
            label,
            style: TextStyle(
              fontSize: screenWidth * 0.04,
              fontWeight: FontWeight.bold,
              fontFamily: "Poppins",
            ),
          ),
          // Value (right-aligned)
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: screenWidth * 0.04,
                fontFamily: "Poppins",
              ),
            ),
          ),
        ],
      ),
    );
  }

