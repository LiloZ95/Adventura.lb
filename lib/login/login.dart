import 'package:adventura/Main%20screen%20components/MainScreen.dart';
import 'package:adventura/Services/auth_service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:adventura/OTP/OTPVerification.dart';
import 'package:adventura/OTP/ForgotPasswordScreen.dart';
import 'package:adventura/signUp%20page/Signup.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import '';
import 'dart:ui'; // For ImageFilter
import '../colors.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final AuthService authService = AuthService(); // Instance of auth service
  final FlutterSecureStorage storage = FlutterSecureStorage();
  bool _obscureText = true;
  bool _isLoading = false;

  void _toggle() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  bool _isEmailValid = true; // Tracks the validation state of the email
  String? _passwordError; // Tracks password validation error message

  // Function to validate email
  bool isValidEmail(String email) {
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(email);
  }

  // Function to validate password
  String? validatePassword(String password) {
    if (password.length < 8 ||
        !RegExp(r'[A-Z]').hasMatch(password) ||
        !RegExp(r'\d').hasMatch(password)) {
      return "Password must be at least 8 characters long, must contain an uppercase character, and contain at least one number";
    }

    return null; // Password is valid
  }

  // Function to validate email and password when "Continue" is pressed
  // Login Function
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

    final AuthService apiService =
        AuthService(); // ✅ Create an instance of ApiService

    try {
      final response = await apiService.loginUser(
        _emailController.text,
        _passwordController.text,
      );

      print("🔍 API Response: $response");

      if (response["success"] == true) {
        print("✅ Login Successful!");

        // ✅ Ensure 'user' exists before accessing it
        if (response.containsKey("user") && response["user"] is Map) {
          setState(() =>
              _isLoading = false); // ✅ Reset loading state before navigation

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => MainScreen()),
          );
        } else {
          setState(
              () => _isLoading = false); // ✅ Ensure loading is reset on error

          print("❌ Error: 'user' key not found in response.");
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text("Invalid server response. Please try again.")),
          );
        }
      } else {
        setState(
            () => _isLoading = false); // ✅ Reset loading state if login fails

        print("❌ Login Failed: ${response["error"]}");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  response["error"] ?? "Login failed. Check credentials.")),
        );
      }
    } catch (e) {
      setState(() => _isLoading = false); // ✅ Reset loading state on exception

      print("❌ Login error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Server error. Try again later.")),
      );
    }

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    // Get the screen width and height dynamically
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      resizeToAvoidBottomInset: false,
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
          Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.symmetric(
                    horizontal:
                        screenWidth * 0.05), // Dynamic horizontal padding
                child: Container(
                  padding:
                      EdgeInsets.all(screenWidth * 0.05), // Dynamic padding
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
                      // Title
                      Text(
                        "Glad to see you Back!",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: screenWidth * 0.07, // Dynamic font size
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.bold,
                          letterSpacing: -0.5,
                          color: Colors.black,
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.005), // Dynamic spacing
                      Text(
                        "Login with your credentials or create a new account.",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: screenWidth * 0.035, // Dynamic font size
                          fontFamily: 'Poppins',
                          letterSpacing: -0.5,
                          color: Color(0x77000000),
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.02), // Dynamic spacing

                      // Email text field with validation
                      TextField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          hintText: "Email address",
                          hintStyle: TextStyle(
                            color: Colors.grey,
                            fontSize: screenWidth * 0.04, // Dynamic font size
                            fontFamily: 'Poppins',
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          errorText: _isEmailValid
                              ? null
                              : "Please enter a valid email address",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(
                              color: _isEmailValid
                                  ? AppColors.grey2
                                  : AppColors.red,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(
                              color: _isEmailValid
                                  ? AppColors.black
                                  : AppColors.red,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.02), // Dynamic spacing

                      // Password text field with validation
                      TextField(
                        controller: _passwordController,
                        obscureText: _obscureText,
                        decoration: InputDecoration(
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureText
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                            ),
                            onPressed: _toggle,
                          ),
                          hintText: "Password",
                          hintStyle: TextStyle(
                            color: Colors.grey,
                            fontSize: screenWidth * 0.04, // Dynamic font size
                            fontFamily: 'Poppins',
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          errorText: _passwordError,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(
                              color: _passwordError == null
                                  ? AppColors.grey2
                                  : Colors.red,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(
                              color: _passwordError == null
                                  ? AppColors.grey2
                                  : Colors.red,
                            ),
                          ),
                        ),
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
                              "Or continue with",
                              style: TextStyle(
                                  color: Colors.grey, fontFamily: 'Poppins'),
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
                      SizedBox(height: screenHeight * 0.01), // Dynamic spacing

                      // Facebook login button
                      ElevatedButton.icon(
                        onPressed: () {
                          // Handle Apple login
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => MainScreen()),
                          );
                        },
                        icon: Image.asset(
                          'assets/Icons/Facebook.png',
                          width: screenWidth * 0.1,
                          height: screenWidth * 0.1,
                        ),
                        label: Text(
                          "Sign in With Facebook",
                          style: TextStyle(fontSize: 16, fontFamily: 'Poppins'),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black,
                          padding: EdgeInsets.symmetric(vertical: 6),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.02), // Dynamic spacing

                      // Google login button
                      ElevatedButton.icon(
                        onPressed: () {
                          // Handle Apple login
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => MainScreen()),
                          );
                        },
                        icon: Image.asset(
                          'assets/Icons/google.png',
                          width: screenWidth * 0.1,
                          height: screenWidth * 0.1,
                        ),
                        label: Text(
                          "Sign in With Google",
                          style: TextStyle(fontSize: 16, fontFamily: 'Poppins'),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black,
                          padding: EdgeInsets.symmetric(vertical: 6),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.01), // Dynamic spacing
                      Center(
                        child: TextButton(
                          onPressed: () {
                            // Navigate to the OTP page when clicked
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
                              fontSize: 18.5,
                              fontFamily: "poppins",
                            ),
                          ),
                        ),
                      ),
                      // Continue button
                      SizedBox(height: screenHeight * 0.01), // Dynamic spacing
                      ElevatedButton(
                        onPressed: _isLoading
                            ? null
                            : _validateInputs, // Validate inputs on press
                        child: _isLoading
                            ? CircularProgressIndicator()
                            : Text(
                                "Continue",
                                style: TextStyle(
                                    fontSize: screenWidth *
                                        0.045, // Dynamic font size
                                    color: Colors.white,
                                    fontFamily: 'Poppins'),
                              ),

                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.blue,
                          padding: EdgeInsets.symmetric(
                            vertical: screenHeight * 0.02, // Dynamic padding
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: screenWidth * 0.03,
                      ),

                      // Not a member? Create an account
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
}
