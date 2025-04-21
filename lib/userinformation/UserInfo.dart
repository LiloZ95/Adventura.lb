import 'dart:io';

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
import 'package:hive/hive.dart';
import 'package:adventura/userinformation/widgets/PaymentMethod.dart';
import 'package:adventura/userinformation/widgets/PersonalInformition.dart';
import 'package:provider/provider.dart';

class ProfileOptionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;
  final bool isDarkMode;

  const ProfileOptionTile({
    Key? key,
    required this.icon,
    required this.title,
    this.subtitle,
    required this.onTap,
    required this.isDarkMode,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF2A2A2A) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: isDarkMode 
                ? Colors.black.withOpacity(0.2) 
                : Colors.grey.withOpacity(0.1),
            spreadRadius: 0,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: isDarkMode ? const Color(0xFF3D3D3D) : const Color(0xFFF5F5F5),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    icon,
                    color: title == "Logout" || title == "Close Account"
                        ? Colors.red
                        : isDarkMode 
                            ? Colors.white 
                            : Colors.black87,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: title == "Logout" || title == "Close Account"
                              ? Colors.red
                              : isDarkMode 
                                  ? Colors.white 
                                  : Colors.black87,
                        ),
                      ),
                      if (subtitle != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            subtitle!,
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 12,
                              color: isDarkMode 
                                  ? Colors.grey[400] 
                                  : Colors.grey[600],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: isDarkMode ? Colors.grey[400] : Colors.grey[700],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class SectionHeader extends StatelessWidget {
  final String title;
  final bool isDarkMode;

  const SectionHeader({
    Key? key,
    required this.title,
    required this.isDarkMode,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
      child: Text(
        title,
        style: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: isDarkMode ? Colors.white : Colors.black,
        ),
      ),
    );
  }
}

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

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    Box box = await Hive.openBox('authBox');
    userType = box.get("userType", defaultValue: "client");

    userId = box.get("userId", defaultValue: "");
    firstName = box.get("firstName", defaultValue: "");
    lastName = box.get("lastName", defaultValue: "");

    if (firstName.isEmpty || lastName.isEmpty) {
      firstName = await StorageService.getFirstName();
      lastName = await StorageService.getLastName();
    }

    profilePicture = await ProfileService.fetchProfilePicture(userId);

    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDarkMode ? const Color(0xFF1F1F1F) : Colors.white;
    final cardColor = isDarkMode ? const Color(0xFF2A2A2A) : Colors.white;
    final textColor = isDarkMode ? Colors.white : Colors.black;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: textColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "My Profile",
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            fontFamily: "Poppins",
            color: textColor,
          ),
        ),
        centerTitle: true,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Profile Section
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: Column(
                      children: [
                        // Profile Picture
                        GestureDetector(
                          onTap: () async {
                            File? selectedImage = await ProfileService.pickImage();
                            if (selectedImage != null) {
                              await ProfileService.uploadProfilePicture(
                                  context, userId, selectedImage);
                              _loadUserData();
                            }
                          },
                          child: Stack(
                            alignment: Alignment.bottomRight,
                            children: [
                              Container(
                                width: 100,
                                height: 100,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      spreadRadius: 1,
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(50),
                                  child: _buildProfileImage(),
                                ),
                              ),
                              Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: isDarkMode ? Colors.white : Colors.black,
                                    width: 2,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      spreadRadius: 1,
                                      blurRadius: 2,
                                      offset: const Offset(0, 1),
                                    ),
                                  ],
                                ),
                                child: CircleAvatar(
                                  backgroundColor: isDarkMode ? Colors.black : Colors.white,
                                  radius: 16,
                                  child: Icon(
                                    Icons.camera_alt,
                                    color: isDarkMode ? Colors.white : Colors.black,
                                    size: 16,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        
                        // Name
                        Text(
                          "$firstName $lastName",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                            fontFamily: "Poppins",
                          ),
                        ),
                        
                        // Account Type
                        Padding(
                          padding: const EdgeInsets.only(top: 4, bottom: 16),
                          child: Text(
                            userType == "provider" ? "Business Account" : "Personal Account",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: isDarkMode ? Colors.grey[400] : Colors.grey[700],
                              fontFamily: "Poppins",
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Organizer Options for Providers
                  if (userType == "provider") ...[
                    SectionHeader(
                      title: "Organizer Options",
                      isDarkMode: isDarkMode,
                    ),
                    ProfileOptionTile(
                      isDarkMode: isDarkMode,
                      icon: Icons.pages_rounded,
                      title: "Landing page",
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => OrganizerProfilePage(
                              organizerId: userId,
                              organizerName: "$firstName $lastName",
                              organizerImage: profilePicture,
                              bio: "Welcome",
                              activities: [],
                            ),
                          ),
                        );
                      },
                    ),
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

                        if (userType != 'provider' || providerId == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text("Only providers can access My Listings."),
                            ),
                          );
                          return;
                        }

                        Navigator.push(
                          context,
                          SecurityPageRoute(child: const MyListingsPage()),
                        );
                      },
                    ),
                  ],

                  // Settings Section
                  SectionHeader(
                    title: "Settings",
                    isDarkMode: isDarkMode,
                  ),
                  ProfileOptionTile(
                    isDarkMode: isDarkMode,
                    icon: Icons.security,
                    title: "Security & Privacy",
                    subtitle: "Change your security and privacy settings",
                    onTap: () {
                      Navigator.push(
                        context,
                        SecurityPageRoute(child: const SecurityPrivacyPage()),
                      );
                    },
                  ),
                  ProfileOptionTile(
                    isDarkMode: isDarkMode,
                    icon: Icons.payment,
                    title: "Payment Methods",
                    subtitle: "Manage saved cards and bank accounts that are linked to this account",
                    onTap: () {
                      Navigator.push(
                        context,
                        SecurityPageRoute(child: const AddPaymentMethodPage()),
                      );
                    },
                  ),
                  ProfileOptionTile(
                    isDarkMode: isDarkMode,
                    icon: Icons.person,
                    title: "Personal Details",
                    subtitle: "Update your personal information",
                    onTap: () {
                      Navigator.push(
                        context,
                        SecurityPageRoute(child: const PersonalDetailsPage()),
                      );
                    },
                  ),

                  // Actions and Agreements
                  SectionHeader(
                    title: "Actions And Agreements",
                    isDarkMode: isDarkMode,
                  ),
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
                  ProfileOptionTile(
                    isDarkMode: isDarkMode,
                    icon: Icons.delete,
                    title: "Close Account",
                    subtitle: "Close your personal account",
                    onTap: () {
                      _showDeleteConfirmationDialog(context);
                    },
                  ),
                  ProfileOptionTile(
                    isDarkMode: isDarkMode,
                    icon: Icons.logout,
                    title: "Logout",
                    onTap: () async {
                      await StorageService.logout(context);
                    },
                  ),
                  
                  // Membership Section
                  SectionHeader(
                    title: "Membership",
                    isDarkMode: isDarkMode,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 24, bottom: 32),
                    child: Text(
                      "P122312802",
                      style: TextStyle(
                        fontSize: 15,
                        fontFamily: "Poppins",
                        color: isDarkMode ? Colors.grey[400] : Colors.grey[700],
                      ),
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

  Widget _buildProfileImage() {
    if (profilePicture.isNotEmpty && profilePicture.length > 50) {
      if (profilePicture.startsWith("data:image")) {
        try {
          String base64String = profilePicture.split(",")[1];
          Uint8List imageBytes = base64Decode(base64String.split(',').last);

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

  void _showDeleteConfirmationDialog(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final dialogBackgroundColor = isDarkMode ? const Color(0xFF2A2A2A) : Colors.white;
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: dialogBackgroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.red[400], size: 28),
              const SizedBox(width: 12),
              Text(
                "Confirm Deletion",
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Colors.red[400],
                ),
              ),
            ],
          ),
          content: Text(
            "Are you sure you want to delete your account?\nThis action is permanent and cannot be undone.",
            style: TextStyle(
              fontSize: 15,
              fontFamily: 'Poppins',
              color: isDarkMode ? Colors.white : Colors.black87,
            ),
          ),
          actions: [
            TextButton(
              style: TextButton.styleFrom(
                backgroundColor: isDarkMode ? Color(0xFF3D3D3D) : Colors.grey[200],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: Text(
                "Cancel",
                style: TextStyle(
                  fontFamily: 'Poppins',
                  color: isDarkMode ? Colors.white : Colors.black87,
                ),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red[400],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              onPressed: () async {
                Navigator.pop(dialogContext);
                
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
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

// You would need to define this AppearanceFAB widget if it doesn't exist already
// This is just a placeholder implementation
class AppearanceFAB extends StatelessWidget {
  final bool isDarkMode;
  final VoidCallback onToggle;

  const AppearanceFAB({
    Key? key,
    required this.isDarkMode,
    required this.onToggle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: onToggle,
      backgroundColor: isDarkMode ? Colors.white : Colors.black,
      child: Icon(
        isDarkMode ? Icons.light_mode : Icons.dark_mode,
        color: isDarkMode ? Colors.black : Colors.white,
      ),
    );
  }
}