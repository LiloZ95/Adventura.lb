import 'package:flutter/material.dart';

class TitleSection extends StatelessWidget {
  final TextEditingController controller;
  final int currentLength;
  final int maxLength;

  const TitleSection({
    Key? key,
    required this.controller,
    required this.currentLength,
    this.maxLength = 30,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: const [
            Text(
              'Title',
              style: TextStyle(
                fontFamily: "poppins",
                fontSize: 20,
                color: Colors.black87,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(width: 8),
            Expanded(child: Divider(color: Colors.grey)),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          height: 50,
          decoration: BoxDecoration(
            border: Border.all(
              color: const Color.fromRGBO(167, 167, 167, 1),
              width: 1,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: TextField(
            controller: controller,
            maxLength: maxLength,
            decoration: InputDecoration(
              counterText: '',
              hintText: 'Enter title',
              hintStyle: const TextStyle(
                color: Color.fromRGBO(190, 188, 188, 0.87),
                fontFamily: "poppins",
                fontSize: 15,
              ),
              suffixText: '$currentLength/$maxLength',
              suffixStyle: const TextStyle(
                color: Color.fromRGBO(190, 188, 188, 0.87),
                fontFamily: "poppins",
                fontSize: 15,
              ),
              border: InputBorder.none,
            ),
          ),
        ),
      ],
    );
  }
}
