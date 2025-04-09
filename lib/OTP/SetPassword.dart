import 'package:adventura/colors.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:ui';
import 'package:http/http.dart' as http;
import '../login/login.dart';
import 'package:adventura/config.dart';

class SetPassword extends StatefulWidget {
  final String email;
  SetPassword({required this.email});

  @override
  _SetPasswordState createState() => _SetPasswordState();
}

class _SetPasswordState extends State<SetPassword> {
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  bool _isLoading = false;
  String _errorMessage = "";
  // Password visibility toggle
  bool _obscureText = true;
  bool _obscureConfirmText = true;

  void _togglePasswordVisibility() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  void _toggleConfirmPasswordVisibility() {
    setState(() {
      _obscureConfirmText = !_obscureConfirmText;
    });
  }

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

  Future<void> resetPassword() async {
    // **Validate password before proceeding**
    String? validationMessage = validatePassword(_passwordController.text);
    if (validationMessage != null) {
      setState(() => _errorMessage = validationMessage);
      return;
    }

    // **Check if passwords match**
    if (_passwordController.text != _confirmPasswordController.text) {
      setState(() => _errorMessage = "Passwords do not match");
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await http.post(
        Uri.parse(
            '$baseUrl/users/reset-password'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': widget.email,
          'newPassword': _passwordController.text,
        }),
      );

      print("🔍 API Response Code: ${response.statusCode}");
      print("🔍 API Response Body: ${response.body}");

      setState(() => _isLoading = false);

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200 && responseData["success"] == true) {
        print("✅ Password Reset Successful!");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Password reset successful!")),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LoginPage()),
        );
      } else {
        print("❌ Password Reset Failed: ${responseData["error"]}");
        setState(() => _errorMessage =
            responseData["error"] ?? "Failed to reset password. Try again.");
      }
    } catch (e) {
      print("❌ Error Resetting Password: $e");
      setState(() {
        _isLoading = false;
        _errorMessage = "Server error. Please try again.";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/Pictures/island.jpg"),
                fit: BoxFit.cover,
              ),
            ),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 2.0, sigmaY: 2.0),
              child: Container(color: Colors.black.withOpacity(0.5)),
            ),
          ),
          Center(
            child: Container(
              padding: EdgeInsets.all(screenWidth * 0.05),
              margin: EdgeInsets.symmetric(horizontal: screenWidth * 0.08),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Set up a new password",
                    style: TextStyle(
                      fontSize: screenWidth * 0.05,
                      fontWeight: FontWeight.bold,
                      fontFamily: "Poppins",
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.02),
                  // Password Format Information
                  Text(
                    "Password must be at least 8 characters long,\ninclude one uppercase letter and one number.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                      fontFamily: "Poppins",
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.02),

                  // New Password Field
                  TextField(
                    controller: _passwordController,
                    obscureText: _obscureText,
                    style: TextStyle(
                      fontFamily: "Poppins",
                      fontSize: screenWidth * 0.04,
                      color: Colors.black,
                    ),
                    decoration: InputDecoration(
                      labelText: "New Password",
                      labelStyle: TextStyle(
                        fontFamily: "Poppins",
                        color: Colors.black,
                      ),
                      floatingLabelStyle: TextStyle(
                        fontFamily: "Poppins",
                        color: AppColors.blue,
                      ),
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
                          color: const Color.fromARGB(255, 0, 0, 0),
                          width: 1.0,
                        ),
                      ),
                      // Toggle Confirm Password Visibility
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureText
                              ? Icons.visibility_off
                              : Icons.visibility,
                          color: Colors.grey[400],
                        ),
                        onPressed: _togglePasswordVisibility,
                      ),
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.02),

                  // Confirm Password Field
                  TextField(
                    controller: _confirmPasswordController,
                    obscureText: _obscureConfirmText,
                    style: TextStyle(
                      fontFamily: "Poppins",
                      fontSize: screenWidth * 0.04,
                      color: Colors.black,
                    ),
                    decoration: InputDecoration(
                      labelText: "Confirm New Password",
                      labelStyle: TextStyle(
                        fontFamily: "Poppins",
                        color: Colors.black,
                      ),
                      floatingLabelStyle: TextStyle(
                        fontFamily: "Poppins",
                        color: AppColors.blue,
                      ),
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
                          color: const Color.fromARGB(255, 0, 0, 0),
                          width: 1.0,
                        ),
                      ),
                      // Toggle Confirm Password Visibility
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureConfirmText
                              ? Icons.visibility_off
                              : Icons.visibility,
                          color: Colors.grey[400],
                        ),
                        onPressed: _toggleConfirmPasswordVisibility,
                      ),
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.02),

                  if (_errorMessage.isNotEmpty)
                    Text(
                      _errorMessage,
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 14,
                        fontFamily: "Poppins",
                      ),
                    ),

                  SizedBox(height: screenHeight * 0.02),

                  SizedBox(
                    width: double.infinity,
                    height: screenHeight * 0.07,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.blue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: _isLoading ? null : resetPassword,
                      child: _isLoading
                          ? CircularProgressIndicator(color: Colors.white)
                          : Text(
                              "Set Password",
                              style: TextStyle(
                                fontSize: screenWidth * 0.045,
                                color: Colors.white,
                                fontFamily: "Poppins",
                              ),
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
