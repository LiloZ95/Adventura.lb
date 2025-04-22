import 'package:adventura/Services/otp_service.dart';
import 'package:adventura/colors.dart';
import 'package:flutter/material.dart';
import 'package:adventura/OTP/OTPVerification.dart';
import 'dart:ui' as ui; // For ImageFilter

class ForgotPasswordScreen extends StatefulWidget {
  @override
  _ForgotPasswordScreenState createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController _emailController = TextEditingController();
  bool _isLoading = false;
  // ignore: unused_field
  String _errorMessage = "";


  void _sendOtp() async {
    setState(() => _isLoading = true);

    try {
      print("🔍 Sending OTP request to: ${_emailController.text}");

      final response = await OtpService.sendOtp(_emailController.text,
          isForSignup: false); // Get response

      setState(() => _isLoading = false);

      if (response["success"] == true) {
        print("✅ OTP Sent Successfully!");

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => OtpVerificationScreen(
              target: _emailController.text,
              targetType: "email",
              isForSignup: false,
            ),
          ),
        );
      } else {
        setState(() {
          _errorMessage = response["error"] ?? "Failed to send OTP. Try again.";
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  "Failed to send OTP: ${response["error"] ?? "Unknown error"}")),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = "Something went wrong. Please try again.";
      });

      print("❌ Exception in _sendOtp: $e");
    }
  }


   @override
Widget build(BuildContext context) {
  final screenWidth = MediaQuery.of(context).size.width;
  final screenHeight = MediaQuery.of(context).size.height;
  final isDarkMode = Theme.of(context).brightness == Brightness.dark;

  return Scaffold(
    resizeToAvoidBottomInset: false,
    body: Stack(
      children: [
        // ✅ Background Blur Image
        Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/Pictures/island.jpg'),
              fit: BoxFit.cover,
            ),
          ),
          child: BackdropFilter(
            filter: ui.ImageFilter.blur(sigmaX: 2.0, sigmaY: 2.0),
            child: Container(
              color: Colors.black.withOpacity(0.5),
            ),
          ),
        ),

        // ✅ Centered Card Content
        Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
              child: Container(
                padding: EdgeInsets.all(screenWidth * 0.05),
                decoration: BoxDecoration(
                  color: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    if (!isDarkMode)
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // ✅ Title
                    Text(
                      "Forgot Password?",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: screenWidth * 0.05,
                        fontWeight: FontWeight.bold,
                        fontFamily: "Poppins",
                        color: isDarkMode ? Colors.white : Colors.black,
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.02),

                    // ✅ Subtitle
                    Text(
                      "Enter Your Email here to get an OTP Code",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: screenWidth * 0.035,
                        color: isDarkMode ? Colors.grey[400] : Colors.grey[700],
                        fontFamily: "Poppins",
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.02),

                    // ✅ Email Input
                    TextField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: "Poppins",
                        fontSize: screenWidth * 0.045,
                        color: isDarkMode ? Colors.white : Colors.black,
                      ),
                      decoration: InputDecoration(
                        hintText: "Enter Your Email Here",
                        hintStyle: TextStyle(
                          color: isDarkMode ? Colors.grey[500] : const Color(0xFF8E8E8E),
                          fontFamily: "Poppins",
                        ),
                        filled: false,
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                            color: isDarkMode ? Colors.grey[700]! : Colors.grey[600]!,
                            width: 1.0,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                            color: isDarkMode ? Colors.grey[400]! : Colors.grey[400]!,
                            width: 1.0,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.03),

                    // ✅ Button
                    ElevatedButton(
                      onPressed: _isLoading ? null : _sendOtp,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.blue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: EdgeInsets.symmetric(
                          vertical: screenHeight * 0.02,
                        ),
                        minimumSize: Size(screenWidth * 0.2, 20),
                      ),
                      child: _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : Text(
                              "Send OTP",
                              style: TextStyle(
                                fontSize: screenWidth * 0.04,
                                color: Colors.white,
                                fontFamily: "Poppins",
                              ),
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),

        // ✅ Top-left Back Arrow
        Positioned(
          top: 16,
          left: 16,
          child: SafeArea(
            child: IconButton(
              icon: Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ),
      ],
    ),
  );
}

  }
