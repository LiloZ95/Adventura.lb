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
    final List<String> ageOptions = ['All Ages', '12+', '18+', '21+'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: const [
            Text(
              'Age Allowed',
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
        const SizedBox(height: 8),
        Row(
          children: ageOptions.map((label) {
            final bool isSelected = selectedAge == label;

            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: InkWell(
                onTap: () => onChanged(isSelected ? null : label),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: isSelected
                          ? const Color.fromARGB(255, 63, 161, 241)
                          : const Color(0xFFCFCFCF),
                      width: 1,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    color: isSelected ? Colors.blue : Colors.white,
                  ),
                  child: Text(
                    label,
                    style: TextStyle(
                      fontFamily: 'poppins',
                      fontSize: 14,
                      color: isSelected ? Colors.white : Colors.blue,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
