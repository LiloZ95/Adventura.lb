import 'package:flutter/material.dart';

class TitleSection extends StatelessWidget {
  final TextEditingController controller;
  final int currentLength;
  final Function(String) onChanged;

  const TitleSection({
    Key? key,
    required this.controller,
    required this.currentLength,
    required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Title',
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
        Container(
          width: screenWidth * 0.9,
          height: 50,
          decoration: BoxDecoration(
            color: isDarkMode ? const Color(0xFF2C2C2C) : Colors.transparent,
            border: Border.all(
              color: isDarkMode
                  ? Colors.grey.shade700
                  : const Color.fromRGBO(167, 167, 167, 1),
              width: 1,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Stack(
            children: [
              TextField(
                controller: controller,
                maxLength: 30,
                onChanged: onChanged,
                style: TextStyle(
                  fontFamily: 'poppins',
                  fontSize: screenWidth * 0.04,
                  color: isDarkMode ? Colors.white : const Color(0xFF1F1F1F),
                ),
                decoration: InputDecoration(
                  border: InputBorder.none,
                  counterText: '',
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: screenWidth * 0.04,
                    vertical: screenHeight * 0.01,
                  ),
                  hintText: 'Enter title...',
                  hintStyle: TextStyle(
                    color: isDarkMode
                        ? Colors.grey.shade500
                        : const Color.fromRGBO(190, 188, 188, 0.87),
                    fontFamily: "poppins",
                    fontSize: screenWidth * 0.04,
                  ),
                ),
              ),
              Positioned(
                bottom: 6,
                right: screenWidth * 0.04,
                child: Text(
                  '$currentLength/30',
                  style: TextStyle(
                    fontFamily: 'poppins',
                    fontSize: screenWidth * 0.03,
                    color: isDarkMode ? Colors.white70 : const Color(0xFF1F1F1F),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
