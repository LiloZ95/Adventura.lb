import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../Main screen components/MainScreen.dart';
import 'package:hive/hive.dart';
import 'package:adventura/widgets/bouncing_dots_loader.dart';
import 'package:adventura/config.dart'; // ✅ Import the global config file

class Favorite extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: EventSelectionScreen(),
    );
  }
}

class EventSelectionScreen extends StatefulWidget {
  @override
  _EventSelectionScreenState createState() => _EventSelectionScreenState();
}

class _EventSelectionScreenState extends State<EventSelectionScreen> {
  List<Map<String, dynamic>> categories = [];
  List<Map<String, dynamic>> selectedPreferences = [];
  final int minSelections = 1;
  final int maxSelections = 5;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    fetchCategories();
  }

  Future<void> fetchCategories() async {
    try {
      final response = await http.get(Uri.parse("$baseUrl/categories"));

      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);

        if (data.isNotEmpty) {
          setState(() {
            categories = data
                .map((item) => {
                      "id": item["category_id"] ?? 0,
                      "name": item["name"] ?? "Unknown Category"
                    })
                .toList();
          });
        }
      } else {
        print("❌ Failed to fetch categories: ${response.body}");
      }
    } catch (e) {
      print("❌ Error fetching categories: $e");
    }
  }

  Future<void> _savePreferences() async {
    if (selectedPreferences.length < minSelections) {
      setState(() {
        errorMessage = "❌ Please select at least $minSelections preference.";
      });
      return;
    }

    final Box authBox = await Hive.openBox('authBox');
    String? userId = authBox.get("userId");
    String? accessToken = authBox.get("accessToken");

    if (userId == null || accessToken == null) {
      print("❌ No user ID or token found in Hive!");
      return;
    }

    final response = await http.post(
      Uri.parse("$baseUrl/users/preferences"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $accessToken"
      },
      body: jsonEncode(
          {"userId": int.parse(userId), "preferences": selectedPreferences}),
    );

    if (response.statusCode == 200) {
      print("✅ Preferences saved successfully!");
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => MainScreen()),
      );
    } else {
      print("❌ Failed to save preferences. Server response: ${response.body}");
      setState(() {
        errorMessage = "❌ Failed to save preferences. Try again.";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Using SafeArea to automatically handle status bar and notches
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title centered with Poppins font family
              Center(
                child: Column(
                  children: [
                    SizedBox(height: 10),
                    Text(
                      'Choose your favorite event',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Poppins',
                      ),
                    ),
                    SizedBox(height: 5),
                    Text(
                      'Get personalized activity recommendation.',
                      style: TextStyle(
                        color: Colors.grey,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              // Wrap widget for categories, which will wrap as screen size changes
              categories.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: BouncingDotsLoader(
                          color: Colors.blue,
                          size: 14.0,
                        ),
                      ),
                    )
                  : Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: categories.map((category) {
                        String categoryName = category["name"] ??
                            "Unknown"; // ✅ Prevent null values
                        bool isSelected = selectedPreferences
                            .any((p) => p['category_id'] == category['id']);
                        bool isDisabled =
                            selectedPreferences.length >= maxSelections &&
                                !isSelected;

                        return GestureDetector(
                          onTap: isDisabled
                              ? null
                              : () {
                                  setState(() {
                                    if (isSelected) {
                                      selectedPreferences.removeWhere((p) =>
                                          p['category_id'] == category['id']);
                                    } else if (selectedPreferences.length <
                                        maxSelections) {
                                      selectedPreferences.add({
                                        "category_id": category['id'],
                                        "preference_level":
                                            3, // Default preference level
                                      });
                                    }
                                  });
                                  print("Selected: $categoryName");
                                },
                          child: Container(
                            padding: EdgeInsets.symmetric(
                                vertical: 10, horizontal: 15),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: isSelected
                                    ? Colors.blue
                                    : Colors.grey[300]!,
                                width: 2,
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  category['name']!,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    fontStyle: FontStyle.normal,
                                    color: isDisabled
                                        ? Colors.grey[500]
                                        : Colors.black,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
              SizedBox(height: 20),
              if (errorMessage != null)
                Text(
                  errorMessage!,
                  style:
                      TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                ),
              SizedBox(height: 10),
              // Finish Button
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  gradient: LinearGradient(
                    colors: [Color(0xff007AFF), Color(0xff00C6FF)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        Colors.transparent, // Transparent background
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 18),
                  ),
                  onPressed: _savePreferences,
                  child: Text(
                    'Finish',
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
              ),
              SizedBox(height: 20), // Extra spacing at the bottom if needed
            ],
          ),
        ),
      ),
    );
  }
}
