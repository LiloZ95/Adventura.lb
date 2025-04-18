import 'package:flutter/material.dart';

class ProfileOptionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback? onTap;
  final bool isDarkMode; // ✅ Receive isDarkMode from parent

  const ProfileOptionTile({
    Key? key,
    required this.icon,
    required this.title,
    this.subtitle,
    required this.onTap,
    required this.isDarkMode, // ✅ Required now
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(
        icon,
        color: isDarkMode ? Colors.white : Colors.black,
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          color: isDarkMode ? Colors.white : Colors.black,
          fontFamily: "Poppins",
          fontWeight: FontWeight.bold,
        ),
      ),
      subtitle: subtitle == null
          ? null
          : Text(
              subtitle!,
              style: TextStyle(
                fontSize: 12,
                color: isDarkMode
                    ? Colors.white.withOpacity(0.8) // ✅ Brighter in dark mode
                    : Colors.grey[700],
                fontFamily: "Poppins",
              ),
            ),
      trailing: Icon(
        Icons.arrow_forward_ios,
        color: isDarkMode ? Colors.white : Colors.black,
        size: 16,
      ),
      onTap: onTap,
    );
  }
}
