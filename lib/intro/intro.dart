import 'dart:async';
import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:adventura/signUp%20page/Signup.dart';

class DynamicOnboarding extends StatefulWidget {
  @override
  _DynamicOnboardingState createState() => _DynamicOnboardingState();
}

class _DynamicOnboardingState extends State<DynamicOnboarding> {
  final PageController _controller = PageController();
  int _currentPage = 0;
  Timer? _autoScrollTimer;

  final List<Map<String, String>> screens = [
    {
      "image": "assets/Pictures/sunset.jpg",
      "highlight": "Discover",
      "title": "Lebanon’s\nEndless Adventures",
      "description": "Explore untouched coastal beauty and rocky trails."
    },
    {
      "image": "assets/Pictures/sea2.webp",
      "highlight": "Plan",
      "title": "Activities with Ease",
      "description":
          "Book activities, reserve equipment, and create personalized trip packages—all in one place with flexible options and hassle-free planning."
    },
    {
      "image": "assets/Pictures/shakie.jpg",
      "highlight": "Real-Time",
      "title": "Updates & Reviews",
      "description":
          "Get notifications, track upcoming events, and read reviews to make the best choices for your adventures."
    },
  ];

  @override
  void initState() {
    super.initState();

    _autoScrollTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (_controller.hasClients) {
        int nextPage = _controller.page!.round() + 1;
        if (nextPage < screens.length) {
          setState(() => _currentPage = nextPage);
          _controller.animateToPage(
            nextPage,
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeInOut,
          );
        } else {
          _autoScrollTimer?.cancel();
        }
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _autoScrollTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 🔹 BACKGROUND IMAGE with black fade transition
          AnimatedSwitcher(
            duration: const Duration(
                milliseconds: 1200), // ⬅️ makes it slower and smoother
            switchInCurve: Curves.easeInOut,
            switchOutCurve: Curves.easeInOut,
            transitionBuilder: (Widget child, Animation<double> animation) {
              return FadeTransition(
                opacity: animation,
                child: Container(
                  color: Colors.black, // ensures black fade effect
                  child: child,
                ),
              );
            },
            child: Container(
              key: ValueKey<String>(screens[_currentPage]['image']!),
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(screens[_currentPage]['image']!),
                  fit: BoxFit.cover,
                ),
              ),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Colors.black,
                      Colors.black.withOpacity(0.3),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // 🔹 FOREGROUND TEXT
          PageView.builder(
            controller: _controller,
            itemCount: screens.length,
            onPageChanged: (index) {
              setState(() => _currentPage = index);
            },
            itemBuilder: (context, index) {
              final screen = screens[index];
              return Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 100),
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: "${screen['highlight']} ",
                            style: const TextStyle(
                              fontSize: 38,
                              fontWeight: FontWeight.bold,
                              color: Color(0xff007AFF),
                              fontFamily: 'Poppins',
                              height: 1.2,
                            ),
                          ),
                          TextSpan(
                            text: screen['title'],
                            style: const TextStyle(
                              fontSize: 38,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              fontFamily: 'Poppins',
                              height: 1.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      screen['description'] ?? '',
                      style: const TextStyle(
                        color: Color.fromRGBO(255, 255, 255, 0.7),
                        fontSize: 16,
                        fontFamily: 'Poppins',
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 40),
                    if (index == screens.length - 1)
                      Center(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => SignUpPage()),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xff007AFF),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            fixedSize: const Size(376, 54),
                          ),
                          child: const Text(
                            "Let's Get Started",
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                              fontFamily: 'Poppins',
                            ),
                          ),
                        ),
                      ),
                    const SizedBox(height: 32),
                  ],
                ),
              );
            },
          ),

          // 🔹 SKIP BUTTON
          Positioned(
            top: 50,
            right: 24,
            child: TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => SignUpPage()),
                );
              },
              child: const Text(
                "Skip",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontFamily: 'Poppins',
                ),
              ),
            ),
          ),

          // 🔹 PAGE INDICATOR
          Positioned(
            bottom: 24,
            left: 0,
            right: 0,
            child: Center(
              child: SmoothPageIndicator(
                controller: _controller,
                count: screens.length,
                effect: const ExpandingDotsEffect(
                  dotColor: Colors.white30,
                  activeDotColor: Color(0xff007AFF),
                  dotHeight: 10,
                  dotWidth: 10,
                  expansionFactor: 4,
                  spacing: 6,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
