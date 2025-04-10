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
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          // ✅ Background Color
          AnimatedContainer(
            duration: Duration(milliseconds: 500),
            curve: Curves.easeInOut,
            decoration: BoxDecoration(
              color: Colors.white,
            ),
          ),

          // ✅ Background Image with Blur
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

          // ✅ Centered Content
          Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
                child: Container(
                  padding: EdgeInsets.all(screenWidth * 0.05),
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
                      // ✅ Heading
                      Text(
                        "Forgot Password?",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: screenWidth * 0.05,
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
                          fontSize: screenWidth * 0.035,
                          color: Colors.grey[700],
                          fontFamily: "Poppins",
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.02),

                      // ✅ Email Input Field (No background, grey[200] border, 1px thick)
                      TextField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: "poppins",
                          fontSize: screenWidth * 0.045,
                          color: Colors.black,
                        ),
                        decoration: InputDecoration(
                          hintText: "Enter Your Email Here",

                          hintStyle: TextStyle(color: Color(0xFF8E8E8E)),
                          // ✅ No background
                          filled: false,
                          // ✅ Grey[200] border with 1px thickness
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
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.03),

                      // ✅ Verify OTP Button
                      ElevatedButton(
                        onPressed: _isLoading ? null : _sendOtp,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.blue, // Always blue
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: EdgeInsets.symmetric(
                            vertical: screenHeight * 0.02,
                          ),
                          minimumSize: Size(screenWidth * 0.2, 20),
                        ),
                        child: _isLoading
                            ? CircularProgressIndicator(color: Colors.white)
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

          // ✅ Arrow icon in the top left corner without an AppBar
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
