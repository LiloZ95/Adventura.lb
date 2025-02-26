import 'package:adventura/login/login.dart';
import 'package:flutter/material.dart';
import 'package:adventura/Services/api_service.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import 'dart:typed_data';
import 'package:dotted_border/dotted_border.dart';
import 'package:adventura/userinformation/profileOptionTile.dart';

class UserInfo extends StatefulWidget {
  @override
  _UserInfoState createState() => _UserInfoState();
}

class _UserInfoState extends State<UserInfo> {
  late ApiService apiService;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    apiService = Provider.of<ApiService>(context, listen: false);
    apiService.getUserId();
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
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: screenHeight * 0.02),

            // ✅ Profile Picture Section
            Consumer<ApiService>(
              builder: (context, apiService, child) {
                return GestureDetector(
                  onTap: () async {
                    String userId = apiService.userId ?? "";
                    if (userId.isNotEmpty) {
                      await apiService.pickImage(context, userId);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text("❌ User ID is missing!"),
                          backgroundColor: Colors.red,
                        ),
                      );
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
                          child: _buildProfileImage(apiService),
                        ),
                      ),
                      // ✅ Camera Icon with Black Border
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.black, width: 2),
                        ),
                        child: CircleAvatar(
                          backgroundColor: Colors.white,
                          radius: 18,
                          child: Icon(Icons.camera_alt, color: Colors.black),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),

            SizedBox(height: 8),

            // ✅ Display User Name
            Consumer<ApiService>(
              builder: (context, apiService, child) {
                return Text(
                  "${apiService.firstName} ${apiService.lastName}",
                  style: TextStyle(
                    fontSize: screenHeight * 0.030,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                    fontFamily: "Poppins",
                  ),
                );
              },
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
              title: "Security & Privacy",
              onTap: () {
                // handle tap
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
              icon: Icons.close, 
              title: "Close Account",
              subtitle: "Close your personal account",
              onTap: () {
                // handle tap
              },
            ),
            //logout
            ProfileOptionTile(
              icon: Icons.logout_outlined,
              title: "Logout",
              onTap: () {
                // handle tap
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

// ✅ Build Profile Image
Widget _buildProfileImage(ApiService apiService) {
  if (apiService.selectedImage != null) {
    return Image.file(apiService.selectedImage!, fit: BoxFit.cover);
  } else if (apiService.profileImageUrl != null &&
      apiService.profileImageUrl!.isNotEmpty) {
    if (apiService.profileImageUrl!.startsWith("data:image")) {
      try {
        String base64String = apiService.profileImageUrl!.split(",")[1];
        Uint8List imageBytes = base64Decode(base64String);

        return Image.memory(
          imageBytes,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            print("❌ Image Load Error: $error");
            return Image.asset("assets/images/default_user.png",
                fit: BoxFit.cover);
          },
        );
      } catch (e) {
        print("❌ Error decoding Base64 image: $e");
        return Image.asset("assets/images/default_user.png", fit: BoxFit.cover);
      }
    }

    // Otherwise, it's a normal URL
    return Image.network(
      apiService.profileImageUrl!,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        print("❌ Image Load Error: $error");
        return Image.asset("assets/images/default_user.png", fit: BoxFit.cover);
      },
    );
  } else {
    return Image.asset("assets/images/default_user.png", fit: BoxFit.cover);
  }
}

// ✅ Original _profileOption (3 parameters)
Widget _profileOption(IconData icon, String title, BuildContext context) {
  return ListTile(
    leading: Icon(icon, color: Colors.black87),
    title: Text(
      title,
      style:
          TextStyle(fontSize: 16, color: Colors.black, fontFamily: "Poppins"),
    ),
    trailing: Icon(Icons.arrow_forward_ios, color: Colors.black),
    onTap: () {},
  );
}

// ✅ OPTIONAL: The new function with subtitles, renamed to avoid conflicts
//    Use this if you want a bold title + grey subtitle. No lines removed, just placed at the end.
Widget _profileOptionWithSubtitle(
  IconData icon,
  String title,
  String subtitle,
  BuildContext context,
) {
  return ListTile(
    leading: Icon(icon, color: Colors.black87),
    title: Text(
      title,
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: Colors.black,
        fontFamily: "Poppins",
      ),
    ),
    subtitle: Text(
      subtitle,
      style: TextStyle(
        fontSize: 12,
        color: Colors.grey[200],
        fontFamily: "Poppins",
      ),
    ),
    trailing: Icon(Icons.arrow_forward_ios, color: Colors.black),
    onTap: () {
      // Handle onTap
    },
  );
}

// ✅ Logout Button
Widget _logoutOption(BuildContext context, double screenHeight) {
  return ListTile(
    leading: Icon(Icons.logout, color: Colors.red),
    title: Text(
      "Logout",
      style: TextStyle(fontSize: 16, color: Colors.red, fontFamily: "Poppins"),
    ),
    onTap: () async {
      await ApiService.logout(context);
    },
  );
}

// ✅ Delete Account Button
Widget _deleteAccountOption(BuildContext context, double screenHeight) {
  return ListTile(
    leading: Icon(Icons.delete_forever, color: Colors.red),
    title: Text(
      "Delete Account",
      style: TextStyle(fontSize: 16, color: Colors.red, fontFamily: "Poppins"),
    ),
    onTap: () => _showDeleteConfirmationDialog(context),
  );
}

// ✅ Delete Account Confirmation Dialog
void _showDeleteConfirmationDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text("Delete Account"),
        content: Text(
          "Are you sure you want to delete your account? This action is irreversible.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel", style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () async {
              final apiService =
                  Provider.of<ApiService>(context, listen: false);
              bool success = await apiService.deleteUser(context);

              if (success) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => LoginPage()),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Failed to delete account.")),
                );
              }
            },
            child: Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      );
    },
  );
}
