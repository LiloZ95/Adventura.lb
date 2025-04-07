import 'package:adventura/Chatbot/activityCard.dart';
import 'package:flutter/material.dart';

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
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

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

  @override
  Widget build(BuildContext context) {
    final card = widget.card;

    return SlideTransition(
      position: _offsetAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: ActivityCard(
          name: card['name'],
          description: card['description'],
          price: card['price'],
          duration: card['duration'],
          seats: card['seats'],
          location: card['location'],
        ),
      ),
    );
  }
}
