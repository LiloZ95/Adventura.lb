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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: const [
            Text(
              'Listing Type',
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
    final isSelected = selectedType == type;

    return InkWell(
      onTap: () => onChanged(type),
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      child: Container(
        width: double.infinity,
        height: 45,
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? Colors.blue : Colors.grey,
            width: 1,
          ),
          color: Colors.white,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.autorenew,
              color: isSelected ? Colors.blue : Colors.grey,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'poppins',
                fontSize: 15,
                color: isSelected ? Colors.blue : Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
