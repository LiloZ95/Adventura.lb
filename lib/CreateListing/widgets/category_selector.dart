import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:adventura/config.dart'; // adjust if needed

class CategorySelector extends StatefulWidget {
  final String? selectedCategoryName;
  final Function(String) onCategorySelected;

  const CategorySelector({
    Key? key,
    required this.selectedCategoryName,
    required this.onCategorySelected,
  }) : super(key: key);

  @override
  State<CategorySelector> createState() => _CategorySelectorState();
}

class _CategorySelectorState extends State<CategorySelector> {
  List<Map<String, dynamic>> categories = [];
  bool isLoading = true;

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

        setState(() {
          categories = data
              .map<Map<String, dynamic>>((item) => {
                    "id": item["category_id"] ?? 0,
                    "name": item["name"] ?? "Unknown Category"
                  })
              .toList();
          isLoading = false;
        });
      } else {
        print("❌ Failed to fetch categories: ${response.body}");
        setState(() => isLoading = false);
      }
    } catch (e) {
      print("❌ Error fetching categories: $e");
      setState(() => isLoading = false);
    }
  }

  Future<void> _showBottomSheet(BuildContext context) async {
    if (isLoading) return;

    final chosenName = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return FractionallySizedBox(
          heightFactor: 0.6,
          child: SafeArea(
            child: Column(
              children: [
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey[400],
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: categories.length,
                    itemBuilder: (context, index) {
                      final cat = categories[index];
                      final isSelected =
                          cat["name"] == widget.selectedCategoryName;

                      return InkWell(
                        onTap: () => Navigator.pop(context, cat["name"]),
                        child: Container(
                          margin: const EdgeInsets.symmetric(
                              vertical: 6, horizontal: 16),
                          padding: const EdgeInsets.symmetric(
                              vertical: 12, horizontal: 16),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: isSelected
                                  ? const Color.fromARGB(255, 63, 161, 241)
                                  : const Color(0xFFCFCFCF),
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(12),
                            color: isSelected ? Colors.blue : Colors.white,
                          ),
                          child: Center(
                            child: Text(
                              cat["name"],
                              style: TextStyle(
                                fontFamily: 'poppins',
                                fontSize: 16,
                                color: isSelected ? Colors.white : Colors.black,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (chosenName != null) {
      widget.onCategorySelected(chosenName);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: const [
            Text(
              'Category',
              style: TextStyle(
                fontFamily: "poppins",
                fontSize: 20,
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(width: 8),
            Expanded(child: Divider(color: Colors.grey)),
          ],
        ),
        const SizedBox(height: 12),
        InkWell(
          onTap: () => _showBottomSheet(context),
          child: Container(
            height: 50,
            decoration: BoxDecoration(
              border: Border.all(
                color: const Color.fromRGBO(167, 167, 167, 1),
                width: 1,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                isLoading
                    ? const Text(
                        'Loading...',
                        style: TextStyle(
                            fontFamily: 'poppins', color: Colors.grey),
                      )
                    : Text(
                        widget.selectedCategoryName ?? 'Select Category',
                        style: TextStyle(
                          fontFamily: "poppins",
                          fontSize: 15,
                          color: widget.selectedCategoryName == null
                              ? const Color.fromRGBO(190, 188, 188, 0.87)
                              : Colors.black,
                        ),
                      ),
                const Icon(
                  Icons.arrow_circle_up,
                  color: Color.fromRGBO(190, 188, 188, 0.87),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
