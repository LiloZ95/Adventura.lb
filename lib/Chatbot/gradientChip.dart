import 'package:flutter/material.dart';

class GradientChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const GradientChip({
    Key? key,
    required this.label,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        margin: const EdgeInsets.only(bottom: 6),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [
              Colors.blue,
              Color.fromARGB(255, 0, 99, 179),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [
            BoxShadow(
              color: Color.fromARGB(100, 0, 99, 179),
              blurRadius: 6,
              offset: Offset(2, 2),
            ),
          ],
        ),
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontFamily: "poppins",
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}
