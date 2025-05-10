import 'dart:convert';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:adventura/config.dart';

import '../widgets/bouncing_dots_loader.dart';

Future<void> showFollowersListModal(
    BuildContext context, String organizerId) async {
  List followers = [];
  List filteredFollowers = [];
  bool isLoading = true;
  final isDarkMode = Theme.of(context).brightness == Brightness.dark;

  await showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withOpacity(0.25),
    isDismissible: true,
    enableDrag: true,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          Future<void> fetchFollowers() async {
            try {
              final response = await http
                  .get(Uri.parse('$baseUrl/followers/list/$organizerId'));

              if (response.statusCode == 200) {
                final decoded = jsonDecode(response.body);
                if (decoded is Map<String, dynamic> &&
                    decoded['followers'] is List) {
                  setState(() {
                    followers = decoded['followers'];
                    filteredFollowers = decoded['followers'];
                    isLoading = false;
                  });
                } else {
                  print("❌ Unexpected JSON structure: $decoded");
                  setState(() => isLoading = false);
                }
              } else {
                print("❌ HTTP ${response.statusCode}: ${response.body}");
                setState(() => isLoading = false);
              }
            } catch (e) {
              print("❌ Exception during fetchFollowers: $e");
              setState(() => isLoading = false);
            }
          }

          if (isLoading) {
            fetchFollowers();
          }

          void searchFollowers(String query) {
            final results = followers.where((follower) {
              final fullName =
                  "${follower['firstName']} ${follower['lastName']}"
                      .toLowerCase();
              return fullName.contains(query.toLowerCase());
            }).toList();

            setState(() {
              filteredFollowers = results;
            });
          }

          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => Navigator.of(context).pop(),
            child: GestureDetector(
              onTap: () {}, // Absorb tap inside modal
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: FractionallySizedBox(
                    heightFactor: 0.7,
                    widthFactor: 0.95,
                    child: Material(
                      color: isDarkMode
                          ? const Color(0xFF1E1E1E).withOpacity(0.95)
                          : Colors.white.withOpacity(0.95),
                      borderRadius:
                          const BorderRadius.vertical(top: Radius.circular(24)),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Center(
                              child: Container(
                                width: 40,
                                height: 5,
                                margin: const EdgeInsets.only(bottom: 12),
                                decoration: BoxDecoration(
                                  color: Colors.grey[500],
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                            TextField(
                              onChanged: searchFollowers,
                              decoration: InputDecoration(
                                hintText: 'Search followers...',
                                prefixIcon: const Icon(Icons.search),
                                filled: true,
                                fillColor: isDarkMode
                                    ? Colors.grey[900]
                                    : Colors.grey[100],
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            isLoading
                                ? const Expanded(
                                    child: Center(
                                      child: BouncingDotsLoader(
                                        color:
                                            Colors.blueAccent, // or theme color
                                        size: 12.0,
                                      ),
                                    ),
                                  )
                                : filteredFollowers.isEmpty
                                    ? const Expanded(
                                        child: Center(
                                          child: Text(
                                            "No followers found.",
                                            style: TextStyle(
                                                fontFamily: 'Poppins'),
                                          ),
                                        ),
                                      )
                                    : Expanded(
                                        child: ListView.separated(
                                          itemCount: filteredFollowers.length,
                                          separatorBuilder: (_, __) =>
                                              const SizedBox(height: 12),
                                          itemBuilder: (context, index) {
                                            final follower =
                                                filteredFollowers[index];
                                            final profilePicture =
                                                follower['profilePicture'];
                                            final profileUrl =
                                                profilePicture is String
                                                    ? profilePicture
                                                    : (profilePicture?['url'] ??
                                                        '');
                                            return ListTile(
                                              leading: CircleAvatar(
                                                backgroundColor:
                                                    Colors.transparent,
                                                backgroundImage: (profileUrl
                                                        .isNotEmpty)
                                                    ? NetworkImage(profileUrl)
                                                    : AssetImage(isDarkMode
                                                            ? "assets/images/default_user_white.png"
                                                            : "assets/images/default_user.png")
                                                        as ImageProvider,
                                              ),
                                              title: Text(
                                                "${follower['firstName']} ${follower['lastName']}",
                                                style: const TextStyle(
                                                    fontFamily: 'Poppins'),
                                              ),
                                              onTap: () {
                                                // TODO: Open follower profile
                                              },
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
              ),
            ),
          );
        },
      );
    },
  );
}
