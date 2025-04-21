import 'dart:convert';

import 'package:adventura/config.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class CancelBookingScreen extends StatefulWidget {
  final String bookingId;
  const CancelBookingScreen({Key? key, required this.bookingId})
      : super(key: key);
  @override
  _CancelBookingScreenState createState() => _CancelBookingScreenState();
}

class _CancelBookingScreenState extends State<CancelBookingScreen> {
  int? selectedReason; // Stores selected index
  TextEditingController reasonController = TextEditingController();

  // List of reasons; first four for outlined buttons and the fifth for "Another reason"
  final List<String> reasons = [
    "I have a better deal",
    "Some other work, can’t come",
    "I want to book another event",
    "Venue location is too far from my location",
    "Another reason"
  ];

  @override
  Widget build(BuildContext context) {
    // Adjust horizontal padding based on screen width.
    final double horizontalPadding =
        MediaQuery.of(context).size.width < 360 ? 8.0 : 16.0;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        // Dismiss keyboard if the user taps anywhere outside input fields.
        FocusScope.of(context).unfocus();
      },
      child: ClipRRect(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
        child: Scaffold(
          appBar: AppBar(
            // Back arrow on the top left.
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: Colors.black),
              onPressed: () => Navigator.pop(context),
              padding: EdgeInsets.zero,
              constraints: BoxConstraints(),
            ),
            // Title in the center.
            title: Text(
              'Cancel Booking',
              style: TextStyle(
                fontFamily: "Poppins",
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            centerTitle: true,
            backgroundColor: Colors.transparent,
            elevation: 0,
          ),
          body: Padding(
            padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: IntrinsicHeight(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Content part (expands or scrolls as needed)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(height: 24),
                              Text(
                                "Please select the reason for cancellation",
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Poppins',
                                ),
                              ),
                              SizedBox(height: 16),
                              // Outlined buttons for the first four reasons.
                              ...List.generate(4, (index) {
                                return Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 8.0),
                                  child: SizedBox(
                                    width: double.infinity,
                                    child: OutlinedButton(
                                      onPressed: () {
                                        setState(() {
                                          selectedReason = index;
                                        });
                                      },
                                      style: OutlinedButton.styleFrom(
                                        backgroundColor: Colors.transparent,
                                        side: BorderSide(
                                          color: selectedReason == index
                                              ? Colors.blue
                                              : Colors.grey[200]!,
                                          width: 1,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        padding: EdgeInsets.symmetric(
                                            vertical: 16, horizontal: 12),
                                      ),
                                      child: Align(
                                        alignment: Alignment.centerLeft,
                                        child: Text(
                                          reasons[index],
                                          style: TextStyle(
                                            fontFamily: "Poppins",
                                            fontSize: 16,
                                            color: Colors.black,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              }),
                              // "Another reason" acting as a button.
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 8.0),
                                child: SizedBox(
                                  width: double.infinity,
                                  child: InkWell(
                                    onTap: () {
                                      setState(() {
                                        selectedReason = 4;
                                      });
                                    },
                                    child: AnimatedContainer(
                                      duration: Duration(milliseconds: 300),
                                      curve: Curves.easeInOut,
                                      padding: EdgeInsets.symmetric(
                                        vertical: 20,
                                        horizontal: 12,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.transparent,
                                        border: Border.all(
                                          color: selectedReason == 4
                                              ? Colors.blue
                                              : Colors.grey[200]!,
                                          width: 1,
                                        ),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Center(
                                        child: Text(
                                          "Another reason",
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontFamily: "Poppins",
                                            fontSize: 18,
                                            color: selectedReason == 4
                                                ? Colors.blue
                                                : Colors.grey[600],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              // If "Another reason" is selected, show the text field inline.
                              if (selectedReason == 4)
                                Padding(
                                  padding: const EdgeInsets.only(top: 16.0),
                                  child: TextField(
                                    controller: reasonController,
                                    maxLines: 3,
                                    textAlign: TextAlign.center,
                                    decoration: InputDecoration(
                                      hintText: "Tell us your reason",
                                      hintStyle: TextStyle(
                                        fontFamily: "poppins",
                                        color: Colors.grey[400],
                                      ),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                        borderSide: BorderSide(
                                          color: Colors.grey[400]!,
                                          width: 1,
                                        ),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                        borderSide: BorderSide(
                                          color: Colors.grey[400]!,
                                          width: 1,
                                        ),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                        borderSide: BorderSide(
                                          color: Colors.blue,
                                          width: 1,
                                        ),
                                      ),
                                      contentPadding: EdgeInsets.all(12),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          // Spacer pushes the Cancel button to the bottom if there's extra space.
                          Spacer(),
                          // "Cancel Booking" button at the bottom.
                          Padding(
                            padding: EdgeInsets.symmetric(vertical: 16),
                            child: SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: () async {
                                  // final reason = selectedReason == 4
                                  //     ? reasonController.text.trim()
                                  //     : reasons[selectedReason ?? 0];

                                  // final bookingId = widget
                                  //     .bookingId; // ✅ already passed from parent

                                  final response = await http.put(
                                    Uri.parse(
                                        '$baseUrl/booking/cancel/${widget.bookingId}'), // 👈 no # here
                                    headers: {
                                      'Content-Type': 'application/json'
                                    },
                                    body: jsonEncode({
                                      'reason': selectedReason == 4
                                          ? reasonController.text
                                          : reasons[selectedReason ?? 0],
                                    }),
                                  );

                                  if (response.statusCode == 200) {
                                    Navigator.pop(context); // Close modal
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                          content: Text("✅ Booking cancelled")),
                                    );
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                          content: Text("❌ Failed to cancel"),
                                          backgroundColor: Colors.red),
                                    );
                                  }
                                },
                                child: Text(
                                  "Cancel Booking",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: "Poppins",
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue,
                                  padding: EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}