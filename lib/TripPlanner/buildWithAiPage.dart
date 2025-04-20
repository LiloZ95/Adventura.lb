import 'package:adventura/TripPlanner/categoryShip.dart';
import 'package:adventura/TripPlanner/locationTile.dart';
import 'package:adventura/TripPlanner/progressBar.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class BuildWithAIPage extends StatefulWidget {
  const BuildWithAIPage({super.key});

  @override
  State<BuildWithAIPage> createState() => _BuildWithAIPageState();
}

class _BuildWithAIPageState extends State<BuildWithAIPage> {
  int _currentStep = 0;
  final int _totalSteps = 4;

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
        break;
    }

    if (_currentStep < _totalSteps - 1) {
      setState(() => _currentStep++);
    } else {
      print("✅ GENERATE ITINERARY");
      print("Days: ${_daysController.text}");
      print("Start Date: ${DateFormat.yMMMd().format(_startDate!)}");
      print("Locations: $selectedLocations");
      print("Categories: $selectedCategories");
      print("Attendees: $selectedAttendees");
    }
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
          color: isSelected ? Colors.deepPurple.shade50 : Colors.white,
          border: Border.all(
            color: isSelected ? Colors.deepPurple : Colors.grey.shade300,
            width: 1.5,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 24)),
            const SizedBox(width: 16),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.deepPurple : Colors.black,
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
            const Text("When is your trip?",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            TextField(
              controller: _daysController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: "How many days?",
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 24),
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
                      ),
                    ),
                    const Icon(Icons.calendar_today, size: 20),
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
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
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
                          selectedLocations = {"All over Lebanon"};
                        } else {
                          if (selectedLocations.contains("All over Lebanon")) {
                            selectedLocations.remove("All over Lebanon");
                          }
                          if (isSelected) {
                            selectedLocations.remove(loc);
                          } else {
                            selectedLocations.add(loc);
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
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
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
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
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
      appBar: AppBar(title: const Text("Build with AI"), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            StepProgressBar(
                currentStep: _currentStep + 1, totalSteps: _totalSteps),
            const SizedBox(height: 16),
            Expanded(child: _buildStepContent()),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _nextStep,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: Text(
                    _currentStep == _totalSteps - 1 ? "Generate Trip" : "Next"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
