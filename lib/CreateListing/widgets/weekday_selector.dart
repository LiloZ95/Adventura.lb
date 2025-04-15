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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: const [
            Text(
              'Repeat On',
              style: TextStyle(
                fontFamily: 'poppins',
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(width: 8),
            Expanded(child: Divider(color: Colors.grey)),
          ],
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 10,
          children: weekdays.map((day) {
            final isSelected = selectedDays.contains(day);
            return ChoiceChip(
              label: Text(day.substring(0, 3)),
              selected: isSelected,
              onSelected: (_) {
                final updated = Set<String>.from(selectedDays);
                isSelected ? updated.remove(day) : updated.add(day);
                onChanged(updated);
              },
            );
          }).toList(),
        ),
      ],
    );
  }
}
