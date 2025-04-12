import 'dart:async';
import 'dart:ui';

import 'package:adventura/event_cards/Cards.dart';
import 'package:adventura/Services/activity_service.dart';
import 'package:adventura/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class SearchScreen extends StatefulWidget {
  final String? filterMode;
  final Function(bool) onScrollChanged;

  SearchScreen({this.filterMode, required this.onScrollChanged});
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;
  List<Map<String, dynamic>> searchResults = [];
  final ScrollController _scrollController = ScrollController();
  Timer? _scrollStopTimer;

  void showEventDetails(BuildContext context, String title, String date,
      String location, String price) {}

  List<String> categories = [
    "Sea Trips",
    "Picnic",
    "Paragliding",
    "Sunsets",
    "Tours",
    "Car Events",
    "Festivals",
    "Hikes",
    "Snow Skiing",
    "Boats",
    "Jetski",
    "Museums"
  ];

  Set<String> selectedCategories = {};
  Set<int> selectedRatings = {};
  Set<String> selectedSorts = {};
  Set<int> selectedReviews = {};
  double budgetMin = 0;
  double? budgetMax = 0;
  String? selectedLocation;
  TextEditingController budgetMinController = TextEditingController();
  TextEditingController budgetMaxController = TextEditingController();

  // ✅ NEW additions:
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchResults();

    _scrollController.addListener(() {
      final direction = _scrollController.position.userScrollDirection;

      // Cancel any running timer
      _scrollStopTimer?.cancel();

      if (direction == ScrollDirection.reverse) {
        widget.onScrollChanged(false); // hide nav bar
      } else if (direction == ScrollDirection.forward) {
        widget.onScrollChanged(true); // show nav bar
      }

      _scrollStopTimer = Timer(Duration(milliseconds: 300), () {
        widget.onScrollChanged(true);
      });
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _scrollStopTimer?.cancel();
    super.dispose();
  }

  // Show filter dialog
  void showFilterDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(32),
                color: Colors.white,
              ),
              child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              TextButton(
                                onPressed: () {
                                  setState(() {
                                    selectedRatings.clear();
                                    selectedSorts.clear();
                                    selectedReviews.clear();
                                    budgetMin = 0;
                                    budgetMax = 0;
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
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'Poppins',
                                  ),
                                ),
                              )
                            ]),
                        SizedBox(height: 16),

                        Text("Rating",
                            style: TextStyle(
                                fontFamily: 'poppins',
                                fontSize: 18,
                                fontWeight: FontWeight.bold)),
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
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 8.0, horizontal: 12),
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
                                          fontFamily: 'poppins',
                                          color:
                                              selectedRatings.contains(rating)
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

                        Text("Sort By",
                            style: TextStyle(
                                fontFamily: 'poppins',
                                fontSize: 18,
                                fontWeight: FontWeight.bold)),
                        SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            "All",
                            "Limited",
                            "New",
                            "Popular",
                            "Nearby"
                          ]
                              .map((sortOption) => GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        selectedSorts.contains(sortOption)
                                            ? selectedSorts.remove(sortOption)
                                            : selectedSorts.add(sortOption);
                                      });
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 8.0, horizontal: 12),
                                      decoration: BoxDecoration(
                                        color:
                                            selectedSorts.contains(sortOption)
                                                ? AppColors.blue
                                                : Colors.white,
                                        borderRadius: BorderRadius.circular(15),
                                        border: Border.all(width: 0.3),
                                      ),
                                      child: Text(
                                        sortOption,
                                        style: TextStyle(
                                          fontFamily: 'poppins',
                                          fontSize: 16,
                                          color:
                                              selectedSorts.contains(sortOption)
                                                  ? Colors.white
                                                  : Colors.black,
                                        ),
                                      ),
                                    ),
                                  ))
                              .toList(),
                        ),
                        SizedBox(height: 16),

                        Text("Budget",
                            style: TextStyle(
                                fontFamily: 'poppins',
                                fontSize: 18,
                                fontWeight: FontWeight.bold)),
                        SizedBox(height: 8),
                        // Budget Fields
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: budgetMinController,
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  labelText: "Min",
                                  labelStyle: TextStyle(
                                      color: Colors.black, fontSize: 16),
                                  focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(20),
                                      borderSide:
                                          BorderSide(color: Colors.black)),
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(20)),
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
                                  labelStyle: TextStyle(
                                      color: Colors.black, fontSize: 16),
                                  focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(20),
                                      borderSide:
                                          BorderSide(color: Colors.black)),
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(20)),
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
                        Text("Location",
                            style: TextStyle(
                                fontFamily: 'poppins',
                                fontSize: 18,
                                fontWeight: FontWeight.bold)),
                        SizedBox(height: 8),
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
                              child: Text(
                                location,
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 16,
                                ),
                              ),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              selectedLocation = value;
                            });
                          },
                          decoration: InputDecoration(
                            labelText: "Location",
                            labelStyle:
                                TextStyle(color: Colors.black, fontSize: 16),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                              borderSide: BorderSide(color: Colors.grey),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                              borderSide: BorderSide(color: Colors.black),
                            ),
                          ),
                        ),

                        SizedBox(height: 16),

                        // Apply Button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.pop(context);
                              _fetchResults(); // Trigger search when filters are applied
                            },
                            child: Text(
                              "Apply",
                              style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.white,
                                  fontFamily: 'poppins'),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.blue,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                              padding: EdgeInsets.symmetric(vertical: 20),
                            ),
                          ),
                        )
                      ],
                    ),
                  )),
            );
          },
        );
      },
    );
  }

  Future<void> _fetchResults() async {
    String searchText = searchController.text.trim();

    final Map<String, int> categoryMap = {
      "Sea Trips": 1,
      "Picnic": 2,
      "Paragliding": 3,
      "Sunsets": 4,
      "Tours": 5,
      "Car Events": 6,
      "Festivals": 7,
      "Hikes": 8,
      "Snow Skiing": 9,
      "Boats": 10,
      "Jetski": 11,
      "Museums": 12,
    };

    String? selectedLabel =
        selectedCategories.isNotEmpty ? selectedCategories.first : null;
    int? categoryId = selectedLabel != null ? categoryMap[selectedLabel] : null;

    final isLimitedEventsOnly = widget.filterMode == "limited_events_only";

    // 👇 If only fetching events
    if (isLimitedEventsOnly) {
      final events = await ActivityService.fetchEvents(
        search: searchText,
        category: categoryId?.toString(),
        location: selectedLocation == "all" ? null : selectedLocation,
        minPrice: budgetMin > 0 ? budgetMin : null,
        maxPrice: budgetMax != null && budgetMax! > 0 ? budgetMax : null,
        rating: selectedRatings.isNotEmpty
            ? selectedRatings.reduce((a, b) => a > b ? a : b)
            : null,
        listingType: "event", // ✅ make sure this is passed
      );

      setState(() {
        searchResults = events;
      });
      return;
    }

    // 👇 Normal flow for both activities & events
    final activities = await ActivityService.fetchActivities(
      search: searchText,
      category: categoryId?.toString(),
      location: selectedLocation == "all" ? null : selectedLocation,
      minPrice: budgetMin > 0 ? budgetMin : null,
      maxPrice: budgetMax != null && budgetMax! > 0 ? budgetMax : null,
      rating: selectedRatings.isNotEmpty
          ? selectedRatings.reduce((a, b) => a > b ? a : b)
          : null,
    );

    final events = await ActivityService.fetchEvents(
      search: searchText,
      category: categoryId?.toString(),
      location: selectedLocation == "all" ? null : selectedLocation,
      minPrice: budgetMin > 0 ? budgetMin : null,
      maxPrice: budgetMax != null && budgetMax! > 0 ? budgetMax : null,
      rating: selectedRatings.isNotEmpty
          ? selectedRatings.reduce((a, b) => a > b ? a : b)
          : null,
      listingType: "event", // optional, or leave null
    );
    // ✅ Filter each to ensure no overlap
    final onlyActivities = activities
        .where((a) => a["listing_type"]?.toLowerCase() != "onetime")
        .toList();

    final onlyEvents = events
        .where((e) => e["listing_type"]?.toLowerCase() == "onetime")
        .toList();

    final combinedResults = [...onlyActivities, ...onlyEvents];
    combinedResults.shuffle();

    setState(() {
      searchResults = combinedResults;
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    double statusBarHeight = MediaQuery.of(context).padding.top;
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          SingleChildScrollView(
            controller: _scrollController,
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
                          controller: searchController,
                          onChanged: (value) => _fetchResults(),
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
                                  color: AppColors.blue,
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
                        ...searchResults.map((activity) {
                          return EventCard(
                            context: context,
                            activity: activity,
                          );
                        }).toList(),
                        SizedBox(
                            height: MediaQuery.of(context).size.height *
                                0.12), // 👈 Add spacing
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Bottom Navigation Bar
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
              selectedCategories
                  .clear(); // Make it single-selection for simplicity
              selectedCategories.add(label);
            }
          });
          _fetchResults(); // Fetch results on chip tap
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
