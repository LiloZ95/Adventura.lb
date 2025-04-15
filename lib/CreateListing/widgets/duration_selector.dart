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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: const [
            Text(
              'Activity Duration',
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
        if (availableDurations.isEmpty)
          const Text("⏳ Please select valid start and end times first."),
        if (availableDurations.isNotEmpty)
          Wrap(
            spacing: 12,
            children: availableDurations.map((d) {
              final text = "${d.inHours}${d.inMinutes % 60 > 0 ? 'h ${d.inMinutes % 60}m' : 'h'}";
              return ChoiceChip(
                label: Text(text),
                selected: selectedDuration == d,
                onSelected: (_) => onChanged(d),
              );
            }).toList(),
          ),
      ],
    );
  }
}
