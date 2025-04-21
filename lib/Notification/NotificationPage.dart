import 'package:adventura/Services/NotificationService.dart';
import 'package:adventura/colors.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({Key? key}) : super(key: key);

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  List<Map<String, dynamic>> notifications = [];
  bool isLoading = true;
  
  // To store organized notifications
  Map<String, List<Map<String, dynamic>>> groupedNotifications = {};

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
      final universalNotifs = await NotificationService.fetchUniversalNotifications();

      // Merge and sort all notifications by created_at
      final allNotifications = [...userNotifs, ...universalNotifs];

      allNotifications.sort((a, b) {
        final dateA = DateTime.tryParse(a["created_at"] ?? "") ?? DateTime.now();
        final dateB = DateTime.tryParse(b["created_at"] ?? "") ?? DateTime.now();
        return dateB.compareTo(dateA); // Most recent first
      });

      // Group notifications by date
      _organizeNotifications(allNotifications);

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

  void _organizeNotifications(List<Map<String, dynamic>> allNotifications) {
    groupedNotifications = {};
    
    final today = DateTime.now();
    final yesterday = today.subtract(const Duration(days: 1));
    
    for (var notification in allNotifications) {
      String dateStr = notification["created_at"] ?? "";
      DateTime? notifDate = DateTime.tryParse(dateStr);
      
      if (notifDate == null) continue;
      
      String key;
      
      if (isSameDay(notifDate, today)) {
        key = "Today";
      } else if (isSameDay(notifDate, yesterday)) {
        key = "Yesterday";
      } else {
        // Format as "April 18, 2025" for other dates
        key = DateFormat('MMMM d, yyyy').format(notifDate);
      }
      
      if (!groupedNotifications.containsKey(key)) {
        groupedNotifications[key] = [];
      }
      
      groupedNotifications[key]!.add(notification);
    }
  }
  
  bool isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year && 
           date1.month == date2.month && 
           date1.day == date2.day;
  }

  String formatDate(String timestamp) {
    try {
      final date = DateTime.parse(timestamp);
      return DateFormat('hh:mm a').format(date); // Simplified to just time
    } catch (e) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isWeb = kIsWeb;
    final screenWidth = MediaQuery.of(context).size.width;
    
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Enhanced Header
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: 16.0, 
                vertical: isWeb ? 20.0 : 16.0
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: isWeb ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4)
                  )
                ] : null,
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(
                      isWeb ? Icons.arrow_back : Icons.arrow_back_ios_new, 
                      color: Colors.black
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        "Notifications",
                        style: TextStyle(
                          fontSize: isWeb ? 26 : 24,
                          fontWeight: FontWeight.bold,
                          fontFamily: "Poppins",
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 48), // Balance the layout
                ],
              ),
            ),
            
            // Notifications Content
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : notifications.isEmpty
                      ? const Center(
                          child: Text(
                            "No notifications yet.",
                            style: TextStyle(fontFamily: "Poppins"),
                          ),
                        )
                      : isWeb
                          ? _buildWebLayout(screenWidth)
                          : _buildMobileLayout(),
            ),
          ],
        ),
      ),
    );
  }

  // Web-optimized layout
  Widget _buildWebLayout(double screenWidth) {
        int columns = screenWidth > 1400 ? 3 : (screenWidth > 900 ? 2 : 1);
    
    return Container(
      width: double.infinity,
      color: Colors.grey.shade50,
      padding: const EdgeInsets.all(24.0),
      child: ListView.builder(
        itemCount: groupedNotifications.length,
        itemBuilder: (context, sectionIndex) {
          String dateSection = groupedNotifications.keys.elementAt(sectionIndex);
          List<Map<String, dynamic>> sectionNotifications = groupedNotifications[dateSection]!;
          
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle(dateSection),
              const SizedBox(height: 16),
              
              // Grid layout for notifications
              GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: columns,
                  childAspectRatio: 4.0,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemCount: sectionNotifications.length,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  return _buildWebNotificationItem(sectionNotifications[index]);
                },
              ),
              
              const SizedBox(height: 32),
            ],
          );
        },
      ),
    );
  }

  Widget _buildMobileLayout() {
    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: groupedNotifications.length,
      itemBuilder: (context, sectionIndex) {
        String dateSection = groupedNotifications.keys.elementAt(sectionIndex);
        List<Map<String, dynamic>> sectionNotifications = groupedNotifications[dateSection]!;
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle(dateSection),
            const SizedBox(height: 12),
            
            ...sectionNotifications.map((notification) => 
              _buildMobileNotificationItem(notification)
            ).toList(),
            
            const SizedBox(height: 24),
          ],
        );
      },
    );
  }

  // Web notification item
  Widget _buildWebNotificationItem(Map<String, dynamic> notification) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            spreadRadius: 1,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {},
          splashColor: AppColors.mainBlue,
          highlightColor: AppColors.mainBlue,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Circular Icon with improved styling
                Container(
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(
                    color: _getNotificationColor(notification["icon"]),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: _getNotificationColor(notification["icon"]).withOpacity(0.3),
                        blurRadius: 8,
                        spreadRadius: 0,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Icon(
                    _getNotificationIcon(notification["icon"]),
                    color: Colors.white,
                    size: 26
                  ),
                ),
                const SizedBox(width: 18),

                // Notification Text
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        notification["title"] ?? '',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 17,
                          fontFamily: "Poppins",
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        notification["description"] ?? '',
                        style: const TextStyle(
                          fontSize: 15, 
                          fontFamily: "Poppins", 
                          color: Colors.black54
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        formatDate(notification["created_at"] ?? ''),
                        style: const TextStyle(
                          fontSize: 12,
                          fontFamily: "Poppins",
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Arrow icon
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  padding: const EdgeInsets.all(8),
                  child: Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.grey.shade600,
                    size: 18,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Mobile notification item
  Widget _buildMobileNotificationItem(Map<String, dynamic> notification) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        children: [
          Row(
            children: [
              // Circular Icon with subtle shadow
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: _getNotificationColor(notification["icon"]),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: _getNotificationColor(notification["icon"]).withOpacity(0.2),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(
                  _getNotificationIcon(notification["icon"]),
                  color: Colors.white,
                  size: 24
                ),
              ),
              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      notification["title"] ?? '',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        fontFamily: "Poppins",
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      notification["description"] ?? '',
                      style: const TextStyle(
                        fontSize: 14,
                        fontFamily: "Poppins",
                        color: Colors.black54
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      formatDate(notification["created_at"] ?? ''),
                      style: const TextStyle(
                        fontSize: 12,
                        fontFamily: "Poppins",
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Enhanced divider with gradient
          Container(
            height: 1.5,
            margin: const EdgeInsets.only(left: 30, right: 16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.grey.shade300.withOpacity(0.1),
                  Colors.grey.shade300,
                  Colors.grey.shade300,
                  Colors.grey.shade300.withOpacity(0.1),
                ],
                stops: const [0.0, 0.2, 0.8, 1.0],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Section Title Widget with enhanced styling
  Widget _buildSectionTitle(String title) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 20,
          decoration: BoxDecoration(
            color: AppColors.mainBlue,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: kIsWeb ? 20 : 18,
            fontWeight: FontWeight.bold,
            fontFamily: "Poppins",
            color: Colors.black87,
            letterSpacing: 0.5,
          ),
        ),
      ],
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
      case 'deal':
      case 'offer':
        return const Color(0xFFFF9800); // Orange
      default:
        return AppColors.mainBlue; // Default purple
    }
  }
}