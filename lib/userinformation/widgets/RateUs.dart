import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

class RateUsPage extends StatefulWidget {
  const RateUsPage({super.key});

  @override
  State<RateUsPage> createState() => _RateUsPageState();
}

class _RateUsPageState extends State<RateUsPage> with SingleTickerProviderStateMixin {
  int selectedStars = 0;
  final TextEditingController feedbackController = TextEditingController();

  void submitRating() {
    if (selectedStars == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a star rating')),
      );
      return;
    }

    print("Rating: $selectedStars");
    print("Feedback: ${feedbackController.text}");

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Thank you for your feedback!')),
    );

    setState(() {
      selectedStars = 0;
      feedbackController.clear();
    });
  }

  Widget buildStar(int index, bool isDarkMode) {
    return AnimatedScale(
      scale: selectedStars >= index ? 1.2 : 1.0,
      duration: const Duration(milliseconds: 200),
      child: IconButton(
        icon: Icon(
          selectedStars >= index ? Icons.star : Icons.star_border,
          size: 32,
          color: selectedStars >= index ? Colors.amber : (isDarkMode ? Colors.white24 : Colors.grey[400]),
        ),
        onPressed: () {
          setState(() {
            selectedStars = index;
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDarkMode ? const Color(0xFF1F1F1F) : const Color(0xFFF2F4F8),
      appBar: AppBar(
        title: Text(
          "Rate Us",
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: isDarkMode ? Colors.white : Colors.black,
          ),
        ),
        backgroundColor: isDarkMode ? const Color(0xFF1F1F1F) : Colors.white,
        elevation: 1,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: isDarkMode ? Colors.white : Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Center(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(28),
                gradient: isDarkMode
                    ? null
                    : const LinearGradient(
                        colors: [Colors.white, Color(0xFFF9FAFB)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                color: isDarkMode ? const Color(0xFF2C2C2C) : null,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 24,
                    offset: const Offset(0, 12),
                  )
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(28),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.emoji_people, size: 40, color: Colors.blue),
                    const SizedBox(height: 12),
                    Text(
                      "How was your experience?",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: isDarkMode ? Colors.white : Colors.black,
                      ),
                    ),
                    const SizedBox(height: 18),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(5, (index) => buildStar(index + 1, isDarkMode)),
                    ),
                    const SizedBox(height: 24),
                    TextField(
                      controller: feedbackController,
                      maxLines: 4,
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        color: isDarkMode ? Colors.white : Colors.black,
                      ),
                      decoration: InputDecoration(
                        hintText: "Write your thoughts (optional)...",
                        hintStyle: TextStyle(
                          fontFamily: 'Poppins',
                          color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                        ),
                        filled: true,
                        fillColor: isDarkMode ? const Color(0xFF1F1F1F) : Colors.grey[100],
                        contentPadding: const EdgeInsets.all(16),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        icon: const Icon(LucideIcons.send, size: 20, color: Colors.white),
                        label: const Text(
                          "Submit Feedback",
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 3,
                        ),
                        onPressed: submitRating,
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
