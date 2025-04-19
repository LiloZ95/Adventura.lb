import 'package:adventura/MyListings/Mylisting.dart';
import 'package:adventura/utils/snackbars.dart';
import 'package:adventura/CreateListing/widgets/category_selector.dart';
import 'package:adventura/CreateListing/widgets/image_selector.dart';
import 'package:adventura/widgets/location_picker.dart';
import 'package:adventura/CreateListing/widgets/title_section.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as gmap;
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

  void _submitActivity() async {
    bool isRecurrent = _selectedListingType == ListingType.recurrent;

    print("Title: ${_titleController.text}");
    print("Desc: ${_descriptionController.text}");
    print("Location: ${_locationDisplayController.text}");
    print("Price: ${_priceController.text}");
    print("From: ${_fromController.text}");
    print("To: ${_toController.text}");
    print("Seats: ${_seatsController.text}");
    print("Category: $_selectedCategory");
    print("Type: $_selectedListingType");
    print("LatLng: $_mapLatLng");
    print("Duration: $_selectedDuration");
    print("Weekdays: $_selectedWeekdays");
    print("Start Date: $_startDate");

    if (_titleController.text.trim().isEmpty ||
        _descriptionController.text.trim().isEmpty ||
        _locationDisplayController.text.trim().isEmpty ||
        _priceController.text.trim().isEmpty ||
        _seatsController.text.trim().isEmpty ||
        _selectedCategory == null ||
        _selectedListingType == null ||
        _mapLatLng == null ||
        (isRecurrent &&
            (_selectedDuration == null ||
                _selectedWeekdays.isEmpty ||
                _startDate == null ||
                _endDate == null))) {
      showAppSnackBar(context, "⚠️ Please fill in all required fields.");
      return;
    }

    final tripPlans = _tripPlanControllers
        .where((plan) =>
            plan["time"]!.text.trim().isNotEmpty &&
            plan["desc"]!.text.trim().isNotEmpty)
        .map((plan) => {
              "time": plan["time"]!.text.trim(),
              "description": plan["desc"]!.text.trim(),
            })
        .toList();

    // final features = _featureControllers
    //     .map((f) => f.text.trim())
    //     .where((text) => text.isNotEmpty)
    //     .toList();

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
      "from_time": _fromTime != null ? _formatTime(_fromTime!) : "",
      "to_time": _toTime != null ? _formatTime(_toTime!) : "",
      "listing_type": _selectedListingType.toString().split('.').last,
      // "repeat_weeks": _repeatWeeks,
      "start_date": _startDate?.toIso8601String().split("T")[0],
      "end_date": _endDate?.toIso8601String().split("T")[0] ??
          _startDate?.toIso8601String().split("T")[0],
      "repeat_days": _selectedWeekdays.toList(),
      "duration_minutes": _selectedDuration?.inMinutes ?? 60,
    };
    if (_fromTime == null || _toTime == null) {
      showAppSnackBar(context, "⚠️ Please select start and end times.");
      return;
    }

    final success = await ActivityService.createActivity(activityData);

    if (success) {
      showAppSnackBar(context, "✅ Activity created successfully!");

      // Delay briefly so the snackbar is visible before navigating
      await Future.delayed(const Duration(milliseconds: 500));

      // Push to MyListingsPage and remove this screen from back stack
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
            builder: (_) => MyListingsPage(cameFromCreation: true)),
        (route) => false,
      );
    } else {
      showAppSnackBar(context, "❌ Failed to create activity.");
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
    final List<XFile>? pickedImages = await _picker.pickMultiImage();
    if (pickedImages != null && pickedImages.isNotEmpty) {
      final int remainingSpace = _maxImages - _images.length;
      if (remainingSpace <= 0) {
        showAppSnackBar(
            context, 'You can only select up to $_maxImages images.');
        return;
      }

      final imagesToAdd = pickedImages.take(remainingSpace).toList();

      setState(() {
        _images.addAll(imagesToAdd);
        _currentPage = _images.length - 1;
      });

      if (_pageController.hasClients) {
        _pageController.jumpToPage(_currentPage);
      }

      if (pickedImages.length > remainingSpace) {
        showAppSnackBar(
          context,
          'Only the first $remainingSpace images were added (max $_maxImages).',
        );
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
    showAppSnackBar(context, "All images cleared.");
  }

  @override
  Widget build(BuildContext context) {
    final categoryId = _selectedCategory?["id"];
    final List<Map<String, String>> availableFeatures = categoryId != null
        ? List<Map<String, String>>.from(featuresByCategoryId[categoryId] ?? [])
        : [];

    return (Scaffold(
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
              ImageSelector(
                images: _images,
                currentPage: _currentPage,
                maxImages: _maxImages,
                pageController: _pageController,
                onPickImages: _pickImages,
                onClearImages: _clearImages,
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
                    _selectedWeekdays = {}; // Reset weekdays when type changes
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
                onDurationChanged: (d) => setState(() => _selectedDuration = d),
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
                  final time = _tripPlanControllers[index]['time']!.text.trim();
                  final desc = _tripPlanControllers[index]['desc']!.text.trim();

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
        height: 60,
        color: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // PREVIEW (Outlined) button
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

                // final builtFeatures = _featureControllers
                //     .map((c) => c.text.trim())
                //     .where((text) => text.isNotEmpty)
                //     .toList();

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
                      seats: int.tryParse(_seatsController.text.trim()) ?? 0,
                      ageAllowed: _selectedAge,
                      price: int.tryParse(_priceController.text.trim()) ?? 0,
                      priceType: _selectedTicketPriceType,
                    ),
                  ),
                );
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
                _submitActivity();
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
    ));
  }
}
