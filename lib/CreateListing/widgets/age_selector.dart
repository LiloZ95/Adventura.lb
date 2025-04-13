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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: const [
            Text(
              'Age Allowed',
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
                  color: isSelected ? Colors.white : Colors.black,
                  fontFamily: 'poppins',
                ),
              ),
              selected: isSelected,
              selectedColor: Colors.blue,
              backgroundColor: const Color.fromARGB(255, 245, 245, 245),
              onSelected: (_) => onChanged(age),
            );
          }).toList(),
        ),
      ],
    );
  }
}
