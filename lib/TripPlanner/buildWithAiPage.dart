import 'dart:convert';

import 'package:adventura/TripPlanner/categoryShip.dart';
import 'package:adventura/TripPlanner/locationTile.dart';
import 'package:adventura/TripPlanner/progressBar.dart';
import 'package:adventura/TripPlanner/tripSummary.dart';
import 'package:adventura/config.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class BuildWithAIPage extends StatefulWidget {
  const BuildWithAIPage({super.key});

  @override
  State<BuildWithAIPage> createState() => _BuildWithAIPageState();
}

class _BuildWithAIPageState extends State<BuildWithAIPage> {
  int _selectedDays = 1;
  int _currentStep = 0;
  final int _totalSteps = 4;
  final Map<String, int> categoryNameToId = {
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
  bool isLoading = false;

  void submitTripPlan() async {
    final selectedCategoryIds = selectedCategories
        .map((name) => categoryNameToId[name])
        .whereType<int>()
        .toList();

    if (_startDate == null ||
        selectedLocations.isEmpty ||
        selectedCategoryIds.isEmpty) {
      _showError("Missing some trip info.");
      return;
    }

    setState(() => isLoading = true);

    final body = {
      "trip_request": true,
      "nb_attendees": selectedAttendees,
      "location": selectedLocations.contains("All over Lebanon")
          ? null
          : selectedLocations.toList(),
      "category_ids": selectedCategoryIds,
      "start_date": DateFormat('yyyy-MM-dd').format(_startDate!),
      "nb_days": int.parse(_daysController.text)
    };

    final response = await http.post(
      Uri.parse('$chabotUrl/chat'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(body),
    );

    setState(() => isLoading = false);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      // 👇 Push to TripResultPage and await result
      final shouldRefresh = await Navigator.push<bool>(
        context,
        MaterialPageRoute(
          builder: (_) => TripResultPage(plan: data["trip_plan"]),
        ),
      );

      // 👇 If trip was saved, pop back to MyTripsPage and trigger reload
      if (shouldRefresh == true && mounted) {
        Navigator.pop(context, true);
      }
    } else {
      final error =
          jsonDecode(response.body)['error'] ?? "Trip generation failed.";
      _showError(error);
    }
  }

  final TextEditingController _daysController = TextEditingController();
  DateTime? _startDate;

  final List<String> locations = [
    "Beirut",
    "Batroun",
    "Byblos",
    "Tripoli",
    "Baalbek",
    "Tyre",
    "Zahle",
    "Ehden",
    "Bcharre",
    "Deir el Qamar",
    "All over Lebanon"
  ];
  Set<String> selectedLocations = {};

  final List<String> categories = [
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
    "Museums",
  ];
  Set<String> selectedCategories = {};

  int? selectedAttendees;

  void _nextStep() {
    switch (_currentStep) {
      case 0:
        if (_daysController.text.isEmpty || _startDate == null) {
          _showError("Please enter duration and select a start date.");
          return;
        }
        break;
      case 1:
        if (selectedLocations.isEmpty) {
          _showError("Please select at least one location.");
          return;
        }
        break;
      case 2:
        if (selectedCategories.isEmpty) {
          _showError("Please select at least one interest.");
          return;
        }
        break;
      case 3:
        if (selectedAttendees == null) {
          _showError("Please select the number of attendees.");
          return;
        }
        submitTripPlan(); // 🚀 Trigger the trip generation!
        return;
    }

    setState(() => _currentStep++);
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  void _pickStartDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: DateTime(now.year + 2),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Colors.blue, // Header background color
              onPrimary: Colors.white, // Header text/icon color
              onSurface: Colors.black, // Default text color
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: Colors.blue, // Button text color
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _startDate = picked);
    }
  }

  Widget _buildAttendeeOption(String title, String emoji, int value) {
    final isSelected = selectedAttendees == value;

    return GestureDetector(
      onTap: () => setState(() => selectedAttendees = value),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(20),
        width: double.infinity,
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue.shade50 : Colors.white,
          border: Border.all(
            color: isSelected ? Colors.blue : Colors.grey.shade300,
            width: 1.5,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Text(emoji,
                style: const TextStyle(
                  fontSize: 24,
                  fontFamily: 'poppins',
                )),
            const SizedBox(width: 16),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.blue : Colors.black,
                fontFamily: 'poppins',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepContent() {
    switch (_currentStep) {
      case 0:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "When is your trip?",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                fontFamily: 'poppins',
              ),
            ),
            const SizedBox(height: 24),

            // 🟦 Slider for duration
            Text(
              "Duration: ${_selectedDays} day${_selectedDays > 1 ? 's' : ''}",
              style: TextStyle(
                fontSize: 16,
                fontFamily: 'poppins',
                color: Colors.grey[800],
              ),
            ),
            SliderTheme(
              data: SliderTheme.of(context).copyWith(
                activeTrackColor: Colors.blue,
                inactiveTrackColor: Colors.grey.shade300,
                thumbColor: Colors.blue,
                overlayColor: Colors.blue.withOpacity(0.2),
                trackHeight: 4,
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
                overlayShape: const RoundSliderOverlayShape(overlayRadius: 18),
                valueIndicatorShape: const PaddleSliderValueIndicatorShape(),
                valueIndicatorColor: Colors.blue,
                valueIndicatorTextStyle: const TextStyle(
                  color: Colors.white,
                  fontFamily: 'poppins',
                ),
              ),
              child: Slider(
                value: _selectedDays.toDouble(),
                min: 1,
                max: 7,
                divisions: 6,
                label: "$_selectedDays days",
                onChanged: (value) {
                  setState(() {
                    _selectedDays = value.toInt();
                    _daysController.text = _selectedDays.toString();
                  });
                },
              ),
            ),

            const SizedBox(height: 24),

            // 🗓️ Start date picker
            GestureDetector(
              onTap: _pickStartDate,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _startDate != null
                          ? DateFormat.yMMMd().format(_startDate!)
                          : "Pick a start date",
                      style: TextStyle(
                        fontSize: 16,
                        color: _startDate != null
                            ? Colors.black
                            : Colors.grey[600],
                        fontFamily: 'poppins',
                      ),
                    ),
                    const Icon(Icons.calendar_today,
                        size: 20, color: Colors.grey),
                  ],
                ),
              ),
            ),
          ],
        );

      case 1:
        final isAllLebanon = selectedLocations.contains("All over Lebanon");
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Where are you going?",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'poppins',
                )),
            const SizedBox(height: 16),
            Expanded(
              child: ListView(
                children: locations.map((loc) {
                  final isDisabled = isAllLebanon && loc != "All over Lebanon";
                  final isSelected = selectedLocations.contains(loc);
                  return LocationTile(
                    location: loc,
                    isSelected: isSelected,
                    isDisabled: isDisabled,
                    onTap: () {
                      setState(() {
                        if (loc == "All over Lebanon") {
                          if (selectedLocations.contains("All over Lebanon")) {
                            // 🔁 Toggle off "All over Lebanon"
                            selectedLocations.remove("All over Lebanon");
                          } else {
                            // ✅ Select only "All over Lebanon", clear others
                            selectedLocations = {"All over Lebanon"};
                          }
                        } else {
                          if (selectedLocations.contains("All over Lebanon")) {
                            // ❌ Prevent adding cities when "All over Lebanon" is selected
                            return;
                          }

                          if (selectedLocations.contains(loc)) {
                            // 🔄 Deselect city
                            selectedLocations.remove(loc);
                          } else if (selectedLocations.length < 3) {
                            // ✅ Add city only if under limit
                            selectedLocations.add(loc);
                          } else {
                            // ⚠️ Max limit reached — optional feedback
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                    "You can select up to 3 locations only."),
                                duration: Duration(seconds: 2),
                              ),
                            );
                          }
                        }
                      });
                    },
                  );
                }).toList(),
              ),
            ),
          ],
        );

      case 2:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("What are you interested in?",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'poppins',
                )),
            const SizedBox(height: 16),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: categories.map((cat) {
                final isSelected = selectedCategories.contains(cat);
                return CategoryChip(
                  label: cat,
                  isSelected: isSelected,
                  onTap: () {
                    setState(() {
                      if (isSelected) {
                        selectedCategories.remove(cat);
                      } else {
                        selectedCategories.add(cat);
                      }
                    });
                  },
                );
              }).toList(),
            ),
          ],
        );

      case 3:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("How many people are going?",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'poppins',
                )),
            const SizedBox(height: 20),
            _buildAttendeeOption("Solo", "👤", 1),
            _buildAttendeeOption("Duo", "👥", 2),
            _buildAttendeeOption("Triple", "👨‍👩‍👧", 3),
            _buildAttendeeOption("4 or more", "🧑‍🤝‍🧑", 4),
          ],
        );

      default:
        return const SizedBox();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Build with AI",
          style: TextStyle(fontFamily: "poppins"),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (_currentStep > 0) {
              setState(() => _currentStep--);
            } else {
              Navigator.pop(context); // Exit the page if already at step 0
            }
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            StepProgressBar(
                currentStep: _currentStep + 1, totalSteps: _totalSteps),
            const SizedBox(height: 16),
            Expanded(child: _buildStepContent()),
            const SizedBox(height: 16),
            Row(
              children: [
                if (_currentStep > 0) // Only show back if not on first step
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        setState(() {
                          _currentStep--;
                        });
                      },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text(
                        "Back",
                        style: TextStyle(
                          fontFamily: 'poppins',
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                if (_currentStep > 0)
                  const SizedBox(width: 16), // spacing between buttons
                Expanded(
                  child: ElevatedButton(
                    onPressed: _nextStep,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text(
                            _currentStep == _totalSteps - 1
                                ? "Generate Trip"
                                : "Next",
                            style: const TextStyle(
                                color: Colors.white,
                                fontFamily: 'poppins',
                                fontWeight: FontWeight.bold,
                                fontSize: 16),
                          ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
