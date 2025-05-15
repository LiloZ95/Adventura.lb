import 'dart:convert';

import 'package:adventura/TripPlanner/buildWithAiPage.dart';
import 'package:adventura/TripPlanner/tripSummary.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MyTripsPage extends StatefulWidget {
  const MyTripsPage({super.key});

  @override
  State<MyTripsPage> createState() => _MyTripsPageState();
}

class _MyTripsPageState extends State<MyTripsPage> {
  List<Map<String, dynamic>> trips = [];
  @override
  void initState() {
    super.initState();
    _loadTrips();
  }

  bool _isFabOpen = false;

  void _toggleFab() {
    setState(() => _isFabOpen = !_isFabOpen);
  }

  void _loadTrips() async {
    final prefs = await SharedPreferences.getInstance();
    final savedTripsJson = prefs.getStringList('savedTrips') ?? [];

    final loadedTrips = savedTripsJson.map((tripStr) {
      return jsonDecode(tripStr);
    }).toList();

    setState(() => trips = List<Map<String, dynamic>>.from(loadedTrips));
  }

  Widget _buildTripTile(Map<String, dynamic> trip) {
    return ListTile(
      onTap: () {
        final plan = trip['plan'];
        if (plan != null && plan is Map) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  TripResultPage(plan: Map<String, dynamic>.from(plan)),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Invalid trip data')),
          );
        }
      },
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: Colors.grey.shade800,
        ),
        child: Icon(Icons.explore, color: Colors.white),
      ),
      title: Text(
        trip['title'],
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          fontFamily: 'poppins',
        ),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(Icons.calendar_today, size: 16, color: Colors.grey[400]),
              const SizedBox(width: 4),
              Text(
                trip['date'] ?? "No date",
                style: TextStyle(
                  color: Colors.grey[400],
                  fontFamily: 'poppins',
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Row(
            children: [
              Icon(Icons.favorite_border, size: 16, color: Colors.grey[400]),
              const SizedBox(width: 4),
              Text(
                '${trip['saves'] ?? 0} saves',
                style: TextStyle(
                  color: Colors.grey[400],
                  fontFamily: 'poppins',
                ),
              ),
            ],
          ),
        ],
      ),
      trailing: PopupMenuButton<String>(
        onSelected: (value) async {
          if (value == 'delete') {
            final prefs = await SharedPreferences.getInstance();
            final savedTripsJson = prefs.getStringList('savedTrips') ?? [];

            // Remove the exact trip match (serialized version)
            final updatedTrips = savedTripsJson.where((tripStr) {
              final decoded = jsonDecode(tripStr);
              return decoded['title'] != trip['title'] ||
                  decoded['date'] != trip['date'];
            }).toList();

            await prefs.setStringList('savedTrips', updatedTrips);
            _loadTrips(); // Refresh UI
          }
        },
        itemBuilder: (context) => [
          const PopupMenuItem(
            value: 'delete',
            child: Text('Delete Trip'),
          ),
        ],
      ),
    );
  }

  Widget _buildFabOption({
    required String label,
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                    color: Colors.black26, blurRadius: 8, offset: Offset(0, 2)),
              ],
            ),
            child: Row(
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    fontFamily: 'poppins',
                  ),
                ),
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: onPressed,
                  child: Container(
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.black,
                    ),
                    padding: const EdgeInsets.all(6),
                    child: Icon(icon, color: Colors.white, size: 18),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final statusBarHeight = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Column(
        children: [
          // 🔹 Custom Header
          Padding(
            padding: EdgeInsets.fromLTRB(16, statusBarHeight + 6, 16, 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Divider(
                    thickness: 1,
                    color: isDark ? Colors.grey.shade700 : Colors.grey,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  "My Trips",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Poppins',
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Divider(
                    thickness: 1,
                    color: isDark ? Colors.grey.shade700 : Colors.grey,
                  ),
                ),
              ],
            ),
          ),

          // 🔹 Main Content
          Expanded(
            child: ListView(
              padding: const EdgeInsets.only(bottom: 100),
              children: [
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Text(
                    'Here you’ll find all your upcoming adventures. '
                    'Click the + icon below to start planning!',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                      fontFamily: 'poppins',
                    ),
                  ),
                ),
                if (trips.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 32),
                    child: Column(
                      children: const [
                        Icon(Icons.travel_explore,
                            size: 48, color: Colors.grey),
                        SizedBox(height: 12),
                        Text(
                          "You haven’t created any trips yet.",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                            fontFamily: 'poppins',
                          ),
                        ),
                        SizedBox(height: 6),
                        Text(
                          "Tap the + button below to get started!",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                            fontFamily: 'poppins',
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  ...trips.map(_buildTripTile),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: SizedBox(
        width: 200,
        child: Stack(
          alignment: Alignment.bottomRight,
          clipBehavior: Clip.none,
          children: [
            // Create a trip
            AnimatedPositioned(
              duration: Duration(milliseconds: 300),
              right: 0,
              bottom: _isFabOpen ? 140 : 80,
              child: AnimatedOpacity(
                duration: Duration(milliseconds: 300),
                opacity: _isFabOpen ? 1.0 : 0.0,
                child: _buildFabOption(
                  label: "Create a trip",
                  icon: Icons.add,
                  onPressed: () {
                    print("Manual Trip");
                    _toggleFab();
                  },
                ),
              ),
            ),

            // AI Builder
            AnimatedPositioned(
              duration: Duration(milliseconds: 300),
              right: 0,
              bottom: _isFabOpen ? 200 : 80,
              child: AnimatedOpacity(
                duration: Duration(milliseconds: 300),
                opacity: _isFabOpen ? 1.0 : 0.0,
                child: _buildFabOption(
                  label: "Build a trip with AI",
                  icon: Icons.auto_awesome,
                  onPressed: () async {
                    _toggleFab();
                    final shouldReload = await Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const BuildWithAIPage()),
                    );

                    if (shouldReload == true && mounted) {
                      _loadTrips(); // 🔄 Refresh saved trips list
                    }
                  },
                ),
              ),
            ),

            // FAB Base Button
            Positioned(
              bottom: 80,
              right: 0,
              child: FloatingActionButton(
                backgroundColor: Colors.white,
                onPressed: _toggleFab,
                child: AnimatedRotation(
                  duration: Duration(milliseconds: 300),
                  turns: _isFabOpen ? 0.75 : 0,
                  child: Icon(
                    _isFabOpen ? Icons.close : Icons.add,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
