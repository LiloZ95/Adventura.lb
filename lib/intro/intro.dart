import 'package:adventura/signUp%20page/Signup.dart';
import 'package:flutter/material.dart';
import 'package:animated_text_kit/animated_text_kit.dart';

class DynamicOnboarding extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final Map<String, String> screen = {
      "image": "assets/Pictures/sunset.jpg",
      "titleStatic": "Lebanon’s \nEndless \nAdventures",
      "description":
          "From sea trips to mountain hikes, explore curated experiences tailored for everyone.",
    };

    final List<String> dynamicWords = [
      "Discover",
      "Plan",
      "Get Notified about"
    ];

    return Scaffold(
      body: Stack(
        children: [
          // Background Image
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(screen['image']!),
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
                  Colors.black.withOpacity(1.0),
                  Colors.black.withOpacity(0.5),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title with dynamic first word and static part
                RichText(
                  text: TextSpan(
                    children: [
                      WidgetSpan(
                        alignment: PlaceholderAlignment.baseline,
                        baseline: TextBaseline.alphabetic,
                        child: DefaultTextStyle(
                          style: TextStyle(
                            fontSize: 55,
                            fontWeight: FontWeight.bold,
                            color: Color(0xff007AFF),
                            height: 1,
                            fontFamily: 'Raleway',
                          ),
                          child: AnimatedTextKit(
                            animatedTexts: dynamicWords
                                .map((word) => FadeAnimatedText(
                                      word,
                                      duration: Duration(milliseconds: 2200),
                                    ))
                                .toList(),
                            repeatForever: true,
                          ),
                        ),
                      ),
                      TextSpan(
                        text: screen['titleStatic']!,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 55,
                          color: Color(0xffffffff),
                          height: 1.0,
                          fontFamily: 'Raleway',
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 16),
                // Description
                Text(
                  screen['description']!,
                  style: TextStyle(
                    color: Color.fromRGBO(255, 255, 255, 0.7),
                    fontSize: 16,
                    height: 1.2,
                  ),
                ),
                SizedBox(height: 48),
                // Button
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => SignUpPage()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue, // Button color
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(20), // Rounded corners
                      ),
                      fixedSize: Size(376, 54), // Fixed width and height
                    ),
                    child: Text(
                      "Let's Get Started",
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                ),
                SizedBox(height: 32),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
