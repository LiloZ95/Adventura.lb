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

    return Container(
      width: screenWidth * 0.9,
      // height: 65,
      decoration: BoxDecoration(
        color: const Color(0xFF1B1B1B), // solid dark
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            offset: Offset(0, 8),
            blurRadius: 20,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _navIcon("assets/Icons/home.png", 0, onTap),
          _navIcon("assets/Icons/search.png", 1, onTap),
          _navIcon("assets/Icons/ticket.png", 2, onTap),
          _navIcon("assets/Icons/bookmark.png", 3, onTap),
          _navIcon("assets/Icons/paper-plane.png", 4, onTap),
        ],
      ),
    );
  }

  Widget _navIcon(String iconPath, int index, Function(int) onTap) {
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
            onPressed: () {
              print("Tapped index $index"); // ✅ Add for debug
              onTap(index);
            },
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
