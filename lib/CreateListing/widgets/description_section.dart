import 'package:flutter/material.dart';

class DescriptionSection extends StatelessWidget {
  final TextEditingController controller;
  final int currentLength;
  final Function(String) onChanged;

  const DescriptionSection({
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
              'Description',
              style: TextStyle(
                fontFamily: "poppins",
                fontSize: 20,
                color: isDarkMode ? Colors.white : Colors.black,
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
          decoration: BoxDecoration(
            color: isDarkMode ? const Color(0xFF2C2C2C) : Colors.transparent,
            border: Border.all(
              color: isDarkMode
                  ? Colors.grey.shade700
                  : const Color.fromRGBO(167, 167, 167, 1),
              width: 1,
            ),
            borderRadius: BorderRadius.circular(screenWidth * 0.03),
          ),
          child: Stack(
            children: [
              TextField(
                controller: controller,
                maxLines: 6,
                maxLength: 250,
                onChanged: onChanged,
                style: TextStyle(
                  fontFamily: 'poppins',
                  fontSize: screenWidth * 0.04,
                  color: isDarkMode ? Colors.white : Colors.black,
                ),
                decoration: InputDecoration(
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: screenWidth * 0.04,
                    vertical: screenHeight * 0.015,
                  ),
                  hintText: 'Enter your description...',
                  hintStyle: TextStyle(
                    fontFamily: "poppins",
                    fontSize: screenWidth * 0.04,
                    color: isDarkMode
                        ? Colors.grey.shade500
                        : const Color.fromRGBO(190, 188, 188, 0.87),
                  ),
                  counterText: '',
                ),
              ),
              Positioned(
                bottom: screenHeight * 0.005,
                right: screenWidth * 0.04,
                child: Text(
                  '$currentLength/250',
                  style: TextStyle(
                    fontFamily: 'poppins',
                    fontSize: screenWidth * 0.03,
                    color: isDarkMode ? Colors.white70 : Colors.grey,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: screenHeight * 0.015),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.info, color: Colors.blue, size: 18),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Write an engaging description to attract participants',
                style: TextStyle(
                  fontFamily: 'poppins',
                  fontSize: 10,
                  color: isDarkMode ? Colors.lightBlueAccent : Colors.blue,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
      ],
    );
  }
}
