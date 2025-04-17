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

  final List<Map<String, dynamic>> bugTypes = [
    {'label': 'UI Bug', 'icon': LucideIcons.layoutDashboard},
    {'label': 'Crash/Error', 'icon': LucideIcons.alertTriangle},
    {'label': 'Performance', 'icon': LucideIcons.gauge},
    {'label': 'Payment', 'icon': LucideIcons.creditCard},
    {'label': 'Other', 'icon': LucideIcons.moreHorizontal},
  ];
  File? selectedImage;

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

  Widget buildBugTypeDropdown() {
    return DropdownButtonFormField<String>(
      value: selectedType,
      decoration: InputDecoration(
        labelText: "Type of issue",
        labelStyle: const TextStyle(fontFamily: 'Poppins'),
        filled: true,
        fillColor: Colors.grey[100],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
      ),
      icon: const Icon(Icons.expand_more),
      dropdownColor: Colors.white,
      style: const TextStyle(fontFamily: 'Poppins', color: Colors.black),
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

  Widget buildHeaderSection() {
    return Column(
      children: [
        const Icon(LucideIcons.bug, size: 38, color: Colors.blue),
        const SizedBox(height: 12),
        const Text(
          "Report a Bug",
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          "Help us squash bugs by telling us what went wrong.",
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 14,
            color: Colors.black54,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget buildDescriptionBox() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: descriptionController,
          maxLines: 5,
          style: const TextStyle(fontFamily: 'Poppins'),
          validator: (val) =>
              val == null || val.isEmpty ? "Please describe the issue" : null,
          decoration: InputDecoration(
            hintText: "Describe what happened...",
            hintStyle: const TextStyle(fontFamily: 'Poppins'),
            filled: true,
            fillColor: Colors.grey[100],
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
            style: const TextStyle(
              fontSize: 12,
              fontFamily: 'Poppins',
              color: Colors.grey,
            ),
          ),
        ),
      ],
    );
  }

  Widget buildScreenshotUploadPlaceholder() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          const Icon(LucideIcons.image, color: Colors.grey),
          const SizedBox(width: 10),
          const Expanded(
            child: Text(
              "Add screenshot (optional)",
              style: TextStyle(fontFamily: 'Poppins'),
            ),
          ),
          TextButton(
            onPressed: pickImage, // ✅ THIS MAKES IT WORK!
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F8),
      appBar: AppBar(
        title: const Text(
          "Bug Report",
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: Card(
            elevation: 12,
            color: Colors.white,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: ListView(
                  shrinkWrap: true,
                  children: [
                    buildHeaderSection(),
                    const SizedBox(height: 28),
                    buildBugTypeDropdown(),
                    const SizedBox(height: 20),
                    buildDescriptionBox(),
                    const SizedBox(height: 20),
                    buildScreenshotUploadPlaceholder(),
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
}
