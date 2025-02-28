import 'package:flutter/material.dart';

class CancelBookingScreen extends StatefulWidget {
  @override
  _CancelBookingScreenState createState() => _CancelBookingScreenState();
}

class _CancelBookingScreenState extends State<CancelBookingScreen> {
  int? selectedReason; // Stores selected radio button index
  TextEditingController reasonController = TextEditingController();

  // List of reasons
  final List<String> reasons = [
    "I have a better deal",
    "Some other work, can’t come",
    "I want to book another event",
    "Venue location is too far from my location",
    "Another reason"
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
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
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Please select the reason for cancellation",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                fontFamily: 'Poppins',
              ),
            ),
            SizedBox(height: 10),

            // Radio Button List
            Column(
              children: List.generate(reasons.length, (index) {
                return RadioListTile<int>(
                  title: Text(reasons[index]),
                  value: index,
                  groupValue: selectedReason,
                  activeColor: Colors.pink, // Selected radio color
                  onChanged: (value) {
                    setState(() {
                      selectedReason = value;
                    });
                  },
                );
              }),
            ),

            // Optional Reason TextField (Shown only when "Another reason" is selected)
            if (selectedReason == 4)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: TextField(
                  controller: reasonController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: "Tell us your reason",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),

            Spacer(), // Pushes the button to the bottom

            // Full-Width Cancel Booking Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // Handle cancel booking logic here
                  print("Cancelled for reason: ${reasons[selectedReason ?? 0]}");
                  if (selectedReason == 4) {
                    print("Additional comment: ${reasonController.text}");
                  }
                  Navigator.pop(context); // Close the screen
                },
                child: Text(
                  "Cancel Booking",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.pink,
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


