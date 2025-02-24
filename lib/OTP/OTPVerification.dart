import 'package:adventura/OTP/SetPassword.dart';
import 'package:adventura/Services/api_service.dart';
import 'package:adventura/favorite/userPreferences.dart';
import 'package:flutter/material.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:async'; // ✅ Import for Timer
import 'dart:ui' as ui; // ✅ Use alias for dart:ui
import '../login/login.dart';
import 'package:adventura/signUp page/Signup.dart';

class OtpVerificationScreen extends StatefulWidget {
  final String email;
  final bool isForSignup;
  final String? firstName, lastName, phoneNumber, password;

  OtpVerificationScreen(
      {required this.email,
      required this.isForSignup,
      this.firstName,
      this.lastName,
      this.phoneNumber,
      this.password});

  @override
  _OtpVerificationScreenState createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final TextEditingController _otpController = TextEditingController();
  bool _isResendingOtp = false; // Track resend status
  bool _isLoading = false;
  String _errorMessage = "";

  // ✅ Countdown Timer Variables
  int _remainingSeconds = 300; // 5 minutes = 300 seconds
  late Timer _timer;
  bool _showResendButton =
      false; // ✅ Controls visibility of "Resend OTP" button

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  // ✅ Start countdown timer
  void _startCountdown() {
    // _timer?.cancel(); // ✅ Cancel any existing timer before starting a new one

    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        setState(() => _remainingSeconds--);
      } else {
        setState(() {
          _showResendButton =
              true; // ✅ Show "Resend Code" button when timer ends
        });
        timer.cancel(); // Stop the timer at 00:00
      }
    });
  }

  // ✅ Format time to MM:SS (e.g., 04:59)
  String _formatTime(int seconds) {
    int minutes = seconds ~/ 60;
    int secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  // ✅ Reset timer when "RESET CODE" is pressed
  void _resetTimer() {
    setState(() {
      _remainingSeconds = 300; // Reset to 5:00
      _showResendButton = false; // Hide reset button
    });

    _startCountdown(); // Restart countdown
  }

  void _resendOtp() async {
    setState(() => _isResendingOtp = true);

    print("🔍 Requesting OTP resend for: ${widget.email}");

    final response = await ApiService.resendOtp(
      widget.email,
      isForSignup: widget.isForSignup,
    );

    if (response["success"] == true) {
      print("✅ OTP Resent Successfully!");

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("A new OTP has been sent to your email.")),
      );

      _resetTimer(); // ✅ Reset countdown timer after resending OTP
    } else {
      print("❌ Failed to resend OTP: ${response["error"]}");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(response["error"] ?? "Failed to resend OTP.")),
      );
    }

    setState(() => _isResendingOtp = false);
  }

  void _verifyOtp() async {
    setState(() => _isLoading = true);

    print("🔍 Sending OTP Verification Request:");
    print("Email: ${widget.email}");
    print("Entered OTP: ${_otpController.text}");
    print("isForSignup: ${widget.isForSignup}");

    final response = await ApiService.verifyOtp(
      widget.email,
      _otpController.text,
      isForSignup: widget.isForSignup,
      firstName: widget.firstName,
      lastName: widget.lastName,
      phoneNumber: widget.phoneNumber,
      password: widget.password,
    );

    print("🔍 API Response: $response");

    if (response["success"] == true) {
      print("✅ OTP Verified Successfully! Navigating to Login...");

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content:
                Text("OTP Verified Successfully! Redirecting to Login...")),
      );

      if (widget.isForSignup) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => Favorite()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => SetPassword(email: widget.email)),
        );
      }
    } else {
      print("❌ Failed OTP Verification: ${response["error"]}");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(response["error"] ?? "Invalid OTP. Try again.")),
      );
    }

    setState(() => _isLoading = false);
  }

  @override
  void dispose() {
    _timer.cancel(); // ✅ Stop the timer when widget is disposed
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Stack(
        children: [
          // ✅ Background Image with Blur Effect
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/Pictures/island.jpg"),
                fit: BoxFit.cover,
              ),
            ),
            child: BackdropFilter(
              filter: ui.ImageFilter.blur(sigmaX: 2.0, sigmaY: 2.0),
              child: Container(color: Colors.black.withOpacity(0.5)),
            ),
          ),

          // Centered Content
          Center(
            child: Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: screenWidth * 0.05), // Dynamic horizontal padding
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Card(
                    color: Colors.white, // Background based on dark mode
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    elevation: 5,
                    child: Padding(
                      padding: EdgeInsets.all(screenWidth * 0.05),
                      child: Column(
                        children: [
                          Text(
                            "Check your email",
                            style: TextStyle(
                              fontSize: screenWidth * 0.05,
                              fontWeight: FontWeight.bold,
                              fontFamily: "Poppins",
                              color: Colors.black, // Text color based on dark mode
                            ),
                          ),
                          SizedBox(height: screenHeight * 0.02),

                          // ✅ Updated Text with Countdown Timer
                          Text(
                            "We have sent a verification code to your email, it will expire in ${_formatTime(_remainingSeconds)}.",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: screenWidth * 0.035,
                              color: Colors.grey, // Text color based on dark mode
                              fontFamily: "Poppins",
                            ),
                          ),

                          SizedBox(height: screenHeight * 0.02),

                          Text(
                            "Enter the OTP sent to ${widget.email}",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: screenWidth * 0.04,
                              fontWeight: FontWeight.bold,
                              fontFamily: "Poppins",
                              color: Colors.black, // Text color based on dark mode
                            ),
                          ),
                          SizedBox(height: screenHeight * 0.02),

                          // ✅ OTP Input Field
                          Form(
                            child: PinCodeTextField(
                              controller: _otpController,
                              appContext: context,
                              length: 6,
                              obscureText: false,
                              animationType: AnimationType.fade,
                              pinTheme: PinTheme(
                                shape: PinCodeFieldShape.box,
                                borderRadius: BorderRadius.circular(8),
                                fieldHeight: screenHeight * 0.06,
                                fieldWidth: screenWidth * 0.12,
                                activeFillColor: Colors.grey[300]!, // Dynamic color based on dark mode
                                selectedFillColor: Colors.grey[300]!,
                                inactiveFillColor: Colors.grey[300]!,
                                activeColor: Colors.black,
                                selectedColor: Colors.black,
                                inactiveColor: Colors.black,
                              ),
                              enableActiveFill: true,
                              showCursor: false,
                              onChanged: (value) {},
                            ),
                          ),

                          // ✅ Error Message Display
                          if (_errorMessage.isNotEmpty)
                            Padding(
                              padding: EdgeInsets.symmetric(vertical: 8.0),
                              child: Text(
                                _errorMessage,
                                style:
                                    TextStyle(color: Colors.red, fontSize: 14),
                              ),
                            ),

                          SizedBox(height: screenHeight * 0.01),

                          // ✅ Resend OTP Button (Shows only when _showResendButton is true)
                          if (_showResendButton)
                            TextButton(
                              onPressed: _isResendingOtp
                                  ? null
                                  : _resendOtp, // Disable while resending
                              child: Text(
                                "Resend code",
                                style: TextStyle(
                                    color: Colors.blue, // Color based on dark mode
                                    fontFamily: "Poppins"),
                              ),
                            ),

                          SizedBox(height: screenHeight * 0.01),

                          // ✅ Verify OTP Button with Loading State
                          ElevatedButton(
                            onPressed: _isLoading ? null : _verifyOtp,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.black,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              padding: EdgeInsets.symmetric(
                                vertical: screenHeight * 0.02,
                                horizontal: screenWidth * 0.2,
                              ),
                            ),
                            child: _isLoading
                                ? CircularProgressIndicator(color: Colors.white)
                                : Text(
                                    "Verify",
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
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
