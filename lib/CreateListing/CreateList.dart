import 'dart:convert';
import 'dart:io';
import 'package:adventura/config.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map_cancellable_tile_provider/flutter_map_cancellable_tile_provider.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as gmap;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_map/flutter_map.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:latlong2/latlong.dart' as latlong;
import 'package:flutter_dotenv/flutter_dotenv.dart';

// Define an enum for listing type
enum ListingType {
  recurrent,
  oneTime,
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Image Picker Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const CreateListingPage(),
    );
  }
}

class CreateListingPage extends StatefulWidget {
  const CreateListingPage({Key? key}) : super(key: key);

  @override
  State<CreateListingPage> createState() => _CreateListingPageState();
}

class _CreateListingPageState extends State<CreateListingPage> {
  final ImagePicker _picker = ImagePicker();
  final List<XFile> _images = [];
  static const int _maxImages = 10;
  gmap.LatLng? _mapLatLng;
  final MAPBOX_ACCESS_TOKEN = dotenv.env['MAPBOX_TOKEN'];

  int _currentPage = 0;
  final PageController _pageController = PageController();

  // Controller and character count for the title TextField
  final TextEditingController _titleController = TextEditingController();
  int _currentTitleLength = 0;

  // Category selection
  String? _selectedCategoryName;
  List<Map<String, dynamic>> categories = [];

  Future<void> fetchCategories() async {
    try {
      final response = await http.get(Uri.parse("$baseUrl/categories"));

      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);

        if (data.isNotEmpty) {
          setState(() {
            categories = data.cast<Map<String, dynamic>>();
          });
        }
      } else {
        print("❌ Failed to fetch categories: ${response.body}");
      }
    } catch (e) {
      print("❌ Error fetching categories: $e");
    }
  }

  // Listing Type selection
  ListingType? _selectedListingType;

  // Ticket Price selection dropdown variables
  String _selectedTicketPriceType = 'Person';
  final List<String> _ticketPriceTypes = ['Person', 'Per hour', 'Per day'];

  // Controller + count for Description field
  final TextEditingController _descriptionController = TextEditingController();
  int _currentDescLength = 0;

  // Day/Month/Year + Age Allowed
  final List<String> _daysOfWeek = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];

  final List<String> _months = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  // Age Allowed
  final List<String> _ageOptions = ['All Ages', '12+', '18+', '21+'];
  String? _selectedAge;

  final List<int> _years = List.generate(
    DateTime.now().year - 1900 + 1,
    (index) => 1900 + index,
  );

  String _selectedDay = 'Monday';
  String _selectedMonth = 'January';
  int _selectedYear = DateTime.now().year;

  // from / to
  final TextEditingController _fromController = TextEditingController();
  final TextEditingController _toController = TextEditingController();

  // Trip Plan
  final TextEditingController _planTimeController = TextEditingController();
  final TextEditingController _planDescController = TextEditingController();

  // Location
  final TextEditingController _locationDisplayController =
      TextEditingController();
  final TextEditingController _googleMapsUrlController =
      TextEditingController();
  final TextEditingController _locationController = TextEditingController();

  void _parseGoogleMapsUrl() {
    final url = _googleMapsUrlController.text.trim();
    final regex = RegExp(r'@(-?\d+\.\d+),\s*(-?\d+\.\d+)');
    final match = regex.firstMatch(url);

    if (match != null) {
      final lat = double.parse(match.group(1)!);
      final lng = double.parse(match.group(2)!);
      setState(() {
        _mapLatLng = gmap.LatLng(lat, lng);
      });
    } else {
      setState(() {
        _mapLatLng = null;
      });
      _showSnackBar('Invalid Google Maps URL');
    }
  }

  // A reusable widget method for text fields
  Widget _buildTextFieldBox({
    required TextEditingController controller,
    required String hint,
    IconData? icon,
  }) {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFCFCFCF), width: 1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          suffixIcon: icon != null
              ? Icon(
                  icon,
                  color: Colors.blue, // Change icon color here
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 14,
          ),
          hintText: hint,
          hintStyle: const TextStyle(
            color: Colors.grey,
            fontSize: 14,
            fontFamily: 'poppins',
          ),
        ),
        style: const TextStyle(
          color: Colors.black,
          fontSize: 14,
          fontFamily: 'poppins',
        ),
      ),
    );
  }

  // Reusable method for building age-allowed buttons
  Widget _buildAgeButton(String label) {
    final bool isSelected = (_selectedAge == label);

    return InkWell(
      onTap: () {
        setState(() {
          _selectedAge = (isSelected) ? null : label;
        });
      },
      child: Container(
        margin: const EdgeInsets.all(8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? Colors.blue : const Color(0xFFCFCFCF),
            width: 1,
          ),
          borderRadius: BorderRadius.circular(12),
          color: Colors.white,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: 'poppins',
            fontSize: 14,
            color: isSelected ? Colors.blue : Colors.grey[800],
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();

    // Fetch categories from your API when the widget loads
    fetchCategories();

    // Listen for text changes in the title
    _titleController.addListener(() {
      setState(() {
        _currentTitleLength = _titleController.text.length;
      });
    });

    // Listen for text changes in the description
    _descriptionController.addListener(() {
      setState(() {
        _currentDescLength = _descriptionController.text.length;
      });
    });

    // Listen for changes in the Google Maps URL
    _googleMapsUrlController.addListener(() {
      _parseGoogleMapsUrl();
    });
  }

  @override
  void dispose() {
    // Dispose all controllers
    _titleController.dispose();
    _descriptionController.dispose();
    _pageController.dispose();
    _fromController.dispose();
    _toController.dispose();
    _planTimeController.dispose();
    _planDescController.dispose();
    _locationDisplayController.dispose();
    _googleMapsUrlController.dispose();
    super.dispose();
  }

  // Helper to show a brief SnackBar
  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 2)),
    );
  }

  // Picks multiple images from the gallery
  Future<void> _pickImages() async {
    final List<XFile>? pickedImages = await _picker.pickMultiImage();
    if (pickedImages != null && pickedImages.isNotEmpty) {
      final int remainingSpace = _maxImages - _images.length;
      if (remainingSpace <= 0) {
        _showSnackBar('You can only select up to $_maxImages images.');
        return;
      }

      if (pickedImages.length > remainingSpace) {
        final truncatedList = pickedImages.sublist(0, remainingSpace);
        setState(() {
          _images.addAll(truncatedList);
          _currentPage = 0;
        });
        if (_pageController.hasClients) {
          _pageController.jumpToPage(0);
        }
        _showSnackBar(
          'Only the first $remainingSpace images were added (max $_maxImages).',
        );
      } else {
        setState(() {
          _images.addAll(pickedImages);
          _currentPage = 0;
        });
        if (_pageController.hasClients) {
          _pageController.jumpToPage(0);
        }
      }
    }
  }

  // Clears all selected images
  void _clearImages() {
    setState(() {
      _images.clear();
      _currentPage = 0;
    });
    if (_pageController.hasClients) {
      _pageController.jumpToPage(0);
    }
    _showSnackBar("All images cleared.");
  }

  // Shows a bottom sheet containing the list of categories
  Future<void> _showCategorySheet() async {
    final chosenName = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return FractionallySizedBox(
          heightFactor: 0.6,
          child: SafeArea(
            child: Column(
              children: [
                // A small drag handle
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(top: 16, bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey[400],
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                // Scrollable list of categories
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: categories.map((cat) {
                        // Check if this cat is the currently selected one
                        bool isSelected =
                            (cat["name"] == _selectedCategoryName);

                        return InkWell(
                          onTap: () {
                            // On tap, return the category name and close bottom sheet
                            Navigator.pop(context, cat["name"]);
                          },
                          child: Container(
                            margin: const EdgeInsets.symmetric(
                                vertical: 6, horizontal: 16),
                            padding: const EdgeInsets.symmetric(
                                vertical: 12, horizontal: 16),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: isSelected ? Colors.blue : Colors.grey,
                                width: 2,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Center(
                              child: Text(
                                cat["name"] ?? "Unknown",
                                style: TextStyle(
                                  fontFamily: 'poppins',
                                  fontSize: 16,
                                  color:
                                      isSelected ? Colors.blue : Colors.black,
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    // If user tapped a category, chosenName is non-null
    if (chosenName != null) {
      setState(() {
        _selectedCategoryName = chosenName;
      });
    }
  }

  /// Listing-type button
  Widget _buildListingTypeOption({
    required ListingType type,
    required String text,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 45,
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? Colors.blue : Colors.grey,
            width: 1,
          ),
          color: Colors.white,
        ),
        // Center icon + text
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.autorenew,
              color: isSelected ? Colors.blue : Colors.grey,
            ),
            const SizedBox(width: 8),
            Text(
              text,
              style: TextStyle(
                fontFamily: 'poppins',
                fontSize: 15,
                color: isSelected ? Colors.blue : Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final totalImages = _images.length;
    final screenWidth = MediaQuery.of(context).size.width;
    final TextEditingController _featuresController = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Create Listing',
          style: TextStyle(
            fontFamily: 'poppins',
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Color.fromARGB(255, 112, 112, 112),
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),

      // ----------------------------------------------------------------
      // 1) Use bottomNavigationBar to keep the bar pinned at the bottom
      // 2) The content is in a SingleChildScrollView, so it can scroll
      //    independently above the pinned nav bar
      // ----------------------------------------------------------------
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // ---------------------------------
              // Images (Add, Clear, Display)
              // ---------------------------------
              Container(
                width: double.infinity,
                height: screenHeight * 0.25,
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey, width: 2),
                ),
                child: Stack(
                  children: [
                    // If no images, show "Add Photos"
                    _images.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                IconButton(
                                  icon: const Icon(
                                      Icons.add_photo_alternate_outlined),
                                  iconSize: 48,
                                  color: Colors.grey[600],
                                  onPressed: _pickImages,
                                ),
                                const SizedBox(height: 8),
                                const Text(
                                  'Add Photos',
                                  style: TextStyle(
                                    fontFamily: 'poppins',
                                    fontSize: 16,
                                    color: Colors.black54,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: PageView.builder(
                              controller: _pageController,
                              itemCount: totalImages,
                              onPageChanged: (index) {
                                setState(() {
                                  _currentPage = index;
                                });
                              },
                              itemBuilder: (context, index) {
                                return Image.file(
                                  File(_images[index].path),
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  height: double.infinity,
                                );
                              },
                            ),
                          ),
                    // "Clear All" button if images exist
                    if (_images.isNotEmpty)
                      Positioned(
                        bottom: 8,
                        left: 8,
                        child: TextButton(
                          onPressed: _clearImages,
                          style: TextButton.styleFrom(
                            backgroundColor: Colors.grey[300],
                            foregroundColor: Colors.blue,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            textStyle: const TextStyle(
                              fontFamily: 'poppins',
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          child: const Text("Clear All"),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Image info text
              Text(
                _images.isEmpty
                    ? 'Photos: 0/$_maxImages - First photo will be shown in the listing\'s thumbnail'
                    : 'Photos: ${_currentPage + 1}/$totalImages - First photo will be shown in the listing\'s thumbnail',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: "poppins",
                  color: Colors.blue,
                  fontSize: 14,
                ),
              ),

              const SizedBox(height: 15),

              // ---------------------------------
              // Title
              // ---------------------------------
              Row(
                children: [
                  const Text(
                    'Title',
                    style: TextStyle(
                      fontFamily: "poppins",
                      fontSize: 20,
                      color: Colors.black87,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(child: Container(height: 1, color: Colors.grey)),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                height: 50,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: const Color.fromRGBO(167, 167, 167, 1),
                    width: 1,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: TextField(
                  controller: _titleController,
                  maxLength: 30,
                  decoration: InputDecoration(
                    counterText: '',
                    hintText: 'Enter title',
                    hintStyle: const TextStyle(
                      color: Color.fromRGBO(190, 188, 188, 0.87),
                      fontFamily: "poppins",
                      fontSize: 15,
                    ),
                    suffixText: '$_currentTitleLength/30',
                    suffixStyle: const TextStyle(
                      color: Color.fromRGBO(190, 188, 188, 0.87),
                      fontFamily: "poppins",
                      fontSize: 15,
                    ),
                    border: InputBorder.none,
                  ),
                  textAlign: TextAlign.left,
                ),
              ),
              const SizedBox(height: 22),

              // ---------------------------------
              // Category
              // ---------------------------------
              Row(
                children: [
                  const Text(
                    'Category',
                    style: TextStyle(
                      fontFamily: "poppins",
                      fontSize: 20,
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(child: Container(height: 1, color: Colors.grey)),
                ],
              ),
              const SizedBox(height: 12),
              InkWell(
                onTap: _showCategorySheet,
                child: Container(
                  height: 50,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: const Color.fromRGBO(167, 167, 167, 1),
                      width: 1,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _selectedCategoryName ?? 'Select Category',
                        // if it's null, we show 'Select Category'
                        style: TextStyle(
                          fontFamily: "poppins",
                          fontSize: 15,
                          color: _selectedCategoryName == null
                              ? const Color.fromRGBO(190, 188, 188, 0.87)
                              : Colors.black,
                        ),
                      ),
                      const Icon(
                        Icons.arrow_circle_up,
                        color: Color.fromRGBO(190, 188, 188, 0.87),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 22),

              // ---------------------------------
              // Listing Type
              // ---------------------------------
              Row(
                children: [
                  const Text(
                    'Listing Type',
                    style: TextStyle(
                      fontFamily: "poppins",
                      fontSize: 20,
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(child: Container(height: 1, color: Colors.grey)),
                ],
              ),
              const SizedBox(height: 12),
              Column(
                children: [
                  _buildListingTypeOption(
                    type: ListingType.recurrent,
                    text: "Recurrent Activity",
                    isSelected: _selectedListingType == ListingType.recurrent,
                    onTap: () {
                      setState(() {
                        _selectedListingType = ListingType.recurrent;
                      });
                    },
                  ),
                  _buildListingTypeOption(
                    type: ListingType.oneTime,
                    text: "One-time Event",
                    isSelected: _selectedListingType == ListingType.oneTime,
                    onTap: () {
                      setState(() {
                        _selectedListingType = ListingType.oneTime;
                      });
                    },
                  ),

                  // ---------------------------------
                  // Ticket Price
                  // ---------------------------------
                  Row(
                    children: [
                      const Text(
                        'Ticket Price',
                        style: TextStyle(
                          fontFamily: "poppins",
                          fontSize: 20,
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(child: Container(height: 1, color: Colors.grey)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 50,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey, width: 1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  keyboardType: TextInputType.number,
                                  decoration: const InputDecoration(
                                    border: InputBorder.none,
                                    hintText: '0',
                                    hintStyle: TextStyle(
                                      fontFamily: 'poppins',
                                      fontSize: 15,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  style: const TextStyle(
                                    fontFamily: 'poppins',
                                    fontSize: 15,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                              const Text(
                                '\$',
                                style: TextStyle(
                                  fontFamily: 'poppins',
                                  fontSize: 15,
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        '/',
                        style: TextStyle(
                          fontFamily: 'poppins',
                          fontSize: 18,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        height: 50,
                        width: 100,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey, width: 1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _selectedTicketPriceType,
                            icon: const Icon(Icons.arrow_drop_down,
                                color: Colors.black),
                            isExpanded: true,
                            items: _ticketPriceTypes.map((String type) {
                              return DropdownMenuItem<String>(
                                value: type,
                                child: Text(
                                  type,
                                  style: const TextStyle(
                                    fontFamily: 'poppins',
                                    fontSize: 15,
                                    color: Colors.black,
                                  ),
                                ),
                              );
                            }).toList(),
                            onChanged: (String? newValue) {
                              setState(() {
                                _selectedTicketPriceType = newValue!;
                              });
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.info, color: Colors.blue, size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Putting 0 will make this ticket for Free.',
                          style: const TextStyle(
                            fontFamily: 'poppins',
                            fontSize: 11,
                            color: Colors.blue,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.info, color: Colors.blue, size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Select whether the ticket is per (Person, Hour, Day, etc..)',
                          style: const TextStyle(
                            fontFamily: 'poppins',
                            fontSize: 11,
                            color: Colors.blue,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              // ---------------------------------
              // Description
              // ---------------------------------
              const SizedBox(height: 22),
              Row(
                children: [
                  const Text(
                    'Description',
                    style: TextStyle(
                      fontFamily: "poppins",
                      fontSize: 20,
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(child: Container(height: 1, color: Colors.grey)),
                ],
              ),
              const SizedBox(height: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    width: screenWidth * 0.9,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: const Color.fromRGBO(167, 167, 167, 1),
                        width: 1,
                      ),
                      borderRadius: BorderRadius.circular(screenWidth * 0.03),
                    ),
                    child: Stack(
                      children: [
                        TextField(
                          controller: _descriptionController,
                          maxLines: 6,
                          maxLength: 250,
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: screenWidth * 0.04,
                              vertical: screenHeight * 0.015,
                            ),
                            hintText: 'Enter your description...',
                            hintStyle: TextStyle(
                              color: const Color.fromRGBO(190, 188, 188, 0.87),
                              fontFamily: "poppins",
                              fontSize: screenWidth * 0.04,
                            ),
                            // Removing the default counter text
                            counterText: '',
                          ),
                          style: TextStyle(
                            fontFamily: 'poppins',
                            fontSize: screenWidth * 0.04,
                            color: Colors.black,
                          ),
                        ),
                        Positioned(
                          bottom: screenHeight * 0.005,
                          right: screenWidth * 0.04,
                          child: Text(
                            '$_currentDescLength/250',
                            style: TextStyle(
                              fontFamily: 'poppins',
                              fontSize: screenWidth * 0.03,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.015),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.info, color: Colors.blue, size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Write an engaging description to attract participants',
                          style: const TextStyle(
                            fontFamily: 'poppins',
                            fontSize: 10,
                            color: Colors.blue,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // ---------------------------------
                  // Date Section
                  // ---------------------------------
                  Row(
                    children: [
                      const Text(
                        'Date',
                        style: TextStyle(
                          fontFamily: "poppins",
                          fontSize: 20,
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Container(height: 1, color: Colors.grey),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      // Day dropdown
                      Expanded(
                        child: Container(
                          height: 50,
                          decoration: BoxDecoration(
                            border: Border.all(
                                color: const Color(0xFFCFCFCF), width: 1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: _selectedDay,
                              icon: const Icon(Icons.arrow_drop_down,
                                  color: Colors.grey),
                              isExpanded: true,
                              style: const TextStyle(
                                fontSize: 9,
                                fontFamily: 'poppins',
                                color: Colors.black,
                              ),
                              onChanged: (String? newValue) {
                                setState(() {
                                  _selectedDay = newValue!;
                                });
                              },
                              items: _daysOfWeek.map((day) {
                                return DropdownMenuItem<String>(
                                  value: day,
                                  child: Text(day),
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),

                      // Month dropdown
                      Expanded(
                        child: Container(
                          height: 50,
                          decoration: BoxDecoration(
                            border: Border.all(
                                color: const Color(0xFFCFCFCF), width: 1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: _selectedMonth,
                              icon: const Icon(Icons.arrow_drop_down,
                                  color: Colors.grey),
                              isExpanded: true,
                              style: const TextStyle(
                                fontSize: 10,
                                fontFamily: 'poppins',
                                color: Colors.black,
                              ),
                              onChanged: (String? newValue) {
                                setState(() {
                                  _selectedMonth = newValue!;
                                });
                              },
                              items: _months.map((month) {
                                return DropdownMenuItem<String>(
                                  value: month,
                                  child: Text(
                                    month,
                                    style: const TextStyle(color: Colors.black),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),

                      // Year dropdown
                      Expanded(
                        child: Container(
                          height: 50,
                          decoration: BoxDecoration(
                            border: Border.all(
                                color: const Color(0xFFCFCFCF), width: 1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<int>(
                              value: _selectedYear,
                              icon: const Icon(Icons.arrow_drop_down,
                                  color: Colors.grey),
                              isExpanded: true,
                              style: const TextStyle(
                                fontSize: 14,
                                fontFamily: 'poppins',
                                color: Colors.black,
                              ),
                              onChanged: (int? newValue) {
                                setState(() {
                                  _selectedYear = newValue!;
                                });
                              },
                              items: _years.map((year) {
                                return DropdownMenuItem<int>(
                                  value: year,
                                  child: Text(year.toString()),
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // from / To text fields
                  Row(
                    children: [
                      Expanded(
                        child: _buildTextFieldBox(
                          controller: _fromController,
                          hint: 'from',
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildTextFieldBox(
                          controller: _toController,
                          hint: 'To',
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // ---------------------------------
              // Trip Plan Section
              // ---------------------------------
              Row(
                children: [
                  const Text(
                    'Trip Plan',
                    style: TextStyle(
                      fontFamily: 'poppins',
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(child: Container(height: 1, color: Colors.grey)),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Container with Time on top, divider, Description below
                  Expanded(
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: const Color(0xFFCFCFCF),
                              width: 1,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Time
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 10,
                                ),
                                child: TextField(
                                  controller: _planTimeController,
                                  decoration: const InputDecoration(
                                    border: InputBorder.none,
                                    hintText: 'Time',
                                    isDense: true,
                                  ),
                                  style: const TextStyle(
                                    fontFamily: 'poppins',
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                              const Divider(
                                height: 1,
                                color: Color(0xFFCFCFCF),
                              ),
                              // Description
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 10,
                                ),
                                child: TextField(
                                  controller: _planDescController,
                                  decoration: const InputDecoration(
                                    border: InputBorder.none,
                                    hintText: 'Description',
                                    isDense: true,
                                  ),
                                  style: const TextStyle(
                                    fontFamily: 'poppins',
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Gray handle (just a decorative bracket)
                        Positioned(
                          right: -10,
                          top: 40,
                          child: Container(
                            width: 20,
                            height: 32,
                            decoration: BoxDecoration(
                              color: Colors.grey[300],
                              borderRadius: BorderRadius.circular(4),
                            ),
                            alignment: Alignment.center,
                            child: const Text(
                              ']',
                              style: TextStyle(
                                fontFamily: 'poppins',
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Black circular plus button
                  Container(
                    width: 30,
                    height: 30,
                    decoration: const BoxDecoration(
                      color: Colors.black,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon:
                          const Icon(Icons.add, color: Colors.white, size: 16),
                      onPressed: () {
                        // TODO: Add logic to add more plan checkpoints
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // Info row: "Add trip/activity plan checkpoints..."
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Icon(Icons.info, color: Colors.blue, size: 18),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Add trip/activity plan checkpoints at its specific time',
                      style: TextStyle(
                        fontFamily: 'poppins',
                        fontSize: 12,
                        color: Colors.blue,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // ---------------------------------
              // Features
              // ---------------------------------
              Row(
                children: [
                  const Text(
                    'Features',
                    style: TextStyle(
                      fontFamily: "poppins",
                      fontSize: 20,
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Container(height: 1, color: Colors.grey),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Row for the text field container + black plus button
                  Row(
                    children: [
                      Flexible(
                        child: SizedBox(
                          width: 150,
                          child: Container(
                            height: 50,
                            decoration: BoxDecoration(
                              border: Border.all(
                                  color: const Color(0xFFCFCFCF), width: 1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: TextField(
                              controller: _featuresController,
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                hintText: 'Ex: Entertainment',
                                hintStyle: TextStyle(
                                  fontFamily: 'poppins',
                                  fontSize: 14,
                                  color: Colors.grey,
                                ),
                              ),
                              style: const TextStyle(
                                fontFamily: 'poppins',
                                fontSize: 14,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        width: 30,
                        height: 30,
                        decoration: const BoxDecoration(
                          color: Colors.black,
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          iconSize: 16,
                          icon: const Icon(Icons.add, color: Colors.white),
                          onPressed: () {
                            // TODO: Implement "Add" logic
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Icon(Icons.info, color: Colors.blue, size: 18),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          "Add what's featured in the activity/event.",
                          style: TextStyle(
                            fontFamily: 'poppins',
                            fontSize: 12,
                            color: Colors.blue,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // ---------------------------------
                  // Age Allowed
                  // ---------------------------------
                  Row(
                    children: [
                      const Text(
                        'Age Allowed',
                        style: TextStyle(
                          fontFamily: "poppins",
                          fontSize: 20,
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Container(height: 1, color: Colors.grey),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _buildAgeButton('All Ages'),
                      _buildAgeButton('12+'),
                      _buildAgeButton('18+'),
                      _buildAgeButton('21+'),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // ---------------------------------
                  // Location
                  // ---------------------------------
                  Row(
                    children: [
                      const Text(
                        'Location',
                        style: TextStyle(
                          fontFamily: "poppins",
                          fontSize: 20,
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Container(height: 1, color: Colors.grey),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildTextFieldBox(
                    controller: _locationDisplayController,
                    hint: 'Add Location to Display',
                  ),
                  const SizedBox(height: 8),
                  _buildTextFieldBox(
                    controller: _googleMapsUrlController,
                    hint: 'Add Google Maps Url',
                    icon: Icons.link_sharp,
                  ),
                  const SizedBox(height: 8),
                  if (_mapLatLng != null)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: SizedBox(
                        height: 180,
                        child: kIsWeb ? _buildWebMap() : _buildNativeMap(),
                      ),
                    )
                  else
                    Container(
                      height: 180,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        "Waiting for valid location...",
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                ],
              ),
              // End of scrollable content
              const SizedBox(
                  height: 50), // Extra space so we can scroll under nav
            ],
          ),
        ),
      ),

      // ----------------------------------------------------------------
      // Bottom nav is always pinned & visible
      // ----------------------------------------------------------------
      bottomNavigationBar: Container(
        height: 60,
        color: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // PREVIEW (Outlined) button
            OutlinedButton(
              onPressed: () {
                // TODO: Handle "Preview" action
              },
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFF007AFF), width: 1.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 24),
              ),
              child: const Text(
                'Preview',
                style: TextStyle(
                  color: Color(0xFF007AFF),
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),

            // PUBLISH (Filled) button
            ElevatedButton(
              onPressed: () {
                // TODO: Handle "Publish" action
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF007AFF),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 24),
              ),
              child: const Text(
                'Publish',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWebMap() {
    return FlutterMap(
      options: MapOptions(
        center: latlong.LatLng(_mapLatLng!.latitude, _mapLatLng!.longitude),
        zoom: 14,
        interactiveFlags: InteractiveFlag.all,
        onTap: (_, __) async {
          final url = Uri.parse(
              "https://www.google.com/maps/search/?api=1&query=${_mapLatLng!.latitude},${_mapLatLng!.longitude}");
          await launchUrl(url, mode: LaunchMode.externalApplication);
        },
      ),
      children: [
        TileLayer(
          urlTemplate:
              'https://api.mapbox.com/styles/v1/mapbox/streets-v11/tiles/{z}/{x}/{y}?access_token=$MAPBOX_ACCESS_TOKEN',
          tileProvider: CancellableNetworkTileProvider(),
        ),
        MarkerLayer(
          markers: [
            Marker(
              point:
                  latlong.LatLng(_mapLatLng!.latitude, _mapLatLng!.longitude),
              width: 40,
              height: 40,
              child:
                  const Icon(Icons.location_pin, color: Colors.red, size: 32),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildNativeMap() {
    return GestureDetector(
      onTap: () async {
        final url = Uri.parse(
            "https://www.google.com/maps/search/?api=1&query=${_mapLatLng!.latitude},${_mapLatLng!.longitude}");
        await launchUrl(url, mode: LaunchMode.externalApplication);
      },
      child: gmap.GoogleMap(
        initialCameraPosition: gmap.CameraPosition(
          target: _mapLatLng!,
          zoom: 14,
        ),
        markers: {
          gmap.Marker(
            markerId: const gmap.MarkerId('location'),
            position: _mapLatLng!,
            infoWindow: const gmap.InfoWindow(title: "Selected Location"),
          ),
        },
        zoomControlsEnabled: false,
        myLocationButtonEnabled: false,
      ),
    );
  }
}
