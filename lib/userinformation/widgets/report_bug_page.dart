import 'dart:io';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:image_picker/image_picker.dart';

class ReportBugPage extends StatefulWidget {
  const ReportBugPage({super.key});

  @override
  State<ReportBugPage> createState() => _ReportBugPageState();
}

class _ReportBugPageState extends State<ReportBugPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController descriptionController = TextEditingController();
  String selectedType = 'UI Bug';
  File? selectedImage;

  final List<Map<String, dynamic>> bugTypes = [
    {'label': 'UI Bug', 'icon': LucideIcons.layoutDashboard},
    {'label': 'Crash/Error', 'icon': LucideIcons.alertTriangle},
    {'label': 'Performance', 'icon': LucideIcons.gauge},
    {'label': 'Payment', 'icon': LucideIcons.creditCard},
    {'label': 'Other', 'icon': LucideIcons.moreHorizontal},
  ];

  Future<void> pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);

    if (picked != null) {
      setState(() => selectedImage = File(picked.path));
    }
  }

  void submitBug() {
    if (!_formKey.currentState!.validate()) return;

    print("🔍 Bug Type: $selectedType");
    print("📄 Description: ${descriptionController.text}");

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Bug report submitted — thanks! 🛠️")),
    );

    setState(() {
      selectedType = 'UI Bug';
      descriptionController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDarkMode ? const Color(0xFF1F1F1F) : const Color(0xFFF3F4F8),
      appBar: AppBar(
        title: Text(
          "Bug Report",
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: isDarkMode ? Colors.white : Colors.black,
          ),
        ),
        backgroundColor: isDarkMode ? const Color(0xFF1F1F1F) : Colors.white,
        elevation: 1,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: isDarkMode ? Colors.white : Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: Card(
            elevation: 12,
            color: isDarkMode ? const Color(0xFF2C2C2C) : Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: ListView(
                  shrinkWrap: true,
                  children: [
                    _buildHeaderSection(isDarkMode),
                    const SizedBox(height: 28),
                    _buildBugTypeDropdown(isDarkMode),
                    const SizedBox(height: 20),
                    _buildDescriptionBox(isDarkMode),
                    const SizedBox(height: 20),
                    _buildScreenshotUploadPlaceholder(isDarkMode),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        icon: const Icon(LucideIcons.bug, color: Colors.white),
                        label: const Text(
                          "Submit Report",
                          style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        onPressed: submitBug,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderSection(bool isDarkMode) {
    return Column(
      children: [
        const Icon(LucideIcons.bug, size: 38, color: Colors.blue),
        const SizedBox(height: 12),
        Text(
          "Report a Bug",
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.bold,
            fontSize: 22,
            color: isDarkMode ? Colors.white : Colors.black,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          "Help us squash bugs by telling us what went wrong.",
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 14,
            color: isDarkMode ? Colors.grey[400] : Colors.black54,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildBugTypeDropdown(bool isDarkMode) {
    return DropdownButtonFormField<String>(
      value: selectedType,
      decoration: InputDecoration(
        labelText: "Type of issue",
        labelStyle: const TextStyle(fontFamily: 'Poppins'),
        filled: true,
        fillColor: isDarkMode ? const Color(0xFF1F1F1F) : Colors.grey[100],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
      ),
      icon: Icon(Icons.expand_more, color: isDarkMode ? Colors.white : Colors.black),
      dropdownColor: isDarkMode ? const Color(0xFF2C2C2C) : Colors.white,
      style: TextStyle(
        fontFamily: 'Poppins',
        color: isDarkMode ? Colors.white : Colors.black,
      ),
      items: bugTypes.map((type) {
        return DropdownMenuItem<String>(
          value: type['label'],
          child: Row(
            children: [
              Icon(type['icon'], size: 18, color: Colors.blue),
              const SizedBox(width: 8),
              Text(type['label']),
            ],
          ),
        );
      }).toList(),
      onChanged: (val) {
        if (val != null) setState(() => selectedType = val);
      },
    );
  }

  Widget _buildDescriptionBox(bool isDarkMode) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: descriptionController,
          maxLines: 5,
          style: TextStyle(
            fontFamily: 'Poppins',
            color: isDarkMode ? Colors.white : Colors.black,
          ),
          validator: (val) =>
              val == null || val.isEmpty ? "Please describe the issue" : null,
          decoration: InputDecoration(
            hintText: "Describe what happened...",
            hintStyle: TextStyle(
              fontFamily: 'Poppins',
              color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
            ),
            filled: true,
            fillColor: isDarkMode ? const Color(0xFF1F1F1F) : Colors.grey[100],
            contentPadding: const EdgeInsets.all(16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Align(
          alignment: Alignment.centerRight,
          child: Text(
            "${descriptionController.text.length}/500",
            style: TextStyle(
              fontSize: 12,
              fontFamily: 'Poppins',
              color: isDarkMode ? Colors.grey[400] : Colors.grey,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildScreenshotUploadPlaceholder(bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF1F1F1F) : Colors.grey[100],
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(LucideIcons.image, color: isDarkMode ? Colors.white70 : Colors.grey),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              "Add screenshot (optional)",
              style: TextStyle(
                fontFamily: 'Poppins',
                color: isDarkMode ? Colors.white : Colors.black,
              ),
            ),
          ),
          TextButton(
            onPressed: pickImage,
            child: const Text(
              "Browse",
              style: TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w500,
                color: Colors.blue,
              ),
            ),
          )
        ],
      ),
    );
  }
}
