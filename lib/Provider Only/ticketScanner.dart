import 'dart:convert';
import 'package:adventura/config.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mobile_scanner/mobile_scanner.dart';

class TicketScanner extends StatefulWidget {
  @override
  _TicketScannerState createState() => _TicketScannerState();
}

class _TicketScannerState extends State<TicketScanner> {
  String scannedData = "No QR Code Scanned";
  String eventName = "-";
  String clientName = "-";
  String eventTime = "-";
  String ticketID = "-";
  String status = "-";
  bool hasScanned = false;

  Future<void> fetchBookingByQR(String bookingId) async {
    try {
      final url = Uri.parse(
          '$baseUrl/booking/scan/$bookingId'); // 🧠 Replace with your actual IP:PORT

      final res = await http.get(url);
      if (res.statusCode == 200) {
        final data = json.decode(res.body);
        setState(() {
          eventName = data['event_name'];
          clientName = data['client_name'];
          eventTime = data['event_time'];
          ticketID = "AZT BWS ${data['booking_id']}";
          status = data['status'];
          scannedData = bookingId;
          hasScanned = true;
        });
      } else {
        showError("❌ Booking not found");
      }
    } catch (e) {
      print("Error fetching booking: $e");
      showError("🚨 Network error");
    }
  }

  void showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;


return  Scaffold(
  backgroundColor: isDarkMode ? Color(0xFF1F1F1F) : Colors.white,
  appBar: AppBar(
    backgroundColor:
        isDarkMode ? Colors.transparent : const Color(0xFFF6F6F6),
    elevation: 1,
    leading: IconButton(
      icon: Icon(Icons.arrow_back,
          color: isDarkMode ? Colors.white : Colors.black),
      onPressed: () => Navigator.pop(context),
    ),
    title: Text(
      'Scan QR Ticket',
      style: TextStyle(
        fontFamily: "Poppins",
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: isDarkMode ? Colors.white : const Color(0xff121212),
      ),
    ),
    centerTitle: true,
  ),
  body: Padding(
    padding: const EdgeInsets.all(16.0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          "Scan Client’s QR Code",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            fontFamily: 'Poppins',
            color: isDarkMode ? Colors.white : Colors.black,
          ),
        ),
        SizedBox(height: 5),
        Text(
          "Point your camera to the client’s QR ticket to admit ticket",
          style: TextStyle(
            fontSize: 14,
            color: isDarkMode ? Colors.grey[400] : Colors.grey[700],
            fontFamily: 'Poppins',
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 20),
        Container(
          width: screenWidth * 0.7,
          height: screenWidth * 0.7,
          decoration: BoxDecoration(
            border: Border.all(
                color: isDarkMode ? Colors.white70 : Colors.black, width: 2),
            borderRadius: BorderRadius.circular(10),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: MobileScanner(
              controller: MobileScannerController(),
              onDetect: (BarcodeCapture capture) {
                final barcode = capture.barcodes.first;
                final qrValue = barcode.rawValue;
                if (!hasScanned && qrValue != null) {
                  final cleanedId = qrValue.replaceAll('#', '');
                  fetchBookingByQR(cleanedId);
                }
              },
            ),
          ),
        ),
        SizedBox(height: 20),
        Text(
          "Scanned Booking ID: $scannedData",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.blue,
            fontFamily: 'Poppins',
          ),
        ),
        if (hasScanned && status == "pending")
          Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: ElevatedButton.icon(
              onPressed: () async {
                final updateUrl = Uri.parse('$baseUrl/booking/status/$scannedData');
                final res = await http.put(
                  updateUrl,
                  headers: {'Content-Type': 'application/json'},
                  body: jsonEncode({'status': 'confirmed'}),
                );

                if (res.statusCode == 200) {
                  setState(() {
                    status = 'confirmed';
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("✅ Ticket marked as confirmed")),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("❌ Failed to update status"),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              icon: Icon(Icons.check_circle_outline, color: Colors.white),
              label: Text("Mark as Confirmed"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
        Spacer(),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow("Event", eventName, isDarkMode),
            _buildDetailRow("Client", clientName, isDarkMode),
            _buildDetailRow("Event Time", eventTime, isDarkMode),
            _buildDetailRow("Ticket ID", ticketID, isDarkMode),
            Row(
              children: [
                Text(
                  "Status",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Poppins',
                    color: isDarkMode ? Colors.white : Colors.black,
                  ),
                ),
                SizedBox(width: 10),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: status == "confirmed"
                        ? Colors.green
                        : status == "pending"
                            ? Colors.orange
                            : Colors.red,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    status.toUpperCase(),
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        Spacer(),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  // Block/report client logic
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 12),
                ),
                child: Text(
                  'Report Client',
                  style: TextStyle(
                    fontSize: 16,
                    fontFamily: 'Poppins',
                    color: Colors.white,
                  ),
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
                    eventName = "-";
                    clientName = "-";
                    eventTime = "-";
                    ticketID = "-";
                    status = "-";
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 12),
                ),
                child: Text(
                  'Scan New Ticket',
                  style: TextStyle(
                    fontSize: 16,
                    fontFamily: 'Poppins',
                    color: Colors.white,
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

  Widget _buildDetailRow(String title, String value, bool isDarkMode) {
        final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title,
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Poppins')),
          Text(value, style: TextStyle(fontSize: 16, fontFamily: 'Poppins')),
        ],
      ),
    );
  }
}
