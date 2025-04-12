// import 'package:adventura/Booking/CancelBooking.dart';
// import 'package:adventura/Main%20screen%20components/MainScreen.dart';
// import 'package:adventura/search%20screen/searchScreen.dart';
// import 'package:flutter/material.dart';
// import 'package:adventura/widgets/booking_card.dart';

// void main() {
//   runApp(MyApp());
// }

// /// The root widget of the application.
// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'My Bookings',
//       debugShowCheckedModeBanner: false,
//       home: MyBookingsPage(),
//     );
//   }
// }

// /// The MyBookingsPage displays the list of bookings.
// /// Tapping the Cancel button on a booking opens the CancelBookingScreen
// /// as a responsive modal that covers about 80% of the screen height.
// class MyBookingsPage extends StatefulWidget {
//   const MyBookingsPage({Key? key}) : super(key: key);

//   @override
//   _MyBookingsPageState createState() => _MyBookingsPageState();
// }

// int selectedRating = 0;
// bool isUpcomingSelected = true;

// class _MyBookingsPageState extends State<MyBookingsPage> {
//   // Temporary dummy bookings
//   List<Map<String, dynamic>> bookings = [
//     {
//       "activity": {
//         "name": "Saint Moritz",
//         "location": "Switzerland",
//         "date": "May 22, 2024 - May 26, 2024",
//         "price": "45",
//         "description": "A luxury mountain resort.",
//         "activity_images": ["assets/Pictures/island.jpg"]
//       },
//       "bookingId": "#UI891827BHY",
//       "guests": "3 Guests",
//       "status": "Upcoming",
//     },
//     {
//       "activity": {
//         "name": "Addu Atoll",
//         "location": "Maldives",
//         "date": "May 22, 2024 - May 26, 2024",
//         "price": "60",
//         "description": "Enjoy a tropical getaway.",
//         "activity_images": ["assets/Pictures/picnic.webp"]
//       },
//       "bookingId": "#TY671829BUI",
//       "guests": "2 Guests",
//       "status": "Upcoming",
//     },
//   ];
//   @override
//   Widget build(BuildContext context) {
//     double statusBarHeight = MediaQuery.of(context).padding.top;
//     double screenWidth = MediaQuery.of(context).size.width;
//     return Scaffold(
//       // appBar: AppBar(
//       //   backgroundColor: Colors.white, // Matches the page background
//       //   elevation: 0,
//       //   leading: IconButton(
//       //     icon: const Icon(Icons.arrow_back, color: Colors.black),
//       //     onPressed: () => Navigator.pop(context),
//       //   ),
//       //   title: const Text(
//       //     'My Bookings',
//       //     style: TextStyle(
//       //       fontFamily: "Poppins",
//       //       fontSize: 20,
//       //       fontWeight: FontWeight.bold,
//       //       color: Colors.black,
//       //     ),
//       //   ),
//       //   centerTitle: true,
//       // ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           children: [
//             Padding(
//               padding: EdgeInsets.fromLTRB(16, statusBarHeight + 6, 16, 6),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Text(
//                     "My Bookings",
//                     style: TextStyle(
//                       height: 0.96,
//                       fontSize: 36,
//                       fontWeight: FontWeight.bold,
//                       fontFamily: 'Poppins',
//                       color: Colors.black,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             // Tab Selector for Upcoming & Past
//             // Container(
//             //   height: 40,
//             //   width: double.infinity,
//             //   decoration: BoxDecoration(
//             //     color: const Color(0xFFF2F3F4), // Background color for toggle
//             //     borderRadius: BorderRadius.circular(12),
//             //   ),
//             //   child: Row(
//             //     children: [
//             //       // Upcoming Button
//             //       Expanded(
//             //         child: GestureDetector(
//             //           onTap: () {
//             //             setState(() {
//             //               isUpcomingSelected = true;
//             //             });
//             //           },
//             //           child: Container(
//             //             decoration: BoxDecoration(
//             //               color: isUpcomingSelected
//             //                   ? Colors.white
//             //                   : Colors.transparent,
//             //               borderRadius: BorderRadius.circular(12),
//             //             ),
//             //             alignment: Alignment.center,
//             //             child: Text(
//             //               'Upcoming',
//             //               style: TextStyle(
//             //                 fontSize: 16,
//             //                 fontWeight: FontWeight.bold,
//             //                 fontFamily: 'Poppins',
//             //                 color: isUpcomingSelected
//             //                     ? Colors.black
//             //                     : Colors.grey[600],
//             //               ),
//             //             ),
//             //           ),
//             //         ),
//             //       ),
//             //       // Past Button
//             //       Expanded(
//             //         child: GestureDetector(
//             //           onTap: () {
//             //             setState(() {
//             //               isUpcomingSelected = false;
//             //             });
//             //           },
//             //           child: Container(
//             //             decoration: BoxDecoration(
//             //               color: !isUpcomingSelected
//             //                   ? Colors.white
//             //                   : Colors.transparent,
//             //               borderRadius: BorderRadius.circular(12),
//             //             ),
//             //             alignment: Alignment.center,
//             //             child: Text(
//             //               'Past',
//             //               style: TextStyle(
//             //                 fontSize: 16,
//             //                 fontWeight: FontWeight.bold,
//             //                 fontFamily: 'Poppins',
//             //                 color: !isUpcomingSelected
//             //                     ? Colors.black
//             //                     : Colors.grey[600],
//             //               ),
//             //             ),
//             //           ),
//             //         ),
//             //       ),
//             //     ],
//             //   ),
//             // ),
//             // const SizedBox(height: 20), // Spacing below toggle buttons
//             SizedBox(height: 20),
//             Container(
//               height: 40,
//               width: double.infinity,
//               decoration: BoxDecoration(
//                 color: const Color(0xFFF2F3F4),
//                 borderRadius: BorderRadius.circular(12),
//               ),
//               child: Row(
//                 children: [
//                   Expanded(child: bookingTab("Upcoming", true)),
//                   Expanded(child: bookingTab("Past", false)),
//                 ],
//               ),
//             ),
//             const SizedBox(height: 20),
//             // Dynamic Title
//             Align(
//               alignment: Alignment.centerLeft,
//               child: Text(
//                 isUpcomingSelected ? 'Upcoming Bookings' : 'Past Bookings',
//                 style: const TextStyle(
//                   fontSize: 18,
//                   fontWeight: FontWeight.bold,
//                   fontFamily: 'Poppins',
//                 ),
//               ),
//             ),
//             const SizedBox(height: 10),
//             // Dynamic Booking List
//             Expanded(
//               child: ListView.builder(
//                 itemCount: bookings.length,
//                 itemBuilder: (context, index) {
//                   final booking = bookings[index];
//                   return BookingCard(
//                     activity: booking["activity"],
//                     bookingId: booking["bookingId"],
//                     guests: booking["guests"],
//                     status: booking["status"],
//                     onCancel: () {
//                       showModalBottomSheet(
//                         context: context,
//                         isScrollControlled: true,
//                         shape: RoundedRectangleBorder(
//                           borderRadius:
//                               BorderRadius.vertical(top: Radius.circular(16)),
//                         ),
//                         builder: (context) {
//                           return FractionallySizedBox(
//                             heightFactor: 0.8,
//                             child: CancelBookingScreen(),
//                           );
//                         },
//                       );
//                     },
//                   );
//                 },
//               ),
//             ),
//             Align(
//               alignment: Alignment.bottomCenter,
//               child: Container(
//                 margin: const EdgeInsets.only(bottom: 20),
//                 width: screenWidth * 0.93,
//                 height: 65,
//                 decoration: BoxDecoration(
//                   color: const Color(0xFF1B1B1B),
//                   borderRadius: BorderRadius.circular(15),
//                   boxShadow: [
//                     BoxShadow(
//                       color: Colors.black.withOpacity(0.70),
//                       offset: Offset(0, 1),
//                       blurRadius: 5,
//                       spreadRadius: 0,
//                     ),
//                   ],
//                 ),
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                   children: [
//                     IconButton(
//                       onPressed: () {
//                         Navigator.push(
//                             context,
//                             MaterialPageRoute(
//                                 builder: (context) => MainScreen()));
//                       },
//                       icon: Image.asset(
//                         'assets/Icons/home.png',
//                         width: 35,
//                         height: 35,
//                         color: Colors.grey, // Adjust based on the screen
//                       ),
//                     ),
//                     IconButton(
//                       onPressed: () {
//                         Navigator.push(
//                             context,
//                             MaterialPageRoute(
//                                 builder: (context) => SearchScreen()));
//                       },
//                       icon: Image.asset(
//                         'assets/Icons/search.png',
//                         width: 35,
//                         height: 35,
//                         color: Colors.grey, // Active
//                       ),
//                     ),
//                     IconButton(
//                       onPressed: () {},
//                       icon: Image.asset(
//                         'assets/Icons/ticket.png',
//                         width: 35,
//                         height: 35,
//                         color: Colors.white,
//                       ),
//                     ),
//                     IconButton(
//                       onPressed: () {},
//                       icon: Image.asset(
//                         'assets/Icons/bookmark.png',
//                         width: 35,
//                         height: 35,
//                         color: Colors.grey,
//                       ),
//                     ),
//                     IconButton(
//                       onPressed: () {},
//                       icon: Image.asset(
//                         'assets/Icons/paper-plane.png',
//                         width: 35,
//                         height: 35,
//                         color: Colors.grey,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget bookingTab(String label, bool isUpcoming) {
//     bool isSelected = isUpcomingSelected == isUpcoming;
//     return GestureDetector(
//       onTap: () {
//         setState(() {
//           isUpcomingSelected = isUpcoming;
//         });
//       },
//       child: Container(
//         decoration: BoxDecoration(
//           color: isSelected ? Colors.white : Colors.transparent,
//           borderRadius: BorderRadius.circular(12),
//         ),
//         alignment: Alignment.center,
//         child: Text(
//           label,
//           style: TextStyle(
//             fontSize: 16,
//             fontWeight: FontWeight.bold,
//             fontFamily: 'Poppins',
//             color: isSelected ? Colors.black : Colors.grey[600],
//           ),
//         ),
//       ),
//     );
//   }
// }
