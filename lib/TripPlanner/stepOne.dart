import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class StepOneDuration extends StatelessWidget {
  final TextEditingController daysController;
  final DateTime? startDate;
  final VoidCallback onDatePick;

  const StepOneDuration({
    super.key,
    required this.daysController,
    required this.startDate,
    required this.onDatePick,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "When is your trip?",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 24),
        TextField(
          controller: daysController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: "How many days?",
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        const SizedBox(height: 24),
        GestureDetector(
          onTap: onDatePick,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  startDate != null
                      ? DateFormat.yMMMd().format(startDate!)
                      : "Pick a start date",
                  style: TextStyle(
                    fontSize: 16,
                    color: startDate != null ? Colors.black : Colors.grey[600],
                  ),
                ),
                const Icon(Icons.calendar_today, size: 20),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
