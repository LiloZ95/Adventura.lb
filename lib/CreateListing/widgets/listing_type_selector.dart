import 'package:flutter/material.dart';
import 'package:adventura/controllers/create_listing_controller.dart';

class ListingTypeSelector extends StatelessWidget {
  final ListingType? selectedType;
  final ValueChanged<ListingType> onChanged;

  const ListingTypeSelector({
    Key? key,
    required this.selectedType,
    required this.onChanged,
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
              'Listing Type',
              style: TextStyle(
                fontFamily: "poppins",
                fontSize: 20,
                color: isDarkMode ? Colors.white : const Color(0xFF1F1F1F),
                fontWeight: FontWeight.bold,
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
        const SizedBox(height: 12),
        Column(
          children: [
            _buildTypeButton(
              context: context,
              type: ListingType.recurrent,
              label: "Recurrent Activity",
            ),
            _buildTypeButton(
              context: context,
              type: ListingType.oneTime,
              label: "One-time Event",
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTypeButton({
    required BuildContext context,
    required ListingType type,
    required String label,
  }) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final isSelected = selectedType == type;

    return InkWell(
      onTap: () => onChanged(type),
      splashColor: isDarkMode ? Colors.white24 : const Color(0x11000000),
      highlightColor: Colors.transparent,
      child: Container(
        width: double.infinity,
        height: 45,
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected
                ? Colors.blue
                : isDarkMode
                    ? Colors.grey.shade600
                    : Colors.grey,
            width: 1,
          ),
          color: isDarkMode
              ? (isSelected ? Colors.blue.shade900.withOpacity(0.3) : const Color(0xFF2C2C2C))
              : Colors.white,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              type == ListingType.recurrent ? Icons.repeat : Icons.event,
              color: isSelected
                  ? Colors.blue
                  : isDarkMode
                      ? Colors.grey.shade300
                      : Colors.grey,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'poppins',
                fontSize: 15,
                color: isSelected
                    ? Colors.blue
                    : isDarkMode
                        ? Colors.white
                        : Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
