import 'package:flutter/material.dart';

class BottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onTap;

  const BottomNavBar({
    super.key,
    required this.selectedIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        margin: const EdgeInsets.only(bottom: 25),
        width: screenWidth * 0.93,
        height: 65,
        decoration: BoxDecoration(
          color: const Color(0xFF1B1B1B),
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.70),
              offset: Offset(0, 1),
              blurRadius: 5,
              spreadRadius: 0,
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _navIcon("assets/Icons/home.png", 0),
            _navIcon("assets/Icons/search.png", 1),
            _navIcon("assets/Icons/ticket.png", 2),
            _navIcon("assets/Icons/bookmark.png", 3),
            _navIcon("assets/Icons/paper-plane.png", 4),
          ],
        ),
      ),
    );
  }

  Widget _navIcon(String iconPath, int index) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(
        begin: 1.0,
        end: selectedIndex == index ? 1.2 : 1.0,
      ),
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOutBack,
      builder: (context, scale, child) {
        return Transform.scale(
          scale: scale,
          child: IconButton(
            onPressed: () => onTap(index),
            icon: Image.asset(
              iconPath,
              width: 35,
              height: 35,
              color: selectedIndex == index ? Colors.white : Colors.grey,
            ),
          ),
        );
      },
    );
  }
}
