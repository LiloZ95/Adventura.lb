import 'dart:io';

import 'package:adventura/BecomeProvider/WelcomePage.dart';
import 'package:adventura/MyListings/Mylisting.dart';
import 'package:flutter/material.dart';
import 'package:adventura/login/login.dart';
import 'package:adventura/Services/profile_service.dart';
import 'package:adventura/Services/user_service.dart';
import 'package:adventura/Services/storage_service.dart';
import 'dart:typed_data';
import 'dart:convert';
import 'package:dotted_border/dotted_border.dart';
import 'package:adventura/userinformation/profileOptionTile.dart';
import 'package:hive/hive.dart';

class UserInfo extends StatefulWidget {
  @override
  _UserInfoState createState() => _UserInfoState();
}

class _UserInfoState extends State<UserInfo> {
  late String userId;
  late String firstName;
  late String lastName;
  late String profilePicture;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  // ✅ Load user data from storage and fetch profile picture
  Future<void> _loadUserData() async {
    Box box = await Hive.openBox('authBox');

    userId = box.get("userId", defaultValue: "");
    firstName = box.get("firstName", defaultValue: "");
    lastName = box.get("lastName", defaultValue: "");

    // Fallback in case it's empty in Hive
    if (firstName.isEmpty || lastName.isEmpty) {
      firstName = await StorageService.getFirstName();
      lastName = await StorageService.getLastName();
    }

    profilePicture = await ProfileService.fetchProfilePicture(userId);

    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(screenHeight * 0.12),
        child: Container(
          padding: EdgeInsets.only(
            top: screenHeight * 0.05,
            left: screenWidth * 0.05,
            right: screenWidth * 0.05,
          ),
          color: Colors.white,
          child: Row(
            children: [
              // ✅ Back Arrow
              IconButton(
                icon: Icon(Icons.arrow_back, color: Colors.black),
                onPressed: () => Navigator.pop(context),
              ),
              Expanded(
                child: Text(
                  "My Profile",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: screenHeight * 0.03,
                    fontWeight: FontWeight.bold,
                    fontFamily: "Poppins",
                    color: Colors.black,
                  ),
                ),
              ),
              SizedBox(width: 48), // Balancing the row
            ],
          ),
        ),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(height: screenHeight * 0.02),

                  // ✅ Profile Picture Section
                  GestureDetector(
                    onTap: () async {
                      // Pick and upload new profile picture
                      File? selectedImage = await ProfileService.pickImage();
                      if (selectedImage != null) {
                        await ProfileService.uploadProfilePicture(
                            context, userId, selectedImage);
                        _loadUserData(); // Reload after updating
                      }
                    },
                    child: Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        Container(
                          width: screenHeight * 0.13,
                          height: screenHeight * 0.13,
                          decoration: BoxDecoration(shape: BoxShape.circle),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(50),
                            child: _buildProfileImage(),
                          ),
                        ),
                        // ✅ Camera Icon with Border
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.black, width: 2),
                          ),
                          child: CircleAvatar(
                            backgroundColor: Colors.white,
                            radius: 25,
                            child: Icon(Icons.camera_alt, color: Colors.black),
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 8),

                  // ✅ Display User Name
                  Text(
                    "$firstName $lastName",
                    style: TextStyle(
                      fontSize: screenHeight * 0.025,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                      fontFamily: "Poppins",
                    ),
                  ),

                  SizedBox(height: screenHeight * 0.01),
                  // ✅ Personal Account Text
                  Text(
                    "Personal Account",
                    style: TextStyle(
                      fontSize: screenHeight * 0.018,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[700],
                      fontFamily: "Poppins",
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.02),

                  // ✅ Dotted-Border Button
                  buildBusinessAccountButton(
                    screenWidth: screenWidth,
                    onPressed: () {
                      Navigator.push(
                        context,
                        PageRouteBuilder(
                          pageBuilder:
                              (context, animation, secondaryAnimation) =>
                                  const ProviderWelcomeScreen(),
                          transitionsBuilder:
                              (context, animation, secondaryAnimation, child) {
                            final curved = CurvedAnimation(
                              parent: animation,
                              curve: Curves.easeOutExpo,
                            );

                            return FadeTransition(
                              opacity: curved,
                              child: ScaleTransition(
                                scale: Tween<double>(begin: 1.5, end: 1.0)
                                    .animate(curved),
                                child: SlideTransition(
                                  position: Tween<Offset>(
                                    begin: const Offset(0, 0.08),
                                    end: Offset.zero,
                                  ).animate(curved),
                                  child: child,
                                ),
                              ),
                            );
                          },
                          transitionDuration: const Duration(milliseconds: 650),
                        ),
                      );

                      print("Open Business Account Tapped");
                    },
                  ),

                  SizedBox(height: screenHeight * 0.02),
                  Padding(
                    padding: EdgeInsets.only(
                      left: screenWidth * 0.05,
                      top: screenHeight * 0.02,
                    ),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Account",
                        style: TextStyle(
                          fontSize: screenHeight * 0.025,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                          fontFamily: "Poppins",
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.01),

                  // inbox option
                  ProfileOptionTile(
                    icon: Icons.inbox,
                    title: "Inbox",
                    onTap: () {
                      // handle tap
                    },
                  ),
                  //help option
                  ProfileOptionTile(
                    icon: Icons.help,
                    title: "Help",
                    onTap: () {
                      // handle tap
                    },
                  ),
                  //statement and reports option
                  ProfileOptionTile(
                    icon: Icons.report,
                    title: "My listings",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => MyListingsPage()),
                      );
                    },
                  ),

                  SizedBox(height: screenHeight * 0.01),

                  Padding(
                    padding: EdgeInsets.only(
                      left: screenWidth * 0.05,
                      top: screenHeight * 0.02,
                    ),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Settings",
                        style: TextStyle(
                          fontSize: screenHeight * 0.025,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                          fontFamily: "Poppins",
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.02),
                  //pivacy and security option
                  ProfileOptionTile(
                    icon: Icons.security,
                    title: "Security & Privacy",
                    subtitle: "Change your security and privacy settings",
                    onTap: () {
                      // handle tap
                    },
                  ),
                  //payment methods option
                  ProfileOptionTile(
                    icon: Icons.payment,
                    title: "Payment Methods",
                    subtitle:
                        "Manage saved cards and bank accounts that are linked to this account",
                    onTap: () {
                      // handle tap
                    },
                  ),

                  //appearance options
                  ProfileOptionTile(
                    icon: Icons.dark_mode,
                    title: "Appearance",
                    subtitle: "Light",
                    onTap: () {
                      // handle tap
                    },
                  ),

                  //personal details option
                  ProfileOptionTile(
                    icon: Icons.person,
                    title: "Personal Details",
                    subtitle: "Update your personal informatin",
                    onTap: () {
                      // handle tap
                    },
                  ),
                  SizedBox(height: screenHeight * 0.02),

                  Padding(
                    padding: EdgeInsets.only(
                      left: screenWidth * 0.05,
                      top: screenHeight * 0.02,
                    ),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Actions And Agreements",
                        style: TextStyle(
                          fontSize: screenHeight * 0.025,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                          fontFamily: "Poppins",
                        ),
                      ),
                    ),
                  ),
                  //agreements sections
                  SizedBox(height: screenHeight * 0.02),
                  ProfileOptionTile(
                    icon: Icons.warning,
                    title: "Our Agreements",
                    onTap: () {
                      // handle tap
                    },
                  ),
                  //rate us options
                  ProfileOptionTile(
                    icon: Icons.star,
                    title: "Rate Us",
                    subtitle: "Write a review in App store",
                    onTap: () {
                      // handle tap
                    },
                  ),
                  //report bugs
                  ProfileOptionTile(
                    icon: Icons.bug_report,
                    title: "Report a bug",
                    onTap: () {
                      // handle tap
                    },
                  ),
                  //delete account option
                  ProfileOptionTile(
                    icon: Icons.delete,
                    title: "Close Account",
                    subtitle: "Close your personal account",
                    onTap: () async {
                      print("🚨 Delete button pressed!");
                      _showDeleteConfirmationDialog(
                          context); // ✅ Call dialog directly
                    },
                  ),
                  //logout
                  ProfileOptionTile(
                    icon: Icons.logout,
                    title: "Logout",
                    onTap: () async {
                      print("🚀 Logout button pressed!");
                      await StorageService.logout(context);
                    },
                  ),
                  //membership section
                  Padding(
                    padding: EdgeInsets.only(
                      left: screenWidth * 0.05,
                      top: screenHeight * 0.02,
                    ),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Membership number",
                        style: TextStyle(
                          fontSize: screenHeight * 0.020,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                          fontFamily: "Poppins",
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(
                      left: screenWidth * 0.05,
                      top: screenHeight * 0.02,
                    ),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "P122312802",
                        style: TextStyle(
                          fontSize: screenHeight * 0.015,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                          fontFamily: "Poppins",
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

// ✅ The Dotted-Border Button (Unchanged)
  Widget buildBusinessAccountButton({
    required double screenWidth,
    required VoidCallback onPressed,
  }) {
    return InkWell(
      onTap: onPressed,
      child: DottedBorder(
        color: Colors.grey,
        strokeWidth: 1.5,
        dashPattern: [5, 5],
        borderType: BorderType.RRect,
        radius: Radius.circular(12),
        child: Container(
          width: screenWidth * 0.85,
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: Colors.grey[200],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(
                alignment: Alignment.bottomRight,
                children: [
                  Icon(Icons.business, size: 32, color: Colors.black),
                  Positioned(
                    right: -2,
                    bottom: -2,
                    child: CircleAvatar(
                      radius: 8,
                      backgroundColor: Colors.green,
                      child: Icon(Icons.add, size: 12, color: Colors.white),
                    ),
                  ),
                ],
              ),
              SizedBox(width: 12),
              Text(
                "Open a new business account",
                style: TextStyle(
                  fontFamily: "poppins",
                  fontSize: 13.5,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ✅ Profile Picture Handling
  Widget _buildProfileImage() {
    if (profilePicture.isNotEmpty && profilePicture.length > 50) {
      if (profilePicture.startsWith("data:image")) {
        try {
          String base64String = profilePicture.split(",")[1];
          Uint8List imageBytes =
              base64Decode(base64String.split(',').last); // ✅ Works

          return Image.memory(
            imageBytes,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return _defaultProfileImage();
            },
          );
        } catch (e) {
          return _defaultProfileImage();
        }
      }
      return Image.network(
        profilePicture,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return _defaultProfileImage();
        },
      );
    }
    return _defaultProfileImage();
  }

  Widget _defaultProfileImage() {
    return Image.asset("assets/images/default_user.png", fit: BoxFit.cover);
  }

  // ✅ Delete Account Confirmation Dialog
  void _showDeleteConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text(
            "⚠️ Confirm Account Deletion",
            style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
          ),
          content: Text(
            "Are you sure you want to delete your account? This action is irreversible.",
            style: TextStyle(fontSize: 16),
          ),
          actions: [
            TextButton(
              onPressed: () {
                print("❌ User canceled account deletion.");
                Navigator.pop(dialogContext);
              },
              child: Text("Cancel", style: TextStyle(color: Colors.grey)),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(dialogContext); // ✅ Close dialog first

                print("🚨 User confirmed account deletion.");

                bool success = await UserService.deleteUser(context);
                if (success) {
                  if (context.mounted) {
                    // ✅ Check if the widget is still in the tree
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => LoginPage()),
                      (route) => false,
                    );
                  }
                } else {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Failed to delete account.")),
                    );
                  }
                }
              },
              child: Text("Delete", style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }
}
