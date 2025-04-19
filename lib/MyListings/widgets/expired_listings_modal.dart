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
    backgroundColor: Colors.transparent, // key for blur to work
    barrierColor: Colors.black.withOpacity(0.25),
    builder: (context) {
      return BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15.0, sigmaY: 15.0),
        child: Center(
          // Use Center to apply widthFactor correctly
          child: FractionallySizedBox(
            heightFactor: 0.65,
            widthFactor: 0.95,
            child: Material(
              color: Colors.white.withOpacity(0.95),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(24)),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Text(
                        "Expired Listings",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (expiredListings.isEmpty)
                      Expanded(
                        child: Center(
                          child: Text(
                            "No expired listings found.",
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ),
                      )
                    else
                      Expanded(
                        child: ListView.separated(
                          itemCount: expiredListings.length,
                          separatorBuilder: (_, __) => SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final activity = expiredListings[index];
                            final imageUrl = activity["activity_images"]
                                        ?.isNotEmpty ==
                                    true
                                ? "$baseUrl${activity["activity_images"][0]["image_url"]}"
                                : null;

                            return Card(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 2,
                              child: ListTile(
                                contentPadding: const EdgeInsets.all(12),
                                leading: SizedBox(
                                  width: 64,
                                  height: 64,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: imageUrl != null
                                        ? Image.network(
                                            imageUrl,
                                            width: 64,
                                            height: 64,
                                            fit: BoxFit.cover,
                                            errorBuilder:
                                                (context, error, stackTrace) {
                                              return Image.asset(
                                                "assets/Pictures/island.jpg",
                                                width: 64,
                                                height: 64,
                                                fit: BoxFit.cover,
                                              );
                                            },
                                          )
                                        : Image.asset(
                                            "assets/Pictures/island.jpg",
                                            width: 64,
                                            height: 64,
                                            fit: BoxFit.cover,
                                          ),
                                  ),
                                ),
                                title: Text(
                                  activity["name"] ?? "Unnamed",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                subtitle: Text(
                                  (activity["listing_type"] == "oneTime" &&
                                          DateTime.tryParse(
                                                      activity["to_time"] ?? "")
                                                  ?.isBefore(DateTime.now()) ==
                                              true)
                                      ? "Expired • ${activity["location"] ?? 'Unknown location'}"
                                      : "Deleted • ${activity["location"] ?? 'Unknown location'}",
                                  style: TextStyle(color: Colors.grey.shade600),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    },
  );
}
