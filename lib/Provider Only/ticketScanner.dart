
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class TicketScanner extends StatefulWidget {
  @override
  _TicketScannerState createState() => _TicketScannerState();
}

class _TicketScannerState extends State<TicketScanner> {
  String scannedData = "No QR Code Scanned"; // Stores scanned QR code data
  String eventName = "Hardine Village Hike";
  String clientName = "Khalil Kurdi";
  String eventTime = "08:30 AM";
  int numberOfAttendees = 3;
  String ticketID = "AZT EKC BWS 1900";
  String status = "Complete"; // Possible values: Complete, Pending, Denied

  bool hasScanned = false;

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Scan QR Ticket',
          style: TextStyle(
            fontFamily: "Poppins",
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 10),
            // Scan QR Code Title
            Text(
              "Scan Client’s QR Code",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                fontFamily: 'Poppins',
              ),
            ),
            SizedBox(height: 5),
            Text(
              "Point your camera to the client’s QR ticket to admit ticket",
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
                fontFamily: 'Poppins',
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),

            // Live QR Code Scanner Box using mobile_scanner
            Container(
              width: screenWidth * 0.7,
              height: screenWidth * 0.7,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black, width: 2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: MobileScanner(
  controller: MobileScannerController(),
  onDetect: (BarcodeCapture capture) {
    final barcode = capture.barcodes.first;
    if (!hasScanned && barcode.rawValue != null) {
      setState(() {
        scannedData = barcode.rawValue!;
        hasScanned = true;
      });
    }
  },
)
              ),
            ),

            SizedBox(height: 20),
            Text(
              "Scanned Data: $scannedData",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),

            Spacer(),

            // Ticket Details
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDetailRow("Event", eventName),
                _buildDetailRow("Client name", clientName),
                _buildDetailRow("Event time", eventTime),
                _buildDetailRow("Number of attendees", numberOfAttendees.toString()),
                _buildDetailRow("Ticket ID", ticketID),
                Row(
                  children: [
                    Text(
                      "Status",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(width: 10),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: status == "Complete"
                            ? Colors.green
                            : status == "Pending"
                                ? Colors.orange
                                : Colors.red,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        status,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),

            Spacer(),

            // Action Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      // Report Client Functionality
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      padding: EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: Text(
                      'Report Client',
                      style: TextStyle(fontSize: 16, fontFamily: 'Poppins'),
                    ),
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        hasScanned = false;
                        scannedData = "No QR Code Scanned";
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      padding: EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: Text(
                      'Scan new ticket',
                      style: TextStyle(fontSize: 16, fontFamily: 'Poppins'),
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

  // Helper function for ticket details
  Widget _buildDetailRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              fontFamily: 'Poppins',
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontFamily: 'Poppins',
            ),
          ),
        ],
      ),
    );
  }
}
