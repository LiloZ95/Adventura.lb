import 'dart:ui';

import 'package:flutter/material.dart';

class AppearanceToggleTile extends StatefulWidget {
  final bool isDarkMode;
  final ValueChanged<bool> onChanged;

  const AppearanceToggleTile({
    super.key,
    required this.isDarkMode,
    required this.onChanged,
  });

  @override
  State<AppearanceToggleTile> createState() => _AppearanceToggleTileState();
}

class _AppearanceToggleTileState extends State<AppearanceToggleTile> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black12.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: widget.isDarkMode ? Colors.blueGrey[800] : Colors.grey,
              shape: BoxShape.circle,
            ),
            child: Icon(
              widget.isDarkMode ? Icons.dark_mode : Icons.light_mode,
              color: widget.isDarkMode ? Colors.white : Colors.blue,
              size: 22,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              "Appearance",
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                fontFamily: 'Poppins',
              ),
            ),
          ),
          Text(
            widget.isDarkMode ? "Dark Mode" : "Light Mode",
            style: TextStyle(
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 10),
          Switch(
            value: widget.isDarkMode,
            activeColor: Colors.blue,
            onChanged: widget.onChanged,
          ),
        ],
      ),
    );
  }
}
