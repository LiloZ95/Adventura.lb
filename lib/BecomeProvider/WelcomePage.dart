import 'package:flutter/material.dart';
import 'package:adventura/BecomeProvider/BecomeProviderFlow.dart';

class ProviderWelcomeScreen extends StatefulWidget {
  const ProviderWelcomeScreen({super.key});

  @override
  State<ProviderWelcomeScreen> createState() => _ProviderWelcomeScreenState();
}

class _ProviderWelcomeScreenState extends State<ProviderWelcomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<Animation<double>> _fadeAnimations;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );

    _fadeAnimations = List.generate(6, (index) {
      final start = index * 0.1;
      final end = start + 0.3;
      return CurvedAnimation(
        parent: _controller,
        curve: Interval(start, end, curve: Curves.easeIn),
      );
    });

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  @override
Widget build(BuildContext context) {
  final isDarkMode = Theme.of(context).brightness == Brightness.dark;

  return Scaffold(
    backgroundColor: isDarkMode ? const Color(0xFF1B1B1D) : Colors.white,
    body: SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),

            // Back + title
            FadeTransition(
              opacity: _fadeAnimations[0],
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Icon(Icons.arrow_back_ios_new,
                          size: 20,
                          color: isDarkMode ? Colors.white : Colors.black),
                    ),
                  ),
                  Center(
                    child: Text(
                      'Welcome to',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        fontFamily: "Poppins",
                        color: isDarkMode ? Colors.white : Colors.black,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),

            // Logo
            FadeTransition(
              opacity: _fadeAnimations[1],
              child: Center(
                child: Image.asset(
                  'assets/Pictures/Group 44.png',
                  height: 95,
                  fit: BoxFit.contain,
                ),
              ),
            ),

            const SizedBox(height: 22),

            // RichText
            FadeTransition(
              opacity: _fadeAnimations[2],
              child: Center(
                child: RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    style: TextStyle(
                      fontSize: 15,
                      height: 1.6,
                      fontFamily: "Poppins",
                      color: isDarkMode ? Colors.grey[300] : Colors.grey[800],
                    ),
                    children: [
                      const TextSpan(
                        text:
                            "We’re thrilled to have you here!\nAs a provider, you have the power to share amazing experiences, connect with adventure-seekers, and grow your business. ",
                      ),
                      const TextSpan(
                        text:
                            "Whether you’re hosting thrilling outdoor activities, limited events, or unique cultural experiences, ",
                      ),
                      WidgetSpan(
                        alignment: PlaceholderAlignment.baseline,
                        baseline: TextBaseline.alphabetic,
                        child: ShaderMask(
                          shaderCallback: (bounds) => const LinearGradient(
                            colors: [Color(0xFF00A3FF), Color(0xFF006DFF)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ).createShader(bounds),
                          child: const Text(
                            'Adventura',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Poppins',
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      const TextSpan(
                        text: " is here to support your journey.",
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 32),

            // Section title
            FadeTransition(
              opacity: _fadeAnimations[3],
              child: Text(
                'Benefits of Becoming a Provider',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  fontFamily: "Poppins",
                  color: isDarkMode ? Colors.white : Colors.black,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Card
            FadeTransition(
              opacity: _fadeAnimations[4],
              child: Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: isDarkMode ? const Color(0xFF292A2E) : Colors.grey.shade100,
                  boxShadow: [
                    if (!isDarkMode)
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    ShaderMask(
                      shaderCallback: (bounds) => const LinearGradient(
                        colors: [Color(0xFF00A3FF), Color(0xFF006DFF)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ).createShader(bounds),
                      child: const Icon(
                        Icons.group_add,
                        size: 48,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Reach a wider audience\nand increase your\nbookings.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w400,
                        fontFamily: "Poppins",
                        color: isDarkMode ? Colors.white : Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const Spacer(),

            // CTA button
            FadeTransition(
              opacity: _fadeAnimations[5],
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const BecomeProviderFlow(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF006DFF),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    shadowColor: isDarkMode ? Colors.transparent : null,
                  ),
                  child: const Text(
                    "Let’s Get Started!",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      fontFamily: "Poppins",
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
    }