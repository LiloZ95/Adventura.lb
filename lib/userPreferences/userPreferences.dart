import 'dart:convert';
import 'package:adventura/colors.dart';
import 'package:adventura/web/homeweb.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:adventura/config.dart';
import 'package:hive/hive.dart';
import 'package:adventura/widgets/bouncing_dots_loader.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:ui' as ui;
import 'package:google_fonts/google_fonts.dart';

class Favorite extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        textTheme: GoogleFonts.poppinsTextTheme(
          Theme.of(context).textTheme,
        ),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF3D5A8E),
          primary: const Color(0xFF3D5A8E),
          secondary: const Color(0xFF2DCE98),
        ),
      ),
      home: EventSelectionScreen(),
    );
  }
}

class EventSelectionScreen extends StatefulWidget {
  @override
  _EventSelectionScreenState createState() => _EventSelectionScreenState();
}

class _EventSelectionScreenState extends State<EventSelectionScreen>
    with SingleTickerProviderStateMixin {
  List<Map<String, dynamic>> categories = [];
  List<Map<String, dynamic>> selectedPreferences = [];
  final int minSelections = 1;
  final int maxSelections = 5;
  String? errorMessage;
  bool isLoading = true;
  late AnimationController _animationController;

  // Category icon mapping for visual enhancement
  final Map<String, IconData> categoryIcons = {
    "Adventure": Icons.terrain_rounded,
    "Sports": Icons.sports_basketball_rounded,
    "Food": Icons.restaurant_rounded,
    "Art": Icons.palette_rounded,
    "Music": Icons.music_note_rounded,
    "Nature": Icons.forest_rounded,
    "Technology": Icons.computer_rounded,
    "Education": Icons.school_rounded,
    "Beach": Icons.beach_access_rounded,
    "Travel": Icons.flight_rounded,
    "Health": Icons.favorite_rounded,
    "Shopping": Icons.shopping_bag_rounded,
    "Entertainment": Icons.movie_rounded,
    "Photography": Icons.camera_alt_rounded,
    "History": Icons.history_edu_rounded,
    "Wildlife": Icons.pets_rounded,
    "Nightlife": Icons.nightlife_rounded,
    "Relaxation": Icons.spa_rounded,
  };

  // Colors for category cards
  final List<Color> categoryColors = [
    const Color(0xFF3D5A8E), // Main Blue
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    fetchCategories();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> fetchCategories() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final response = await http.get(Uri.parse("$baseUrl/categories"));

      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);

        if (data.isNotEmpty) {
          setState(() {
            categories = data
                .map((item) => {
                      "id": item["category_id"] ?? 0,
                      "name": item["name"] ?? "Unknown Category"
                    })
                .toList();
            isLoading = false;
          });
        } else {
          setState(() {
            isLoading = false;
          });
        }
      } else {
        print("Failed to fetch categories: ${response.body}");
        setState(() {
          isLoading = false;
          errorMessage = "We couldn't load the categories. Please try again.";
        });
      }
    } catch (e) {
      print("Error fetching categories: $e");
      setState(() {
        isLoading = false;
        errorMessage =
            "Connection error. Please check your internet and try again.";
      });
    }
  }

  Future<void> _savePreferences() async {
    if (selectedPreferences.length < minSelections) {
      setState(() {
        errorMessage =
            "Please select at least $minSelections category to continue.";
      });
      return;
    }

    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final Box authBox = await Hive.openBox('authBox');
      String? userId = authBox.get("userId");
      String? accessToken = authBox.get("accessToken");

      if (userId == null || accessToken == null) {
        print("No user ID or token found in Hive!");
        setState(() {
          isLoading = false;
          errorMessage = "Session expired. Please login again.";
        });
        return;
      }

      final response = await http.post(
        Uri.parse("$baseUrl/users/preferences"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $accessToken"
        },
        body: jsonEncode(
            {"userId": int.parse(userId), "preferences": selectedPreferences}),
      );

      if (response.statusCode == 200) {
        print("Preferences saved successfully!");
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) => const AdventuraWebHomee()));
      } else {
        print("Failed to save preferences. Server response: ${response.body}");
        setState(() {
          isLoading = false;
          errorMessage = "We couldn't save your preferences. Please try again.";
        });
      }
    } catch (e) {
      print("Error saving preferences: $e");
      setState(() {
        isLoading = false;
        errorMessage =
            "Connection error. Please check your internet and try again.";
      });
    }
  }

  // Get an appropriate icon for the category
  IconData _getCategoryIcon(String categoryName) {
    // Try exact match
    if (categoryIcons.containsKey(categoryName)) {
      return categoryIcons[categoryName]!;
    }

    // Try partial match (case insensitive)
    for (var entry in categoryIcons.entries) {
      if (categoryName.toLowerCase().contains(entry.key.toLowerCase())) {
        return entry.value;
      }
    }

    // Default fallback
    return Icons.interests_rounded;
  }

  // Get a color for a category (cycles through the colors based on index)
  Color _getCategoryColor(int index) {
    return categoryColors[index % categoryColors.length];
  }

  // Web layout with masonry-style grid - modified for more compact categories
  Widget _buildWebCategoriesGrid() {
    int crossAxisCount = 5; // Adjusted to make cards narrower
    double screenWidth = MediaQuery.of(context).size.width;

    // Responsive grid adjustments for different screen sizes
    if (screenWidth < 1400) crossAxisCount = 8;
    if (screenWidth < 1100) crossAxisCount = 7;
    if (screenWidth < 800) crossAxisCount = 6;
    if (screenWidth < 500) crossAxisCount = 4;

    // Calculate how many items will fit in 2 rows
    int itemsInTwoRows = crossAxisCount * 2;
    
    // Ensure we don't exceed the number of available categories
    int displayCount = categories.length > itemsInTwoRows ? itemsInTwoRows : categories.length;

    return Container(
      width: screenWidth > 1200 
          ? screenWidth * 0.9
          : MediaQuery.of(context).size.width * 0.98,
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          childAspectRatio: 1.2, // REDUCED from 1.4 to 1.2 to make cards narrower
          crossAxisSpacing: 12, // REDUCED from 15 to 12
          mainAxisSpacing: 12, // REDUCED from 15 to 12
        ),
        itemCount: displayCount, // LIMITED to show only 2 rows
        itemBuilder: (context, index) {
          final category = categories[index];
          final String categoryName = category["name"] ?? "Unknown";
          final IconData iconData = _getCategoryIcon(categoryName);
          final Color categoryColor = _getCategoryColor(index);
          final bool isSelected = selectedPreferences
              .any((p) => p['category_id'] == category['id']);
          final bool isDisabled =
              selectedPreferences.length >= maxSelections && !isSelected;

          return AnimatedScale(
            scale: isSelected ? 1.03 : 1.0,
            duration: const Duration(milliseconds: 200),
            child: GestureDetector(
              onTap: isDisabled
                  ? null
                  : () {
                      setState(() {
                        if (isSelected) {
                          selectedPreferences.removeWhere(
                              (p) => p['category_id'] == category['id']);
                        } else if (selectedPreferences.length < maxSelections) {
                          selectedPreferences.add({
                            "category_id": category['id'],
                            "preference_level": 3,
                          });
                          // Play selection animation
                          _animationController.reset();
                          _animationController.forward();
                        }
                        errorMessage = null;
                      });
                    },
              child: Container(
                decoration: BoxDecoration(
                  color: isSelected
                      ? categoryColor.withOpacity(0.15)
                      : Colors.white,
                  borderRadius: BorderRadius.circular(14), // REDUCED from 16 to 14
                  border: Border.all(
                    color: isSelected
                        ? categoryColor.withOpacity(0.8)
                        : Colors.grey.withOpacity(0.2),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: isSelected
                          ? categoryColor.withOpacity(0.25)
                          : Colors.black.withOpacity(0.05),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    // Selection indicator
                    if (isSelected)
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: categoryColor,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.check,
                            color: Colors.white,
                            size: 14,
                          ),
                        ),
                      ),

                    // Main content
                    Padding(
                      padding: const EdgeInsets.all(10), // REDUCED from 12 to 10
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Category icon
                          Container(
                            padding: const EdgeInsets.all(8), // REDUCED from 10 to 8
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? categoryColor.withOpacity(0.2)
                                  : categoryColor.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              iconData,
                              size: 24, // REDUCED from 26 to 24
                              color: isSelected
                                  ? categoryColor
                                  : categoryColor.withOpacity(0.7),
                            ),
                          ),
                          const SizedBox(height: 6), // REDUCED from 8 to 6

                          // Category name
                          Text(
                            categoryName,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(
                              fontSize: 15, // REDUCED from 16 to 15
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.w500,
                              color:
                                  isSelected ? categoryColor : Colors.black87,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),

                    // Disabled overlay
                    if (isDisabled)
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.7),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Center(
                            child: Text(
                              "Max selected",
                              style: GoogleFonts.poppins(
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w500,
                                fontSize: 14,
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
    );
  }

  // Progress indicator - MODIFIED to take full width
  Widget _buildProgressIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: 20, vertical: 16),
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Selection count
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Your selections",
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: selectedPreferences.length >= minSelections
                      ? const Color(0xFF3D5A8E)
                          .withOpacity(0.15)
                      : Colors.grey[200],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  "${selectedPreferences.length}/$maxSelections",
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold,
                    color: selectedPreferences.length >= minSelections
                        ? const Color(0xFF3D5A8E)
                        : Colors.grey[700],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Progress bar - MODIFIED to use full width
          Container(
            height: 8,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeOutQuart,
                  width: MediaQuery.of(context).size.width * 
                      (selectedPreferences.isEmpty
                          ? 0.05
                          : selectedPreferences.length / maxSelections), 
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFF3D5A8E),
                        Color(0xFF3D5A8E),
                      ],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // Status message
          Text(
            selectedPreferences.isEmpty
                ? "Select categories to personalize your experience"
                : selectedPreferences.length < minSelections
                    ? "Select at least $minSelections category to continue"
                    : selectedPreferences.length == maxSelections
                        ? "Great! You've selected the maximum number of categories"
                        : "Nice! You can select ${maxSelections - selectedPreferences.length} more",
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: selectedPreferences.length >= minSelections
                  ? const Color(0xFF3D5A8E)
                  : Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  // Main build method
  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isWideScreen = screenWidth > 1000;

    return Scaffold(
      body: Stack(
        children: [
          // Background with subtle pattern
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/Pictures/island.jpg"),
                fit: BoxFit.cover,
                opacity: 0.1,
              ),
            ),
            child: BackdropFilter(
              filter: ui.ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.white.withOpacity(0.95),
                      const Color(0xFFF8FDFF).withOpacity(0.95),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Main content
          SafeArea(
            child: Center(
              child: Container(
                width: isWideScreen ? screenWidth * 0.95 : double.infinity,
                child: Column(
                  children: [
                    // App bar - REDUCED vertical spacing
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "iVENTU",
                            style: GoogleFonts.poppins(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF3D5A8E),
                            ),
                          ),

                          // Skip button
                          TextButton(
                            onPressed: () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const AdventuraWebHomee(),
                                ),
                              );
                            },
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                            ),
                            child: Row(
                              children: [
                                Text(
                                  "Skip for now",
                                  style: GoogleFonts.poppins(
                                    color: Colors.grey[700],
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Icon(
                                  Icons.arrow_forward_rounded,
                                  size: 16,
                                  color: Colors.grey[700],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Content area - REDUCED padding
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // Header - REDUCED top margin
                            Container(
                              margin: const EdgeInsets.only(bottom: 12, top: 8),
                              child: Column(
                                children: [
                                  Text(
                                    'Tailor Your Adventure',
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.poppins(
                                      fontSize: isWideScreen ? 36 : 30,
                                      fontWeight: FontWeight.bold,
                                      foreground: Paint()
                                        ..shader = ui.Gradient.linear(
                                          const Offset(0, 0),
                                          const Offset(300, 0),
                                          [
                                            const Color(0xFF3D5A8E),
                                            const Color(0xFF2B4170),
                                          ],
                                        ),
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Container(
                                    width:
                                        isWideScreen ? 700 : screenWidth * 0.95,
                                    child: Text(
                                      'Select categories that excite you the most. We\'ll use your preferences to recommend activities and destinations that match your interests.',
                                      textAlign: TextAlign.center,
                                      style: GoogleFonts.poppins(
                                        fontSize: isWideScreen ? 18 : 16,
                                        color: Colors.grey[700],
                                        height: 1.4,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 16),

                            // Progress indicator
                            _buildProgressIndicator(),

                            // Loading state
                            if (isLoading)
                              Container(
                                height: 240,
                                child: Center(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const BouncingDotsLoader(
                                        color: Color(0xFF3D5A8E),
                                        size: 16.0,
                                      ),
                                      const SizedBox(height: 20),
                                      Text(
                                        'Loading your personalization options...',
                                        style: GoogleFonts.poppins(
                                          color: Colors.grey[600],
                                          fontSize: 16,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )

                            // Empty state
                            else if (categories.isEmpty)
                              Container(
                                height: 240,
                                child: Center(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.category_rounded,
                                        size: 64,
                                        color: Colors.grey[300],
                                      ),
                                      const SizedBox(height: 20),
                                      Text(
                                        'No categories available',
                                        style: GoogleFonts.poppins(
                                          fontSize: 20,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.grey[700],
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                      ElevatedButton.icon(
                                        onPressed: fetchCategories,
                                        icon: const Icon(Icons.refresh_rounded),
                                        label: const Text('Try Again'),
                                        style: ElevatedButton.styleFrom(
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(30),
                                          ),
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 24,
                                            vertical: 12,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )

                            // Categories display
                            else
                              _buildWebCategoriesGrid(),

                            const SizedBox(height: 16),

                            // Error message
                            if (errorMessage != null)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 12, horizontal: 20),
                                margin: const EdgeInsets.symmetric(vertical: 12),
                                decoration: BoxDecoration(
                                  color: Colors.red[50],
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: Colors.red[100]!),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.error_outline_rounded,
                                      color: Colors.red[700],
                                      size: 24,
                                    ),
                                    const SizedBox(width: 16),
                                    Flexible(
                                      child: Text(
                                        errorMessage!,
                                        style: GoogleFonts.poppins(
                                          color: Colors.red[700],
                                          fontWeight: FontWeight.w500,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                            const SizedBox(height: 30),

                            // Continue button - WIDENED
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              width: isWideScreen ? 350 : 400, // INCREASED from 250/300 to 350/400
                              height: 56,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(28),
                                gradient: LinearGradient(
                                  colors: selectedPreferences.length >=
                                          minSelections
                                      ? [
                                          const Color(0xFF3D5A8E),
                                          const Color(0xFF3D5A8E),
                                        ]
                                      : [Colors.grey[400]!, Colors.grey[500]!],
                                  begin: Alignment.centerLeft,
                                  end: Alignment.centerRight,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: selectedPreferences.length >=
                                            minSelections
                                        ? const Color(0xFF3D5A8E).withOpacity(0.3)
                                        : Colors.black.withOpacity(0.1),
                                    blurRadius: 15,
                                    offset: const Offset(0, 5),
                                  ),
                                ],
                              ),
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  shadowColor: Colors.transparent,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(28),
                                  ),
                                  padding: EdgeInsets.zero,
                                ),
                                onPressed: selectedPreferences.length >=
                                            minSelections &&
                                        !isLoading
                                    ? _savePreferences
                                    : null,
                                child: isLoading
                                    ? const Center(
                                        child: SizedBox(
                                          width: 24,
                                          height: 24,
                                          child: CircularProgressIndicator(
                                            color: Colors.white,
                                            strokeWidth: 3,
                                          ),
                                        ),
                                      )
                                    : Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 20),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              'Continue',
                                              style: GoogleFonts.poppins(
                                                fontSize: 18,
                                                fontWeight: FontWeight.w600,
                                                color: Colors.white,
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            const Icon(
                                              Icons.arrow_forward_rounded,
                                              color: Colors.white,
                                              size: 20,
                                            ),
                                          ],
                                        ),
                                      ),
                              ),
                            ),
                            const SizedBox(height: 40),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}