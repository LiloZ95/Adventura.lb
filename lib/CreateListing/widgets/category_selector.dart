import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:adventura/config.dart';

class CategorySelector extends StatefulWidget {
  final Map<String, dynamic>? selectedCategory;
  final Function(Map<String, dynamic>?) onCategorySelected;

  const CategorySelector({
    Key? key,
    required this.selectedCategory,
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

    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    final chosenCategory = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDarkMode ? const Color(0xFF1F1F1F) : Colors.white,
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
                    color: isDarkMode ? Colors.grey[600] : Colors.grey[400],
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: categories.length,
                    itemBuilder: (context, index) {
                      final cat = categories[index];
                      final isSelected =
                          cat["id"] == widget.selectedCategory?["id"];

                      return InkWell(
                        onTap: () => Navigator.pop(context, cat),
                        child: Container(
                          margin: const EdgeInsets.symmetric(
                              vertical: 6, horizontal: 16),
                          padding: const EdgeInsets.symmetric(
                              vertical: 12, horizontal: 16),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: isSelected
                                  ? const Color.fromARGB(255, 63, 161, 241)
                                  : isDarkMode
                                      ? Colors.grey.shade700
                                      : const Color(0xFFCFCFCF),
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(12),
                            color: isSelected
                                ? Colors.blue
                                : isDarkMode
                                    ? const Color(0xFF2C2C2C)
                                    : Colors.white,
                          ),
                          child: Center(
                            child: Text(
                              cat["name"],
                              style: TextStyle(
                                fontFamily: 'poppins',
                                fontSize: 16,
                                color: isSelected
                                    ? Colors.white
                                    : isDarkMode
                                        ? Colors.white
                                        : Colors.black,
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

    if (chosenCategory != null) {
      widget.onCategorySelected(chosenCategory);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Category',
              style: TextStyle(
                fontFamily: "poppins",
                fontSize: 20,
                color: isDarkMode ? Colors.white : const Color(0xFF1F1F1F),
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Divider(
                color: isDarkMode ? Colors.grey.shade600 : Colors.grey,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        InkWell(
          onTap: () => _showBottomSheet(context),
          child: Container(
            height: 50,
            decoration: BoxDecoration(
              border: Border.all(
                color: isDarkMode
                    ? Colors.grey.shade700
                    : const Color.fromRGBO(167, 167, 167, 1),
                width: 1,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                isLoading
                    ? Text(
                        'Loading...',
                        style: TextStyle(
                          fontFamily: 'poppins',
                          color: isDarkMode ? Colors.grey : Colors.grey,
                        ),
                      )
                    : Text(
                        widget.selectedCategory?['name'] ?? 'Select Category',
                        style: TextStyle(
                          fontFamily: "poppins",
                          fontSize: 15,
                          color: widget.selectedCategory == null
                              ? (isDarkMode
                                  ? Colors.grey.shade500
                                  : const Color.fromRGBO(190, 188, 188, 0.87))
                              : (isDarkMode ? Colors.white : Colors.black),
                        ),
                      ),
                Icon(
                  Icons.arrow_circle_up,
                  color: isDarkMode
                      ? Colors.grey.shade400
                      : const Color.fromRGBO(190, 188, 188, 0.87),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
