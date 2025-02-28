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
  List<int> selectedCategoryIds = [];
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
      final response = await http
          .get(Uri.parse("http://localhost:3000/users/categories"));

      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        setState(() {
          categories = data
              .map((item) => {
                    "id": item["category_id"],
                    "name": item["name"],
                    "emoji": item["emoji"]
                  })
              .toList();
        });
      } else {
        print("❌ Failed to fetch categories: ${response.body}");
      }
    } catch (e) {
      print("❌ Error fetching categories: $e");
    }
  }

  Future<void> _savePreferences() async {
    if (selectedCategoryIds.length < minSelections) {
      setState(() {
        errorMessage = "❌ Please select at least $minSelections preference.";
      });
      return;
    }

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString("userId");

    if (userId == null) {
      print("❌ No user ID found!");
      return;
    }

    final response = await http.post(
      Uri.parse("http://localhost:3000/users/preferences"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"userId": userId, "preferences": selectedCategoryIds}),
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
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: categories.map((category) {
                  bool isSelected =
                      selectedCategoryIds.contains(category['id']);
                  bool isDisabled =
                      selectedCategoryIds.length >= maxSelections &&
                          !isSelected;
                  return GestureDetector(
                    onTap: isDisabled
                        ? null
                        : () {
                            setState(() {
                              if (isSelected) {
                                selectedCategoryIds.remove(category['id']);
                              } else if (selectedCategoryIds.length <
                                  maxSelections) {
                                selectedCategoryIds.add(category['id']);
                              }
                            });
                          },
                    child: Container(
                      decoration: BoxDecoration(
                        color: isDisabled
                            ? Colors.grey[
                                200] // Disabled buttons have grey[200] background
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          // If no button is selected, give all buttons a 1px grey[200] border.
                          // Otherwise, apply the specific logic based on state.
                          color: isSelected ? Colors.blue : Colors.grey[300]!,
                          width: 2,
                        ),
                      ),
                      padding:
                          EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (!isDisabled)
                            Text(category['emoji']!,
                                style: TextStyle(fontSize: 18)),
                          SizedBox(width: 6),
                          Text(
                            category['name']!,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              fontStyle: isDisabled
                                  ? FontStyle.italic
                                  : FontStyle.normal,
                              color:
                                  isDisabled ? Colors.grey[500] : Colors.black,
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
