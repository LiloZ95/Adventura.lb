import 'package:flutter/material.dart';
import 'package:adventura/colors.dart';
import 'package:adventura/event_cards/Cards.dart';

class RecommendedActivitiesSection extends StatelessWidget {
  final List<dynamic> recommendedActivities;
  final double screenWidth;
  final double screenHeight;
  final bool isDarkMode;
  final VoidCallback onSeeAll;

  const RecommendedActivitiesSection({
    Key? key,
    required this.recommendedActivities,
    required this.screenWidth,
    required this.screenHeight,
    required this.isDarkMode,
    required this.onSeeAll,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 6, 16, 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                "You Might Like",
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
        const SizedBox(height: 6),
        recommendedActivities.isEmpty
            ? Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  children: [
                    Icon(
                      Icons.warning,
                      size: 48,
                      color:
                          isDarkMode ? Colors.grey.shade400 : Colors.grey,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "No recommendations found.",
                      style: TextStyle(
                        fontSize: 16,
                        fontFamily: 'Poppins',
                        color:
                            isDarkMode ? Colors.grey.shade400 : Colors.grey,
                      ),
                    ),
                  ],
                ),
              )
            : Column(
                children: [
                  ...recommendedActivities
                      .where((activity) =>
                          activity['availability_status'] == true)
                      .map((activity) => EventCard(
                            context: context,
                            activity: activity,
                          ))
                      .toList(),
                  SizedBox(height: screenHeight * 0.12),
                ],
              ),
      ],
    );
  }
}
