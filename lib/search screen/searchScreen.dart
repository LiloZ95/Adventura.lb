import 'dart:ui';

import 'package:adventura/Booking/MyBooking.dart';
import 'package:adventura/Main%20screen%20components/Cards.dart';
import 'package:adventura/colors.dart';
import 'package:flutter/material.dart';

class SearchScreen extends StatefulWidget {
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  void showEventDetails(BuildContext context, String title, String date,
      String location, String price) {}

  // Track the selected categories
  List<String> categories = ["Hikes", "Boats", "Sunsets", "Tours", "More"];
  Set<String> selectedCategories = {};
  Set<int> selectedRatings = {};
  Set<String> selectedSorts = {};
  Set<int> selectedReviews = {};
  double budgetMin=0;
  double? budgetMax=0;
  String? selectedLocation;
  TextEditingController budgetMinController = TextEditingController();
    TextEditingController budgetMaxController = TextEditingController();


  // Show filter dialog
  void showFilterDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Container(
              
              decoration: BoxDecoration(borderRadius:BorderRadius.circular(32),color: Colors.white,),
              child: Padding( 
                padding: const EdgeInsets.all(16.0),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                        TextButton(
                          onPressed: () {
                            setState(() {
                              selectedRatings.clear();
                              selectedSorts.clear();
                              selectedReviews.clear();
                              budgetMin=0;
                              budgetMax=0;
                              selectedLocation = "all";
                              selectedCategories.clear();
                              budgetMinController.clear();
                              budgetMaxController.clear();
                            });
                          },
                          child: Text(
                            "Reset",
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Poppins',
                            ),
                          ),
                        )
                      ]),
                      SizedBox(height: 16),
                      
                      Text("Rating", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: List.generate(
                          5,
                          (index) {
                            int rating = index + 1;
                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  selectedRatings.contains(rating)
                                      ? selectedRatings.remove(rating)
                                      : selectedRatings.add(rating);
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.all(8.0),
                                decoration: BoxDecoration(
                                  color: selectedRatings.contains(rating)
                                      ? AppColors.blue
                                      : Colors.white,
                                  borderRadius: BorderRadius.circular(15),
                                  border: Border.all(width: 0.3),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.star,
                                      color: selectedRatings.contains(rating)
                                          ? Colors.yellow
                                          : Colors.grey,
                                    ),
                                    SizedBox(width: 4),
                                    Text(
                                      "$rating",
                                      style: TextStyle(
                                        color: selectedRatings.contains(rating)
                                            ? Colors.white
                                            : Colors.black,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      SizedBox(height: 16),
                      
                      Text("Sort By", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: ["All", "Limited", "New", "Popular", "Nearby"]
                            .map((sortOption) => GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      selectedSorts.contains(sortOption)
                                          ? selectedSorts.remove(sortOption)
                                          : selectedSorts.add(sortOption);
                                    });
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(8.0),
                                    decoration: BoxDecoration(
                                      color: selectedSorts.contains(sortOption)
                                          ? AppColors.blue
                                          : Colors.white,
                                      borderRadius: BorderRadius.circular(15),
                                       border: Border.all(width: 0.3),
                                      
                                    ),
                                    child: Text(
                                      sortOption,
                                      style: TextStyle(
                                        color: selectedSorts.contains(sortOption)
                                            ? Colors.white
                                            : Colors.black,
                                      ),
                                    ),
                                  ),
                                ))
                            .toList(),
                      ),
                      SizedBox(height: 16),
              
                      Text("Budget", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              
                    // Budget Fields
                    Row(
                      children: [
                                              Expanded(
                          child: TextField(
                            controller: budgetMinController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText: "Min",
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
                            ),
                          
                            onChanged: (value) {
                              setState(() {
                                budgetMin = double.tryParse(value)!;
                              });
                            },
                          ),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: TextField(
                            controller: budgetMaxController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText: "Max",
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
                            ),
                            onChanged: (value) {
                              setState(() {
                                budgetMax = double.tryParse(value);
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
              
                    // Location Filter
                    Text("Location", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    DropdownButtonFormField<String>(
                      value: selectedLocation,
                      items: [
                        "Tripoli",
                        "Beirut",
                        "Jbeil",
                        "Jounieh",
                        "all",
                      ].map((location) {
                        return DropdownMenuItem(
                          value: location,
                          child: Text(location),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedLocation = value;
                        });
                      },
                      decoration: InputDecoration(
                        labelText: "Location",
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
                      ),
                    ),
                    SizedBox(height: 16),
              
                    // Apply Button
                 SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text("Apply",style: TextStyle(color: Colors.white),),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              )
              
                  ],
                ),
              )
                        ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double statusBarHeight = MediaQuery.of(context).padding.top;
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              children: [
                // Title Section
                Padding(
                  padding: EdgeInsets.fromLTRB(16, statusBarHeight + 6, 16, 6),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Search what you \ndesire",
                        style: TextStyle(
                          height: 0.96,
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Poppins',
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
                // Search and Filter Section
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 6),
                  child: Row(
                    children: [
                      // Filter Button
                      GestureDetector(
                        onTap: showFilterDialog,
                        child: Container(
                          height: 48,
                          width: 48,
                          decoration: BoxDecoration(
                            color: AppColors.blue,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(Icons.filter_list, color: Colors.white),
                        ),
                      ),
                      SizedBox(width: 10),
                      // Search Bar
                      Expanded(
                        child: TextField(
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.grey.shade200,
                            hintText: "Search...",
                            hintStyle: TextStyle(
                              fontFamily: 'Poppins',
                              color: Colors.grey,
                            ),
                            prefixIcon: Icon(Icons.search, color: Colors.grey),
                            suffixIcon: Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: Colors.blue,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(Icons.mic, color: Colors.white),
                              ),
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Scrollable Event Section
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Search by Categories",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Poppins',
                          color: Colors.black,
                        ),
                      ),
                      SizedBox(height: 10),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: categories
                              .map((category) => categoryChip(category))
                              .toList(),
                        ),
                      ),
                    ],
                  ),
                ),
                // Scrollable Cards
                SizedBox(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
                    child: Column(
                      children: [
                        EventCard(
                          context: context,
                          imagePath: 'assets/Pictures/cars.webp',
                          title: 'Aaqoura Night Hike',
                          providerName: 'Lebanon Explorers',
                          date: 'Saturday, 29th Sep',
                          location: 'Aaqoura, Hadath',
                          rating: 4.8,
                          totalReviews: 125,
                          price: '\$20',
                        ),
                        EventCard(
                          context: context,
                          imagePath: 'assets/Pictures/sea1.webp',
                          title: 'Aaqoura Night Hike',
                          providerName: 'Lebanon Explorers',
                          date: 'Saturday, 29th Sep',
                          location: 'Aaqoura, Hadath',
                          rating: 4.8,
                          totalReviews: 125,
                          price: '\$20',
                        ),
                        EventCard(
                          context: context,
                          imagePath: 'assets/Pictures/picnic.webp',
                          title: 'Aaqoura Night Hike',
                          providerName: 'Lebanon Explorers',
                          date: 'Saturday, 29th Sep',
                          location: 'Aaqoura, Hadath',
                          rating: 4.8,
                          totalReviews: 125,
                          price: '\$20',
                        ),
                        EventCard(
                          context: context,
                          imagePath: 'assets/Pictures/sea2.webp',
                          title: 'Aaqoura Night Hike',
                          providerName: 'Lebanon Explorers',
                          date: 'Saturday, 29th Sep',
                          location: 'Aaqoura, Hadath',
                          rating: 4.8,
                          totalReviews: 125,
                          price: '\$20',
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Bottom Navigation Bar
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              margin: const EdgeInsets.only(bottom: 25),
              width: screenWidth * 0.93,
              height: 65,
              decoration: BoxDecoration(
                color: Color(0xFF1B1B1B),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(
                    onPressed: () {
                      // Navigate to Main Screen
                      Navigator.pop(context);
                    },
                    icon: Image.asset(
                      'assets/Icons/home.png',
                      width: 35,
                      height: 35,
                      color: Colors.grey, // Adjust based on the screen
                    ),
                  ),
                  IconButton(
                    onPressed: () {},
                    icon: Image.asset(
                      'assets/Icons/search.png',
                      width: 35,
                      height: 35,
                      color: Colors.white, // Active
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => MyBookingsPage()));
                    },
                    icon: Image.asset(
                      'assets/Icons/ticket.png',
                      width: 35,
                      height: 35,
                      color: Colors.grey,
                    ),
                  ),
                  IconButton(
                    onPressed: () {},
                    icon: Image.asset(
                      'assets/Icons/bookmark.png',
                      width: 35,
                      height: 35,
                      color: Colors.grey,
                    ),
                  ),
                  IconButton(
                    onPressed: () {},
                    icon: Image.asset(
                      'assets/Icons/paper-plane.png',
                      width: 35,
                      height: 35,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget categoryChip(String label) {
    bool isSelected = selectedCategories.contains(label);

    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: GestureDetector(
        onTap: () {
          setState(() {
            if (isSelected) {
              selectedCategories.remove(label);
            } else {
              selectedCategories.add(label);
            }
          });
        },
        child: Chip(
          label: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 14,
                  // fontWeight: FontWeight.bold,
                  color: isSelected
                      ? Colors.white
                      : Color.fromARGB(255, 216, 216, 216),
                ),
              ),
              if (isSelected)
                GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedCategories.remove(label);
                    });
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(left: 4.0),
                    child: Icon(
                      Icons.close,
                      size: 16,
                      color: Colors.white,
                    ),
                  ),
                ),
            ],
          ),
          backgroundColor: isSelected ? AppColors.blue : Colors.white,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
              side: BorderSide(
                  color: isSelected
                      ? AppColors.blue
                      : Color.fromARGB(255, 216, 216, 216))),
        ),
      ),
    );
  }
}
