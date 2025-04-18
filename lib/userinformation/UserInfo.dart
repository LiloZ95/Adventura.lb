import 'dart:io';

import 'package:adventura/BecomeProvider/WelcomePage.dart';
import 'package:adventura/MyListings/Mylisting.dart';
import 'package:adventura/OrganizerProfile/OrganizerProfile.dart';
import 'package:adventura/userinformation/widgets/Agreements.dart';
import 'package:adventura/userinformation/widgets/RateUs.dart';
import 'package:adventura/userinformation/widgets/Security&Privacy.dart';
import 'package:adventura/userinformation/widgets/report_bug_page.dart';
import 'package:adventura/userinformation/widgets/theme_button.dart';
import 'package:adventura/userinformation/widgets/custom_page_route.dart';
import 'package:adventura/userinformation/widgets/theme_controller.dart';
import 'package:flutter/material.dart';
import 'package:adventura/login/login.dart';
import 'package:adventura/Services/profile_service.dart';
import 'package:adventura/Services/user_service.dart';
import 'package:adventura/Services/storage_service.dart';
import 'dart:typed_data';
import 'dart:convert';
import 'package:dotted_border/dotted_border.dart';
import 'package:adventura/userinformation/widgets/profileOptionTile.dart';
import 'package:hive/hive.dart';
import 'package:adventura/userinformation/widgets/PaymentMethod.dart';
import 'package:adventura/userinformation/widgets/PersonalInformition.dart';
import 'package:provider/provider.dart';

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
  late String userType = "null";
  // Add this in your State class

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  // ✅ Load user data from storage and fetch profile picture
  Future<void> _loadUserData() async {
    Box box = await Hive.openBox('authBox');
    userType =
        box.get("userType", defaultValue: "client"); // fallback to 'client'
    userType = box.get("userType"); // 👈 Add this

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
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDarkMode ? const Color(0xFF1F1F1F) : Colors.white, // 🌙
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(screenHeight * 0.12),
        child: Container(
          padding: EdgeInsets.only(
            top: screenHeight * 0.05,
            left: screenWidth * 0.05,
            right: screenWidth * 0.05,
          ),
          color: isDarkMode ? const Color(0xFF1F1F1F) : Colors.white,
          child: Row(
            children: [
              // ✅ Back Arrow
              IconButton(
                icon: Icon(Icons.arrow_back,
                    color: isDarkMode ? Colors.white : Colors.black),
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
                    color: isDarkMode ? Colors.white : Colors.black,
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
                            border: Border.all(
                                color: isDarkMode ? Colors.white : Colors.black,
                                width: 2),
                          ),
                          child: CircleAvatar(
                            backgroundColor:
                                isDarkMode ? Colors.black : Colors.white,
                            radius: 25,
                            child: Icon(
                              Icons.camera_alt,
                              color: isDarkMode ? Colors.white : Colors.black,
                            ),
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
                      color: isDarkMode ? Colors.white : Colors.black,
                      fontFamily: "Poppins",
                    ),
                  ),

                  SizedBox(height: screenHeight * 0.02),
                  // ✅ Personal Account Text
                  Text(
                    userType == "provider"
                        ? "Business Account"
                        : "Personal Account",
                    style: TextStyle(
                      fontSize: screenHeight * 0.018,
                      fontWeight: FontWeight.w500,
                      color: isDarkMode ? Colors.white : Colors.grey[700],
                      fontFamily: "Poppins",
                    ),
                  ),

                  SizedBox(height: screenHeight * 0.01),

                  // ✅ Dotted-Border Button
                  if (userType != "provider")
                    buildBusinessAccountButton(
                      isDarkMode: Theme.of(context).brightness ==
                          Brightness.dark, // 👈 named
                      screenWidth: screenWidth,
                      onPressed: () {
                        Navigator.push(
                          context,
                          PageRouteBuilder(
                            pageBuilder:
                                (context, animation, secondaryAnimation) =>
                                    const ProviderWelcomeScreen(),
                            transitionsBuilder: (context, animation,
                                secondaryAnimation, child) {
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
                            transitionDuration:
                                const Duration(milliseconds: 650),
                          ),
                        );
                        print("Open Business Account Tapped");
                      },
                    ),

                  SizedBox(height: screenHeight * 0.005),
                  Padding(
                    padding: EdgeInsets.only(
                      left: screenWidth * 0.01,
                      top: screenHeight * 0.025,
                    ),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (userType == "provider") ...[
                            Padding(
                              padding: EdgeInsets.only(
                                left: screenWidth * 0.05,
                                top: screenHeight * 0.02,
                              ),
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  "Organizer Options",
                                  style: TextStyle(
                                    fontSize: screenHeight * 0.025,
                                    fontWeight: FontWeight.bold,
                                    color: isDarkMode
                                        ? Colors.white
                                        : Colors.black,
                                    fontFamily: "Poppins",
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: screenHeight * 0.01),
                            ProfileOptionTile(
                                isDarkMode: isDarkMode,
                                icon: Icons.pages_rounded,
                                title: "Landing page",
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          OrganizerProfilePage(
                                        organizerId: userId,
                                        organizerName: "$firstName $lastName",
                                        organizerImage: profilePicture,
                                        bio:
                                            "Welcome", // You can replace this later with a real one
                                        activities: [], // Replace with actual activity list when available
                                      ),
                                    ),
                                  );
                                }),
                            ProfileOptionTile(
                              isDarkMode: isDarkMode,
                              icon: Icons.create,
                              title: "Create Reels",
                              onTap: () {},
                            ),
                            ProfileOptionTile(
                              isDarkMode: isDarkMode,
                              icon: Icons.list_sharp,
                              title: "My listings",
                              onTap: () async {
                                final box = await Hive.openBox('authBox');
                                final userType = box.get('userType');
                                final providerId = box.get('providerId');

                                if (userType != 'provider' ||
                                    providerId == null) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                        content: Text(
                                            "Only providers can access My Listings.")),
                                  );
                                  return;
                                }

                                Navigator.push(
                                  context,
                                  SecurityPageRoute(
                                      child: const MyListingsPage()),
                                );
                              },
                            ),
                          ],
                        ],
                      ),
                    ),
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
                          color: isDarkMode ? Colors.white : Colors.black,
                          fontFamily: "Poppins",
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.02),
                  //pivacy and security option
                  ProfileOptionTile(
                    isDarkMode: isDarkMode,
                    icon: Icons.security,
                    title: "Security & Privacy",
                    subtitle: "Change your security and privacy settings",
                    onTap: () {
                      // Navigator.push(
                      //   context,
                      //   MaterialPageRoute(
                      //       builder: (context) => SecurityPrivacyPage()),
                      // );

                      Navigator.push(
                        context,
                        SecurityPageRoute(child: const SecurityPrivacyPage()),
                      );
                    },
                  ),
                  //payment methods option
                  ProfileOptionTile(
                    isDarkMode: isDarkMode,
                    icon: Icons.payment,
                    title: "Payment Methods",
                    subtitle:
                        "Manage saved cards and bank accounts that are linked to this account",
                    onTap: () {
                      Navigator.push(
                        context,
                        SecurityPageRoute(child: const AddPaymentMethodPage()),
                      );
                    },
                  ),

                  //personal details option
                  ProfileOptionTile(
                    isDarkMode: isDarkMode,
                    icon: Icons.person,
                    title: "Personal Details",
                    subtitle: "Update your personal informatin",
                    onTap: () {
                      Navigator.push(
                        context,
                        SecurityPageRoute(child: const PersonalDetailsPage()),
                      );
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
                          color: isDarkMode ? Colors.white : Colors.black,
                          fontFamily: "Poppins",
                        ),
                      ),
                    ),
                  ),
                  //agreements sections
                  SizedBox(height: screenHeight * 0.02),
                  ProfileOptionTile(
                    isDarkMode: isDarkMode,
                    icon: Icons.warning,
                    title: "Our Agreements",
                    onTap: () {
                      Navigator.push(
                        context,
                        SecurityPageRoute(child: const ProviderAgreementPage()),
                      );
                    },
                  ),
                  //rate us options
                  ProfileOptionTile(
                    isDarkMode: isDarkMode,
                    icon: Icons.star,
                    title: "Rate Us",
                    subtitle: "Write a review in App store",
                    onTap: () {
                      Navigator.push(
                        context,
                        SecurityPageRoute(child: const RateUsPage()),
                      );
                    },
                  ),
                  //report bugs
                  ProfileOptionTile(
                    isDarkMode: isDarkMode,
                    icon: Icons.bug_report,
                    title: "Report a bug",
                    onTap: () {
                      Navigator.push(
                        context,
                        SecurityPageRoute(child: const ReportBugPage()),
                      );
                    },
                  ),
                  //delete account option
                  ProfileOptionTile(
                    isDarkMode: isDarkMode,
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
                    isDarkMode: isDarkMode,
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
                  ),
                ],
              ),
            ),
      floatingActionButton: AppearanceFAB(
        isDarkMode: Provider.of<ThemeController>(context).isDarkMode,
        onToggle: () {
          Provider.of<ThemeController>(context, listen: false).toggleTheme();
        },
      ),
    );
  }

// ✅ The Dotted-Border Button (Unchanged)
  Widget buildBusinessAccountButton({
    required double screenWidth,
    required VoidCallback onPressed,
    required bool isDarkMode,
  }) {
    return InkWell(
      onTap: onPressed,
      child: DottedBorder(
        color: isDarkMode ? Colors.white : Colors.black,
        strokeWidth: 1.5,
        dashPattern: [5, 5],
        borderType: BorderType.RRect,
        radius: Radius.circular(12),
        child: Container(
          width: screenWidth * 0.85,
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: isDarkMode ? Color(0xFF1F1F1F) : Colors.grey[200]),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(
                alignment: Alignment.bottomRight,
                children: [
                  Icon(Icons.business,
                      size: 32,
                      color: isDarkMode ? Colors.white : Colors.black),
                  Positioned(
                    right: -2,
                    bottom: -2,
                    child: CircleAvatar(
                      radius: 8,
                      backgroundColor: Colors.green,
                      child: Icon(Icons.add,
                          size: 12,
                          color: isDarkMode ? Colors.white : Colors.black),
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
                  color: isDarkMode ? Colors.white : Colors.black,
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
      barrierDismissible: false, // Prevent closing by tapping outside
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
          contentPadding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
          title: Row(
            children: const [
              Icon(Icons.warning_amber_rounded, color: Colors.blue),
              SizedBox(width: 8),
              Text(
                "Confirm Deletion",
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Colors.blue,
                ),
              ),
            ],
          ),
          content: const Text(
            "Are you sure you want to delete your account?\nThis action is permanent and cannot be undone.",
            style: TextStyle(
              fontSize: 15,
              fontFamily: 'Poppins',
              color: Colors.black87,
            ),
          ),
          actionsPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          actionsAlignment: MainAxisAlignment.spaceBetween,
          actions: [
            OutlinedButton(
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.grey),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              onPressed: () {
                print("❌ User canceled account deletion.");
                Navigator.pop(dialogContext);
              },
              child: const Text(
                "Cancel",
                style: TextStyle(
                  fontFamily: 'Poppins',
                  color: Colors.grey,
                ),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () async {
                Navigator.pop(dialogContext);

                print("🚨 User confirmed account deletion.");
                bool success = await UserService.deleteUser(context);

                if (success) {
                  if (context.mounted) {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => LoginPage()),
                      (route) => false,
                    );
                  }
                } else {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Failed to delete account."),
                      ),
                    );
                  }
                }
              },
              child: const Text(
                "Delete",
                style: TextStyle(
                  fontFamily: 'Poppins',
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
