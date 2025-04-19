import 'package:flutter/material.dart';

class DurationSelector extends StatelessWidget {
  final Duration? selectedDuration;
  final void Function(Duration) onChanged;
  final List<Duration> availableDurations;

  const DurationSelector({
    Key? key,
    required this.selectedDuration,
    required this.onChanged,
    required this.availableDurations,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Activity Duration',
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
        if (availableDurations.isEmpty)
          Text(
            "⏳ Please select valid start and end times first.",
            style: TextStyle(
              fontFamily: 'poppins',
              color: isDarkMode ? Colors.white70 : Colors.black87,
            ),
          ),
        if (availableDurations.isNotEmpty)
          Wrap(
            spacing: 12,
            children: availableDurations.map((d) {
              final text = "${d.inHours}${d.inMinutes % 60 > 0 ? 'h ${d.inMinutes % 60}m' : 'h'}";
              final isSelected = selectedDuration == d;

              return ChoiceChip(
                label: Text(
                  text,
                  style: TextStyle(
                    fontFamily: 'poppins',
                    color: isSelected
                        ? Colors.white
                        : (isDarkMode ? Colors.white70 : Colors.black),
                  ),
                ),
                selected: isSelected,
                selectedColor: Colors.blue,
                backgroundColor: isDarkMode ? Colors.grey.shade800 : Colors.grey.shade200,
                onSelected: (_) => onChanged(d),
              );
            }).toList(),
          ),
      ],
    );
  }
}
