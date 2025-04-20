import 'package:adventura/config.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class TripPlannerPage extends StatefulWidget {
  @override
  _TripPlannerPageState createState() => _TripPlannerPageState();
}

class _TripPlannerPageState extends State<TripPlannerPage> {
  int currentStep = 0;
  DateTime? startDate;
  int numberOfDays = 1;
  int attendees = 1;
  List<String> selectedLocations = [];
  List<int> selectedCategories = [];

  final List<String> availableLocations = [
    'Tripoli',
    'Batroun',
    'Ehden',
    'Byblos'
  ];
  final Map<int, String> categoryMap = {
    1: 'Sea Trips',
    2: 'Picnic',
    3: 'Paragliding',
    4: 'Sunsets',
    5: 'Tours',
    6: 'Car Events',
    7: 'Festivals',
    8: 'Hikes',
    9: 'Snow Skiing',
    10: 'Boats',
    11: 'Jetski',
    12: 'Museums'
  };

  bool isLoading = false;

  void submitTripPlan() async {
    if (startDate == null ||
        selectedLocations.isEmpty ||
        selectedCategories.isEmpty) return;

    setState(() => isLoading = true);

    final response = await http.post(
      Uri.parse('$chabotUrl/chat'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "trip_request": true,
        "nb_attendees": attendees,
        "location": selectedLocations,
        "category_ids": selectedCategories,
        "start_date": DateFormat('yyyy-MM-dd').format(startDate!),
        "nb_days": numberOfDays
      }),
    );
    print("📬 Status: ${response.statusCode}");
    print("🧾 Body: ${response.body}");
    setState(() => isLoading = false);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => TripResultPage(plan: data["trip_plan"]),
        ),
      );
    } else {
      final errorData = jsonDecode(response.body);
      final errorMessage = errorData['error'] ?? "Failed to generate trip.";
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(errorMessage)));
    }
  }

  Widget buildStepIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(4, (index) {
        return Container(
          width: 20,
          height: 20,
          margin: EdgeInsets.symmetric(horizontal: 6),
          decoration: BoxDecoration(
            color: currentStep == index ? Colors.blue : Colors.grey[300],
            shape: BoxShape.circle,
          ),
        );
      }),
    );
  }

  Widget buildStepContent() {
    switch (currentStep) {
      case 0:
        return Column(
          children: [
            ListTile(
              title: Text("Start Date:"),
              trailing: Text(startDate != null
                  ? DateFormat('MMM dd, yyyy').format(startDate!)
                  : "Pick"),
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(Duration(days: 365)),
                );
                if (picked != null) setState(() => startDate = picked);
              },
            ),
            ListTile(
              title: Text("Number of Days: $numberOfDays"),
              trailing: IconButton(
                icon: Icon(Icons.add),
                onPressed: () => setState(() => numberOfDays++),
              ),
            ),
          ],
        );
      case 1:
        return Column(
          children: [
            Text("Attendees: $attendees", style: TextStyle(fontSize: 16)),
            Slider(
              min: 1,
              max: 10,
              value: attendees.toDouble(),
              divisions: 9,
              label: attendees.toString(),
              onChanged: (val) => setState(() => attendees = val.toInt()),
            ),
          ],
        );
      case 2:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: availableLocations.map((loc) {
            final isSelected = selectedLocations.contains(loc);
            return FilterChip(
              label: Text(loc),
              selected: isSelected,
              onSelected: (_) {
                setState(() {
                  if (isSelected) {
                    selectedLocations.remove(loc);
                  } else {
                    selectedLocations.add(loc);
                  }
                });
              },
            );
          }).toList(),
        );
      case 3:
        return Wrap(
          spacing: 8,
          children: categoryMap.entries.map((entry) {
            final selected = selectedCategories.contains(entry.key);
            return FilterChip(
              label: Text(entry.value),
              selected: selected,
              onSelected: (_) {
                setState(() {
                  if (selected) {
                    selectedCategories.remove(entry.key);
                  } else {
                    selectedCategories.add(entry.key);
                  }
                });
              },
            );
          }).toList(),
        );
      default:
        return Container();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Trip Planner"),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Text("Welcome to your personalized trip planner ✨",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 12),
            buildStepIndicator(),
            SizedBox(height: 24),
            Expanded(child: buildStepContent()),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (currentStep > 0)
                  TextButton(
                    onPressed: () => setState(() => currentStep--),
                    child: Text("Back"),
                  ),
                if (currentStep < 3)
                  ElevatedButton(
                    onPressed: () => setState(() => currentStep++),
                    child: Text("Next"),
                  ),
                if (currentStep == 3)
                  ElevatedButton(
                    onPressed: isLoading ? null : submitTripPlan,
                    child: isLoading
                        ? CircularProgressIndicator(color: Colors.white)
                        : Text("Plan My Trip"),
                  ),
              ],
            )
          ],
        ),
      ),
    );
  }
}

class TripResultPage extends StatelessWidget {
  final Map plan;

  const TripResultPage({required this.plan});

  @override
  Widget build(BuildContext context) {
    final days = plan["days"] ?? [];
    final cost = plan["cost_summary"] ?? {};

    return Scaffold(
      appBar: AppBar(
        title: Text("Your Trip Plan"),
        backgroundColor: Colors.blue,
      ),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          // 🔹 Summary box
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "🌍 Trip Summary",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade900,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  plan["summary"] ?? "Let’s get planning!",
                  style: TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),
          SizedBox(height: 20),

          // 🔹 Day Cards
          ...List.generate(days.length, (index) {
            final day = days[index];
            final activities = day["activities"] ?? [];

            return Card(
              margin: EdgeInsets.only(bottom: 16),
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Day ${index + 1} - ${day["date"]}",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(height: 12),
                    ...activities.map<Widget>((act) {
                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: Icon(
                          Icons.location_on,
                          color: Colors.blue,
                        ),
                        title: Text(act["name"]),
                        subtitle: Text(
                          act["type"] == "recurrent"
                              ? "🕒 Slot: ${act["slot"]}"
                              : "🕒 Time: ${act["time"]}",
                        ),
                        trailing: Text(
                          "💸 \$${act["price"]}",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.green.shade700,
                          ),
                        ),
                      );
                    }).toList(),
                  ],
                ),
              ),
            );
          }),

          Divider(),
          SizedBox(height: 12),

          // 🔹 Cost Summary
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Total: \$${cost["total_estimated_cost"]}",
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.black87),
              ),
              Text(
                "Avg/Day: \$${cost["avg_per_day"]}",
                style: TextStyle(color: Colors.grey[600], fontSize: 14),
              ),
            ],
          ),
          SizedBox(height: 20),
        ],
      ),
    );
  }
}
