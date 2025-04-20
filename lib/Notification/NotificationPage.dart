import 'package:adventura/Services/NotificationService.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({Key? key}) : super(key: key);

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  List<Map<String, dynamic>> notifications = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    try {
      final box = await Hive.openBox('authBox');
      final userId = box.get('userId');

      final userNotifs = await NotificationService.fetchNotifications(userId);
      final universalNotifs =
          await NotificationService.fetchUniversalNotifications();

      // Merge and sort all notifications by created_at
      final allNotifications = [...userNotifs, ...universalNotifs];

      allNotifications.sort((a, b) {
        final dateA =
            DateTime.tryParse(a["created_at"] ?? "") ?? DateTime.now();
        final dateB =
            DateTime.tryParse(b["created_at"] ?? "") ?? DateTime.now();
        return dateB.compareTo(dateA); // Most recent first
      });

      setState(() {
        notifications = allNotifications;
        isLoading = false;
      });
    } catch (e) {
      print("❌ Error loading notifications: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  String formatDate(String timestamp) {
    try {
      final date = DateTime.parse(timestamp);
      return DateFormat('MMM d, yyyy – hh:mm a').format(date);
    } catch (e) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDarkMode ? const Color(0xFF1F1F1F) : Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
          child: Column(
            children: [
              // Header
              Row(
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.arrow_back_ios_new,
                      color: isDarkMode ? Colors.white : Colors.black,
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        "Notifications",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          fontFamily: "Poppins",
                          color: isDarkMode ? Colors.white : Colors.black,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
              const SizedBox(height: 16),

              // Body
              Expanded(
                child: isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : notifications.isEmpty
                        ? Center(
                            child: Text(
                              "No notifications yet.",
                              style: TextStyle(
                                fontFamily: "Poppins",
                                color: isDarkMode
                                    ? Colors.grey[400]
                                    : Colors.black,
                              ),
                            ),
                          )
                        : ListView.builder(
                            itemCount: notifications.length,
                            itemBuilder: (context, index) {
                              final notification = notifications[index];
                              return _buildNotificationItem(notification);
                            },
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getNotificationIcon(String? type) {
    switch (type) {
      case 'book':
        return Icons.receipt_long;
      case 'cancel':
        return Icons.cancel;
      case 'password':
        return Icons.lock;
      case 'account':
        return Icons.person;
      case 'deal':
        return Icons.local_offer;
      case 'card':
        return Icons.credit_card;
      case 'ticket':
        return Icons.confirmation_num;
      default:
        return Icons.notifications;
    }
  }

  Color _getNotificationColor(String? iconType) {
    switch (iconType) {
      case 'book':
        return const Color(0xFF4CAF50); // Green
      case 'cancel':
        return const Color(0xFFF44336); // Red
      case 'password':
        return const Color(0xFF3F51B5); // Indigo
      case 'account':
        return const Color(0xFF2196F3); // Blue
      case 'offer':
        return const Color(0xFFFF9800); // Orange
      default:
        return const Color.fromARGB(255, 134, 124, 224); // Default purple
    }
  }

  Widget _buildNotificationItem(Map<String, dynamic> notification) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        Row(
          children: [
            // Circular icon
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: _getNotificationColor(notification["icon"]),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _getNotificationIcon(notification["icon"]),
                color: Colors.white,
                size: 24,
              ),
            ),

            const SizedBox(width: 12),

            // Text content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    notification["title"] ?? '',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      fontFamily: "Poppins",
                      color: isDarkMode ? Colors.white : Colors.black,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    notification["description"] ?? '',
                    style: TextStyle(
                      fontSize: 14,
                      fontFamily: "Poppins",
                      color: isDarkMode ? Colors.grey[300] : Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    formatDate(notification["created_at"] ?? ''),
                    style: TextStyle(
                      fontSize: 12,
                      fontFamily: "Poppins",
                      color: isDarkMode ? Colors.grey[500] : Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          height: 2,
          color: isDarkMode ? Colors.grey[700] : Colors.grey[300],
          margin: const EdgeInsets.only(left: 30, right: 16),
        ),
        const SizedBox(height: 10),
      ],
    );
  }
}
