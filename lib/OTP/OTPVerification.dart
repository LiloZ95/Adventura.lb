import 'package:adventura/OTP/SetPassword.dart';
import 'package:adventura/Services/otp_service.dart';
import 'package:adventura/userPreferences/userPreferences.dart';
import 'package:flutter/material.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async'; // ✅ Import for Timer
import 'dart:ui' as ui; // ✅ Use alias for dart:ui

class OtpVerificationScreen extends StatefulWidget {
  final String email;
  final bool isForSignup;
  final Map<String, String>? signupData; // ✅ Store signup data

  OtpVerificationScreen({
    required this.email,
    required this.isForSignup,
    this.signupData, // ✅ Accept signup data
  });

  @override
  _OtpVerificationScreenState createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final TextEditingController _otpController = TextEditingController();
  final storage = FlutterSecureStorage();
  bool _isResendingOtp = false; // Track resend status
  bool _isLoading = false;
  String _errorMessage = "";

  // ✅ Countdown Timer Variables
  int _remainingSeconds = 300; // 5 minutes = 300 seconds
  late Timer _timer;
  bool _showResendButton =
      false; // ✅ Controls visibility of "Resend OTP" button

  // ✅ New: Border color for PinCodeTextField
  Color _pinBorderColor = Colors.grey[600]!; // Default grey

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  // ✅ Start countdown timer
  void _startCountdown() {
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

    final response = await OtpService.resendOtp(
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
    if (_otpController.text.isEmpty) {
      setState(() {
        _errorMessage = "❌ OTP cannot be empty!"; // ✅ Show error message
        _isLoading = false;
      });
      return; // ✅ Stop execution
    }

    setState(() {
      _isLoading = true; // ✅ Start loading only if OTP is not empty
      _errorMessage = ""; // ✅ Clear previous errors
    });

    print("🔍 Sending OTP Verification Request:");
    print("Email: ${widget.email}");
    print("Entered OTP: ${_otpController.text}");
    print("isForSignup: ${widget.isForSignup}");

    try {
      final response = await OtpService.verifyOtp(
        widget.email,
        _otpController.text,
        isForSignup: widget.isForSignup,
        firstName: widget.signupData?["firstName"],
        lastName: widget.signupData?["lastName"],
        phoneNumber: widget.signupData?["phoneNumber"],
        password: widget.signupData?["password"],
      );

      // ✅ Ensure response contains "user"
      if (!response.containsKey("user") || response["user"] == null) {
        print("❌ User data is missing in response! Full Response: $response");
        setState(() {
          _errorMessage = response["error"] ??
              "Invalid OTP. Please try again."; // ✅ Show error message
          _isLoading = false; // ✅ Stop loading
        });
        return;
      }

      Map<String, dynamic> user = response["user"];

      // ✅ Debugging: Ensure all fields are present
      print("🔍 Extracted User Data: $user");

      if (!user.containsKey("user_id") || user["user_id"] == null) {
        print("❌ User ID is missing in response!");
        setState(() {
          _errorMessage = response["error"] ??
              "Invalid OTP. Please try again."; // ✅ Show error message
          _isLoading = false; // ✅ Stop loading
        });
        return;
      }

      if (response["success"] == true) {
        print("✅ OTP Verified Successfully!");

        final SharedPreferences prefs = await SharedPreferences.getInstance();

        String userId = user["user_id"].toString();
        String firstName = user["first_name"] ?? "";
        String lastName = user["last_name"] ?? "";
        String profilePicture = user["profilePicture"] ?? "";

        // ✅ Store user data
        await prefs.setString("userId", userId);
        await prefs.setString("firstName", firstName);
        await prefs.setString("lastName", lastName);
        await prefs.setString("profilePicture", profilePicture);
        await prefs.setBool("isLoggedIn", true);

        print(
            "✅ Stored User Data: ID=$userId, Name=$firstName $lastName, ProfilePicture=$profilePicture");

        setState(() {
          _isLoading = false; // ✅ Ensure loading stops after success
        });

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
        print("❌ OTP Verification Failed: ${response["error"]}");
        setState(() {
          _errorMessage = response["error"] ??
              "Invalid OTP. Please try again."; // ✅ Show error message
          _isLoading = false; // ✅ Stop loading
        });
      }
    } catch (e) {
      print("❌ Network or Server Error: $e");
      setState(() {
        _errorMessage = "❌ Network error. Please try again.";
        _isLoading = false; // ✅ Ensure loading stops on network error
      });
    }
  }

  @override
  void dispose() {
    _timer.cancel(); // ✅ Stop the timer when widget is disposed
    super.dispose();
  }

  // ✅ We only color the timer portion, not the entire text
  Widget _buildTimerRichText(double screenWidth) {
    // If remaining seconds > 0, color is green, else red
    Color timerColor = _remainingSeconds > 0 ? Colors.green : Colors.red;

    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
        text:
            "We have sent a verification code to your email, it will expire in ",
        style: TextStyle(
          fontSize: screenWidth * 0.035,
          color: Colors.black, // rest of text in black
          fontFamily: "Poppins",
        ),
        children: [
          TextSpan(
            text: _formatTime(_remainingSeconds),
            style: TextStyle(
              fontSize: screenWidth * 0.035,
              color: timerColor, // only timer portion changes color
              fontFamily: "Poppins",
            ),
          ),
          TextSpan(
            text: ".", // end with a period
            style: TextStyle(
              fontSize: screenWidth * 0.035,
              color: Colors.black,
              fontFamily: "Poppins",
            ),
          ),
        ],
      ),
    );
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
                              color:
                                  Colors.black, // Text color based on dark mode
                            ),
                          ),
                          SizedBox(height: screenHeight * 0.01),

                          // ✅ Timer Text with Dynamic Color (only timer portion)
                          _buildTimerRichText(screenWidth),

                          SizedBox(height: screenHeight * 0.02),

                          Text(
                            "Enter the OTP sent to ${widget.email}",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: screenWidth * 0.04,
                              fontWeight: FontWeight.bold,
                              fontFamily: "Poppins",
                              color:
                                  Colors.black, // Text color based on dark mode
                            ),
                          ),
                          SizedBox(height: screenHeight * 0.02),

                          // ✅ OTP Input Field with dynamic border color
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
                                activeFillColor: Colors
                                    .white, // Dynamic color based on dark mode
                                selectedFillColor: Colors.white,
                                inactiveFillColor: Colors.white,

                                // ✅ Use our dynamic color for the border
                                activeColor: _pinBorderColor,
                                selectedColor: _pinBorderColor,
                                inactiveColor: _pinBorderColor,
                              ),
                              enableActiveFill: true,
                              showCursor: false,
                              onChanged: (value) {},
                            ),
                          ),

                          // ✅ Error Message Display
                          if (_errorMessage.isNotEmpty)
                            Padding(
                              padding: EdgeInsets.symmetric(vertical: 1.0),
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
                                  color:
                                      Colors.blue, // Color based on dark mode
                                  fontFamily: "Poppins",
                                ),
                              ),
                            ),

                          SizedBox(height: screenHeight * 0.01),

                          // ✅ Verify OTP Button with Loading State
                          ElevatedButton(
                            onPressed: _isLoading ? null : _verifyOtp,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
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
