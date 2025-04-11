import 'package:adventura/Services/activity_service.dart';
import 'package:adventura/event_cards/eventDetailsScreen.dart';
import 'package:flutter/material.dart';
import 'package:adventura/Chatbot/activityCard.dart';

class SlideTransitionCard extends StatefulWidget {
  final Map<String, dynamic> card;
  final int index;

  const SlideTransitionCard({
    Key? key,
    required this.card,
    required this.index,
  }) : super(key: key);

  @override
  State<SlideTransitionCard> createState() => _SlideTransitionCardState();
}

class _SlideTransitionCardState extends State<SlideTransitionCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _offsetAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _offsetAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    Future.delayed(Duration(milliseconds: 100 * widget.index), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleCardTap() async {
    int activityId = widget.card['cardId'];

    final activities = await ActivityService.fetchActivitiesByIds([activityId]);

    if (activities.isNotEmpty) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => EventDetailsScreen(activity: activities.first),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to load activity details")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleCardTap,
      child: SlideTransition(
        position: _offsetAnimation,
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: ActivityCard(
            name: widget.card['name'],
            description: widget.card['description'],
            price: widget.card['price'],
            duration: widget.card['duration'],
            seats: widget.card['seats'],
            location: widget.card['location'],
          ),
        ),
      ),
    );
  }
}
