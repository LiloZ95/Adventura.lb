import 'package:flutter/material.dart';

class CancelBookingScreen extends StatefulWidget {
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

  void _showAdditionalReasonModal() async {
    // Show a modal bottom sheet with the text field.
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Resizes when the keyboard appears.
      builder: (context) {
        return Padding(
          // Include keyboard inset.
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 16,
            bottom: MediaQuery.of(context).viewInsets.bottom + 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: reasonController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: "Tell us your reason",
                  hintStyle: TextStyle(
                    fontFamily: "poppins",
                    color: Colors.grey[400],
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  contentPadding: EdgeInsets.all(12),
                ),
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text(
                  "Submit",
                  style: TextStyle(
                    fontFamily: "Poppins",
                    fontSize: 13,
                    color: Colors.white,
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
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Adjust horizontal padding based on screen width.
    final double horizontalPadding =
        MediaQuery.of(context).size.width < 360 ? 8.0 : 16.0;

    return ClipRRect(
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
        // Body contains the main content and the cancel button at the bottom.
        body: Padding(
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
          child: Column(
            children: [
              // Expanded scrollable area for the reasons.
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Extra spacing between the AppBar title and content.
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
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
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
                                  borderRadius: BorderRadius.circular(10),
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
                      // "Another reason" acting as a button; bigger, centered, with a grey border that animates to blue when selected.
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: SizedBox(
                          width: double.infinity,
                          child: InkWell(
                            onTap: () {
                              setState(() {
                                selectedReason = 4;
                              });
                              _showAdditionalReasonModal();
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
                    ],
                  ),
                ),
              ),
              // "Cancel Booking" button at the bottom of the screen.
              Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      print("Cancelled for reason: ${selectedReason != null ? reasons[selectedReason!] : reasons[0]}");
                      if (selectedReason == 4) {
                        print("Additional comment: ${reasonController.text}");
                      }
                      Navigator.pop(context);
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
  }
}
