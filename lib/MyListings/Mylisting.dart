import 'package:adventura/event_cards/eventDetailsScreen.dart';
import 'package:flutter/material.dart';
import 'package:adventura/services/activity_service.dart';
import 'package:adventura/config.dart';
import 'package:hive/hive.dart';

import 'widgets/expired_listings_modal.dart';

class MyListingsPage extends StatefulWidget {
  @override
  _MyListingsPageState createState() => _MyListingsPageState();
}

class _MyListingsPageState extends State<MyListingsPage> {
  List<Map<String, dynamic>> _myListings = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    loadListings();
  }

  Future<void> loadListings() async {
    final box = await Hive.openBox('authBox');
    final providerIdRaw = box.get("providerId");
    final providerId = int.tryParse(providerIdRaw.toString());

    print("🔍 providerId from Hive: $providerId");

    if (providerId != null) {
      final listings = await ActivityService.fetchProviderListings(providerId);
      setState(() {
        _myListings = listings;
        _loading = false;
      });
    } else {
      print("❌ providerId is null.");
      setState(() => _loading = false);
    }
  }

  Future<void> _confirmAndDelete(int index, String activityId) async {
    final confirmed = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Confirm Delete"),
        content: Text("Are you sure you want to delete this listing?"),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text("Cancel")),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text("Delete")),
        ],
      ),
    );

    if (confirmed == true) {
      final success = await ActivityService.deleteActivity(activityId);
      if (success) {
        // ✅ Re-fetch from server so both UI and modal are up-to-date
        await loadListings(); // re-fetch main active listings
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Listing archived (moved to expired).")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to delete listing.")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "My Listings",
          style: TextStyle(
            fontFamily: "Poppins",
            color: Colors.blue,
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0.5,
      ),
      backgroundColor: const Color(0xFFF6F6F6),
      body: Column(
        children: [
          // 🔹 Expired Listings Button
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
            child: Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: () => showExpiredListingsModal(context),
                icon: Icon(Icons.history, color: Colors.blue.shade600),
                label: Text(
                  "Expired Listings",
                  style: TextStyle(
                    color: Colors.blue.shade600,
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                    fontFamily: 'Poppins',
                  ),
                ),
              ),
            ),
          ),

          // 🔹 Listings content
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _myListings.isEmpty
                    ? const Center(
                        child: Text(
                          "No listings found.",
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _myListings.length,
                        itemBuilder: (context, index) {
                          final activity = _myListings[index];
                          final String activityId =
                              activity["activity_id"].toString();
                          final List<dynamic> imagesRaw =
                              activity["activity_images"] ?? [];
                          final String? imageUrl = imagesRaw.isNotEmpty
                              ? (imagesRaw[0]["image_url"]
                                          ?.toString()
                                          .startsWith("http") ==
                                      true
                                  ? imagesRaw[0]["image_url"]
                                  : "$baseUrl${imagesRaw[0]["image_url"]}")
                              : null;

                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      EventDetailsScreen(activity: activity),
                                ),
                              );
                            },
                            child: TweenAnimationBuilder(
                              tween: Tween<double>(begin: 0.95, end: 1.0),
                              duration:
                                  Duration(milliseconds: 400 + index * 80),
                              curve: Curves.easeOutBack,
                              builder: (context, scale, child) {
                                return Transform.scale(
                                    scale: scale, child: child);
                              },
                              child: Container(
                                margin: const EdgeInsets.only(bottom: 20),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(24),
                                  color: Colors.white,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.05),
                                      blurRadius: 14,
                                      offset: Offset(0, 6),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Stack(
                                      children: [
                                        ClipRRect(
                                          borderRadius:
                                              const BorderRadius.vertical(
                                                  top: Radius.circular(24)),
                                          child: imageUrl != null
                                              ? Image.network(
                                                  imageUrl,
                                                  height: 220,
                                                  width: double.infinity,
                                                  fit: BoxFit.cover,
                                                  errorBuilder: (context, error,
                                                      stackTrace) {
                                                    return Image.asset(
                                                      "assets/Pictures/island.jpg",
                                                      height: 220,
                                                      width: double.infinity,
                                                      fit: BoxFit.cover,
                                                    );
                                                  },
                                                )
                                              : Image.asset(
                                                  "assets/Pictures/island.jpg",
                                                  height: 220,
                                                  width: double.infinity,
                                                  fit: BoxFit.cover,
                                                ),
                                        ),
                                        Positioned(
                                          top: 12,
                                          right: 12,
                                          child: GestureDetector(
                                            onTap: () => _confirmAndDelete(
                                                index, activityId),
                                            child: Container(
                                              padding: const EdgeInsets.all(8),
                                              decoration: BoxDecoration(
                                                color: Colors.white
                                                    .withOpacity(0.85),
                                                shape: BoxShape.circle,
                                              ),
                                              child: const Icon(
                                                  Icons.delete_outline,
                                                  size: 20,
                                                  color: Colors.red),
                                            ),
                                          ),
                                        ),
                                        if ((activity["price"] ?? 0) == 0)
                                          Positioned(
                                            bottom: 12,
                                            left: 12,
                                            child: Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 10,
                                                      vertical: 4),
                                              decoration: BoxDecoration(
                                                color: Colors.green.shade600,
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                              ),
                                              child: const Text(
                                                "Free",
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(16),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            activity["name"] ??
                                                "Unnamed Activity",
                                            style: const TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                          const SizedBox(height: 6),
                                          Row(
                                            children: [
                                              Icon(Icons.location_on,
                                                  size: 16,
                                                  color: Colors.grey.shade500),
                                              const SizedBox(width: 4),
                                              Expanded(
                                                child: Text(
                                                  activity["location"] ??
                                                      "Unknown",
                                                  style: TextStyle(
                                                    color: Colors.grey.shade700,
                                                    fontSize: 14,
                                                  ),
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 10),
                                          Row(
                                            children: [
                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 10,
                                                        vertical: 4),
                                                decoration: BoxDecoration(
                                                  color: Colors.blue.shade50,
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                ),
                                                child: Text(
                                                  activity["price"] != null
                                                      ? "\$${activity["price"]} / person"
                                                      : "Free",
                                                  style: const TextStyle(
                                                    color: Colors.blue,
                                                    fontWeight: FontWeight.w600,
                                                    fontSize: 13,
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 12),
                                              Row(
                                                children: [
                                                  Icon(Icons.timer,
                                                      size: 16,
                                                      color:
                                                          Colors.grey.shade500),
                                                  const SizedBox(width: 4),
                                                  Text(
                                                    "${activity["duration"] ?? 0} mins",
                                                    style: TextStyle(
                                                      color:
                                                          Colors.grey.shade600,
                                                      fontSize: 13,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
