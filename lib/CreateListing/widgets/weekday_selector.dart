import 'package:flutter/material.dart';

class WeekdaySelector extends StatelessWidget {
  final Set<String> selectedDays;
  final Function(Set<String>) onChanged;

  const WeekdaySelector({
    Key? key,
    required this.selectedDays,
    required this.onChanged,
  }) : super(key: key);

  static const List<String> weekdays = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday'
  ];

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Repeat On',
              style: TextStyle(
                fontFamily: 'poppins',
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isDarkMode ? Colors.white : Colors.black,
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
        const SizedBox(height: 10),
        Wrap(
          spacing: 10,
          children: weekdays.map((day) {
            final isSelected = selectedDays.contains(day);
            return ChoiceChip(
              label: Text(
                day.substring(0, 3),
                style: TextStyle(
                  fontFamily: 'poppins',
                  color: isSelected
                      ? Colors.white
                      : isDarkMode
                          ? Colors.white70
                          : Colors.black87,
                ),
              ),
              selected: isSelected,
              onSelected: (_) {
                final updated = Set<String>.from(selectedDays);
                isSelected ? updated.remove(day) : updated.add(day);
                onChanged(updated);
              },
              selectedColor: Colors.blue,
              backgroundColor: isDarkMode ? Colors.grey.shade800 : Colors.grey.shade200,
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
