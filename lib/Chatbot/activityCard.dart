import 'package:flutter/material.dart';

class ActivityCard extends StatelessWidget {
  final String name;
  final String description; // We can keep it or remove if unused
  final double price;
  final int duration;
  final int seats;
  final String location;

  const ActivityCard({
    Key? key,
    required this.name,
    required this.description,
    required this.price,
    required this.duration,
    required this.seats,
    required this.location,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        padding: const EdgeInsets.all(8),
        child: Row(
          children: [
            // 🖼️ Image section
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.asset(
                'assets/Pictures/sunset.jpg', // replace with your actual image path
                width: 120,
                height: 130,
                fit: BoxFit.cover,
              ),
            ),

            const SizedBox(width: 12),

            // 📄 Info section
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title + Heart
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
                      // const Icon(Icons.favorite_border,
                      //     color: Color.fromARGB(255, 255, 97, 97)),
                    ],
                  ),

                  const SizedBox(height: 4),

                  // Location
                  Row(
                    children: [
                      const Icon(Icons.location_on,
                          size: 14, color: Colors.grey),
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

                  // Rating
                  Row(
                    children: const [
                      Icon(Icons.star, color: Colors.amber, size: 16),
                      SizedBox(width: 4),
                      Text("4.9",
                          style: TextStyle(
                              fontSize: 13, fontWeight: FontWeight.w600)),
                      SizedBox(width: 4),
                      Text("(89 reviews)",
                          style: TextStyle(fontSize: 12, color: Colors.grey)),
                    ],
                  ),

                  const SizedBox(height: 2),

                  // Tags (Seats, Age, Difficulty)
                  Row(
                    children: [
                      _infoTag(Icons.group, '$seats'),
                      const SizedBox(width: 6),
                      _infoTag(null, '+16'),
                      // const SizedBox(width: 6),
                      // _infoTag(null, 'easy', color: Colors.green),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Price
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
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
                        "/Hour",
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
            ),
          ],
        ),
      ),
    );
  }

  // Helper widget for rounded tags
  Widget _infoTag(IconData? icon, String text, {Color? color}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        // color: (color ?? Colors.grey[200]),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey.shade400, // Thin gray border
          width: 0.5,
        ),
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
}
