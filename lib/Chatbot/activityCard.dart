import 'package:flutter/material.dart';

class ActivityCard extends StatelessWidget {
  final String name;
  final String description;
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
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(name,
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(description, style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("📍 $location"),
                Text("⏳ ${duration} mins"),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("💰 \$${price.toStringAsFixed(2)}"),
                Text("🏆 Seats: $seats"),
              ],
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () {
               
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(40),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text("Book Now"),
            ),
          ],
        ),
      ),
    );
  }
}
