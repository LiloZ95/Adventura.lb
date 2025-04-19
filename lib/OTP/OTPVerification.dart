import 'package:adventura/OTP/SetPassword.dart';
import 'package:adventura/Services/otp_service.dart';
import 'package:adventura/userPreferences/userPreferences.dart';
import 'package:flutter/material.dart';
// Removed pin_code_fields import as we're using custom OTP field design
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'dart:ui' as ui;
import 'package:flutter/foundation.dart' show kIsWeb;

class OtpVerificationScreen extends StatefulWidget {
  final String email;
  final bool isForSignup;
  final Map<String, String>? signupData;

  OtpVerificationScreen({
    required this.email,
    required this.isForSignup,
    this.signupData,
  });

  @override
  _OtpVerificationScreenState createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  // Using individual controllers for each OTP digit instead of a single controller
  final storage = FlutterSecureStorage();
  bool _isResendingOtp = false;
  bool _isLoading = false;
  String _errorMessage = "";

  // Countdown Timer Variables
  int _remainingSeconds = 300; // 5 minutes = 300 seconds
  late Timer _timer;
  bool _showResendButton = false;

  // Border color for PinCodeTextField
  Color _pinBorderColor = Colors.grey[600]!;

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  void _startCountdown() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        setState(() => _remainingSeconds--);
      } else {
        setState(() {
          _showResendButton = true;
        });
        timer.cancel();
      }
    });
  }

  String _formatTime(int seconds) {
    int minutes = seconds ~/ 60;
    int secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  void _resetTimer() {
    setState(() {
      _remainingSeconds = 300;
      _showResendButton = false;
    });
    _startCountdown();
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

      _resetTimer();
    } else {
      print("❌ Failed to resend OTP: ${response["error"]}");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(response["error"] ?? "Failed to resend OTP.")),
      );
    }

    setState(() => _isResendingOtp = false);
  }

  // Custom OTP text controllers for individual digits
  final List<TextEditingController> _digitControllers = 
    List.generate(6, (index) => TextEditingController());
    
  // Focus nodes for each digit field
  final List<FocusNode> _focusNodes = 
    List.generate(6, (index) => FocusNode());
  
  String get _fullOtp => 
    _digitControllers.map((controller) => controller.text).join();
  
  void _verifyOtp() async {
    if (_fullOtp.length < 6) {
      setState(() {
        _errorMessage = "❌ OTP cannot be empty!";
        _isLoading = false;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = "";
    });

    print("🔍 Sending OTP Verification Request:");
    print("Email: ${widget.email}");
    print("Entered OTP: ${_fullOtp}");
    print("isForSignup: ${widget.isForSignup}");

    try {
      final response = await OtpService.verifyOtp(
        widget.email,
        _fullOtp,
        isForSignup: widget.isForSignup,
        firstName: widget.signupData?["firstName"],
        lastName: widget.signupData?["lastName"],
        phoneNumber: widget.signupData?["phoneNumber"],
        password: widget.signupData?["password"],
      );

      print("🔍 FULL API Response: $response");

      if (!response.containsKey("user") || response["user"] == null) {
        print("❌ User data is missing in response! Full Response: $response");
        setState(() {
          _errorMessage = response["error"] ?? "Invalid OTP. Please try again.";
          _isLoading = false;
        });
        return;
      }

      Map<String, dynamic> user = response["user"];

      print("🔍 Extracted User Data: $user");

      if (!user.containsKey("user_id") || user["user_id"] == null) {
        print("❌ User ID is missing in response!");
        setState(() {
          _errorMessage = response["error"] ?? "Invalid OTP. Please try again.";
          _isLoading = false;
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

        await prefs.setString("userId", userId);
        await prefs.setString("firstName", firstName);
        await prefs.setString("lastName", lastName);
        await prefs.setString("profilePicture", profilePicture);
        await prefs.setBool("isLoggedIn", true);

        print(
            "✅ Stored User Data: ID=$userId, Name=$firstName $lastName, ProfilePicture=$profilePicture");

        setState(() {
          _isLoading = false;
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
          _errorMessage = response["error"] ?? "Invalid OTP. Please try again.";
          _isLoading = false;
        });
      }
    } catch (e) {
      print("❌ Network or Server Error: $e");
      setState(() {
        _errorMessage = "❌ Network error. Please try again.";
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _timer.cancel();
    
    // Dispose controllers and focus nodes
    for (var controller in _digitControllers) {
      controller.dispose();
    }
    
    for (var node in _focusNodes) {
      node.dispose();
    }
    
    super.dispose();
  }

  Widget _buildTimerRichText(double fontSize) {
    Color timerColor = Colors.green; // Always green as shown in the design

    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
        text:
            "We have sent a verification code to your email, it will expire in ",
        style: TextStyle(
          fontSize: fontSize,
          color: Colors.black,
          fontFamily: "Poppins",
          height: 1.5,
        ),
        children: [
          TextSpan(
            text: _formatTime(_remainingSeconds),
            style: TextStyle(
              fontSize: fontSize,
              color: timerColor,
              fontFamily: "Poppins",
              fontWeight: FontWeight.bold,
            ),
          ),
          TextSpan(
            text: ".",
            style: TextStyle(
              fontSize: fontSize,
              color: Colors.black,
              fontFamily: "Poppins",
            ),
          ),
        ],
      ),
    );
  }

  // Web-specific layout for larger screens
  Widget _buildWebLayout() {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 500), // Limit width for web
        child: Card(
          margin: EdgeInsets.all(24),
          color: Colors.white, 
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 5,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 32, vertical: 40),
            child: _buildFormContent(isWeb: true),
          ),
        ),
      ),
    );
  }

  // Mobile layout
  Widget _buildMobileLayout(double screenWidth, double screenHeight) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Card(
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              elevation: 5,
              child: Padding(
                padding: EdgeInsets.all(screenWidth * 0.05),
                child: _buildFormContent(isWeb: false),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  // Shared form content with responsive parameters
  Widget _buildFormContent({required bool isWeb}) {
    // Use fixed sizes for web, percentage-based for mobile
    double fontSize = isWeb ? 16.0 : MediaQuery.of(context).size.width * 0.04;
    double headerFontSize = isWeb ? 24.0 : MediaQuery.of(context).size.width * 0.05;
    double timerFontSize = isWeb ? 16.0 : MediaQuery.of(context).size.width * 0.035;
    double pinFieldHeight = isWeb ? 60.0 : MediaQuery.of(context).size.height * 0.06;
    double pinFieldWidth = isWeb ? 50.0 : MediaQuery.of(context).size.width * 0.12;
    
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          "Check your email",
          style: TextStyle(
            fontSize: headerFontSize,
            fontWeight: FontWeight.bold,
            fontFamily: "Poppins",
            color: Colors.black,
          ),
        ),
        SizedBox(height: 16),
        
        _buildTimerRichText(timerFontSize),
        
        SizedBox(height: 24),
        
        Text(
          "Enter the OTP sent to ${widget.email}",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.bold,
            fontFamily: "Poppins",
            color: Colors.black,
          ),
        ),
        SizedBox(height: 24),
        
        // OTP input fields
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(
            6,
            (index) => Container(
              width: isWeb ? 50 : pinFieldWidth,
              height: isWeb ? 50 : pinFieldHeight,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[400]!),
                borderRadius: BorderRadius.circular(8),
              ),
              child: TextField(
                controller: _digitControllers[index],
                focusNode: _focusNodes[index],
                textAlign: TextAlign.center,
                keyboardType: TextInputType.number,
                maxLength: 1,
                decoration: InputDecoration(
                  counterText: "",
                  border: InputBorder.none,
                ),
                onChanged: (value) {
                  // Auto-advance to next field
                  if (value.length == 1 && index < 5) {
                    _focusNodes[index + 1].requestFocus();
                  }
                },
              ),
            ),
          ),
        ),
        
        if (_errorMessage.isNotEmpty)
          Padding(
            padding: EdgeInsets.symmetric(vertical: 8.0),
            child: Text(
              _errorMessage,
              style: TextStyle(color: Colors.red, fontSize: 14),
            ),
          ),
        
        SizedBox(height: 24),
        
        // Verify button - matches the design in the image
        Container(
          width: double.infinity,
          height: isWeb ? 50 : MediaQuery.of(context).size.height * 0.06,
          child: ElevatedButton(
            onPressed: _isLoading ? null : _verifyOtp,
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF3498DB), // Match the blue in the image
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: EdgeInsets.zero,
            ),
            child: _isLoading
                ? CircularProgressIndicator(color: Colors.white)
                : Text(
                    "Verify",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: fontSize,
                      color: Colors.white,
                      fontFamily: "Poppins",
                      height: 1.2,
                    ),
                  ),
          ),
        ),
        
        SizedBox(height: 16),
        
        if (_showResendButton)
          TextButton(
            onPressed: _isResendingOtp ? null : _resendOtp,
            child: Text(
              "Resend code",
              style: TextStyle(
                color: Colors.blue,
                fontFamily: "Poppins",
              ),
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Stack(
        children: [
          // Background Image with Blur Effect
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

          // Use different layout based on platform
          kIsWeb ? _buildWebLayout() : _buildMobileLayout(screenWidth, screenHeight),
        ],
      ),
    );
  }
}