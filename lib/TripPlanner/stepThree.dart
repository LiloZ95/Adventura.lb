import 'package:adventura/TripPlanner/categoryShip.dart';
import 'package:adventura/TripPlanner/progressBar.dart';
import 'package:flutter/material.dart';

class StepThreeCategories extends StatefulWidget {
  const StepThreeCategories({super.key});

  @override
  State<StepThreeCategories> createState() => _StepThreeCategoriesState();
}

class _StepThreeCategoriesState extends State<StepThreeCategories> {
  final int _currentStep = 3;
  final int _totalSteps = 4;

  final List<String> allCategories = [
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

  final Set<String> selectedCategories = {};

  void _toggleCategory(String category) {
    setState(() {
      if (selectedCategories.contains(category)) {
        selectedCategories.remove(category);
      } else {
        selectedCategories.add(category);
      }
    });
  }

  void _onNext() {
    if (selectedCategories.isNotEmpty) {
      print("Selected Categories: $selectedCategories");
      // TODO: Proceed to Step 4
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select at least one category.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
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
              "What are you interested in?",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: allCategories
                  .map((cat) => CategoryChip(
                        label: cat,
                        isSelected: selectedCategories.contains(cat),
                        onTap: () => _toggleCategory(cat),
                      ))
                  .toList(),
            ),
            const Spacer(),
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
