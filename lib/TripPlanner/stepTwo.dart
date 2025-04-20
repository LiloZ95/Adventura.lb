import 'package:adventura/TripPlanner/locationTile.dart';
import 'package:adventura/TripPlanner/progressBar.dart';
import 'package:flutter/material.dart';

class StepTwoLocation extends StatefulWidget {
  const StepTwoLocation({super.key});

  @override
  State<StepTwoLocation> createState() => _StepTwoLocationState();
}

class _StepTwoLocationState extends State<StepTwoLocation> {
  final int _currentStep = 2;
  final int _totalSteps = 4;

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
    "All over Lebanon",
  ];

  Set<String> selectedLocations = {};

  void _toggleSelection(String location) {
    setState(() {
      if (location == "All over Lebanon") {
        selectedLocations = {"All over Lebanon"};
      } else {
        if (selectedLocations.contains("All over Lebanon")) {
          selectedLocations.remove("All over Lebanon");
        }
        if (selectedLocations.contains(location)) {
          selectedLocations.remove(location);
        } else {
          selectedLocations.add(location);
        }
      }
    });
  }

  void _onNext() {
    if (selectedLocations.isNotEmpty) {
      print("Selected Locations: $selectedLocations");
      // TODO: Proceed to Step 3
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select at least one location.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isAllLebanonSelected = selectedLocations.contains("All over Lebanon");

    return Scaffold(
      appBar: AppBar(
        title: const Text("Build with AI"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            StepProgressBar(currentStep: _currentStep, totalSteps: _totalSteps),
            const SizedBox(height: 16),
            const Text(
              "Where are you going?",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: locations.length,
                itemBuilder: (context, index) {
                  final loc = locations[index];
                  final isDisabled =
                      isAllLebanonSelected && loc != "All over Lebanon";
                  final isSelected = selectedLocations.contains(loc);
                  return LocationTile(
                    location: loc,
                    isSelected: isSelected,
                    isDisabled: isDisabled,
                    onTap: () => _toggleSelection(loc),
                  );
                },
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _onNext,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text("Next", style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
