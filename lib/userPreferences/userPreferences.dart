import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../Main screen components/MainScreen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(Favorite());
}

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
  final int minSelections = 1; // ✅ Minimum required selections
  final int maxSelections = 5; // ✅ Maximum allowed selections
  String? errorMessage; // ✅ Store error message

  // final List<Map<String, String>> categories = [
  //   {'name': 'Business', 'emoji': '🏢'},
  //   {'name': 'Community', 'emoji': '🤝'},
  //   {'name': 'Music & Entertainment', 'emoji': '🎵'},
  //   {'name': 'Health', 'emoji': '⚕️'},
  //   {'name': 'Food & drink', 'emoji': '🍔'},
  //   {'name': 'Family & Education', 'emoji': '👨‍👩‍👧‍👦'},
  //   {'name': 'Sport', 'emoji': '⚽'},
  //   {'name': 'Fashion', 'emoji': '👗'},
  //   {'name': 'Film & Media', 'emoji': '🎬'},
  //   {'name': 'Home & Lifestyle', 'emoji': '🏡'},
  //   {'name': 'Design', 'emoji': '🎨'},
  //   {'name': 'Gaming', 'emoji': '🎮'},
  //   {'name': 'Science & Tech', 'emoji': '🔬'},
  //   {'name': 'School & Education', 'emoji': '📚'},
  //   {'name': 'Holiday', 'emoji': '🎁'},
  //   {'name': 'Travel', 'emoji': '✈️'},
  //   {'name': 'Art & Culture', 'emoji': '🎨'},
  //   {'name': 'Social Media & Blogging', 'emoji': '📱'},
  //   {'name': 'Photography ', 'emoji': '📸'},
  //   {'name': 'Travel & Adventure', 'emoji': '🏕️'},
  //   {'name': 'Winter Sports ', 'emoji': '🏂'},
  //   {'name': 'Health & Nutrition', 'emoji': '🥗'}
  // ];

  @override
  void initState() {
    super.initState();
    fetchCategories();
  }

  Future<void> fetchCategories() async {
    try {
      final response =
          await http.get(Uri.parse("http://localhost:3000/categories"));

      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);

        // ✅ Check if data is valid before setting state
        if (data != null && data.isNotEmpty) {
          setState(() {
            categories = data
                .map((item) => {
                      "id": item["category_id"] ?? 0, // Prevent null ID
                      "name": item["name"] ??
                          "Unknown Category" // Prevent null name
                    })
                .toList();
          });
        } else {
          print("⚠️ No categories found.");
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

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString("userId");
    String? accessToken = prefs.getString("accessToken"); // ✅ Retrieve token

    if (userId == null || accessToken == null) {
      print("❌ No user ID or token found!");
      return;
    }

    final response = await http.post(
      Uri.parse("http://localhost:3000/users/preferences"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $accessToken" // ✅ Include the token
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
                      'Get personalized event recommendation.',
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
                      child:
                          CircularProgressIndicator()) // Show loading spinner
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
