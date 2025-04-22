import 'package:adventura/BecomeProvider/BusinessInfo.dart';
import 'package:adventura/BecomeProvider/widgets/dots.dart';
import 'package:flutter/material.dart';
import 'BasicInfo.dart';
import 'CredentialsStep.dart';

class BecomeProviderFlow extends StatefulWidget {
  const BecomeProviderFlow({super.key});

  @override
  State<BecomeProviderFlow> createState() => _BecomeProviderFlowState();
}

class _BecomeProviderFlowState extends State<BecomeProviderFlow> {
  final PageController _pageController = PageController();
  int _currentStep = 0;

  void nextStep() {
    if (_currentStep < 2) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void previousStep() {
    if (_currentStep > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDarkMode
          ? const Color(0xFF121212)
          : Colors.white, // 🌙 Full background switch
      body: SafeArea(
        child: Column(
          children: [
            // Dots Indicator (Full Width)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Row(
                children: [
                  Expanded(child: StepDot(active: _currentStep == 0)),
                  const SizedBox(width: 6),
                  Expanded(child: StepDot(active: _currentStep == 1)),
                  const SizedBox(width: 6),
                  Expanded(child: StepDot(active: _currentStep == 2)),
                ],
              ),
            ),

            // Step Pages
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(), // disable swipe
                onPageChanged: (index) {
                  setState(() {
                    _currentStep = index;
                  });
                },
                children: [
                  BasicInfoScreen(
                    onNext: nextStep,
                  ),
                  CredentialsStep(onNext: nextStep, onBack: previousStep),
                  BusinessInfoStep(onNext: nextStep, onBack: previousStep),
                  Center(
                      child: Text('Step 3 – Business Details')), // Placeholder
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
