import 'package:adventura/Services/otp_service.dart';
import 'package:adventura/colors.dart';
import 'package:flutter/material.dart';
import 'package:adventura/OTP/OTPVerification.dart';
import '../login/login.dart';
import 'dart:ui' as ui;
import 'package:flutter/foundation.dart' show kIsWeb;

class ForgotPasswordScreen extends StatefulWidget {
  @override
  _ForgotPasswordScreenState createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController _emailController = TextEditingController();
  bool _isLoading = false;
  String _errorMessage = "";

  void verifyOtp() {
    // TODO: Implement OTP verification logic
  }

  void _sendOtp() async {
    setState(() => _isLoading = true);

    try {
      print("🔍 Sending OTP request to: ${_emailController.text}");

      final response = await OtpService.sendOtp(_emailController.text,
          isForSignup: false);

      print("🔍 API Response: $response");

      setState(() => _isLoading = false);

      if (response["success"] == true) {
        print("✅ OTP Sent Successfully!");

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => OtpVerificationScreen(
              email: _emailController.text,
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
    
    // Adjust layout for web
    final bool isWebPlatform = kIsWeb;
    final double formWidth = isWebPlatform 
        ? (screenWidth > 800 ? 500 : screenWidth * 0.8) 
        : screenWidth * 0.9;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          // Background Image with Blur
          Container(
            decoration: BoxDecoration(
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

          // Centered Content
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: isWebPlatform ? 0 : screenWidth * 0.05,
                  vertical: screenHeight * 0.02
                ),
                child: Container(
                  width: formWidth,
                  padding: EdgeInsets.all(isWebPlatform ? 30 : screenWidth * 0.05),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 10,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Heading
                      Text(
                        "Forgot Password?",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: isWebPlatform 
                              ? (screenWidth > 800 ? 28 : screenWidth * 0.05)
                              : screenWidth * 0.05,
                          fontWeight: FontWeight.bold,
                          fontFamily: "Poppins",
                          color: Colors.black,
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.02),

                      Text(
                        "Enter Your Email here to get an OTP Code",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: isWebPlatform 
                              ? (screenWidth > 800 ? 16 : screenWidth * 0.035)
                              : screenWidth * 0.035,
                          color: Colors.grey[700],
                          fontFamily: "Poppins",
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.03),

                      // Email Input Field
                      TextField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: "poppins",
                          fontSize: isWebPlatform ? 16 : screenWidth * 0.045,
                          color: Colors.black,
                        ),
                        decoration: InputDecoration(
                          hintText: "Enter Your Email Here",
                          hintStyle: TextStyle(
                            color: Color(0xFF8E8E8E),
                            fontSize: isWebPlatform ? 16 : screenWidth * 0.04,
                          ),
                          filled: false,
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(
                              color: Colors.grey[600]!,
                              width: 1.0,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(
                              color: Colors.grey[400]!,
                              width: 1.0,
                            ),
                          ),
                          contentPadding: isWebPlatform
                              ? EdgeInsets.symmetric(vertical: 15, horizontal: 15)
                              : null,
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.03),

                      // Error message if any
                      if (_errorMessage.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Text(
                            _errorMessage,
                            style: TextStyle(
                              color: Colors.red,
                              fontSize: isWebPlatform ? 14 : screenWidth * 0.035,
                              fontFamily: "Poppins",
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),

                      // Verify OTP Button
                      ElevatedButton(
                        onPressed: _isLoading ? null : _sendOtp,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.blue,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: EdgeInsets.symmetric(
                            vertical: isWebPlatform ? 16 : screenHeight * 0.02,
                          ),
                          minimumSize: Size(double.infinity, 50),
                        ),
                        child: _isLoading
                            ? SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2.0,
                                ),
                              )
                            : Text(
                                "Send OTP",
                                style: TextStyle(
                                  fontSize: isWebPlatform ? 16 : screenWidth * 0.04,
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

          // Back button
          Positioned(
            left: 16,
            child: SafeArea(
              child: IconButton(
                icon: Icon(Icons.arrow_back, 
                  color: Colors.white,
                  size: isWebPlatform ? 30 : 24,
                ),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ),
        ],
      ),
    );
  }
}