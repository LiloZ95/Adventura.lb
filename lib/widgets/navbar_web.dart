import 'package:adventura/Chatbot/chatBot.dart';
import 'package:adventura/Notification/NotificationPage.dart';
import 'package:adventura/userinformation/UserInfo.dart';
import 'package:adventura/userinformation/widgets/theme_controller.dart';
import 'package:flutter/material.dart';
import 'package:adventura/colors.dart';
import 'package:adventura/components/customdropdown.dart';
import 'package:hive/hive.dart';
import 'dart:typed_data';
import 'package:blurrycontainer/blurrycontainer.dart';
import 'package:provider/provider.dart';

class NavbarWidget extends StatelessWidget {
  final String firstName;
  final String userId;
  final VoidCallback onMenuTap;
  final String selectedLocation;
  final Function(String) onLocationChanged;
  final int selectedIndex;
  final Function(int) onTapNavItem;
  final bool isTransparent; // New parameter to control transparency

  const NavbarWidget({
    Key? key,
    required this.firstName,
    required this.userId,
    required this.onMenuTap,
    required this.selectedLocation,
    required this.onLocationChanged,
    required this.selectedIndex,
    required this.onTapNavItem,
    this.isTransparent = false, // Default to standard navbar
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final bool isMobile = screenWidth < 768;

    // If transparent mode is enabled, use a different container style
    if (isTransparent) {
      return BlurryContainer(
        blur: 10,
        elevation: 0,
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.zero,
        padding: EdgeInsets.zero,
        child: Container(
          height: 80,
          padding: EdgeInsets.symmetric(horizontal: isMobile ? 16 : 32),
          child: _buildNavbarContent(context, isMobile, true),
        ),
      );
    }

    // Standard navbar with white background
    return Container(
      height: 80,
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 16 : 32),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: _buildNavbarContent(context, isMobile, false),
    );
  }

  // Extracted common content builder with transparency parameter
  Widget _buildNavbarContent(BuildContext context, bool isMobile, bool isTransparent) {
    // Text color based on transparency mode
    final Color textColor = isTransparent ? Colors.white : Colors.grey.shade700;
    final Color selectedTextColor = isTransparent ? Colors.white : AppColors.mainBlue;
    final Color? iconColor = isTransparent ? Colors.white : null;
    
    return Row(
      children: [
        // Logo - if transparent, use a version with transparent background if available
        Image.asset(
          'assets/images/MainLogo.png',
          width: 200,
          height: 70,
          fit: BoxFit.cover,
          color: isTransparent ? Colors.white : null,
        ),
        SizedBox(width: 32),
        
        // Location dropdown - adjust colors based on transparency
        if (!isMobile)
          Expanded(
            child: CreativeLocationDropdown(
              selectedLocation: selectedLocation,
              locations: ["Tripoli", "Beirut", "Jbeil", "Jounieh", "Sayda"],
              onLocationChanged: onLocationChanged,
              accentColor: isTransparent ? Colors.white : AppColors.mainBlue,
              width: 200.0,
            ),
          ),
        
        // Nav items with conditional styling
        if (!isMobile) ...[
          _buildNavItem("Home", 0, selectedTextColor, textColor),
          SizedBox(width: 24),
          _buildNavItem("Discover", 1, selectedTextColor, textColor),
          SizedBox(width: 24),
          _buildNavItem("My Bookings", 2, selectedTextColor, textColor),
          SizedBox(width: 24),
          _buildNavItem("Saved", 3, selectedTextColor, textColor),
        ],
        
        Spacer(),
        Row(
          children: [
            if (!isMobile) ...[
              IconButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AdventuraChatPage(userName: '', userId: '')
                    ),
                  );
                },
                icon: Image.asset(
                  'assets/Icons/ai.png',
                  width: 28,
                  height: 28,
                  color: iconColor,
                ),
              ),
              IconButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => NotificationScreen()
                    ),
                  );
                },
                icon: Image.asset(
                  'assets/Icons/bell-Bold.png',
                  width: 24,
                  height: 24,
                  color: iconColor,
                ),
              ),
              SizedBox(width: 16),
            ],
            FutureBuilder(
  future: Hive.openBox('authBox'),
  builder: (context, snapshot) {
    if (snapshot.connectionState == ConnectionState.done) {
      Box box = Hive.box('authBox');
      Uint8List? userBytes = box.get('profileImageBytes_$userId');
      ImageProvider<Object> imageProvider;

      if (userBytes != null) {
        imageProvider = MemoryImage(userBytes);
      } else {
        imageProvider = AssetImage("assets/images/default_user.png");
      }

      // This will be our clickable avatar widget
      Widget avatarWidget = isTransparent
        ? Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
            ),
            child: CircleAvatar(
              radius: 18,
              backgroundColor: Colors.grey.shade300,
              backgroundImage: imageProvider,
            ),
          )
        : CircleAvatar(
            radius: 18,
            backgroundColor: Colors.grey.shade300,
            backgroundImage: imageProvider,
          );

      // Wrap with GestureDetector to handle tap events
      return GestureDetector(
        onTap: () {
      final themeController = Provider.of<ThemeController>(context, listen: false);

// Navigate with the provider
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) =>  UserInfo(),
  
  ),
);
        },
        child: avatarWidget,
      );
    }

    // Loading placeholder with navigation capability
    return GestureDetector(
      onTap: () {
     final themeController = Provider.of<ThemeController>(context, listen: false);

// Navigate with the provider
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) =>  UserInfo(),
    
  ),
);
      },
      child: CircleAvatar(
        radius: 18,
        backgroundColor: Colors.grey.shade300,
        child: Icon(
          Icons.person, 
          color: isTransparent ? Colors.white : Colors.black, 
          size: 24
        ),
      ),
    );
  },
),
            if (isMobile) IconButton(
              onPressed: onMenuTap,
              icon: Icon(
                Icons.menu,
                color: isTransparent ? Colors.white : Colors.black,
              ),
            ),
          ],
        ),
      ],
    );
  }
  
  // Nav item with conditional styling based on transparency
  Widget _buildNavItem(String title, int index, Color selectedColor, Color defaultColor) {
    final bool isSelected = selectedIndex == index;
    
    return TextButton(
      onPressed: () => onTapNavItem(index),
      style: ButtonStyle(
        overlayColor: MaterialStateProperty.all(Colors.transparent),
        padding: MaterialStateProperty.all(
          EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        ),
      ),
      child: Text(
        title,
        style: TextStyle(
          color: isSelected ? selectedColor : defaultColor,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          fontSize: 16,
        ),
      ),
    );
  }
}