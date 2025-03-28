import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as gmap;
import 'package:adventura/services/activity_service.dart';
import 'package:adventura/utils/location_utils.dart';

class CreateListingController {
  // 📌 Text Controllers
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final locationDisplayController = TextEditingController();
  final googleMapsUrlController = TextEditingController();

  final fromTimeController = TextEditingController();
  final toTimeController = TextEditingController();
  final planTimeController = TextEditingController();
  final planDescController = TextEditingController();
  final featuresController = TextEditingController();

  // 📌 Page State
  int currentTitleLength = 0;
  int currentDescLength = 0;

  // 📌 Dropdowns & Selections
  String? selectedCategoryName;
  List<Map<String, dynamic>> categories = [];

  String selectedTicketPriceType = 'Person';
  String? selectedAge;
  ListingType? selectedListingType;

  String selectedDay = 'Monday';
  String selectedMonth = 'January';
  int selectedYear = DateTime.now().year;

  gmap.LatLng? selectedLatLng;
  String? fallbackPlaceName;

  Timer? _debounce;

  // 📌 Lifecycle setup
  void init(VoidCallback onUpdate) {
    fetchCategories(onUpdate);

    titleController.addListener(() => onUpdate());
    descriptionController.addListener(() => onUpdate());

    googleMapsUrlController.addListener(() {
      if (_debounce?.isActive ?? false) _debounce!.cancel();
      _debounce = Timer(const Duration(milliseconds: 1500), () {
        parseGoogleMapsUrl(onUpdate);
      });
    });
  }

  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    locationDisplayController.dispose();
    googleMapsUrlController.dispose();
    fromTimeController.dispose();
    toTimeController.dispose();
    planTimeController.dispose();
    planDescController.dispose();
    featuresController.dispose();
  }

  // 📌 API call for categories
  Future<void> fetchCategories(VoidCallback onUpdate) async {
    categories = await ActivityService.fetchCategories();
    onUpdate();
  }

  void parseGoogleMapsUrl(VoidCallback onUpdate) async {
    final url = googleMapsUrlController.text.trim();
    String? resolvedUrl = url;

    selectedLatLng = null;

    if (url.contains('goo.gl') || url.contains('maps.app.goo.gl')) {
      resolvedUrl = await resolveShortLink(url);
      if (resolvedUrl == null) return;
    }

    final coords = extractLatLng(resolvedUrl!);
    if (coords != null) {
      selectedLatLng = gmap.LatLng(coords[0], coords[1]);
    } else {
      fallbackPlaceName = extractPlaceName(resolvedUrl);
    }

    onUpdate();
  }
}

// Optional: export listing type
enum ListingType {
  recurrent,
  oneTime,
}
