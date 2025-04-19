import 'package:flutter/material.dart';

const Map<int, List<Map<String, String>>> featuresByCategoryId = {
  // [ ... same as yours ... ]
};

class FeaturesSection extends StatelessWidget {
  final List<String> selectedFeatures;
  final List<Map<String, String>> availableFeatures;
  final Function(String feature) onFeatureToggle;
  final int maxFeatures;

  const FeaturesSection({
    Key? key,
    required this.selectedFeatures,
    required this.availableFeatures,
    required this.onFeatureToggle,
    this.maxFeatures = 5,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    final Color selectedColor = const Color(0xFF007AFF);
    final Color unselectedColor =
        isDarkMode ? const Color(0xFF2C2C2C) : const Color(0xFFF0F0F0);
    final Color unselectedTextColor =
        isDarkMode ? Colors.white70 : Colors.black87;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Select Features',
              style: TextStyle(
                fontFamily: "poppins",
                fontSize: 20,
                fontWeight: FontWeight.w600,
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
        const SizedBox(height: 16),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: availableFeatures.map((feature) {
            final fullLabel = '${feature['icon']} ${feature['label']}';
            final isSelected = selectedFeatures.contains(fullLabel);

            return FilterChip(
              label: Text(
                fullLabel,
                style: TextStyle(
                  fontFamily: 'poppins',
                  fontWeight: FontWeight.w500,
                  color: isSelected ? Colors.white : unselectedTextColor,
                ),
              ),
              selected: isSelected,
              onSelected: (_) => onFeatureToggle(fullLabel),
              selectedColor: selectedColor,
              backgroundColor: unselectedColor,
              checkmarkColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 8,
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            const Icon(Icons.info_outline, color: Colors.blue, size: 18),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                "Tap to select up to 5 features.",
                style: TextStyle(
                  fontFamily: 'poppins',
                  fontSize: 13,
                  color: isDarkMode ? Colors.lightBlueAccent : Colors.blue,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
