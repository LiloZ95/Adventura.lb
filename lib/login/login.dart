import 'package:adventura/Main%20screen%20components/MainScreen.dart';
import 'package:adventura/Services/auth_service.dart';
import 'package:adventura/web/homeweb.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:adventura/OTP/ForgotPasswordScreen.dart';
import 'package:adventura/signUp%20page/Signup.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'dart:ui'; // For ImageFilter
import '../colors.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final AuthService authService = AuthService();
  final FlutterSecureStorage storage = FlutterSecureStorage();
  bool _obscureText = true;
  bool _isLoading = false;

  void _toggle() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  bool _isEmailValid = true;
  String? _passwordError;

  bool isValidEmail(String email) {
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(email);
  }

  String? validatePassword(String password) {
    if (password.length < 8 ||
        !RegExp(r'[A-Z]').hasMatch(password) ||
        !RegExp(r'\d').hasMatch(password)) {
      return "Password must be at least 8 characters long, must contain an uppercase character, and contain at least one number";
    }
    return null;
  }

  void _validateInputs() async {
    setState(() => _isLoading = true);

    final isEmailValid = isValidEmail(_emailController.text);
    if (!isEmailValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Invalid email format.")),
      );
      setState(() => _isLoading = false);
      return;
    }

    final AuthService apiService = AuthService();

    try {
      final response = await apiService.loginUser(
        _emailController.text,
        _passwordController.text,
      );

      if (response["success"] == true) {
        print("✅ Login Successful!");

        if (response.containsKey("user") && response["user"] is Map) {
          final user = response["user"];
          final box = await Hive.openBox('authBox');
          if (user.containsKey("user_id") && user["user_id"] != null) {
            box.put("userId", user["user_id"].toString());
            print("✅ Saved userId to Hive from login screen: ${user["user_id"]}");
          } else {
            print("❌ 'user_id' missing or null in login screen");
          }
          if (user.containsKey("provider_id") && user["provider_id"] != null) {
            box.put("providerId", user["provider_id"].toString());
            print("✅ Stored providerId: ${user["provider_id"]}");
          } else {
            print("⚠️ No provider_id found in user payload.");
          }
          setState(() => _isLoading = false);

          // Navigate based on platform
          kIsWeb? Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>AdventuraWebHomee()),
                ):
         Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => MainScreen(onScrollChanged: (bool visible) {})),
                );
        } else {
          setState(() => _isLoading = false);
          print("❌ Error: 'user' key not found in response.");
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Invalid server response. Please try again.")),
          );
        }
      } else {
        setState(() => _isLoading = false);
        print("❌ Login Failed: ${response["error"]}");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response["error"] ?? "Login failed. Check credentials.")),
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      print("❌ Login error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Server error. Try again later.")),
      );
    }

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    
    // Adjust layout for web
    final bool isWebPlatform = kIsWeb;
    final double formWidth = isWebPlatform 
        ? (screenWidth > 800 ? 600 : screenWidth * 0.8) 
        : screenWidth * 0.88;

    return Scaffold(
      resizeToAvoidBottomInset: true,
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
          // Form Container
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                    horizontal: isWebPlatform ? 0 : screenWidth * 0.06,
                    vertical: screenHeight * 0.02),
                child: Container(
                  width: formWidth,
                  padding: EdgeInsets.all(screenWidth * 0.06),
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
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Title
                      Text(
                        "Glad to see you Back!",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: isWebPlatform 
                              ? (screenWidth > 800 ? 28 : screenWidth * 0.05)
                              : screenWidth * 0.07,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.bold,
                          letterSpacing: -0.5,
                          color: Colors.black,
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.01),
                      Text(
                        "Login with your credentials or create a new account.",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: isWebPlatform 
                              ? (screenWidth > 800 ? 14 : screenWidth * 0.025)
                              : screenWidth * 0.035,
                          fontFamily: 'Poppins',
                          letterSpacing: -0.5,
                          color: Color(0x77000000),
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.02),

                      // Email Field
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

                      // Password Field
                      _buildTextField(
                        controller: _passwordController,
                        hintText: "Password",
                        obscureText: _obscureText,
                        isPasswordField: true,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Password is required.";
                          }
                          return validatePassword(value);
                        },
                      ),
                      SizedBox(height: screenHeight * 0.02),

                      // Forgot Password
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => ForgotPasswordScreen()),
                            );
                          },
                          child: Text(
                            "Forgot Password?",
                            style: TextStyle(
                              color: Colors.black,
                              decoration: TextDecoration.underline,
                              fontSize: isWebPlatform ? 14 : 16,
                              fontFamily: "Poppins",
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.02),

                      // Continue Button
                      ElevatedButton(
                        onPressed: _isLoading ? null : _validateInputs,
                        child: _isLoading
                            ? SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2.0, color: Colors.white),
                              )
                            : Text(
                                "Continue",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontFamily: 'Poppins',
                                  fontSize: isWebPlatform ? 16 : screenWidth * 0.045,
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
                      SizedBox(height: screenHeight * 0.03),

                      // Divider with "Or continue with" text
                      Row(
                        children: [
                          Expanded(
                            child: Divider(
                              color: AppColors.grey2,
                              thickness: 1,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8.0),
                            child: Text(
                              "Or continue with",
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
                      SizedBox(height: screenHeight * 0.02),

                      // Social Login Buttons
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            onPressed: () {
                                 Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => MainScreen(
                                              onScrollChanged: (bool visible) {})),
                                    );
                            },
                            icon: Image.asset(
                              'assets/Icons/Facebook.png',
                              width: isWebPlatform ? 40 : screenWidth * 0.12,
                              height: isWebPlatform ? 40 : screenWidth * 0.12,
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              // Handle Google login
                            Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => MainScreen(
                                              onScrollChanged: (bool visible) {})),
                                    );
                            },
                            icon: Image.asset(
                              'assets/Icons/google.png',
                              width: isWebPlatform ? 40 : screenWidth * 0.12,
                              height: isWebPlatform ? 40 : screenWidth * 0.12,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: screenHeight * 0.02),

                      // Sign Up Prompt
                      Center(
                        child: RichText(
                          text: TextSpan(
                            text: "Not a member? ",
                            style: TextStyle(
                              color: AppColors.grey3,
                              fontFamily: 'Poppins',
                            ),
                            children: [
                              TextSpan(
                                text: "Create an account",
                                style: TextStyle(
                                  color: Colors.blue,
                                  fontFamily: 'Poppins',
                                  fontWeight: FontWeight.bold,
                                ),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => SignUpPage()),
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
        ],
      ),
    );
  }

  // Reusable Text Field Widget
  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    bool isPasswordField = false,
    String? Function(String?)? validator,
  }) {
    final bool isWebPlatform = kIsWeb;
    final double fontSize = isWebPlatform ? 14.0 : 16.0;
    
    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        obscureText: obscureText,
        style: TextStyle(
          color: const Color.fromARGB(255, 5, 5, 5),
          fontFamily: 'Poppins',
          fontSize: fontSize,
        ),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(
            color: Colors.grey[400],
            fontFamily: 'Poppins',
            fontSize: fontSize,
          ),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(
              color: Colors.grey[200]!,
              width: 1,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(
              color: Colors.blue,
              width: 1,
            ),
          ),
          contentPadding: isWebPlatform
              ? EdgeInsets.symmetric(vertical: 15, horizontal: 15)
              : null,
          suffixIcon: isPasswordField
              ? IconButton(
                  icon: Icon(
                    obscureText ? Icons.visibility_off : Icons.visibility,
                    color: Colors.grey[400],
                    size: isWebPlatform ? 20 : 24,
                  ),
                  onPressed: _toggle,
                )
              : null,
        ),
        validator: validator,
        cursorColor: Colors.grey[400],
      ),
    );
  }
}