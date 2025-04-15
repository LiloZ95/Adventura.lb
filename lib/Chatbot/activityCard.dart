import 'package:adventura/Chatbot/circularGlow.dart';
import 'package:flutter/material.dart';

class ActivityCard extends StatelessWidget {
  final Map<String, dynamic> card;

  const ActivityCard({Key? key, required this.card}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final String name = card['name'] ?? 'No Name';
    final String description = card['description'] ?? '';
    final double price = (card['price'] ?? 0).toDouble();
    final int seats = card['seats'] ?? 0;
    final String location = card['location'] ?? 'Unknown';
    final String dateLabel = card['date_label'] ?? 'TBA';
    final bool isTrending = card['is_trending'] ?? false;

    return isTrending
        ? CircularGlowBorder(child: _buildCard(card))
        : _buildCard(card);
  }
}

// Tag widget
Widget _infoTag(IconData? icon, String text) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: Colors.grey.shade400, width: 0.5),
    ),
    child: Row(
      children: [
        if (icon != null) Icon(icon, size: 14, color: Colors.black),
        if (icon != null) const SizedBox(width: 4),
        Text(
          text,
          style: const TextStyle(fontSize: 12, fontFamily: "poppins"),
        ),
      ],
    ),
  );
}

Widget _buildCard(Map<String, dynamic> card) {
  final String name = card['name'] ?? 'Unnamed';
  final String location = card['location'] ?? 'Unknown';
  final int seats = card['seats'] ?? 0;
  final double price = (card['price'] ?? 0).toDouble();
  final String dateLabel = card['date_label'] ?? 'TBA';

  return Card(
    color: Colors.white,
    margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
    elevation: 4,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    child: Container(
      padding: const EdgeInsets.all(8),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.asset(
              'assets/Pictures/sunset.jpg',
              width: 120,
              height: 130,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Text(
                        name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'poppins',
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.calendar_today,
                        size: 14, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      dateLabel,
                      style: const TextStyle(
                        fontSize: 12,
                        fontFamily: "poppins",
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),

                // Location
                Row(
                  children: [
                    const Icon(Icons.location_on, size: 14, color: Colors.grey),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        location,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                          fontFamily: 'poppins',
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 2),

                // Static rating
                // Row(
                //   children: const [
                //     Icon(Icons.star, color: Colors.amber, size: 16),
                //     SizedBox(width: 4),
                //     Text("4.9",
                //         style: TextStyle(
                //             fontSize: 13, fontWeight: FontWeight.w600)),
                //     SizedBox(width: 4),
                //     Text("(89 reviews)",
                //         style: TextStyle(fontSize: 12, color: Colors.grey)),
                //   ],
                // ),

                const SizedBox(height: 2),

                // Tags
                Row(
                  children: [
                    _infoTag(Icons.group, '$seats'),
                    const SizedBox(width: 6),
                    _infoTag(null, '+16'),
                  ],
                ),

                const SizedBox(height: 12),

                // Price + Date
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Text(
                          "\$$price",
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                            fontFamily: "poppins",
                          ),
                        ),
                        const Text(
                          "/person",
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                            fontFamily: "poppins",
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}
