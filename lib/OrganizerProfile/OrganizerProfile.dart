import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:adventura/event_cards/Cards.dart';
import 'package:share_plus/share_plus.dart';

class OrganizerProfilePage extends StatefulWidget {
  final String organizerId;
  final String organizerName;
  final String organizerImage;
  final String bio;
  final List activities;

  const OrganizerProfilePage({
    Key? key,
    required this.organizerId,
    required this.organizerName,
    required this.organizerImage,
    required this.bio,
    required this.activities,
  }) : super(key: key);

  @override
  State<OrganizerProfilePage> createState() => _OrganizerProfilePageState();
}

class _OrganizerProfilePageState extends State<OrganizerProfilePage> {
  bool isFollowing = false;
  int followersCount = 0;

  @override
  void initState() {
    super.initState();
    followersCount = 0; // You can replace this with a backend value
  }

  void toggleFollow() {
    setState(() {
      isFollowing = !isFollowing;
      followersCount += isFollowing ? 1 : -1;
    });
  }

  void shareOrganizer() {
    final shareText = 'Check out ${widget.organizerName} on Adventura! 🌍\n'
        '👉 https://adventura.app/organizer/${widget.organizerId}';
    Share.share(shareText);
  }

  void onMoreOptionSelected(int value) {
    switch (value) {
      case 0:
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Notifications enabled")),
        );
        break;
      case 1:
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Report sent")),
        );
        break;
      case 2:
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Organizer blocked")),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeColor = Colors.blueAccent;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.4,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Organizer Profile",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w600,
            fontFamily: 'Poppins',
          ),
        ),
        centerTitle: true,
        actions: [
          PopupMenuButton<int>(
            icon: const Icon(LucideIcons.moreVertical, color: Colors.black),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            onSelected: onMoreOptionSelected,
            itemBuilder: (context) => [
              PopupMenuItem(
                
                value: 0,
                child: Row(
                  children: const [
                    
                    Icon(Icons.notifications_active, color: Colors.blue, size: 20),
                    SizedBox(width: 10),
                    Text("Allow Notifications",
                    style: TextStyle(fontFamily: "poppins"),),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 1,
                child: Row(
                  children: const [
                    Icon(Icons.flag, color: Colors.blue, size: 20),
                    SizedBox(width: 10),
                    Text("Report",
                    style: TextStyle(fontFamily: "poppins"),),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 2,
                child: Row(
                  children: const [
                    Icon(Icons.block, color: Colors.blue, size: 20),
                    SizedBox(width: 10),
                    Text("Block Organizer",
                    style: TextStyle(fontFamily: "poppins"),),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Column(
            children: [
              // Profile Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 45,
                      backgroundColor: Colors.grey[200],
                      backgroundImage: widget.organizerImage.isNotEmpty
                          ? NetworkImage(widget.organizerImage)
                          : const AssetImage("assets/images/default_user.png") as ImageProvider,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      widget.organizerName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        fontFamily: 'Poppins',
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.bio,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                        fontFamily: 'Poppins',
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildStat("Events", widget.activities.length.toString()),
                        Container(
                          width: 1,
                          height: 24,
                          color: Colors.grey[300],
                          margin: const EdgeInsets.symmetric(horizontal: 24),
                        ),
                        _buildStat("Followers", followersCount.toString()),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: toggleFollow,
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              backgroundColor: isFollowing ? Colors.grey[300] : themeColor,
                              foregroundColor: isFollowing ? Colors.black : Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              elevation: 1,
                            ),
                            child: Text(
                              isFollowing ? "Following" : "Follow",
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 15,
                                fontFamily: 'Poppins',
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton(
                            onPressed: shareOrganizer,
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              side: BorderSide(color: themeColor),
                              foregroundColor: themeColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: const Text(
                              "Share",
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 15,
                                fontFamily: 'Poppins',
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Upcoming Events
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Upcoming Events",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Poppins',
                  ),
                ),
              ),
              const SizedBox(height: 16),
              ListView.builder(
                itemCount: widget.activities.length,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  final activity = widget.activities[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: EventCard(context: context, activity: activity),
                  );
                },
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStat(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            fontFamily: 'Poppins',
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            color: Colors.grey,
            fontFamily: 'Poppins',
          ),
        ),
      ],
    );
  }
}
