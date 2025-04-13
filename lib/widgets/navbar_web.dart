// lib/web/widgets/navbar_widget.dart
import 'package:adventura/Notification/NotificationPage.dart';
import 'package:adventura/components/customdropdown.dart';
import 'package:adventura/web/bookingweb.dart';
import 'package:flutter/material.dart';
import 'package:adventura/colors.dart';
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
       required this.selectedIndex, required this.onTapNavItem,
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
          // Logo
          Image.asset(
            'assets/images/MainLogo.png',
            width: 200,
            height: 700,
            fit: BoxFit.cover,
          ),
          SizedBox(width: 32),
          
          // Creative Location dropdown (shown only on desktop)
          if (!isMobile)
            Expanded(
              child: CreativeLocationDropdown(
                selectedLocation: selectedLocation,
                locations: ["Tripoli", "Beirut", "Jbeil", "Jounieh", "Sayda"],
                onLocationChanged: onLocationChanged,
                accentColor: AppColors.mainBlue,
                width: 200.0, // You can adjust this width based on your needs
              ),
            ),
          
          // Navigation links (shown only on desktop)
          if (!isMobile) ...[
            TextButton(
               onPressed: () => onTapNavItem(0),
              child: Text(
                "Home",
                style: TextStyle(
                  color: AppColors.mainBlue,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(width: 24),
            TextButton(
            onPressed: () =>  onTapNavItem(1),
              child: Text(
                "Discover",
                style: TextStyle(
                  color: Colors.grey.shade700,
                ),
              ),
            ),
            SizedBox(width: 24),
            TextButton(
              onPressed: () {},
              child: Text(
                "My Bookings",
                style: TextStyle(
                  color: Colors.grey.shade700,
                ),
              ),
            ),
            SizedBox(width: 24),
            TextButton(
                 onPressed: () => onTapNavItem(2),
              child: Text(
                "Saved",
                style: TextStyle(
                  color: Colors.grey.shade700,
                ),
              ),
            ),
          ],
          
          // Profile section
          Spacer(),
          Row(
            children: [
              if (!isMobile) ...[
                IconButton(
                  onPressed: () {},
                  icon: Image.asset(
                    'assets/Icons/ai.png',
                    width: 28,
                    height: 28,
                  ),
                ),
                IconButton(
                  onPressed: () { Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) =>NotificationScreen()),);},
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
}