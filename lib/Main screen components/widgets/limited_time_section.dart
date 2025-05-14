import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:adventura/colors.dart';
import 'package:adventura/event_cards/Cards.dart';
import 'package:adventura/utils.dart';

class LimitedTimeActivitiesSection extends StatelessWidget {
  final List<Map<String, dynamic>> events;
  final bool isDarkMode;
  final double screenWidth;
  final double screenHeight;
  final VoidCallback onSeeAll;

  const LimitedTimeActivitiesSection({
    Key? key,
    required this.events,
    required this.isDarkMode,
    required this.screenWidth,
    required this.screenHeight,
    required this.onSeeAll,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 0, 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                "Limited Time Activities",
                style: TextStyle(
                  fontSize: screenWidth * 0.06,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? Colors.white : Colors.black,
                ),
              ),
              TextButton(
                onPressed: onSeeAll,
                child: Text(
                  "See All",
                  style: TextStyle(
                    color: AppColors.blue,
                    fontFamily: 'Poppins',
                    fontSize: screenWidth * 0.035,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: screenHeight * 0.4,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(0, 0, 16, 0),
              child: Row(
                children: events.map((event) {
                  return LimitedEventCard(
                    key: ValueKey(event['id']), // ✅ enables tracking
                    activity: event,
                    imageUrl: getEventImageUrl(event),
                    name: event["name"] ?? "Unnamed Event",
                    date: event["event_date"] != null
                        ? DateFormat('MMM d, yyyy')
                            .format(DateTime.parse(event["event_date"]))
                        : "No date",
                    location: event["location"] ?? "No location",
                    price:
                        event["price"] != null ? "\$${event["price"]}" : "Free",
                  );
                }).toList(),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
