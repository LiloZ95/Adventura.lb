import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:adventura/colors.dart';
import 'package:adventura/event_cards/Cards.dart';
import 'package:adventura/utils.dart';

class LimitedTimeActivitiesSection extends StatefulWidget {
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
  State<LimitedTimeActivitiesSection> createState() =>
      _LimitedTimeActivitiesSectionState();
}

class _LimitedTimeActivitiesSectionState
    extends State<LimitedTimeActivitiesSection> {
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.65);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final events = widget.events;

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
                  fontSize: widget.screenWidth * 0.06,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.bold,
                  color: widget.isDarkMode ? Colors.white : Colors.black,
                ),
              ),
              TextButton(
                onPressed: widget.onSeeAll,
                child: Text(
                  "See All",
                  style: TextStyle(
                    color: AppColors.blue,
                    fontFamily: 'Poppins',
                    fontSize: widget.screenWidth * 0.035,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: widget.screenHeight * 0.3,
          child: PageView.builder(
            controller: _pageController,
            itemCount: events.length,
            physics: const BouncingScrollPhysics(),
            padEnds: true, // 🔥 important: remove auto-padding
            itemBuilder: (context, index) {
              return AnimatedBuilder(
                animation: _pageController,
                builder: (context, child) {
                  double value = 0;
                  if (_pageController.hasClients &&
                      _pageController.position.haveDimensions) {
                    value = _pageController.page! - index;
                  }

                  double scale = (1 - (value.abs() * 0.25)).clamp(0.92, 1.0);
                  double translateY = 20 * value.abs();

                  return Transform.translate(
                    offset: Offset(0, translateY),
                    child: Transform.scale(
                      scale: scale,
                      child: child,
                    ),
                  );
                },
                child: Padding(
                  padding: EdgeInsets.only(
                    right: index == events.length - 1 ? 12.0 : 2.0, // ✅ right only
                  ),
                  child: SizedBox(
                    height: widget.screenHeight * 0.28,
                    child: LimitedEventCard(
                      key: ValueKey(events[index]['id'] ?? "event_$index"),
                      activity: events[index],
                      imageUrl: getEventImageUrl(events[index]),
                      name: events[index]["name"] ?? "Unnamed Event",
                      date: events[index]["event_date"] != null
                          ? DateFormat('MMM d, yyyy').format(
                              DateTime.parse(events[index]["event_date"]))
                          : "No date",
                      location: events[index]["location"] ?? "No location",
                      price: events[index]["price"] != null
                          ? "\$${events[index]["price"]}"
                          : "Free",
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
