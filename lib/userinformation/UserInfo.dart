import 'package:adventura/login/login.dart';
import 'package:flutter/material.dart';
import 'package:adventura/Services/api_service.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import 'dart:typed_data';

class UserInfo extends StatefulWidget {
  @override
  _UserInfoState createState() => _UserInfoState();
}

class _UserInfoState extends State<UserInfo> {
  @override
  void initState() {
    super.initState();
    // ✅ Call loadUserProfile() from ApiService
    Future.microtask(() async {
    final apiService = Provider.of<ApiService>(context, listen: false);
    await apiService.getUserId(); // ✅ Ensure userId is loaded on startup
  });
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
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: screenHeight * 0.02),

            // ✅ Profile Picture Section
            Consumer<ApiService>(
  builder: (context, apiService, child) {
    String userId = apiService.userId ?? ""; // ✅ Get logged-in user ID

    return GestureDetector(
      onTap: () async {
        String userId = apiService.userId ?? ""; // ✅ Get logged-in user ID
        if (userId.isNotEmpty) {
          await apiService.pickImage(context, userId);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("❌ User ID is missing!"), backgroundColor: Colors.red),
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
              borderRadius: BorderRadius.circular(50), // ✅ Ensure circular shape
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
          // ✅ Show Error Message if Image is Too Large
          // if (apiService.errorMessage != null)
          //   Padding(
          //     padding: const EdgeInsets.only(top: 8.0),
          //     child: Text(
          //       apiService.errorMessage!,
          //       style: TextStyle(color: Colors.red, fontSize: 14),
          //     ),
          //   ),
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
                  apiService.fullName.isNotEmpty
                      ? apiService.fullName
                      : "User Name", // ✅ Show full name
                  style: TextStyle(
                    fontSize: screenHeight * 0.025,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                    fontFamily: "Poppins",
                  ),
                );
              },
            ),

            SizedBox(height: screenHeight * 0.02),

            // ✅ Grey Divider
            Padding(
              padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
              child: Divider(thickness: 1, color: Colors.grey[300]),
            ),

            // ✅ Profile Options
            _profileOption(Icons.bookmark_border, "My Bookings", context),
            _profileOption(Icons.credit_card, "My Cards", context),
            _profileOption(Icons.settings, "Settings", context),
            _profileOption(Icons.lock, "Privacy Policy", context),
            _profileOption(Icons.description, "Terms & Conditions", context),

            SizedBox(height: screenHeight * 0.02),

            // ✅ Logout & Delete Account Buttons
            _logoutOption(context, screenHeight),
            _deleteAccountOption(context, screenHeight),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileImage(ApiService apiService) {
  if (apiService.selectedImage != null) {
    return Image.file(apiService.selectedImage!, fit: BoxFit.cover);
  } 
  else if (apiService.profileImageUrl != null &&
      apiService.profileImageUrl!.isNotEmpty) {
    
    // ✅ Check if the response contains Base64 data
    if (apiService.profileImageUrl!.startsWith("data:image")) {
      try {
        String base64String = apiService.profileImageUrl!.split(",")[1]; // ✅ Extract base64 part
        Uint8List imageBytes = base64Decode(base64String); // ✅ Convert to bytes

        return Image.memory(
          imageBytes,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            print("❌ Image Load Error: $error");
            return Image.asset("assets/images/default_user.png", fit: BoxFit.cover);
          },
        );
      } catch (e) {
        print("❌ Error decoding Base64 image: $e");
        return Image.asset("assets/images/default_user.png", fit: BoxFit.cover);
      }
    } 
    
    // ✅ Otherwise, it's a normal URL
    return Image.network(
      apiService.profileImageUrl!,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        print("❌ Image Load Error: $error");
        return Image.asset("assets/images/default_user.png", fit: BoxFit.cover);
      },
    );
  } 
  else {
    return Image.asset("assets/images/default_user.png", fit: BoxFit.cover);
  }
}


  // ✅ Profile Option Tile
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

  // ✅ Logout Button
  Widget _logoutOption(BuildContext context, double screenHeight) {
    return ListTile(
      leading: Icon(Icons.logout, color: Colors.red),
      title: Text(
        "Logout",
        style:
            TextStyle(fontSize: 16, color: Colors.red, fontFamily: "Poppins"),
      ),
      onTap: () async {
        await Provider.of<ApiService>(context, listen: false).logout();
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("Logged out.")));
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => LoginPage()));
      },
    );
  }

  // ✅ Delete Account Button
  Widget _deleteAccountOption(BuildContext context, double screenHeight) {
    return ListTile(
      leading: Icon(Icons.delete_forever, color: Colors.red),
      title: Text(
        "Delete Account",
        style:
            TextStyle(fontSize: 16, color: Colors.red, fontFamily: "Poppins"),
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
              "Are you sure you want to delete your account? This action is irreversible."),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancel", style: TextStyle(color: Colors.grey)),
            ),
            TextButton(
              onPressed: () async {
                final apiService =
                    Provider.of<ApiService>(context, listen: false);
                bool success =
                    await apiService.deleteUser(); // ✅ No argument needed now

                if (success) {
                  Navigator.pushReplacement(context,
                      MaterialPageRoute(builder: (context) => LoginPage()));
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
}
