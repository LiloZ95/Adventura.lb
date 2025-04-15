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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: const [
            Text(
              'Description',
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
        Container(
          width: screenWidth * 0.9,
          decoration: BoxDecoration(
            border: Border.all(
              color: const Color.fromRGBO(167, 167, 167, 1),
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
                decoration: InputDecoration(
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: screenWidth * 0.04,
                    vertical: screenHeight * 0.015,
                  ),
                  hintText: 'Enter your description...',
                  hintStyle: TextStyle(
                    color: const Color.fromRGBO(190, 188, 188, 0.87),
                    fontFamily: "poppins",
                    fontSize: screenWidth * 0.04,
                  ),
                  counterText: '',
                ),
                style: TextStyle(
                  fontFamily: 'poppins',
                  fontSize: screenWidth * 0.04,
                  color: Colors.black,
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
                    color: Colors.grey,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: screenHeight * 0.015),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Icon(Icons.info, color: Colors.blue, size: 18),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                'Write an engaging description to attract participants',
                style: TextStyle(
                  fontFamily: 'poppins',
                  fontSize: 10,
                  color: Colors.blue,
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
