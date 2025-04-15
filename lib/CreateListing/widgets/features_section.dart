// import 'package:flutter/material.dart';

// class FeaturesSection extends StatelessWidget {
//   final List<TextEditingController> controllers;
//   final List<bool> isEditable;
//   final Function(int index) onAdd;
//   final Function(int index) onDelete;

//   const FeaturesSection({
//     Key? key,
//     required this.controllers,
//     required this.isEditable,
//     required this.onAdd,
//     required this.onDelete,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         // Header
//         Row(
//           children: const [
//             Text(
//               'Features',
//               style: TextStyle(
//                 fontFamily: "poppins",
//                 fontSize: 20,
//                 color: Colors.black,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//             SizedBox(width: 8),
//             Expanded(child: Divider(color: Colors.grey)),
//           ],
//         ),
//         const SizedBox(height: 8),

//         // Feature Pills
//         SingleChildScrollView(
//           scrollDirection: Axis.horizontal,
//           child: Row(
//             children: List.generate(controllers.length, (index) {
//               final controller = controllers[index];
//               final editable = isEditable[index];

//               return Padding(
//                 padding: const EdgeInsets.only(right: 8),
//                 child: Row(
//                   children: [
//                     IntrinsicWidth(
//                       child: Container(
//                         constraints: const BoxConstraints(minHeight: 50),
//                         padding: const EdgeInsets.symmetric(horizontal: 12),
//                         decoration: BoxDecoration(
//                           color: editable ? null : const Color(0xFFF5F5F5),
//                           border: Border.all(
//                             color: const Color(0xFFCFCFCF),
//                             width: 1,
//                           ),
//                           borderRadius: BorderRadius.circular(12),
//                         ),
//                         child: Row(
//                           mainAxisSize: MainAxisSize.min,
//                           children: [
//                             Flexible(
//                               child: TextField(
//                                 controller: controller,
//                                 readOnly: !editable,
//                                 decoration: InputDecoration(
//                                   border: InputBorder.none,
//                                   hintText:
//                                       editable ? 'Ex: Entertainment' : null,
//                                   hintStyle: const TextStyle(
//                                     fontFamily: 'poppins',
//                                     fontSize: 14,
//                                     color: Colors.grey,
//                                   ),
//                                   isDense: true,
//                                 ),
//                                 style: const TextStyle(
//                                   fontFamily: 'poppins',
//                                   fontSize: 14,
//                                   color: Colors.black,
//                                 ),
//                               ),
//                             ),

//                             // ❌ Delete button for locked pills
//                             if (!editable)
//                               GestureDetector(
//                                 onTap: () => onDelete(index),
//                                 child: const Padding(
//                                   padding: EdgeInsets.only(left: 6.0),
//                                   child: Icon(
//                                     Icons.close,
//                                     size: 16,
//                                     color: Colors.grey,
//                                   ),
//                                 ),
//                               ),
//                           ],
//                         ),
//                       ),
//                     ),

//                     // ➕ Button on the last one
//                     // if (index == controllers.length - 1)
//                     const SizedBox(width: 8),
//                     if (index == controllers.length - 1)
//                       Padding(
//                         padding:
//                             const EdgeInsets.only(top: 3), // adjust visually
//                         child: GestureDetector(
//                           onTap: () => onAdd(index),
//                           child: Container(
//                             width: 30,
//                             height: 30,
//                             decoration: const BoxDecoration(
//                               color: Colors.black,
//                               shape: BoxShape.circle,
//                             ),
//                             child: const Icon(Icons.add,
//                                 color: Colors.white, size: 16),
//                           ),
//                         ),
//                       )
//                   ],
//                 ),
//               );
//             }),
//           ),
//         ),

//         const SizedBox(height: 8),

//         // Info text
//         Row(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: const [
//             Icon(Icons.info, color: Colors.blue, size: 18),
//             SizedBox(width: 8),
//             Expanded(
//               child: Text(
//                 "Add what's featured in the activity/event.",
//                 style: TextStyle(
//                   fontFamily: 'poppins',
//                   fontSize: 12,
//                   color: Colors.blue,
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ],
//     );
//   }
// }

import 'package:flutter/material.dart';

const Map<int, List<Map<String, String>>> featuresByCategoryId = {
  1: [
    // Sea Trips
    {"icon": "📶", "label": "WiFi"},
    {"icon": "🚗", "label": "Parking"},
    {"icon": "🛟", "label": "Life Jackets"},
    {"icon": "🍽️", "label": "Food"},
    {"icon": "🎵", "label": "Music"},
    {"icon": "🗣️", "label": "Tour Guide"},
  ],
  2: [
    // Picnic
    {"icon": "🌳", "label": "Outdoor"},
    {"icon": "👨‍👩‍👧", "label": "Family Friendly"},
    {"icon": "🍽️", "label": "Food"},
    {"icon": "🐾", "label": "Pets Allowed"},
    {"icon": "🪑", "label": "Seating Available"},
  ],
  3: [
    // Paragliding
    {"icon": "🛡️", "label": "Safety Briefing"},
    {"icon": "🎥", "label": "Video Recording"},
    {"icon": "🪂", "label": "Certified Instructor"},
    {"icon": "🚗", "label": "Parking"},
    {"icon": "📶", "label": "WiFi"},
  ],
  4: [
    // Sunsets
    {"icon": "🌅", "label": "View Point"},
    {"icon": "🧺", "label": "Picnic Setup"},
    {"icon": "🎵", "label": "Music"},
    {"icon": "📷", "label": "Photography Spot"},
  ],
  5: [
    // Tours
    {"icon": "🗣️", "label": "Guided Tour"},
    {"icon": "📸", "label": "Photos Included"},
    {"icon": "📶", "label": "WiFi"},
    {"icon": "🚗", "label": "Transportation"},
    {"icon": "👨‍👩‍👧", "label": "Family Friendly"},
  ],
  6: [
    // Car Events
    {"icon": "🏁", "label": "Race Tracks"},
    {"icon": "🧯", "label": "Safety Equipment"},
    {"icon": "🎵", "label": "Music"},
    {"icon": "🚗", "label": "Parking"},
    {"icon": "📸", "label": "Event Coverage"},
  ],
  7: [
    // Festivals
    {"icon": "🎵", "label": "Live Music"},
    {"icon": "🍽️", "label": "Food Stalls"},
    {"icon": "📶", "label": "WiFi"},
    {"icon": "🪑", "label": "Seating Areas"},
    {"icon": "👨‍👩‍👧", "label": "Family Friendly"},
  ],
  8: [
    // Hikes
    {"icon": "🥾", "label": "Trail Maps"},
    {"icon": "🚰", "label": "Water Points"},
    {"icon": "👨‍👩‍👧", "label": "Family Friendly"},
    {"icon": "🌳", "label": "Outdoor"},
    {"icon": "🧭", "label": "Guide Available"},
  ],
  9: [
    // Snow Skiing
    {"icon": "🎿", "label": "Equipment Rental"},
    {"icon": "🧣", "label": "Warm Drinks"},
    {"icon": "⛷️", "label": "Instructor"},
    {"icon": "🚗", "label": "Parking"},
    {"icon": "📶", "label": "WiFi"},
  ],
  10: [
    // Boats
    {"icon": "🛥️", "label": "Private Charter"},
    {"icon": "🛟", "label": "Life Jackets"},
    {"icon": "🍽️", "label": "Food"},
    {"icon": "🎵", "label": "Music"},
    {"icon": "📶", "label": "WiFi"},
  ],
  11: [
    // Jetski
    {"icon": "🛡️", "label": "Safety Gear"},
    {"icon": "🧑‍🏫", "label": "Briefing Included"},
    {"icon": "🎥", "label": "GoPro Mount"},
    {"icon": "🚿", "label": "Shower Available"},
    {"icon": "📶", "label": "WiFi"},
  ],
  12: [
    // Museums
    {"icon": "🎧", "label": "Audio Guide"},
    {"icon": "📶", "label": "WiFi"},
    {"icon": "🪑", "label": "Seating Available"},
    {"icon": "👨‍👩‍👧", "label": "Family Friendly"},
    {"icon": "🅿️", "label": "Nearby Parking"},
  ],
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
    const Color selectedColor = Color(0xFF007AFF);
    const Color unselectedColor = Color(0xFFF0F0F0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: const [
            Text(
              'Select Features',
              style: TextStyle(
                fontFamily: "poppins",
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(width: 8),
            Expanded(child: Divider(color: Colors.grey)),
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
                  color: isSelected ? Colors.white : Colors.black87,
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
          children: const [
            Icon(Icons.info_outline, color: Colors.blue, size: 18),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                "Tap to select up to 5 features.",
                style: TextStyle(
                  fontFamily: 'poppins',
                  fontSize: 13,
                  color: Colors.blue,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
