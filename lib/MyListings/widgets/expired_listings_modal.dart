// 📄 expired_listings_modal.dart

import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:adventura/services/activity_service.dart';
import 'package:hive/hive.dart';
import 'package:adventura/config.dart';

Future<void> showExpiredListingsModal(BuildContext context) async {
  final box = await Hive.openBox('authBox');
  final providerId = int.tryParse(box.get("providerId").toString());

  if (providerId == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("⚠️ Provider ID not found")),
    );
    return;
  }

  final expiredListings =
      await ActivityService.fetchExpiredListings(providerId);

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withOpacity(0.25),
    isDismissible: true,
    enableDrag: true,
    builder: (context) {
      return GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => Navigator.of(context).pop(),
        child: GestureDetector(
          onTap: () {}, // Absorb tap events
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 15.0, sigmaY: 15.0),
            child: Align(
              alignment: Alignment.bottomCenter,
              child: FractionallySizedBox(
                heightFactor: 0.55,
                widthFactor: 0.95,
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? const Color(0xFF1E1E1E).withOpacity(0.95)
                        : Colors.white.withOpacity(0.95),
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(24)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blue.withOpacity(0.2),
                        blurRadius: 20,
                        spreadRadius: 2,
                        offset: const Offset(0, -2),
                      ),
                    ],
                  ),
                  child: DefaultTabController(
                    length: 2,
                    child: Column(
                      children: [
                        const SizedBox(height: 12),
                        Container(
  width: 40,
  height: 4,
  margin: const EdgeInsets.only(top: 8, bottom: 12),
  decoration: BoxDecoration(
    color: Colors.grey.shade400,
    borderRadius: BorderRadius.circular(4),
  ),
),

                        TabBar(
  indicator: BoxDecoration(
    borderRadius: BorderRadius.circular(30),
    color: Colors.blue.withOpacity(0.15),
  ),
  labelColor: Colors.blue,
  unselectedLabelColor:
      Theme.of(context).brightness == Brightness.dark
          ? Colors.white70
          : Colors.grey.shade600,
  labelStyle: const TextStyle(
    fontWeight: FontWeight.w600,
    fontFamily: 'Poppins',
  ),
  tabs: const [
    Tab(child: Padding(
      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Text("One-Time"),
    )),
    Tab(child: Padding(
      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Text("Recurrent"),
    )),
  ],
),

                        Expanded(
                          child: TabBarView(
                            children: [
                              _buildExpiredList(
                                  context, expiredListings["oneTime"]),
                              _buildExpiredList(
                                  context, expiredListings["recurrent"]),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    },
  );
}

Widget _buildExpiredList(BuildContext context, List<dynamic>? listings) {
  if (listings == null || listings.isEmpty) {
    return const Center(child: Text("No expired listings found."));
  }

  return ListView.separated(
    padding: const EdgeInsets.all(16),
    itemCount: listings.length,
    separatorBuilder: (_, __) => const SizedBox(height: 12),
    itemBuilder: (context, index) {
      final activity = listings[index];
      final imageUrl = activity["activity_images"]?.isNotEmpty == true
          ? "$baseUrl${activity["activity_images"][0]["image_url"]}"
          : null;

      return Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 2,
        child: ListTile(
          contentPadding: const EdgeInsets.all(12),
          leading: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: imageUrl != null
                ? Image.network(
                    imageUrl,
                    width: 64,
                    height: 64,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Image.asset(
                      "assets/Pictures/island.jpg",
                      width: 64,
                      height: 64,
                      fit: BoxFit.cover,
                    ),
                  )
                : Image.asset(
                    "assets/Pictures/island.jpg",
                    width: 64,
                    height: 64,
                    fit: BoxFit.cover,
                  ),
          ),
          title: Text(
            activity["name"] ?? "Unnamed",
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          subtitle: Text(
            activity["listing_type"] == "oneTime"
                ? "Expired • ${activity["location"] ?? 'Unknown'}"
                : "Archived • ${activity["location"] ?? 'Unknown'}",
            style: TextStyle(color: Colors.grey.shade600),
          ),
        ),
      );
    },
  );
}
