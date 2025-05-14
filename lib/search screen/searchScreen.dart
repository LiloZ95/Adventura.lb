import 'dart:async';
import 'dart:ui';

import 'package:adventura/event_cards/Cards.dart';
import 'package:adventura/Services/activity_service.dart';
import 'package:adventura/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class SearchScreen extends StatefulWidget {
  final String? filterMode;
  final String? initialCategory;
  final Function(bool) onScrollChanged;

  SearchScreen(
      {this.filterMode, this.initialCategory, required this.onScrollChanged});
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
  void didUpdateWidget(covariant SearchScreen oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.initialCategory != null &&
        widget.initialCategory != oldWidget.initialCategory) {
      // Ensure chip UI is ready before selecting
      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() {
          selectedCategories = {
            widget.initialCategory!
          }; // ← create a new Set instance
        });

        _fetchResults();
      });
    }
  }

  @override
  void initState() {
    super.initState();

    _scrollController.addListener(() {
      final direction = _scrollController.position.userScrollDirection;
      _scrollStopTimer?.cancel();

      if (direction == ScrollDirection.reverse) {
        widget.onScrollChanged(false);
      } else if (direction == ScrollDirection.forward) {
        widget.onScrollChanged(true);
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
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withOpacity(0.25),
      builder: (BuildContext context) {
        final isDarkMode = Theme.of(context).brightness == Brightness.dark;

        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15.0, sigmaY: 15.0),
          child: FractionallySizedBox(
            heightFactor: 0.63,
            child: Material(
              color: isDarkMode
                  ? const Color(0xFF1E1E1E)
                  : Colors.white.withOpacity(0.95),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(32)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: StatefulBuilder(
                  builder: (BuildContext context, StateSetter setState) {
                    return SingleChildScrollView(
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
                                    color: isDarkMode
                                        ? Colors.white
                                        : Colors.black,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'Poppins',
                                  ),
                                ),
                              )
                            ],
                          ),
                          const SizedBox(height: 16),
                          Text("Rating",
                              style: TextStyle(
                                  fontFamily: 'poppins',
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: isDarkMode
                                      ? Colors.white
                                      : Colors.black)),
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
                                          : isDarkMode
                                              ? Colors.grey.shade900
                                              : Colors.white,
                                      borderRadius: BorderRadius.circular(15),
                                      border: Border.all(
                                          width: 0.3,
                                          color: isDarkMode
                                              ? Colors.grey
                                              : Colors.black),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.star,
                                          color:
                                              selectedRatings.contains(rating)
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
                                                    : isDarkMode
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
                                  fontWeight: FontWeight.bold,
                                  color: isDarkMode
                                      ? Colors.white
                                      : Colors.black)),
                          SizedBox(height: 8),
                          SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              reverse: true,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
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
                                                  ? selectedSorts
                                                      .remove(sortOption)
                                                  : selectedSorts
                                                      .add(sortOption);
                                            });
                                          },
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 8.0, horizontal: 12),
                                            decoration: BoxDecoration(
                                              color: selectedSorts
                                                      .contains(sortOption)
                                                  ? AppColors.blue
                                                  : isDarkMode
                                                      ? Colors.grey.shade900
                                                      : Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(15),
                                              border: Border.all(
                                                  width: 0.3,
                                                  color: isDarkMode
                                                      ? Colors.grey
                                                      : Colors.black),
                                            ),
                                            child: Text(
                                              sortOption,
                                              style: TextStyle(
                                                fontFamily: 'poppins',
                                                fontSize: 16,
                                                color: selectedSorts
                                                        .contains(sortOption)
                                                    ? Colors.white
                                                    : isDarkMode
                                                        ? Colors.white
                                                        : Colors.black,
                                              ),
                                            ),
                                          ),
                                        ))
                                    .toList(),
                              )),
                          SizedBox(height: 16),
                          Text("Budget",
                              style: TextStyle(
                                  fontFamily: 'poppins',
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: isDarkMode
                                      ? Colors.white
                                      : Colors.black)),
                          SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: budgetMinController,
                                  keyboardType: TextInputType.number,
                                  style: TextStyle(
                                      color: isDarkMode
                                          ? Colors.white
                                          : Colors.black),
                                  decoration: InputDecoration(
                                    labelText: "Min",
                                    labelStyle: TextStyle(
                                        color: isDarkMode
                                            ? Colors.white
                                            : Colors.black,
                                        fontSize: 16),
                                    focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(20),
                                        borderSide: BorderSide(
                                            color: isDarkMode
                                                ? Colors.white
                                                : Colors.black)),
                                    border: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(20)),
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
                                  style: TextStyle(
                                      color: isDarkMode
                                          ? Colors.white
                                          : Colors.black),
                                  decoration: InputDecoration(
                                    labelText: "Max",
                                    labelStyle: TextStyle(
                                        color: isDarkMode
                                            ? Colors.white
                                            : Colors.black,
                                        fontSize: 16),
                                    focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(20),
                                        borderSide: BorderSide(
                                            color: isDarkMode
                                                ? Colors.white
                                                : Colors.black)),
                                    border: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(20)),
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
                          Text("Location",
                              style: TextStyle(
                                  fontFamily: 'poppins',
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: isDarkMode
                                      ? Colors.white
                                      : Colors.black)),
                          SizedBox(height: 8),
                          DropdownButtonFormField<String>(
                            value: selectedLocation,
                            dropdownColor: isDarkMode
                                ? Colors.grey.shade900
                                : Colors.white,
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
                                    color: isDarkMode
                                        ? Colors.white
                                        : Colors.black,
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
                              labelStyle: TextStyle(
                                  color:
                                      isDarkMode ? Colors.white : Colors.black,
                                  fontSize: 16),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(20),
                                borderSide: BorderSide(
                                    color:
                                        isDarkMode ? Colors.grey : Colors.grey),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(20),
                                borderSide: BorderSide(
                                    color: isDarkMode
                                        ? Colors.white
                                        : Colors.black),
                              ),
                            ),
                          ),
                          SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.pop(context);
                                _fetchResults();
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
                    );
                  },
                ),
              ),
            ),
          ),
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
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDarkMode ? const Color(0xFF121212) : Colors.white,
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
                      Expanded(
                          child: Divider(
                              thickness: 1,
                              color: isDarkMode
                                  ? Colors.grey.shade700
                                  : Colors.grey)),
                      SizedBox(width: 12),
                      Text(
                        "Search what you desire",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Poppins',
                          color: isDarkMode ? Colors.white : Colors.black,
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                          child: Divider(
                              thickness: 1,
                              color: isDarkMode
                                  ? Colors.grey.shade700
                                  : Colors.grey)),
                    ],
                  ),
                ),
                SizedBox(
                  height: 12,
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
                          style: TextStyle(
                            color: isDarkMode ? Colors.white : Colors.black,
                          ),
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: isDarkMode
                                ? Colors.grey.shade800
                                : Colors.grey.shade200,
                            hintText: "Search...",
                            hintStyle: TextStyle(
                              fontFamily: 'Poppins',
                              color: isDarkMode
                                  ? Colors.grey.shade400
                                  : Colors.grey,
                            ),
                            prefixIcon: Icon(Icons.search,
                                color: isDarkMode
                                    ? Colors.grey.shade400
                                    : Colors.grey),
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
                          color: isDarkMode ? Colors.white : Colors.black,
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
                            height: MediaQuery.of(context).size.height * 0.12),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          // You can add Bottom Navigation Bar or FloatingActionButton here if needed
        ],
      ),
    );
  }

  Widget categoryChip(String label) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    bool isSelected = selectedCategories.contains(label);

    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: GestureDetector(
        onTap: () {
          setState(() {
            if (isSelected) {
              selectedCategories.remove(label);
            } else {
              selectedCategories.clear(); // Single-selection logic
              selectedCategories.add(label);
            }
          });
          _fetchResults();
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
                  color: isSelected
                      ? Colors.white
                      : isDarkMode
                          ? Colors.grey.shade300
                          : Color.fromARGB(255, 80, 80, 80),
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
          backgroundColor: isSelected
              ? AppColors.blue
              : (isDarkMode ? Colors.grey.shade900 : Colors.white),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
            side: BorderSide(
              color: isSelected
                  ? AppColors.blue
                  : isDarkMode
                      ? Colors.grey.shade600
                      : Color.fromARGB(255, 216, 216, 216),
            ),
          ),
        ),
      ),
    );
  }
}
