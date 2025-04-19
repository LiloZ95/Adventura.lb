

import 'package:adventura/Chatbot/chatBot.dart';
import 'package:adventura/Notification/NotificationPage.dart';
import 'package:flutter/material.dart';
import 'package:adventura/colors.dart';
import 'package:adventura/components/customdropdown.dart';
import 'package:hive/hive.dart';
import 'dart:typed_data';

class NavbarWidget extends StatelessWidget {
  final String firstName;
  final String userId;
  final VoidCallback onMenuTap;
  final String selectedLocation;
  final Function(String) onLocationChanged;
  final int selectedIndex;
  final Function(int) onTapNavItem;

  const NavbarWidget({
    Key? key,
    required this.firstName,
    required this.userId,
    required this.onMenuTap,
    required this.selectedLocation,
    required this.onLocationChanged,
    required this.selectedIndex,
    required this.onTapNavItem,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final bool isMobile = screenWidth < 768;

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
      child: Row(
        children: [
          
          Image.asset(
            'assets/images/MainLogo.png',
            width: 200,
            height: 70,
            fit: BoxFit.cover,
          ),
          SizedBox(width: 32),
          
          
          if (!isMobile)
            Expanded(
              child: CreativeLocationDropdown(
                selectedLocation: selectedLocation,
                locations: ["Tripoli", "Beirut", "Jbeil", "Jounieh", "Sayda"],
                onLocationChanged: onLocationChanged,
                accentColor: AppColors.mainBlue,
                width: 200.0, 
              ),
            ),
          
          
          if (!isMobile) ...[
            _buildNavItem("Home", 0),
            SizedBox(width: 24),
            _buildNavItem("Discover", 1),
            SizedBox(width: 24),
            _buildNavItem("My Bookings", 2),
            SizedBox(width: 24),
            _buildNavItem("Saved", 3),
          ],
          
          
          Spacer(),
          Row(
            children: [
              if (!isMobile) ...[
                IconButton(
                  onPressed: () {   Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AdventuraChatPage()
          ),
        );},
                  icon: Image.asset(
                    'assets/Icons/ai.png',
                    width: 28,
                    height: 28,
                  ),
                ),
                IconButton(
                  onPressed: () {   Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => NotificationScreen()
          ),
        );},
                  icon: Image.asset(
                    'assets/Icons/bell-Bold.png',
                    width: 24,
                    height: 24,
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

                    return CircleAvatar(
                      radius: 18,
                      backgroundColor: Colors.grey.shade300,
                      backgroundImage: imageProvider,
                    );
                  }
                  return CircleAvatar(
                    radius: 18,
                    backgroundColor: Colors.grey.shade300,
                    child: Icon(Icons.person, color: Colors.black, size: 24),
                  );
                },
              ),
              if (isMobile) IconButton(
                onPressed: onMenuTap,
                icon: Icon(Icons.menu),
              ),
            ],
          ),
        ],
      ),
    );
  }

  
  Widget _buildNavItem(String title, int index) {
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
          color: isSelected ? AppColors.mainBlue : Colors.grey.shade700,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          fontSize: 16,
        ),
      ),
    );
  }
}