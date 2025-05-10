import 'dart:io';

import 'package:adventura/MyListings/Mylisting.dart';
import 'package:adventura/utils/snackbars.dart';
import 'package:adventura/CreateListing/widgets/category_selector.dart';
import 'package:adventura/CreateListing/widgets/image_selector.dart';
import 'package:adventura/widgets/location_picker.dart';
import 'package:adventura/CreateListing/widgets/title_section.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as gmap;
import 'package:hive/hive.dart';
import 'package:image_picker/image_picker.dart';
import 'package:adventura/services/activity_service.dart';
import 'package:adventura/controllers/create_listing_controller.dart';
import 'package:intl/intl.dart';
import 'widgets/age_selector.dart';
import 'widgets/calendar_date_selector.dart';
import 'widgets/description_section.dart';
import 'widgets/features_section.dart';
import 'widgets/listing_type_selector.dart';
import 'widgets/location_section.dart';
import 'widgets/ticket_price_selector.dart';
import 'widgets/trip_plan_section.dart';
import 'package:adventura/CreateListing/preview_page.dart';
import 'package:path_provider/path_provider.dart';

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
  bool _isUploading = false;
  bool _imageError = false;
  final ImagePicker _picker = ImagePicker();
  final List<XFile> _images = [];
  static const int _maxImages = 10;
  gmap.LatLng? _mapLatLng =
      gmap.LatLng(33.8547, 35.8623); // Defaults to Lebanon
  final controller = CreateListingController();

  int _currentPage = 0;
  final PageController _pageController = PageController();

  // Controller and character count for the title TextField
  final TextEditingController _titleController = TextEditingController();
  int _titleCharCount = 0;

  // Category selection
  Map<String, dynamic>? _selectedCategory;
  List<Map<String, dynamic>> categories = [];

  // Listing Type selection
  ListingType? _selectedListingType;

  // Ticket Price selection dropdown variables
  final TextEditingController _priceController = TextEditingController();
  String _selectedTicketPriceType = 'Person';
  final List<String> _ticketPriceTypes = ['Person', 'Per hour', 'Per day'];

  // Controller + count for Description field
  final TextEditingController _descriptionController = TextEditingController();
  int _currentDescLength = 0;

  // Duration for Recurrent Activities
  Duration? _selectedDuration;

  // Weekdays for Recurrent Activities
  Set<String> _selectedWeekdays = {};
  DateTime? _startDate;
  DateTime? _endDate;

  // Age Allowed
  String? _selectedAge;

  // from / to
  final TextEditingController _fromController = TextEditingController();
  final TextEditingController _toController = TextEditingController();
  TimeOfDay? _fromTime;
  TimeOfDay? _toTime;

  // Trip Plan
  List<bool> _isEditable = [true]; // only last one is editable
  final Map<int, String?> _tripPlanAmPm = {};
  List<Map<String, TextEditingController>> _tripPlanControllers = [
    {
      'time': TextEditingController(),
      'desc': TextEditingController(),
    },
  ];

  // Seats
  final TextEditingController _seatsController = TextEditingController();

  // Features
  // List<TextEditingController> _featureControllers = [TextEditingController()];
  // List<bool> _isFeatureEditable = [true];
  List<String> _selectedFeatures = [];

  // Location
  final TextEditingController _locationDisplayController =
      TextEditingController();

  void _openLocationPicker() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => LocationPicker(initialPosition: _mapLatLng),
      ),
    );

    if (result != null && result is gmap.LatLng) {
      setState(() {
        _mapLatLng = result;
      });
    }
  }

  String _formatTime(TimeOfDay time) {
    final now = DateTime.now();
    final dt = DateTime(now.year, now.month, now.day, time.hour, time.minute);
    return DateFormat('hh:mm a').format(dt); // e.g., "02:00 PM"
  }

  void _updateAmPm(int index, String? value) {
    setState(() {
      _tripPlanAmPm[index] = value;
    });
  }

  // void _submitActivity() async {
  //   // setState(() => _isUploading = true);
  //   bool isRecurrent = _selectedListingType == ListingType.recurrent;

  //   print("Title: ${_titleController.text}");
  //   print("Desc: ${_descriptionController.text}");
  //   print("Location: ${_locationDisplayController.text}");
  //   print("Price: ${_priceController.text}");
  //   print("From: ${_fromController.text}");
  //   print("To: ${_toController.text}");
  //   print("Seats: ${_seatsController.text}");
  //   print("Category: $_selectedCategory");
  //   print("Type: $_selectedListingType");
  //   print("LatLng: $_mapLatLng");
  //   print("Duration: $_selectedDuration");
  //   print("Weekdays: $_selectedWeekdays");
  //   print("Start Date: $_startDate");

  //   if (_titleController.text.trim().isEmpty ||
  //       _descriptionController.text.trim().isEmpty ||
  //       _locationDisplayController.text.trim().isEmpty ||
  //       _priceController.text.trim().isEmpty ||
  //       _seatsController.text.trim().isEmpty ||
  //       _selectedCategory == null ||
  //       _selectedListingType == null ||
  //       _mapLatLng == null ||
  //       (_images.isEmpty) ||
  //       (isRecurrent &&
  //           (_selectedDuration == null ||
  //               _selectedWeekdays.isEmpty ||
  //               _startDate == null ||
  //               _endDate == null))) {
  //     showAppSnackBar(context, "⚠️ Please fill in all required fields.");
  //     return;
  //   }

  //   final tripPlans = _tripPlanControllers.asMap().entries.where((entry) {
  //     final time = entry.value["time"]!.text.trim();
  //     final desc = entry.value["desc"]!.text.trim();
  //     return time.isNotEmpty &&
  //         desc.isNotEmpty &&
  //         _tripPlanAmPm[entry.key] != null;
  //   }).map((entry) {
  //     final index = entry.key;
  //     final time = _tripPlanControllers[index]["time"]!.text.trim();
  //     final desc = _tripPlanControllers[index]["desc"]!.text.trim();
  //     final ampm = _tripPlanAmPm[index]; // 'AM' or 'PM'
  //     return {
  //       "time": "$time $ampm", // 👈 Append AM/PM
  //       "description": desc,
  //     };
  //   }).toList();

  //   setState(() => _isUploading = true);

  //   // final features = _featureControllers
  //   //     .map((f) => f.text.trim())
  //   //     .where((text) => text.isNotEmpty)
  //   //     .toList();

  //   final activityData = {
  //     "name": _titleController.text.trim(),
  //     "description": _descriptionController.text.trim(),
  //     "location": _locationDisplayController.text.trim(),
  //     "price": double.tryParse(_priceController.text) ?? 0.0,
  //     "price_type": _selectedTicketPriceType,
  //     "nb_seats": int.tryParse(_seatsController.text.trim()) ?? 0,
  //     "category_id": _selectedCategory?["id"],
  //     "latitude": _mapLatLng!.latitude,
  //     "longitude": _mapLatLng!.longitude,
  //     "features": _selectedFeatures,
  //     "trip_plan": tripPlans,
  //     "from_time": _fromTime != null ? _formatTime(_fromTime!) : null,
  //     "to_time": _toTime != null ? _formatTime(_toTime!) : null,
  //     "listing_type": _selectedListingType.toString().split('.').last,
  //     // "repeat_weeks": _repeatWeeks,
  //     "start_date": _startDate?.toIso8601String().split("T")[0],
  //     "end_date": _endDate?.toIso8601String().split("T")[0] ??
  //         _startDate?.toIso8601String().split("T")[0],
  //     "repeat_days": _selectedWeekdays.toList(),
  //     "duration_minutes": isRecurrent
  //         ? _selectedDuration?.inMinutes
  //         : _calculateFallbackDurationInMinutes(_fromTime, _toTime),
  //   };
  //   if (_fromTime == null || _toTime == null) {
  //     showAppSnackBar(context, "⚠️ Please select start and end times.");
  //     return;
  //   }

  //   // 🔄 Load images from Hive (saved earlier)
  //   final box = await Hive.openBox('listingFlow');
  //   final imageCount = box.get('listingImageCount', defaultValue: 0);
  //   List<XFile> selectedImages = [];

  //   for (int i = 0; i < imageCount; i++) {
  //     final path = box.get('listingImage_$i');
  //     if (path != null) {
  //       selectedImages.add(XFile(path));
  //     }
  //   }

  //   final success = await ActivityService.createActivity(
  //     activityData,
  //     images: selectedImages, // ✅ Include images here
  //   );

  //   setState(() => _isUploading = false);

  //   if (success) {
  //     showAppSnackBar(context, "✅ Activity created successfully!");

  //     // Optional cleanup
  //     await box.clear();
  //     _clearSavedListingImages();

  //     await Future.delayed(const Duration(milliseconds: 500));
  //     Navigator.pushAndRemoveUntil(
  //       context,
  //       MaterialPageRoute(
  //         builder: (_) => MyListingsPage(cameFromCreation: true),
  //       ),
  //       (route) => false,
  //     );
  //   } else {
  //     showAppSnackBar(context, "❌ Failed to create activity.");
  //   }
  // }

  void _submitActivity() async {
    bool isRecurrent = _selectedListingType == ListingType.recurrent;

    // 🔒 Check if required fields are filled
    final hasRequiredFields = _titleController.text.trim().isNotEmpty &&
        _descriptionController.text.trim().isNotEmpty &&
        _locationDisplayController.text.trim().isNotEmpty &&
        _priceController.text.trim().isNotEmpty &&
        _seatsController.text.trim().isNotEmpty &&
        _selectedCategory != null &&
        _selectedListingType != null &&
        _mapLatLng != null &&
        (_fromTime != null && _toTime != null) &&
        (!isRecurrent ||
            (_selectedDuration != null &&
                _selectedWeekdays.isNotEmpty &&
                _startDate != null &&
                _endDate != null));

    // 🔒 Check image count
    if (_images.isEmpty) {
      setState(() => _imageError = true); // ⛔ Trigger red border
    }

    if (!hasRequiredFields || _images.isEmpty) {
      showAppSnackBar(context,
          "⚠️ Please fill in all required fields and add at least one image.");
      return;
    }

    // ✅ Passed all validation — begin uploading
    setState(() => _isUploading = true);

    final tripPlans = _tripPlanControllers.asMap().entries.where((entry) {
      final time = entry.value["time"]!.text.trim();
      final desc = entry.value["desc"]!.text.trim();
      return time.isNotEmpty &&
          desc.isNotEmpty &&
          _tripPlanAmPm[entry.key] != null;
    }).map((entry) {
      final index = entry.key;
      final time = _tripPlanControllers[index]["time"]!.text.trim();
      final desc = _tripPlanControllers[index]["desc"]!.text.trim();
      final ampm = _tripPlanAmPm[index];
      return {
        "time": "$time $ampm",
        "description": desc,
      };
    }).toList();

    final activityData = {
      "name": _titleController.text.trim(),
      "description": _descriptionController.text.trim(),
      "location": _locationDisplayController.text.trim(),
      "price": double.tryParse(_priceController.text) ?? 0.0,
      "price_type": _selectedTicketPriceType,
      "nb_seats": int.tryParse(_seatsController.text.trim()) ?? 0,
      "category_id": _selectedCategory?["id"],
      "latitude": _mapLatLng!.latitude,
      "longitude": _mapLatLng!.longitude,
      "features": _selectedFeatures,
      "trip_plan": tripPlans,
      "from_time": _formatTime(_fromTime!),
      "to_time": _formatTime(_toTime!),
      "listing_type": _selectedListingType.toString().split('.').last,
      "start_date": _startDate?.toIso8601String().split("T")[0],
      "end_date": _endDate?.toIso8601String().split("T")[0] ??
          _startDate?.toIso8601String().split("T")[0],
      "repeat_days": _selectedWeekdays.toList(),
      "duration_minutes": isRecurrent
          ? _selectedDuration?.inMinutes
          : _calculateFallbackDurationInMinutes(_fromTime, _toTime),
    };

    // 🔄 Load images from Hive
    final box = await Hive.openBox('listingFlow');
    final imageCount = box.get('listingImageCount', defaultValue: 0);
    List<XFile> selectedImages = [];

    for (int i = 0; i < imageCount; i++) {
      final path = box.get('listingImage_$i');
      if (path != null) {
        selectedImages.add(XFile(path));
      }
    }

    final success = await ActivityService.createActivity(
      activityData,
      images: selectedImages,
    );

    setState(() => _isUploading = false);

    if (success) {
      showAppSnackBar(context, "✅ Activity created successfully!");
      await box.clear();
      _clearSavedListingImages();

      await Future.delayed(const Duration(milliseconds: 500));
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (_) => MyListingsPage(cameFromCreation: true),
        ),
        (route) => false,
      );
    } else {
      showAppSnackBar(context, "❌ Failed to create activity.");
    }
  }

  int? _calculateFallbackDurationInMinutes(TimeOfDay? from, TimeOfDay? to) {
    if (from == null || to == null) return null;

    final now = DateTime.now();
    final fromDateTime =
        DateTime(now.year, now.month, now.day, from.hour, from.minute);
    final toDateTime =
        DateTime(now.year, now.month, now.day, to.hour, to.minute);

    final diff = toDateTime.difference(fromDateTime);
    return diff.inMinutes > 0 ? diff.inMinutes : null;
  }

  // A reusable widget method for text fields
  Widget _buildTextFieldBox({
    required TextEditingController controller,
    required String hint,
    IconData? icon,
  }) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF2A2A2A) : Colors.white,
        border: Border.all(
          color: isDarkMode ? Colors.grey[700]! : const Color(0xFFCFCFCF),
          width: 1,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          suffixIcon: icon != null
              ? Icon(
                  icon,
                  color: isDarkMode ? Colors.white : Colors.blue,
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 14,
          ),
          hintText: hint,
          hintStyle: TextStyle(
            color: isDarkMode ? Colors.grey[400] : Colors.blue,
            fontSize: 14,
            fontFamily: 'Poppins',
          ),
        ),
        style: TextStyle(
          color: isDarkMode ? Colors.white : Colors.blue,
          fontSize: 14,
          fontFamily: 'Poppins',
        ),
        cursorColor: isDarkMode ? Colors.white70 : Colors.blue,
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    controller.init(() => setState(() {}));
    _selectedListingType = ListingType.oneTime;

    _fromController.addListener(() => setState(() {}));
    _toController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  // Helper to show a brief SnackBar

  // Picks multiple images from the gallery
  Future<void> _pickImages() async {
    final int remainingSpace = _maxImages - _images.length;
    if (remainingSpace <= 0) {
      showAppSnackBar(context, 'You can only select up to $_maxImages images.');
      return;
    }

    // Show options to user
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Take Photo'),
                onTap: () async {
                  Navigator.pop(context);
                  final XFile? photo =
                      await _picker.pickImage(source: ImageSource.camera);
                  if (photo != null) {
                    setState(() {
                      _images.add(photo);
                      _currentPage = _images.length - 1;
                      _imageError = false;
                    });
                    await _saveImagesToHive();
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Choose from Gallery'),
                onTap: () async {
                  Navigator.pop(context);
                  final List<XFile>? pickedImages =
                      await _picker.pickMultiImage();
                  if (pickedImages != null && pickedImages.isNotEmpty) {
                    final imagesToAdd =
                        pickedImages.take(remainingSpace).toList();

                    setState(() {
                      _images.addAll(imagesToAdd);
                      _currentPage = _images.length - 1;
                      _imageError = false;
                    });

                    await _saveImagesToHive();

                    if (pickedImages.length > remainingSpace) {
                      showAppSnackBar(
                        context,
                        'Only the first $remainingSpace images were added (max $_maxImages).',
                      );
                    }
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _saveImagesToHive() async {
    final box = await Hive.openBox('listingFlow');
    final appDir = await getApplicationDocumentsDirectory(); // Persistent dir

    for (int i = 0; i < _images.length; i++) {
      final file = File(_images[i].path);
      final ext = _images[i].path.split('.').last;
      final newPath = '${appDir.path}/listing_image_$i.$ext';

      final copiedFile =
          await file.copy(newPath); // Copy to persistent location
      await box.put('listingImage_$i', copiedFile.path); // Save new path
    }

    await box.put('listingImageCount', _images.length);
  }

  Future<void> _clearSavedListingImages() async {
    final box = await Hive.openBox('listingFlow');
    final count = box.get('listingImageCount', defaultValue: 0);

    for (int i = 0; i < count; i++) {
      final path = box.get('listingImage_$i');
      if (path != null) {
        final file = File(path);
        if (await file.exists()) await file.delete();
      }
    }

    await box.clear();
  }

  // Clears all selected images
  void _clearImages() async {
    setState(() async {
      _images.clear();
      _currentPage = 0;
    });
    if (_pageController.hasClients) {
      _pageController.jumpToPage(0);
    }
    showAppSnackBar(context, "All images cleared.");
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    final categoryId = _selectedCategory?["id"];
    final List<Map<String, String>> availableFeatures = categoryId != null
        ? List<Map<String, String>>.from(featuresByCategoryId[categoryId] ?? [])
        : [];

    return Stack(children: [
      Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        key: const Key('main_scaffold'),
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
        //  The content is in a SingleChildScrollView, so it can scroll
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
                ImageSelector(
                  images: _images,
                  currentPage: _currentPage,
                  maxImages: _maxImages,
                  pageController: _pageController,
                  onPickImages: _pickImages,
                  onClearImages: _clearImages,
                  showError: _imageError, // 👈 pass the flag here
                ),

                const SizedBox(height: 15),

                // ---------------------------------
                // Title
                // ---------------------------------
                TitleSection(
                  controller: _titleController,
                  currentLength: _titleCharCount,
                  onChanged: (value) {
                    setState(() {
                      _titleCharCount = value.length;
                    });
                  },
                ),

                const SizedBox(height: 22),

                // ---------------------------------
                // Category
                // ---------------------------------
                CategorySelector(
                  selectedCategory: _selectedCategory,
                  onCategorySelected: (cat) {
                    setState(() {
                      _selectedCategory = cat;
                    });
                  },
                ),
                const SizedBox(height: 22),

                // ---------------------------------
                // Listing Type
                // ---------------------------------
                ListingTypeSelector(
                  selectedType: _selectedListingType,
                  onChanged: (newType) {
                    setState(() {
                      _selectedListingType = newType;
                      _selectedDuration =
                          null; // Reset duration when type changes
                      _selectedWeekdays =
                          {}; // Reset weekdays when type changes
                      _startDate = null; // Reset start date when type changes
                      _endDate = null; // Reset end date when type changes
                    });
                  },
                ),

                // ---------------------------------
                // Ticket Price
                // ---------------------------------
                TicketPriceSelector(
                  controller: _priceController,
                  selectedType: _selectedTicketPriceType,
                  types: _ticketPriceTypes,
                  onTypeChanged: (newValue) {
                    setState(() {
                      _selectedTicketPriceType = newValue!;
                    });
                  },
                ),
                const SizedBox(height: 22),
                // ---------------------------------
                // Description
                // ---------------------------------
                DescriptionSection(
                  controller: _descriptionController,
                  currentLength: _currentDescLength,
                  onChanged: (text) {
                    setState(() {
                      _currentDescLength = text.length;
                    });
                  },
                ),
                const SizedBox(height: 10),

                // ---------------------------------
                // Date Section
                // ---------------------------------
                CalendarDateSelector(
                  selectedListingType: _selectedListingType!,
                  onDateRangeSelected: (start, end) {
                    _startDate = start;
                    _endDate = end;
                  },
                  selectedDuration: _selectedDuration,
                  onDurationChanged: (d) =>
                      setState(() => _selectedDuration = d),
                  selectedWeekdays: _selectedWeekdays,
                  onWeekdaysChanged: (days) =>
                      setState(() => _selectedWeekdays = days),
                  onTimeRangeSelected: (from, to) {
                    setState(() {
                      _fromTime = from;
                      _toTime = to;
                    });
                  },
                ),

                const SizedBox(height: 20),

                // ---------------------------------
                // Trip Plan Section
                // ---------------------------------
                TripPlanSection(
                  controllers: _tripPlanControllers,
                  isEditable: _isEditable,
                  onAdd: (index) {
                    final time =
                        _tripPlanControllers[index]['time']!.text.trim();
                    final desc =
                        _tripPlanControllers[index]['desc']!.text.trim();

                    if (time.isNotEmpty && desc.isNotEmpty) {
                      setState(() {
                        _isEditable[index] = false; // lock current
                        _tripPlanControllers.add({
                          'time': TextEditingController(),
                          'desc': TextEditingController(),
                        });
                        _isEditable.add(true); // new one is editable
                      });
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Please fill both fields first."),
                        ),
                      );
                    }
                  },
                  onDelete: (index) {
                    setState(() {
                      _tripPlanControllers.removeAt(index);
                      _isEditable.removeAt(index);
                    });
                  },
                  onReorder: (oldIndex, newIndex) {
                    setState(() {
                      if (newIndex > oldIndex) newIndex -= 1;

                      final item = _tripPlanControllers.removeAt(oldIndex);
                      final editableFlag = _isEditable.removeAt(oldIndex);

                      _tripPlanControllers.insert(newIndex, item);
                      _isEditable.insert(newIndex, editableFlag);
                    });
                  },
                  onAmPmChanged: _updateAmPm,
                  fromTime: _fromTime,
                  toTime: _toTime,
                ),

                const SizedBox(height: 20),

                // ---------------------------------
                // Features
                // ---------------------------------
                FeaturesSection(
                  selectedFeatures: _selectedFeatures,
                  availableFeatures: availableFeatures,
                  onFeatureToggle: (feature) {
                    setState(() {
                      if (_selectedFeatures.contains(feature)) {
                        _selectedFeatures.remove(feature);
                      } else if (_selectedFeatures.length < 5) {
                        _selectedFeatures.add(feature);
                      }
                    });
                  },
                ),

                const SizedBox(height: 20),

                Row(
                  children: const [
                    Text(
                      'Number of Seats',
                      style: TextStyle(
                        fontFamily: 'poppins',
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(width: 8),
                    Expanded(child: Divider(color: Colors.grey)),
                  ],
                ),
                const SizedBox(height: 8),
                _buildTextFieldBox(
                  controller: _seatsController,
                  hint: 'Ex: 20',
                  icon: Icons.event_seat,
                ),
                const SizedBox(height: 8),
                // ---------------------------------
                // Age Allowed
                // ---------------------------------
                AgeSelector(
                  selectedAge: _selectedAge,
                  onChanged: (value) {
                    setState(() {
                      _selectedAge = value;
                    });
                  },
                ),
                const SizedBox(height: 20),

                // ---------------------------------
                // Location
                // ---------------------------------
                LocationSection(
                  locationController: _locationDisplayController,
                  latLng: _mapLatLng,
                  onPickLocation: _openLocationPicker,
                ),

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
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: isDarkMode
                    ? Colors.black.withOpacity(0.4)
                    : Colors.black.withOpacity(0.15),
                blurRadius: 15,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
            child: Container(
              color: isDarkMode ? const Color(0xFF1F1F1F) : Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // PREVIEW BUTTON
                  OutlinedButton(
                    onPressed: () {
                      final builtTripPlan = _tripPlanControllers
                          .where((map) =>
                              map['time']!.text.trim().isNotEmpty &&
                              map['desc']!.text.trim().isNotEmpty)
                          .map((map) => {
                                "time": map['time']!.text.trim(),
                                "description": map['desc']!.text.trim(),
                              })
                          .toList();

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => PreviewPage(
                            title: _titleController.text.trim(),
                            description: _descriptionController.text.trim(),
                            location: _locationDisplayController.text.trim(),
                            features: _selectedFeatures,
                            tripPlan: builtTripPlan,
                            images: _images.isNotEmpty
                                ? _images.map((img) => img.path).toList()
                                : ['assets/Pictures/island.jpg'],
                            mapLatLng: _mapLatLng!,
                            seats:
                                int.tryParse(_seatsController.text.trim()) ?? 0,
                            ageAllowed: _selectedAge,
                            price:
                                int.tryParse(_priceController.text.trim()) ?? 0,
                            priceType: _selectedTicketPriceType,
                          ),
                        ),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(
                          color: Color(0xFF007AFF), width: 1.5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 16),
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

                  // PUBLISH BUTTON
                  ElevatedButton(
                    onPressed: _submitActivity,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF007AFF),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 16),
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
          ),
        ),
      ),
      _buildLoadingOverlay(),
    ]);
  }

  Widget _buildLoadingOverlay() {
    return _isUploading
        ? Container(
            color: Colors.black.withOpacity(0.5),
            child: const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(color: Colors.white),
                  SizedBox(height: 16),
                  Text(
                    "Uploading images...",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontFamily: 'poppins',
                    ),
                  ),
                ],
              ),
            ),
          )
        : const SizedBox.shrink();
  }
}
