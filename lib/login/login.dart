import 'package:adventura/HomeControllerScreen.dart';
import 'package:adventura/Services/auth_service.dart';
import 'package:adventura/login/FadeSlidePageRoute.dart';
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

      if (response["success"] == true) {
        print("✅ Login Successful!");

        // ✅ Ensure 'user' exists before accessing it
        if (response.containsKey("user") && response["user"] is Map) {
          final user = response["user"];
          final box = await Hive.openBox('authBox');
          if (user.containsKey("user_id") && user["user_id"] != null) {
            box.put("userId", user["user_id"].toString());
            print(
                "✅ Saved userId to Hive from login screen: ${user["user_id"]}");
          } else {
            print("❌ 'user_id' missing or null in login screen");
          }
          if (user.containsKey("provider_id") && user["provider_id"] != null) {
            box.put("providerId", user["provider_id"].toString());
            print("✅ Stored providerId: ${user["provider_id"]}");
          } else {
            print("⚠️ No provider_id found in user payload.");
          }
          setState(() =>
              _isLoading = false); // ✅ Reset loading state before navigation

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => HomeControllerScreen(),
            ),
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
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

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
                          color: isDarkMode
                              ? const Color(0xFFF6F6F6)
                              : const Color(0xff121212),
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
                          color: isDarkMode
                              ? Colors.grey
                              : const Color(0xff121212),
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.02), // Dynamic spacing

                      // Email text field with validation + dark mode
                      TextField(
                        controller: _emailController,
                        style: TextStyle(
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.white
                              : Colors.black,
                          fontFamily: 'Poppins',
                        ),
                        decoration: InputDecoration(
                          hintText: "Email address",
                          hintStyle: TextStyle(
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                    ? Colors.grey[400]
                                    : Colors.grey[700],
                            fontSize: screenWidth * 0.04,
                            fontFamily: 'Poppins',
                          ),
                          filled: true,
                          fillColor:
                              Theme.of(context).brightness == Brightness.dark
                                  ? const Color(0xFF2A2A2A)
                                  : Colors.white,
                          errorText: _isEmailValid
                              ? null
                              : "Please enter a valid email address",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(
                              color: _isEmailValid
                                  ? Theme.of(context).brightness ==
                                          Brightness.dark
                                      ? Colors.grey
                                      : AppColors.grey2
                                  : AppColors.red,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(
                              color: _isEmailValid
                                  ? Theme.of(context).brightness ==
                                          Brightness.dark
                                      ? Colors.white
                                      : AppColors.black
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
                        style: TextStyle(
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.white
                              : Colors.black,
                          fontFamily: 'Poppins',
                        ),
                        decoration: InputDecoration(
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureText
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              color: Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? Colors.white70
                                  : Colors.black87,
                            ),
                            onPressed: _toggle,
                          ),
                          hintText: "Password",
                          hintStyle: TextStyle(
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                    ? Colors.grey[400]
                                    : Colors.grey[700],
                            fontSize: screenWidth * 0.04,
                            fontFamily: 'Poppins',
                          ),
                          filled: true,
                          fillColor:
                              Theme.of(context).brightness == Brightness.dark
                                  ? const Color(0xFF2A2A2A)
                                  : Colors.white,
                          errorText: _passwordError,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(
                              color: _passwordError == null
                                  ? Theme.of(context).brightness ==
                                          Brightness.dark
                                      ? Colors.grey
                                      : AppColors.grey2
                                  : AppColors.red,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(
                              color: _passwordError == null
                                  ? Theme.of(context).brightness ==
                                          Brightness.dark
                                      ? Colors.white
                                      : AppColors.grey2
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
                        onPressed: () async {},
                        icon: Image.asset(
                          'assets/Icons/Facebook.png',
                          width: screenWidth * 0.1,
                          height: screenWidth * 0.1,
                        ),
                        label: Text(
                          "Sign in With Facebook",
                          style: TextStyle(
                            fontSize: 16,
                            fontFamily: 'Poppins',
                            color: isDarkMode ? Colors.white : Colors.black,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isDarkMode
                              ? const Color(0xFF2A2A2A)
                              : Colors.white,
                          foregroundColor:
                              isDarkMode ? Colors.white : Colors.black,
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),

                      SizedBox(height: screenHeight * 0.02),

                      ElevatedButton.icon(
                        onPressed: () async {},
                        icon: Image.asset(
                          'assets/Icons/google.png',
                          width: screenWidth * 0.1,
                          height: screenWidth * 0.1,
                        ),
                        label: Text(
                          "Sign in With Google",
                          style: TextStyle(
                            fontSize: 16,
                            fontFamily: 'Poppins',
                            color: isDarkMode ? Colors.white : Colors.black,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isDarkMode
                              ? const Color(0xFF2A2A2A)
                              : Colors.white,
                          foregroundColor:
                              isDarkMode ? Colors.white : Colors.black,
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),

                      SizedBox(height: screenHeight * 0.01), // Dynamic spacing

                      Center(
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
                              color: isDarkMode ? Colors.white : Colors.black,
                              decoration: TextDecoration.underline,
                              fontSize: 18.5,
                              fontFamily: "Poppins",
                            ),
                          ),
                        ),
                      ),

                      SizedBox(height: screenHeight * 0.01),

                      ElevatedButton(
                        onPressed: _isLoading ? null : _validateInputs,
                        child: _isLoading
                            ? CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  isDarkMode ? Colors.white : Colors.blue,
                                ),
                              )
                            : Text(
                                "Continue",
                                style: TextStyle(
                                  fontSize: screenWidth * 0.045,
                                  color: Colors.white,
                                  fontFamily: 'Poppins',
                                ),
                              ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.blue,
                          padding: EdgeInsets.symmetric(
                            vertical: screenHeight * 0.02,
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
                              color: isDarkMode
                                  ? Colors.grey[400]
                                  : AppColors.grey3,
                              fontFamily: 'Poppins',
                            ),
                            children: [
                              TextSpan(
                                text: "Create an account",
                                style: TextStyle(
                                  color: isDarkMode
                                      ? Colors.lightBlueAccent
                                      : Colors.blue,
                                  fontFamily: 'Poppins',
                                  fontWeight: FontWeight.bold,
                                ),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {
                                    Navigator.push(
                                      context,
                                      CinematicPageRoute(page: SignUpPage()),
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
