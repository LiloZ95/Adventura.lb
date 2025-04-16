import 'package:adventura/HomeControllerScreen.dart';
import 'package:adventura/event_cards/Cards.dart';
import 'package:flutter/material.dart';
import 'package:adventura/services/activity_service.dart';
import 'package:hive/hive.dart';

import 'widgets/expired_listings_modal.dart';

class MyListingsPage extends StatefulWidget {
  final bool cameFromCreation;

  const MyListingsPage({Key? key, this.cameFromCreation = false})
      : super(key: key);

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
      print("❌ providerId is null. This user is not a provider.");
      setState(() {
        _loading = false;
      });

      // Optional: Show a dialog or redirect
      Future.delayed(Duration.zero, () {
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: Text("Access Denied"),
            content: Text("Only providers can view listings."),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text("OK"),
              )
            ],
          ),
        );
      });
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
    return WillPopScope(
      onWillPop: () async {
        if (widget.cameFromCreation) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => HomeControllerScreen()),
            (route) => false,
          );
          return false;
        }
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          leading: widget.cameFromCreation
              ? IconButton(
                  icon: const Icon(Icons.arrow_back,
                      color: Color.fromARGB(255, 0, 0, 0)),
                  onPressed: () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (_) => HomeControllerScreen()),
                      (route) => false,
                    );
                  },
                )
              : null,
          title: const Text(
            "My Listings",
            style: TextStyle(
              fontFamily: "Poppins",
              color: Color.fromARGB(255, 0, 0, 0),
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

                            return TweenAnimationBuilder(
                              tween: Tween<double>(begin: 0.95, end: 1.0),
                              duration:
                                  Duration(milliseconds: 400 + index * 80),
                              curve: Curves.easeOutBack,
                              builder: (context, scale, child) {
                                return Transform.scale(
                                    scale: scale, child: child);
                              },
                              child: Padding(
                                padding: const EdgeInsets.only(bottom: 20),
                                child: Stack(
                                  clipBehavior: Clip.none,
                                  children: [
                                    // 🎯 The card itself
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        EventCard(
                                            context: context,
                                            activity: activity),
                                      ],
                                    ),

                                    // 🗑️ Delete button with elevated glassy style
                                    Positioned(
                                      top: 13,
                                      right: 24,
                                      child: GestureDetector(
                                        onTap: () => _confirmAndDelete(index,
                                            activity["activity_id"].toString()),
                                        child: Container(
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              colors: [
                                                Colors.white.withOpacity(0.7),
                                                Colors.white.withOpacity(0.4),
                                              ],
                                              begin: Alignment.topLeft,
                                              end: Alignment.bottomRight,
                                            ),
                                            border: Border.all(
                                                color: Colors.white
                                                    .withOpacity(0.6),
                                                width: 1),
                                            shape: BoxShape.circle,
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black
                                                    .withOpacity(0.2),
                                                blurRadius: 10,
                                                offset: Offset(0, 4),
                                              ),
                                            ],
                                          ),
                                          child: const Icon(Icons.delete,
                                              size: 20, color: Colors.red),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
