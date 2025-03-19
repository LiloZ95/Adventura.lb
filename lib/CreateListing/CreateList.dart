import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

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

  int _currentPage = 0;
  final PageController _pageController = PageController();

  // Controller and character count for the title TextField
  final TextEditingController _titleController = TextEditingController();
  int _currentTitleLength = 0;

  // Category selection
  String? _selectedCategory;
  final List<String> _categories = [
    "sea trip",
    "picnic",
    "paragliding",
    "sunsets",
    "tours",
    "car events",
    "festivals",
    "hikes",
    "snow skiing",
    "Boat",
    "JetSki",
    "Museums",
  ];

  // Listing Type selection
  ListingType? _selectedListingType;

  @override
  void initState() {
    super.initState();
    // Listen for text changes in the title
    _titleController.addListener(() {
      setState(() {
        _currentTitleLength = _titleController.text.length;
      });
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _pageController.dispose();
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
    final chosenCategory = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return FractionallySizedBox(
          heightFactor: 0.6,
          child: SafeArea(
            child: Column(
              children: [
                // Drag handle
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(top: 16, bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.grey[400],
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
                // Scrollable list of categories
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ..._categories.map((category) {
                          return InkWell(
                            onTap: () {
                              Navigator.pop(context, category);
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              child: Center(
                                child: Text(
                                  category,
                                  style: const TextStyle(
                                    fontFamily: 'poppins',
                                    fontSize: 17,
                                    color: Colors.black87,
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (chosenCategory != null) {
      setState(() {
        _selectedCategory = chosenCategory;
      });
    }
  }

  /// Listing-type button
  /// - Removes default ripple/highlight effect
  /// - Text & icon turn blue if selected
  /// - Otherwise, border is grey, icon is grey, text is black
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
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Container for images
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
                                  icon: const Icon(Icons.add_photo_alternate_outlined),
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

              // Title row with divider
              Row(
                children: [
                  const Text(
                    'Title',
                    style: TextStyle(
                      fontFamily: "poppins",
                      fontSize: 22,
                      color: Colors.black87,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Container(
                      height: 1,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Title field
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

              // Category row with divider
              Row(
                children: [
                  const Text(
                    'Category',
                    style: TextStyle(
                      fontFamily: "poppins",
                      fontSize: 22,
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Container(
                      height: 1,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Category selection
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
                        _selectedCategory ?? 'Select Category',
                        style: TextStyle(
                          fontFamily: "poppins",
                          fontSize: 15,
                          color: _selectedCategory == null
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

              // Listing Type row with divider
              Row(
                children: [
                  const Text(
                    'Listing Type',
                    style: TextStyle(
                      fontFamily: "poppins",
                      fontSize: 22,
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Container(
                      height: 1,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Two listing-type buttons, each on its own line
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

                  // Ticket Price row with divider
                  Row(
                    children: [
                      const Text(
                        'Ticket Price',
                        style: TextStyle(
                          fontFamily: "poppins",
                          fontSize: 22,
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Container(
                          height: 1,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Ticket Price Input Row
                  Row(
                    children: [
                      // Price input container
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
                              // Actual text field for price
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
                              // Dollar sign
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
                      // Separator (vertical bar or slash)
                      const Text(
                        '/',
                        style: TextStyle(
                          fontFamily: 'poppins',
                          fontSize: 18,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(width: 8),
                      // "Person" container (could be a dropdown in the future)
                      Container(
                        height: 50,
                        width: 100,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey, width: 1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Text(
                              'Person',
                              style: TextStyle(
                                fontFamily: 'poppins',
                                fontSize: 15,
                                color: Colors.black,
                              ),
                            ),
                            SizedBox(width: 4),
                            Icon(
                              Icons.arrow_drop_down,
                              color: Colors.black,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Info lines
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.info,
                        color: Colors.blue,
                        size: 18,
                      ),
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
                      const Icon(
                        Icons.info,
                        color: Colors.blue,
                        size: 18,
                      ),
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
            ],
          ),
        ),
      ),
    );
  }
}
