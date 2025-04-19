// Update this file: lib/widgets/herosection_web.dart

import 'package:flutter/material.dart';
import 'package:adventura/colors.dart';
import 'dart:math' as math;

class HeroSectionWidget extends StatelessWidget {
  final bool isLoading;
  // Add the callback for search tap
  final VoidCallback onSearchTap;

  const HeroSectionWidget({
    Key? key,
    required this.isLoading,
    required this.onSearchTap, // New required parameter
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final bool isMobile = screenWidth < 768;
    final bool isTablet = screenWidth >= 768 && screenWidth < 1200;

    return Container(
      width: double.infinity,
      height: isMobile ? 500 : 600,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: const AssetImage('assets/images/adventure_background.jpg'),
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(
            Colors.black.withOpacity(0.3),
            BlendMode.darken,
          ),
        ),
      ),
      child: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                // Animated shapes for visual interest (keep as is)
                Positioned(
                  top: -50,
                  right: -50,
                  child: Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      color: AppColors.mainBlue.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                Positioned(
                  bottom: -80,
                  left: screenWidth * 0.2,
                  child: Transform.rotate(
                    angle: -math.pi / 6,
                    child: Container(
                      width: 300,
                      height: 300,
                      decoration: BoxDecoration(
                        color: AppColors.mainBlue.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(60),
                      ),
                    ),
                  ),
                ),
                
                // Content container
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: isMobile ? 16 : (isTablet ? 32 : 64),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.mainBlue.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: const Text(
                          "ADVENTURE AWAITS",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        "Discover Your Next\nUnforgettable Experience",
                        style: TextStyle(
                          fontSize: isMobile ? 32 : 48,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Poppins',
                          color: AppColors.mainBlue.withOpacity(0.8),
                          height: 1.2,
                          shadows: [
                            Shadow(
                              color: Colors.black.withOpacity(0.3),
                              blurRadius: 10,
                            )
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        "Explore thousands of activities and destinations in lebanon",
                        style: TextStyle(
                          fontSize: isMobile ? 16 : 20,
                          fontFamily: 'Poppins',
                          color: AppColors.mainBlue.withOpacity(0.8),
                          shadows: [
                            Shadow(
                              color: Colors.black.withOpacity(0.3),
                              blurRadius: 5,
                            )
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),
                      
                      // Updated search container with GestureDetector
                      GestureDetector(
                        onTap: onSearchTap, // Use the callback when tapped
                        child: Container(
                          width: isMobile ? double.infinity : screenWidth * 0.5,
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(50),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 15,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.search, color: AppColors.mainBlue, size: 28),
                              const SizedBox(width: 16),
                              Expanded(
                                child: AbsorbPointer( // Prevent direct interaction with TextField
                                  child: TextField(
                                    decoration: InputDecoration(
                                      hintText: "What to you want to explore?",
                                      border: InputBorder.none,
                                      hintStyle: TextStyle(
                                        color: Colors.grey.shade400,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              ElevatedButton(
                                onPressed: onSearchTap, // Also use the callback here
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.mainBlue,
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                ),
                                child: const Text(
                                  "Explore",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 32),
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.keyboard_arrow_down,
                            color: Colors.white,
                            size: 32,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                // Login prompt (keep as is)
           
              ],
            ),
    );
  }
}