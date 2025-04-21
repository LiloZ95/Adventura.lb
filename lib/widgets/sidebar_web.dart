import 'package:flutter/material.dart';
import 'package:adventura/colors.dart';
import 'package:hive/hive.dart';
import 'dart:typed_data';

class SidebarWidget extends StatelessWidget {
  final String userId;
  final VoidCallback onClose;
  final bool isProvider;

  const SidebarWidget({
    Key? key,
    required this.userId,
    required this.onClose,
    required this.isProvider,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Colors.black.withOpacity(0.5),
      child: Row(
        children: [
          Container(
            width: 300,
            height: double.infinity,
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 32),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Menu",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Poppins',
                      ),
                    ),
                    IconButton(
                      onPressed: onClose,
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                FutureBuilder(
                  future: Hive.openBox('authBox'),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.done) {
                      Box box = Hive.box('authBox');
                      Uint8List? userBytes = box.get('profileImageBytes_$userId');
                      ImageProvider<Object> imageProvider;
                      String firstName = box.get('firstName') ?? '';
                      String lastName = box.get('lastName') ?? '';

                      if (userBytes != null) {
                        imageProvider = MemoryImage(userBytes);
                      } else {
                        imageProvider = const AssetImage("assets/images/default_user.png");
                      }

                      return Row(
                        children: [
                          CircleAvatar(
                            radius: 30,
                            backgroundColor: Colors.grey.shade300,
                            backgroundImage: imageProvider,
                          ),
                          const SizedBox(width: 16),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "$firstName $lastName",
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Poppins',
                                ),
                              ),
                              Text(
                                isProvider ? "Provider" : "Explorer",
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey.shade600,
                                  fontFamily: 'Poppins',
                                ),
                              ),
                            ],
                          ),
                        ],
                      );
                    }
                    return const CircularProgressIndicator();
                  },
                ),
                const SizedBox(height: 32),
                _buildMenuItem(Icons.home, "Home", AppColors.blue),
                _buildMenuItem(Icons.search, "Discover", Colors.grey.shade700),
                _buildMenuItem(Icons.confirmation_number_outlined, "My Bookings", Colors.grey.shade700),
                _buildMenuItem(Icons.bookmark_border, "Saved", Colors.grey.shade700),
                _buildMenuItem(Icons.send_outlined, "Messages", Colors.grey.shade700),
                if (isProvider) ...[
                  const Divider(height: 32),
                  _buildMenuItem(Icons.qr_code_scanner, "Scan Tickets", Colors.grey.shade700),
                  _buildMenuItem(Icons.add_circle_outline, "Create Activity", Colors.grey.shade700),
                  _buildMenuItem(Icons.bar_chart, "Analytics", Colors.grey.shade700),
                ],
                const Spacer(),
                _buildMenuItem(Icons.settings, "Settings", Colors.grey.shade700),
                _buildMenuItem(Icons.help_outline, "Help", Colors.grey.shade700),
                _buildMenuItem(Icons.logout, "Logout", Colors.grey.shade700),
              ],
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: onClose,
              child: Container(
                color: Colors.transparent,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(IconData icon, String title, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 16),
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              color: color,
              fontFamily: 'Poppins',
            ),
          ),
        ],
      ),
    );
  }
}