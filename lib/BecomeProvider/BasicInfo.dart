import 'package:flutter/material.dart';
import 'package:adventura/BecomeProvider/widgets/TextFieldWidget.dart';

class BasicInfoScreen extends StatelessWidget {
  final VoidCallback onNext;

  const BasicInfoScreen({super.key, required this.onNext});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title with horizontal dividers
          Row(
            children: const [
              Expanded(child: Divider(thickness: 1, color: Colors.grey)),
              SizedBox(width: 12),
              Text(
                "Basic Information",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'poppins',
                ),
              ),
              SizedBox(width: 12),
              Expanded(child: Divider(thickness: 1, color: Colors.grey)),
            ],
          ),
          const SizedBox(height: 12),

          Text(
            "Tell us about yourself to get started.",
            style: TextStyle(
              fontSize: 14,
              fontFamily: 'poppins',
              color: Colors.blue[600],
            ),
          ),
          const SizedBox(height: 32),

          // Full Name
          buildLabel("Owner Full Name"),
          const SizedBox(height: 6),
          const CustomTextField(hint: "Enter your name"),
          const SizedBox(height: 16),

          // Email
          buildLabel("Personal Email"),
          const SizedBox(height: 6),
          const CustomTextField(hint: "client@gmail.com"),
          const SizedBox(height: 16),

          // Birth Date
          buildLabel("Birth Date"),
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(child: buildDropdown(hint: "DD")),
              const SizedBox(width: 8),
              Expanded(child: buildDropdown(hint: "MM")),
              const SizedBox(width: 8),
              Expanded(child: buildDropdown(hint: "YYYY")),
            ],
          ),
          const SizedBox(height: 16),

          // City
          buildLabel("City"),
          const SizedBox(height: 6),
          buildDropdown(hint: "Select your city"),
          const SizedBox(height: 16),

          // Address (optional)
          buildLabel("Address Line 1", optional: true),
          const SizedBox(height: 6),
          const CustomTextField(hint: "Enter your address"),
          const SizedBox(height: 36),

        

          // Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.red),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text(
                    "Cancel",
                    style: TextStyle(
                      fontFamily: 'poppins',
                      fontSize: 16,
                      color: Colors.red,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: onNext,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[700],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text(
                    "Next",
                    style: TextStyle(
                      fontFamily: 'poppins',
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget buildLabel(String text, {bool optional = false}) {
    return Text.rich(
      TextSpan(
        text: text,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          fontFamily: 'poppins',
        ),
        children: optional
            ? [
                const TextSpan(
                  text: " (optional)",
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                    fontStyle: FontStyle.italic,
                    fontWeight: FontWeight.normal,
                  ),
                )
              ]
            : [],
      ),
    );
  }

  Widget buildDropdown({required String hint}) {
    return DropdownButtonFormField<String>(
      value: null,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(fontFamily: 'poppins'),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.blue, width: 1.8),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      items: const [
        DropdownMenuItem(value: null, child: SizedBox.shrink()),
      ],
      onChanged: (_) {},
    );
  }
}
