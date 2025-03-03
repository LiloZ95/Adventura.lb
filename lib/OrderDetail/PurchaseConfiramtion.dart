import 'package:adventura/OrderDetail/ViewTicket.dart';
import 'package:flutter/material.dart';
import 'package:adventura/Main%20screen%20components/MainScreen.dart';
// import 'package:adventura/somewhere/ETicketPage.dart';
// ^ Uncomment and update if you have an E-Ticket page

class PurchaseConfirmationPage extends StatelessWidget {
  const PurchaseConfirmationPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Get screen dimensions for responsiveness
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.06),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Circular checkmark icon
              Container(
                width: screenWidth * 0.2,
                height: screenWidth * 0.2,
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.check,
                  color: Colors.green,
                  size: screenWidth * 0.13,
                ),
              ),
              SizedBox(height: screenHeight * 0.03),

              // Congratulations Title
              Text(
                "Congratulations!",
                style: TextStyle(
                  fontSize: screenWidth * 0.07,
                  fontWeight: FontWeight.bold,
                  fontFamily: "Poppins",
                  color: Colors.black,
                ),
              ),
              SizedBox(height: screenHeight * 0.01),

              // Subtitle
              Text(
                "You have successfully acquired your tickets.\nEnjoy your time!",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: screenWidth * 0.04,
                  fontFamily: "Poppins",
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: screenHeight * 0.04),

              // "View E-Ticket" button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
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
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding:
                        EdgeInsets.symmetric(vertical: screenHeight * 0.02),
                  ),
                  child: Text(
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

              // "Go To Home" button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    // Navigate back to home (MainScreen)
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => MainScreen()),
                      (route) => false, // Clears entire navigation stack
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    side: BorderSide(color: Colors.blue, width: 2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding:
                        EdgeInsets.symmetric(vertical: screenHeight * 0.02),
                  ),
                  child: Text(
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
    );
  }
}
