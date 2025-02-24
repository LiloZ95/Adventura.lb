import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:ui';
import 'package:http/http.dart' as http;
import '../login/login.dart';
import '../Main screen components/MainScreen.dart';

class SetPassword extends StatefulWidget {
  final String email;
  SetPassword({required this.email});

  @override
  _SetPasswordState createState() => _SetPasswordState();
}

class _SetPasswordState extends State<SetPassword> {
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  bool _isLoading = false;
  String _errorMessage = "";

  Future<void> resetPassword() async {
    // **Check if passwords match**
    if (_passwordController.text != _confirmPasswordController.text) {
      setState(() => _errorMessage = "Passwords do not match");
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await http.post(
        Uri.parse('http://10.0.2.2:3000/users/reset-password'), // Adjust for emulator
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': widget.email,
          'newPassword': _passwordController.text,
        }),
      );

      setState(() => _isLoading = false);

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Password reset successful!")),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LoginPage()),
        );
      } else {
        setState(() => _errorMessage = "Failed to reset password. Try again.");
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = "Server error. Please try again.";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Screen dimensions for responsiveness
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Stack(
        children: [
          // ✅ Background Image with Blur
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

          // ✅ Centered Form
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

                  // New Password Field
                  TextField(
                    controller: _passwordController,
                    obscureText: true,
                    style: TextStyle(
                      fontFamily: "Poppins",
                      fontSize: screenWidth * 0.04,
                      color: Colors.black,
                    ),
                    decoration: InputDecoration(
                      labelText: "New Password",
                      // Default label color
                      labelStyle: TextStyle(
                        fontFamily: "Poppins",
                        color: Colors.black,
                      ),
                      // Label color when floating (on focus)
                      floatingLabelStyle: TextStyle(
                        fontFamily: "Poppins",
                        color: Colors.blue,
                      ),
                      filled: false, // No background color
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.grey[600]!,
                          width: 1.0,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.grey[600]!,
                          width: 1.0,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.02),

                  // Confirm Password Field
                  TextField(
                    controller: _confirmPasswordController,
                    obscureText: true,
                    style: TextStyle(
                      fontFamily: "Poppins",
                      fontSize: screenWidth * 0.04,
                      color: Colors.black,
                    ),
                    decoration: InputDecoration(
                      labelText: "Confirm New Password",
                      // Default label color
                      labelStyle: TextStyle(
                        fontFamily: "Poppins",
                        color: Colors.black,
                      ),
                      // Label color when floating (on focus)
                      floatingLabelStyle: TextStyle(
                        fontFamily: "Poppins",
                        color: Colors.blue,
                      ),
                      filled: false, // No background color
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.grey[600]!,
                          width: 1.0,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.grey[600]!,
                          width: 1.0,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.02),

                  // Error Message
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

                  // Set Password Button
                  SizedBox(
                    width: double.infinity,
                    height: screenHeight * 0.07,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
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

          // (Optional) Top-left arrow if needed
          Positioned(
            top: 16,
            left: 16,
            child: SafeArea(
              child: IconButton(
                icon: Icon(Icons.arrow_back_ios, color: Colors.white),
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => LoginPage()),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
