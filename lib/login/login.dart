import 'package:adventura/Main%20screen%20components/MainScreen.dart';
import 'package:adventura/Main%20screen%20components/mainSceeenWeb.dart';
import 'package:adventura/Services/auth_service.dart';
import 'package:adventura/web/homeweb.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:adventura/OTP/OTPVerification.dart';
import 'package:adventura/OTP/ForgotPasswordScreen.dart';
import 'package:adventura/signUp%20page/Signup.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'dart:ui'; 
import '../colors.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

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

      print("🔍 API Response: $response");

      if (response["success"] == true) {
        print("✅ Login Successful!");

        
        if (response.containsKey("user") && response["user"] is Map) {
          setState(() => _isLoading = false); 

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => MainScreen()),
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
  }

  @override
  Widget build(BuildContext context) {
    
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    
    
    final bool isWebPlatform = kIsWeb;
    
    
    final double formWidth = isWebPlatform 
        ? (screenWidth > 800 ? 500 : screenWidth * 0.8) 
        : screenWidth * 0.9;
    
    
    final double titleFontSize = isWebPlatform 
        ? (screenWidth > 800 ? 28 : screenWidth * 0.05)
        : screenWidth * 0.07;
    
    final double subtitleFontSize = isWebPlatform 
        ? (screenWidth > 800 ? 14 : screenWidth * 0.025)
        : screenWidth * 0.035;
    
    final double buttonFontSize = isWebPlatform 
        ? 16
        : screenWidth * 0.045;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/Pictures/island.jpg'),
                fit: BoxFit.cover,
              ),
            ),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 2.0, sigmaY: 2.0),
              child: Container(
                color: Colors.black.withOpacity(0.5),
              ),
            ),
          ),
          
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: isWebPlatform ? 0 : screenWidth * 0.05),
                  child: Container(
                    width: formWidth,
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
                        
                        Text(
                          "Glad to see you Back!",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: titleFontSize,
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.bold,
                            letterSpacing: -0.5,
                            color: Colors.black,
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.005),
                        
                        
                        Text(
                          "Login with your credentials or create a new account.",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: subtitleFontSize,
                            fontFamily: 'Poppins',
                            letterSpacing: -0.5,
                            color: Color(0x77000000),
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.02),

                        
                        _buildTextField(
                          controller: _emailController,
                          hintText: "Email address",
                          isError: !_isEmailValid,
                          errorText: _isEmailValid ? null : "Please enter a valid email address",
                          keyboardType: TextInputType.emailAddress,
                        ),
                        SizedBox(height: screenHeight * 0.02),

                        
                        _buildTextField(
                          controller: _passwordController,
                          hintText: "Password",
                          isPassword: true,
                          isError: _passwordError != null,
                          errorText: _passwordError,
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
                              padding: const EdgeInsets.symmetric(horizontal: 8.0),
                              child: Text(
                                "Or continue with",
                                style: TextStyle(
                                  color: Colors.grey, 
                                  fontFamily: 'Poppins',
                                  fontSize: isWebPlatform ? 14 : null,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Divider(
                                color: Colors.grey,
                                thickness: 1,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: screenHeight * 0.01),

                        
                        _buildSocialLoginButton(
                          onPressed: () {
                            
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => MainScreen()),
                            );
                          },
                          imagePath: 'assets/Icons/Facebook.png',
                          label: "Sign in With Facebook",
                          isWebPlatform: isWebPlatform,
                          screenWidth: screenWidth,
                        ),
                        SizedBox(height: screenHeight * 0.02),

                        
                        _buildSocialLoginButton(
                          onPressed: () {
                            kIsWeb? Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => AdventuraWebHomee())):
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => MainScreen()),
                            );
                          },
                          imagePath: 'assets/Icons/google.png',
                          label: "Sign in With Google",
                          isWebPlatform: isWebPlatform,
                          screenWidth: screenWidth,
                        ),
                        SizedBox(height: screenHeight * 0.01),
                        
                        
                        Center(
                          child: TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => ForgotPasswordScreen()),
                              );
                            },
                            child: Text(
                              "Forgot Password?",
                              style: TextStyle(
                                color: Colors.black,
                                decoration: TextDecoration.underline,
                                fontSize: isWebPlatform ? 16 : 18.5,
                                fontFamily: "poppins",
                              ),
                            ),
                          ),
                        ),
                        
                        
                        SizedBox(height: screenHeight * 0.01),
                        ElevatedButton(
                          onPressed: _isLoading ? null : _validateInputs,
                          child: _isLoading
                              ? SizedBox(
                                  height: 20, 
                                  width: 20, 
                                  child: CircularProgressIndicator(strokeWidth: 2.0, color: Colors.white)
                                )
                              : Text(
                                  "Continue",
                                  style: TextStyle(
                                    fontSize: buttonFontSize,
                                    color: Colors.white,
                                    fontFamily: 'Poppins',
                                  ),
                                ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.blue,
                            padding: EdgeInsets.symmetric(
                              vertical: isWebPlatform ? 15 : screenHeight * 0.02,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                        SizedBox(height: screenWidth * 0.03),

                        
                        Center(
                          child: RichText(
                            text: TextSpan(
                              text: "Not a member? ",
                              style: TextStyle(
                                color: AppColors.grey3,
                                fontFamily: 'Poppins',
                                fontSize: isWebPlatform ? 14 : null,
                              ),
                              children: [
                                TextSpan(
                                  text: "Create an account",
                                  style: TextStyle(
                                    color: Colors.blue,
                                    fontFamily: 'Poppins',
                                    fontWeight: FontWeight.bold,
                                    fontSize: isWebPlatform ? 14 : null,
                                  ),
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (context) => SignUpPage()),
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

  
  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    bool isPassword = false,
    bool isError = false,
    String? errorText,
    TextInputType keyboardType = TextInputType.text,
  }) {
    final bool isWebPlatform = kIsWeb;
    final double fontSize = isWebPlatform ? 14 : 16;
    
    return TextField(
      controller: controller,
      obscureText: isPassword ? _obscureText : false,
      keyboardType: keyboardType,
      style: TextStyle(
        color: Colors.black,
        fontFamily: 'Poppins',
        fontSize: fontSize,
      ),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(
          color: Colors.grey,
          fontSize: fontSize,
          fontFamily: 'Poppins',
        ),
        filled: true,
        fillColor: Colors.white,
        errorText: errorText,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: isError ? Colors.red : AppColors.grey2,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: isError ? Colors.red : Colors.blue,
          ),
        ),
        contentPadding: isWebPlatform
            ? EdgeInsets.symmetric(vertical: 15, horizontal: 15)
            : null,
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(
                  _obscureText ? Icons.visibility_off : Icons.visibility,
                  color: Colors.grey,
                  size: isWebPlatform ? 20 : 24,
                ),
                onPressed: _toggle,
              )
            : null,
      ),
    );
  }

  
  Widget _buildSocialLoginButton({
    required VoidCallback onPressed,
    required String imagePath,
    required String label,
    required bool isWebPlatform,
    required double screenWidth,
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Image.asset(
        imagePath,
        width: isWebPlatform ? 30 : screenWidth * 0.1,
        height: isWebPlatform ? 30 : screenWidth * 0.1,
      ),
      label: Text(
        label,
        style: TextStyle(
          fontSize: isWebPlatform ? 14 : 16, 
          fontFamily: 'Poppins'
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        padding: EdgeInsets.symmetric(
          vertical: isWebPlatform ? 12 : 6
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}