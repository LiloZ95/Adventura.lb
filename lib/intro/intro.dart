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
  Timer? _autoScrollTimer;
  int _currentPage = 0;

  final List<Map<String, String>> screens = [
    {
      "image": "assets/Pictures/nakhil.jpg",
      "description": "Explore untouched coastal beauty and rocky trails."
    },
    {
      "image": "assets/Pictures/sea2.webp",
      "description": "Sail into crystal clear waters and soak in the serenity."
    },
    {
      "image": "assets/Pictures/shakie.jpg",
      "description": "Experience adrenaline with cliff jumps and wild moments."
    },
  ];

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _autoScrollTimer = Timer.periodic(const Duration(seconds: 6), (timer) {
        if (_controller.hasClients) {
          _currentPage++;
          if (_currentPage >= screens.length) {
            _autoScrollTimer?.cancel();
            return;
          }
          _controller.animateToPage(
            _currentPage,
            duration: const Duration(milliseconds: 1000),
            curve: Curves.easeInOutCubicEmphasized,
          );
        }
      });
    });
  }

  @override
  void dispose() {
    _autoScrollTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageView.builder(
            controller: _controller,
            itemCount: screens.length,
            onPageChanged: (index) {
              _currentPage = index;
            },
            itemBuilder: (context, index) {
              return Stack(
                children: [
                  // Background Image
                  Container(
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage(screens[index]['image']!),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  // Gradient Overlay
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          Colors.black.withOpacity(0.9),
                          Colors.black.withOpacity(0.4),
                        ],
                      ),
                    ),
                  ),
                  // Content
                  Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 100),
                        RichText(
                          text: const TextSpan(
                            children: [
                              TextSpan(
                                text: "Discover ",
                                style: TextStyle(
                                  fontSize: 45,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xff007AFF),
                                  fontFamily: 'Poppins',
                                  height: 1.1,
                                ),
                              ),
                              TextSpan(
                                text: "Lebanon’s\nEndless\nAdventures",
                                style: TextStyle(
                                  fontSize: 45,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  fontFamily: 'Poppins',
                                  height: 1.1,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          screens[index]['description'] ?? '',
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
                  ),
                ],
              );
            },
          ),

          // Skip Button
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

          // Page Indicator
          Positioned(
            bottom: 24,
            left: 0,
            right: 0,
            child: Center(
              child: SmoothPageIndicator(
                controller: _controller,
                count: screens.length,
                effect: ExpandingDotsEffect(
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
