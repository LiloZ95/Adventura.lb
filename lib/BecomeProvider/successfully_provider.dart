import 'package:adventura/HomeControllerScreen.dart';
import 'package:flutter/material.dart';

class ProviderWelcomeScreen extends StatefulWidget {
  const ProviderWelcomeScreen({super.key});

  @override
  State<ProviderWelcomeScreen> createState() => _ProviderWelcomeScreenState();
}

class _ProviderWelcomeScreenState extends State<ProviderWelcomeScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _scaleController;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _scaleAnimation = CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    );

    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) _scaleController.forward();
    });
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 40),

              // Animated Check Circle
              ScaleTransition(
                scale: _scaleAnimation,
                child: Container(
                  width: screenWidth * 0.25,
                  height: screenWidth * 0.25,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.green.shade400, Colors.green.shade600],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.green.withOpacity(0.4),
                        blurRadius: 12,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.check_rounded,
                    color: Colors.white,
                    size: screenWidth * 0.15,
                  ),
                ),
              ),

              const SizedBox(height: 30),

              const Text(
                "Request Sent",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'poppins',
                ),
              ),
              const SizedBox(height: 10),

              const Text(
                "Thank you for applying as a provider. Our team is reviewing your information and will get back to you shortly.",
                style: TextStyle(
                    fontSize: 14,
                    color: Colors.black87,
                    fontFamily: 'poppins',
                    height: 1.6),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),

              buildFeatureTile(Icons.verified_user_rounded,
                  "We’re verifying your documents"),
              buildFeatureTile(Icons.watch_later_outlined,
                  "Approval usually takes 24-48 hours"),
              buildFeatureTile(Icons.mark_email_read_outlined,
                  "You’ll receive an email once approved"),

              const Spacer(),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (_) => HomeControllerScreen()),
                      (route) => false,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[700],
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    "Back to Home",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'poppins',
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildFeatureTile(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: Colors.blue[800], size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 14, fontFamily: 'poppins'),
            ),
          ),
        ],
      ),
    );
  }
}
