import 'package:flutter/material.dart';

class AgeSelector extends StatelessWidget {
  final String? selectedAge;
  final ValueChanged<String?> onChanged;

  const AgeSelector({
    Key? key,
    required this.selectedAge,
    required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final List<String> ageOptions = [
      "All Ages",
      "5+",
      "10+",
      "18+",
      "21+",
    ];

    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Age Allowed',
              style: TextStyle(
                fontFamily: 'poppins',
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isDarkMode ? Colors.white : Colors.black,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Divider(color: isDarkMode ? Colors.grey.shade600 : Colors.grey),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: ageOptions.map((age) {
            final bool isSelected = selectedAge == age;
            return ChoiceChip(
              label: Text(
                age,
                style: TextStyle(
                  color: isSelected
                      ? Colors.white
                      : (isDarkMode ? Colors.white70 : Colors.black),
                  fontFamily: 'poppins',
                ),
              ),
              selected: isSelected,
              selectedColor: const Color(0xFF007AFF),
              backgroundColor:
                  isDarkMode ? const Color(0xFF2C2C2E) : const Color(0xFFF5F5F5),
              onSelected: (_) => onChanged(age),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            );
          }).toList(),
        ),
      ],
    );
  }
}
