import 'package:adventura/HomeControllerScreen.dart';
import 'package:adventura/Services/otp_service.dart';
import 'package:adventura/login/FadeSlidePageRoute.dart';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'dart:ui';
import 'package:adventura/colors.dart';
import '../login/login.dart';
import 'package:adventura/OTP/OTPVerification.dart';

class SignUpPage extends StatefulWidget {
  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();

  // Controllers for text fields
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isLoading = false;

  // Password visibility toggle
  bool _obscureText = true;
  void _togglePasswordVisibility() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  // Function to validate email format
  bool isValidEmail(String email) {
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(email);
  }

  // Function to validate password format
  String? validatePassword(String? password) {
    if (password == null || password.isEmpty) {
      return "Password is required.";
    }
    if (password.length < 8 &&
        !RegExp(r'[A-Z]').hasMatch(password) &&
        !RegExp(r'\d').hasMatch(password)) {
      return "Password must contain at least 8 characters,\n one number, one uppercase character.";
    }
    if (!RegExp(r'[A-Z]').hasMatch(password) && password.length < 8) {
      return "Password must contain at least 8 characters,\n one uppercase character.";
    }
    if (!RegExp(r'\d').hasMatch(password) && password.length < 8) {
      return "Password must contain at least 8 characters,\n one number";
    }
    if (!RegExp(r'\d').hasMatch(password) &&
        !RegExp(r'[A-Z]').hasMatch(password)) {
      return "Password must contain at least \none uppercase character, one number.";
    }
    if (!RegExp(r'\d').hasMatch(password)) {
      return "Password must contain at least one number";
    }
    if (!RegExp(r'[A-Z]').hasMatch(password)) {
      return "Password must contain one uppercase character";
    }
    if (password.length < 8) {
      return "Password must be at least 8 characters";
    }
    return null; // Password is valid
  }

  // Function to handle signup
  void _signup() async {
    setState(() => _isLoading = true);

    if (!_formKey.currentState!.validate()) {
      setState(() => _isLoading = false);
      return;
    }

    final email = _emailController.text.trim();
    final firstName = _firstNameController.text.trim();
    final lastName = _lastNameController.text.trim();
    // final phoneNumber = _phoneController.text.trim();
    final password = _passwordController.text;

    try {
      print("🔍 Sending OTP request for email: $email");

      final response = await OtpService.sendOtp(email, isForSignup: true);

      if (response["success"] == true) {
        print(
            "✅ OTP Sent Successfully! Navigating to OTP Verification screen.");

        // ✅ Pass user data to the OTP verification screen
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => OtpVerificationScreen(
              target: email,
              targetType: "email",
              isForSignup: true,
              signupData: {
                "firstName": firstName,
                "lastName": lastName,
                // "phoneNumber": phoneNumber,
                "password": password,
              },
            ),
          ),
        );
      } else {
        print("❌ Failed to send OTP: ${response["error"] ?? "Unknown error"}");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  "Failed to send OTP: ${response["error"] ?? "Unknown error"}")),
        );
      }
    } catch (e) {
      print("❌ Exception in Signup: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Server error. Please try again later.")),
      );
    }

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    // Use MediaQuery to obtain dynamic dimensions
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      resizeToAvoidBottomInset: true, // Adjust when keyboard appears
      body: Stack(
        children: [
          // Background Image with Blur Effect
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/Pictures/island.jpg'),
                fit: BoxFit.cover,
              ),
            ),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 2.0, sigmaY: 2.0),
              child: Container(color: Colors.black.withOpacity(0.5)),
            ),
          ),
          // Form Container wrapped in SafeArea and SingleChildScrollView for scrollability and responsiveness
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                    horizontal: screenWidth * 0.06,
                    vertical: screenHeight * 0.02),
                child: Container(
                  padding: EdgeInsets.all(screenWidth * 0.06),
                  decoration: BoxDecoration(
                    color: isDarkMode
                        ? const Color(0xFF121212)
                        : const Color(0xFFF6F6F6),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 10,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Title
                        Text(
                          "Welcome to the team!",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: screenWidth * 0.07,
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.bold,
                            letterSpacing: -0.5,
                            color: isDarkMode ? Colors.white : Colors.black,
                          ),
                        ),

                        SizedBox(height: screenHeight * 0.01),

                        Text(
                          "Enter the required credentials and start your unforgettable journey.",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: screenWidth * 0.035,
                            fontFamily: 'Poppins',
                            color: isDarkMode
                                ? Colors.grey[300]
                                : const Color(0x77000000),
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.02),

                        // First Name & Last Name Fields
                        Row(
                          children: [
                            Expanded(
                              child: _buildTextField(
                                controller: _firstNameController,
                                hintText: "First name",
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return "First Name is required.";
                                  }
                                  return null;
                                },
                              ),
                            ),
                            SizedBox(width: screenWidth * 0.04),
                            Expanded(
                              child: _buildTextField(
                                controller: _lastNameController,
                                hintText: "Last name",
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return "Last Name is required.";
                                  }
                                  return null;
                                },
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: screenHeight * 0.02),

                        // Phone Number Field
                        // _buildTextField(
                        //   controller: _phoneController,
                        //   hintText: "Phone number",
                        //   keyboardType: TextInputType.phone,
                        //   validator: (value) {
                        //     if (value == null || value.isEmpty) {
                        //       return "Phone Number is required.";
                        //     }
                        //     return null;
                        //   },
                        // ),
                        // SizedBox(height: screenHeight * 0.02),

                        // Email Field with Validation
                        _buildTextField(
                          controller: _emailController,
                          hintText: "Email address",
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Email is required.";
                            } else if (!isValidEmail(value)) {
                              return "Enter a valid email address.";
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: screenHeight * 0.02),

                        // Password Field with Visibility Toggle
                        _buildTextField(
                          controller: _passwordController,
                          hintText: "Password",
                          obscureText: _obscureText,
                          isPasswordField: true,
                          validator: validatePassword,
                        ),
                        SizedBox(height: screenHeight * 0.03),
                        Row(
                          children: [
                            Expanded(
                              child: Divider(
                                color: Colors.grey,
                                thickness: 1,
                              ),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8.0),
                              child: Text(
                                "Or register with",
                                style: TextStyle(
                                    color: Color(0xFF8F8F8F),
                                    fontFamily: 'Poppins'),
                              ),
                            ),
                            Expanded(
                              child: Divider(
                                color: AppColors.grey2,
                                thickness: 1,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: screenHeight * 0.01),
                        // Social login buttons
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            IconButton(
                              onPressed: () {
                                // Handle Facebook login
                              },
                              icon: Image.asset(
                                'assets/Icons/Facebook.png',
                                width: screenWidth * 0.12,
                                height: screenWidth * 0.12,
                              ),
                            ),
                            IconButton(
                              onPressed: () {
                                // Handle Google login
                                Navigator.pushAndRemoveUntil(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) => HomeControllerScreen()),
                                  (route) => false,
                                );
                              },
                              icon: Image.asset(
                                'assets/Icons/google.png',
                                width: screenWidth * 0.12,
                                height: screenWidth * 0.12,
                              ),
                            ),
                            IconButton(
                              onPressed: () {
                                // Handle Apple login
                                Navigator.pushAndRemoveUntil(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) => HomeControllerScreen()),
                                  (route) => false,
                                );
                              },
                              icon: Image.asset(
                                'assets/Icons/apple.png',
                                width: screenWidth * 0.12,
                                height: screenWidth * 0.12,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: screenHeight * 0.01),
                        // Create Account Button
                        ElevatedButton(
                          onPressed: _isLoading ? null : _signup,
                          child: _isLoading
                              ? CircularProgressIndicator()
                              : Text(
                                  "Create account",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontFamily: 'Poppins',
                                    fontSize: screenWidth * 0.045,
                                  ),
                                ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.blue,
                            padding: EdgeInsets.symmetric(
                                vertical: screenHeight * 0.02),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.01),
                        Center(
                          child: RichText(
                            text: TextSpan(
                              text: "Already a member? ",
                              style: TextStyle(
                                color: AppColors.grey3,
                                fontFamily: 'Poppins',
                              ),
                              children: [
                                TextSpan(
                                  text: "Log in",
                                  style: TextStyle(
                                    color: Colors.blue,
                                    fontFamily: 'Poppins',
                                    fontWeight: FontWeight.bold,
                                  ),
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () {
                                      Navigator.push(
                                        context,
                                        CinematicPageRoute(page: LoginPage()),
                                      );
                                    },
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Custom Reusable Text Field Widget with updated border and text style
 Widget _buildTextField({
  required TextEditingController controller,
  required String hintText,
  TextInputType keyboardType = TextInputType.text,
  bool obscureText = false,
  bool isPasswordField = false,
  String? Function(String?)? validator,
}) {
  final isDarkMode = Theme.of(context).brightness == Brightness.dark;

  return AnimatedContainer(
    duration: Duration(milliseconds: 300),
    curve: Curves.easeInOut,
    child: TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      style: TextStyle(
        color: isDarkMode ? Colors.white : Colors.black,
        fontFamily: 'Poppins',
      ),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(
          color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
          fontFamily: 'Poppins',
        ),
        filled: true,
        fillColor: isDarkMode ? const Color(0xFF2A2A2A) : Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(
            color: isDarkMode ? Colors.grey[700]! : Colors.grey[200]!,
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(
            color: isDarkMode ? Colors.white : Colors.black,
            width: 1,
          ),
        ),
        suffixIcon: isPasswordField
            ? IconButton(
                icon: Icon(
                  obscureText ? Icons.visibility_off : Icons.visibility,
                  color: isDarkMode ? Colors.white70 : Colors.grey[600],
                ),
                onPressed: _togglePasswordVisibility,
              )
            : null,
      ),
      validator: validator,
      cursorColor: isDarkMode ? Colors.white70 : Colors.grey[600],
    ),
  );
}
}