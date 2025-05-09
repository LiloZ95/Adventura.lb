import 'package:adventura/HomeControllerScreen.dart';
import 'package:adventura/event_cards/Cards.dart';
import 'package:flutter/material.dart';
import 'package:adventura/services/activity_service.dart';
import 'package:hive/hive.dart';
import 'widgets/expired_listings_modal.dart';

class MyListingsPage extends StatefulWidget {
  final bool cameFromCreation;

  const MyListingsPage({Key? key, this.cameFromCreation = false}) : super(key: key);

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

      Future.delayed(Duration.zero, () {
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text("Access Denied"),
            content: const Text("Only providers can view listings."),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("OK"),
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
        title: const Text("Confirm Delete"),
        content: const Text("Are you sure you want to delete this listing?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Cancel")),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text("Delete")),
        ],
      ),
    );

    if (confirmed == true) {
      final success = await ActivityService.deleteActivity(activityId);
      if (success) {
        await loadListings(); // Refresh data
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Listing archived (moved to expired).")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to delete listing.")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

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
backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor: isDarkMode ? const Color(0xFF1F1F1F) : Colors.white,
          elevation: 0.5,
          centerTitle: true,
          leading: widget.cameFromCreation
              ? IconButton(
                  icon: Icon(Icons.arrow_back, color: isDarkMode ? Colors.white : Colors.black),
                  onPressed: () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (_) => HomeControllerScreen()),
                      (route) => false,
                    );
                  },
                )
              : null,
          title: Text(
            "My Listings",
            style: TextStyle(
              fontFamily: "Poppins",
              color: isDarkMode ? Colors.white : Colors.black,
              fontWeight: FontWeight.w600,
              fontSize: 20,
            ),
          ),
        ),
        body: Column(
          children: [
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
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : _myListings.isEmpty
                      ? Center(
                          child: Text(
                            "No listings found.",
                            style: TextStyle(
                              fontSize: 16,
                              color: isDarkMode ? Colors.white70 : Colors.grey,
                            ),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _myListings.length,
                          itemBuilder: (context, index) {
                            final activity = _myListings[index];

                            return TweenAnimationBuilder(
                              tween: Tween<double>(begin: 0.95, end: 1.0),
                              duration: Duration(milliseconds: 400 + index * 80),
                              curve: Curves.easeOutBack,
                              builder: (context, scale, child) {
                                return Transform.scale(scale: scale, child: child);
                              },
                              child: Padding(
                                padding: const EdgeInsets.only(bottom: 20),
                                child: Stack(
                                  clipBehavior: Clip.none,
                                  children: [
                                    EventCard(context: context, activity: activity),
                                    Positioned(
                                      top: 13,
                                      right: 24,
                                      child: GestureDetector(
                                        onTap: () => _confirmAndDelete(
                                          index,
                                          activity["activity_id"].toString(),
                                        ),
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
                                                color: Colors.white.withOpacity(0.6), width: 1),
                                            shape: BoxShape.circle,
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black.withOpacity(0.2),
                                                blurRadius: 10,
                                                offset: const Offset(0, 4),
                                              ),
                                            ],
                                          ),
                                          child: const Icon(Icons.delete, size: 20, color: Colors.red),
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
