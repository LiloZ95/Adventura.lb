import 'dart:async';
import 'dart:ui';

import 'package:adventura/event_cards/Cards.dart';
import 'package:adventura/Services/activity_service.dart';
import 'package:adventura/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

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

  // Responsive design constants
  bool isWebView = kIsWeb;

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

      _scrollStopTimer = Timer(const Duration(milliseconds: 300), () {
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

  // Show filter dialog - improved for web
void showFilterDialog() {
  if (kIsWeb) {
    // Enhanced web-specific filter dialog with improved design
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Container(
                width: MediaQuery.of(context).size.width * 0.6,
                height: MediaQuery.of(context).size.height * 0.8,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Header section with improved styling
                    Container(
                      padding: const EdgeInsets.fromLTRB(32, 24, 32, 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(16),
                          topRight: Radius.circular(16),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.1),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Filters",
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Poppins',
                              color: Color(0xFF333333),
                            ),
                          ),
                          TextButton.icon(
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
                            icon: const Icon(
                              Icons.refresh_rounded,
                              color: AppColors.mainBlue,
                              size: 18,
                            ),
                            label: const Text(
                              "Reset All",
                              style: TextStyle(
                                color: AppColors.mainBlue,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                fontFamily: 'Poppins',
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    const Divider(height: 1, thickness: 1, color: Color(0xFFEEEEEE)),
                    
                    // Main content area
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Categories with improved styling
                            Row(
                              children: [
                                const Icon(Icons.category_outlined, color: AppColors.mainBlue, size: 22),
                                const SizedBox(width: 8),
                                const Text(
                                  "Categories",
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF333333),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Wrap(
                              spacing: 10,
                              runSpacing: 10,
                              children: categories.map((category) {
                                bool isSelected = selectedCategories.contains(category);
                                return FilterChip(
                                  label: Text(category),
                                  selected: isSelected,
                                  onSelected: (bool selected) {
                                    setState(() {
                                      if (selected) {
                                        selectedCategories.clear();
                                        selectedCategories.add(category);
                                      } else {
                                        selectedCategories.remove(category);
                                      }
                                    });
                                  },
                                  backgroundColor: Colors.white,
                                  selectedColor: AppColors.mainBlue.withOpacity(0.9),
                                  checkmarkColor: Colors.white,
                                  labelStyle: TextStyle(
                                    color: isSelected ? Colors.white : Colors.black87,
                                    fontSize: 14,
                                    fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
                                  ),
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    side: BorderSide(
                                      color: isSelected ? Colors.transparent : Colors.grey.shade300,
                                      width: 1.5,
                                    ),
                                  ),
                                  elevation: isSelected ? 1 : 0,
                                  pressElevation: 2,
                                );
                              }).toList(),
                            ),
                            const SizedBox(height: 28),

                            // Rating section with improved styling
                            Row(
                              children: [
                                const Icon(Icons.star_border_rounded, color: AppColors.mainBlue, size: 22),
                                const SizedBox(width: 8),
                                const Text(
                                  "Rating",
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF333333),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Wrap(
                              spacing: 10,
                              children: List.generate(
                                5,
                                (index) {
                                  int rating = index + 1;
                                  bool isSelected = selectedRatings.contains(rating);
                                  return AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    child: FilterChip(
                                      label: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            isSelected ? Icons.star_rounded : Icons.star_outline_rounded,
                                            size: 18,
                                            color: isSelected ? Colors.amber : Colors.grey.shade600,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            "$rating",
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: isSelected ? Colors.white : Colors.black87,
                                              fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
                                            ),
                                          ),
                                        ],
                                      ),
                                      selected: isSelected,
                                      onSelected: (bool selected) {
                                        setState(() {
                                          selected ? selectedRatings.add(rating) : selectedRatings.remove(rating);
                                        });
                                      },
                                      backgroundColor: Colors.white,
                                      selectedColor: AppColors.mainBlue,
                                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        side: BorderSide(
                                          color: isSelected ? Colors.transparent : Colors.grey.shade300,
                                          width: 1.5,
                                        ),
                                      ),
                                      elevation: isSelected ? 1 : 0,
                                      pressElevation: 2,
                                    ),
                                  );
                                },
                              ),
                            ),
                            const SizedBox(height: 28),

                            // Sort by section with improved styling
                            Row(
                              children: [
                                const Icon(Icons.sort_rounded, color: AppColors.mainBlue, size: 22),
                                const SizedBox(width: 8),
                                const Text(
                                  "Sort By",
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF333333),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Wrap(
                              spacing: 10,
                              runSpacing: 10,
                              children: ["All", "Limited", "New", "Popular", "Nearby"].map((sortOption) {
                                bool isSelected = selectedSorts.contains(sortOption);
                                return FilterChip(
                                  label: Text(
                                    sortOption,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: isSelected ? Colors.white : Colors.black87,
                                      fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
                                    ),
                                  ),
                                  selected: isSelected,
                                  onSelected: (bool selected) {
                                    setState(() {
                                      selected ? selectedSorts.add(sortOption) : selectedSorts.remove(sortOption);
                                    });
                                  },
                                  backgroundColor: Colors.white,
                                  selectedColor: AppColors.mainBlue,
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    side: BorderSide(
                                      color: isSelected ? Colors.transparent : Colors.grey.shade300,
                                      width: 1.5,
                                    ),
                                  ),
                                  elevation: isSelected ? 1 : 0,
                                  pressElevation: 2,
                                );
                              }).toList(),
                            ),
                            const SizedBox(height: 28),

                            // Budget and Location in a responsive grid layout
                            const Row(
                              children: [
                                Icon(Icons.tune_rounded, color: AppColors.mainBlue, size: 22),
                                SizedBox(width: 8),
                                Text(
                                  "Additional Filters",
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF333333),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            
                            // Budget section with improved styling
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF8F9FA),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: const Color(0xFFE8E8E8), width: 1),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Row(
                                    children: [
                                      Icon(Icons.account_balance_wallet_outlined, size: 18, color: Color(0xFF666666)),
                                      SizedBox(width: 8),
                                      Text(
                                        "Budget",
                                        style: TextStyle(
                                          fontFamily: 'Poppins',
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                          color: Color(0xFF444444),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Container(
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(8),
                                            color: Colors.white,
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black.withOpacity(0.05),
                                                blurRadius: 4,
                                                offset: const Offset(0, 2),
                                              ),
                                            ],
                                          ),
                                          child: TextField(
                                            controller: budgetMinController,
                                            keyboardType: TextInputType.number,
                                            decoration: InputDecoration(
                                              labelText: "Min",
                                              labelStyle: TextStyle(
                                                color: Colors.grey[700],
                                                fontSize: 14,
                                              ),
                                              prefixIcon: Icon(Icons.remove, size: 18, color: Colors.grey[500]),
                                              focusedBorder: OutlineInputBorder(
                                                borderRadius: BorderRadius.circular(8),
                                                borderSide: const BorderSide(color: AppColors.mainBlue, width: 1.5),
                                              ),
                                              enabledBorder: OutlineInputBorder(
                                                borderRadius: BorderRadius.circular(8),
                                                borderSide: BorderSide(color: Colors.grey.shade200, width: 1),
                                              ),
                                              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                                            ),
                                            onChanged: (value) {
                                              setState(() {
                                                budgetMin = double.tryParse(value) ?? 0;
                                              });
                                            },
                                            style: const TextStyle(fontSize: 14),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: Container(
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(8),
                                            color: Colors.white,
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black.withOpacity(0.05),
                                                blurRadius: 4,
                                                offset: const Offset(0, 2),
                                              ),
                                            ],
                                          ),
                                          child: TextField(
                                            controller: budgetMaxController,
                                            keyboardType: TextInputType.number,
                                            decoration: InputDecoration(
                                              labelText: "Max",
                                              labelStyle: TextStyle(
                                                color: Colors.grey[700],
                                                fontSize: 14,
                                              ),
                                              prefixIcon: Icon(Icons.add, size: 18, color: Colors.grey[500]),
                                              focusedBorder: OutlineInputBorder(
                                                borderRadius: BorderRadius.circular(8),
                                                borderSide: const BorderSide(color: AppColors.mainBlue, width: 1.5),
                                              ),
                                              enabledBorder: OutlineInputBorder(
                                                borderRadius: BorderRadius.circular(8),
                                                borderSide: BorderSide(color: Colors.grey.shade200, width: 1),
                                              ),
                                              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                                            ),
                                            onChanged: (value) {
                                              setState(() {
                                                budgetMax = double.tryParse(value);
                                              });
                                            },
                                            style: const TextStyle(fontSize: 14),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),
                            
                            // Location section with improved styling
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF8F9FA),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: const Color(0xFFE8E8E8), width: 1),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Row(
                                    children: [
                                      Icon(Icons.location_on_outlined, size: 18, color: Color(0xFF666666)),
                                      SizedBox(width: 8),
                                      Text(
                                        "Location",
                                        style: TextStyle(
                                          fontFamily: 'Poppins',
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                          color: Color(0xFF444444),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8),
                                      color: Colors.white,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.05),
                                          blurRadius: 4,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: DropdownButtonFormField<String>(
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
                                            style: const TextStyle(
                                              color: Colors.black87,
                                              fontSize: 14,
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
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(8),
                                          borderSide: BorderSide(color: Colors.grey.shade200, width: 1),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(8),
                                          borderSide: BorderSide(color: Colors.grey.shade200, width: 1),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(8),
                                          borderSide: const BorderSide(color: AppColors.mainBlue, width: 1.5),
                                        ),
                                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                                        prefixIcon: Icon(Icons.place_outlined, size: 18, color: Colors.grey[500]),
                                      ),
                                      style: const TextStyle(fontSize: 14),
                                      icon: const Icon(Icons.keyboard_arrow_down, color: AppColors.mainBlue, size: 20),
                                      dropdownColor: Colors.white,
                                      isExpanded: true,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    // Footer actions with improved styling
                    Container(
                      padding: const EdgeInsets.fromLTRB(32, 16, 32, 24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(16),
                          bottomRight: Radius.circular(16),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.1),
                            blurRadius: 4,
                            offset: const Offset(0, -2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Text(
                              "Cancel",
                              style: TextStyle(
                                color: Colors.grey[700],
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.pop(context);
                              _fetchResults(); // Apply filters and search
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.mainBlue,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              elevation: 0,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.filter_list, size: 18),
                                const SizedBox(width: 8),
                                const Text(
                                  "Apply Filters",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    fontFamily: 'Poppins',
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  } else {
    // Original mobile bottom sheet for non-web platforms (unchanged)
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
                        // Original mobile filter UI
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
                                child: const Text(
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
                        // Rest of original mobile UI code...

                        // Apply Button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.pop(context);
                              _fetchResults(); // Trigger search when filters are applied
                            },
                            child: const Text(
                              "Apply",
                              style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.white,
                                  fontFamily: 'poppins'),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.mainBlue,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                              padding:
                                  const EdgeInsets.symmetric(vertical: 20),
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
      listingType: "event",
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
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Container(
          width: double.infinity, // Take full width
          child: Column(
            children: [
              // Full-width header section
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: kIsWeb ? 40 : 16,
                  vertical: kIsWeb ? 24 : 16,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: kIsWeb
                      ? [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ]
                      : null,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                   
           
               

                    // Search and Filter Row
                    Row(
                      children: [
                        // Filter Button
                        GestureDetector(
                          onTap: showFilterDialog,
                          child: Container(
                            height: 50,
                            width: 50,
                            decoration: BoxDecoration(
                              color: AppColors.mainBlue,
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.mainBlue.withOpacity(0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: const Icon(Icons.filter_list,
                                color: Colors.white, size: 24),
                          ),
                        ),
                        const SizedBox(width: 16),

                       Expanded(
  child: Container(

    child: Row(
      children: [
        Expanded(
          child: TextField(
            controller: searchController,
            onChanged: (value) => _fetchResults(),
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.grey.shade100,
              hintText: "Search destinations, activities, events...",
              hintStyle: const TextStyle(
                fontFamily: 'Poppins',
                color: Colors.grey,
                fontSize: 16,
              ),
              prefixIcon: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Icon(Icons.search,
                    color: Colors.grey.shade700, size: 24),
              ),
           
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: BorderSide.none,
              ),
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 16),
            ),
            style: const TextStyle(
              fontSize: 16,
              fontFamily: 'Poppins',
            ),
          ),
        ),
        
      ],
    ),
  ),
),
                      ],
                    ),
                  ],
                ),
              ),

              // Scrollable content area
              Expanded(
                child: SingleChildScrollView(
                  controller: _scrollController,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Categories Section
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.fromLTRB(
                            kIsWeb ? 40 : 16, 24, kIsWeb ? 40 : 16, 24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Search by Categories",
                              style: TextStyle(
                                fontSize: kIsWeb ? 24 : 20,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Poppins',
                                color: Colors.black,
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Categories - wrap for web, horizontal scroll for mobile
                            Container(
                              width: double.infinity,
                              child: kIsWeb
                                  ? Wrap(
                                      spacing: 12,
                                      runSpacing: 12,
                                      children: categories
                                          .map((category) =>
                                              categoryChip(category))
                                          .toList(),
                                    )
                                  : Container(
                                      height: 50,
                                      child: ListView(
                                        scrollDirection: Axis.horizontal,
                                        children: categories
                                            .map((category) =>
                                                categoryChip(category))
                                            .toList(),
                                      ),
                                    ),
                            ),
                          ],
                        ),
                      ),

                      // Results Section - Improved grid/list layout
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.fromLTRB(
                            kIsWeb ? 40 : 16, 16, kIsWeb ? 40 : 16, 30),
                        decoration: BoxDecoration(
                          color: kIsWeb ? Colors.grey.shade50 : Colors.white,
                          borderRadius: kIsWeb
                              ? const BorderRadius.only(
                                  topLeft: Radius.circular(32),
                                  topRight: Radius.circular(32),
                                )
                              : null,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Results header
                            if (searchResults.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 24.0),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "Results (${searchResults.length})",
                                      style: const TextStyle(
                                        fontSize: kIsWeb ? 24 : 20,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: 'Poppins',
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                            // Results grid/list
                            searchResults.isEmpty
                                ? Center(
                                    child: Padding(
                                      padding: const EdgeInsets.all(40.0),
                                      child: Column(
                                        children: [
                                          const Icon(
                                            Icons.search_off,
                                            size: 80,
                                            color: Colors.grey,
                                          ),
                                          const SizedBox(height: 16),
                                          Text(
                                            "No results found",
                                            style: TextStyle(
                                              fontSize: 24,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.grey.shade700,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            "Try adjusting your filters or search terms",
                                            style: TextStyle(
                                              fontSize: 16,
                                              color: Colors.grey.shade600,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                        ],
                                      ),
                                    ),
                                  )
                                : kIsWeb
                                    ? GridView.builder(
                                        shrinkWrap: true,
                                        physics:
                                            const NeverScrollableScrollPhysics(),
                                        gridDelegate:
                                            SliverGridDelegateWithFixedCrossAxisCount(
                                          crossAxisCount: screenWidth > 1600
                                              ? 4
                                              : (screenWidth > 1200
                                                  ? 3
                                                  : (screenWidth > 800
                                                      ? 2
                                                      : 1)),
                                          childAspectRatio: 1.1,
                                          crossAxisSpacing: 24,
                                          mainAxisSpacing: 24,
                                        ),
                                        itemCount: searchResults.length,
                                        itemBuilder: (context, index) {
                                          return EventCard(
                                            context: context,
                                            activity: searchResults[index],
                                          );
                                        },
                                      )
                                    : Column(
                                        children: searchResults.map((activity) {
                                          return EventCard(
                                            context: context,
                                            activity: activity,
                                          );
                                        }).toList(),
                                      ),

                            // Bottom spacing
                            const SizedBox(height: 60),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget categoryChip(String label) {
    bool isSelected = selectedCategories.contains(label);

    return Padding(
      padding: const EdgeInsets.only(right: 8.0, bottom: kIsWeb ? 0 : 0),
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
        child: Container(
          decoration: BoxDecoration(
            color: isSelected ? AppColors.mainBlue : Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected ? AppColors.mainBlue : Colors.grey.shade300,
              width: 1.5,
            ),
            boxShadow: kIsWeb
                ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          padding: const EdgeInsets.symmetric(
              horizontal: kIsWeb ? 20 : 16, vertical: kIsWeb ? 12 : 10),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: kIsWeb ? 16 : 14,
                  fontWeight: FontWeight.w500,
                  color: isSelected ? Colors.white : Colors.grey.shade800,
                ),
              ),
              if (isSelected)
                const Padding(
                  padding: EdgeInsets.only(left: 8.0),
                  child: Icon(
                    Icons.close,
                    size: 16,
                    color: Colors.white,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
