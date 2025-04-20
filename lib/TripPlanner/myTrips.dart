import 'package:adventura/TripPlanner/buildWithAiPage.dart';
import 'package:flutter/material.dart';

class MyTripsPage extends StatefulWidget {
  const MyTripsPage({super.key});

  @override
  State<MyTripsPage> createState() => _MyTripsPageState();
}

class _MyTripsPageState extends State<MyTripsPage>
    with SingleTickerProviderStateMixin {
  List<Map<String, dynamic>> trips = [
    // {
    //   'title': 'Dubai for 3 days',
    //   'date': '3 days',
    //   'saves': 15,
    //   'completed': false,
    // },
    // {
    //   'title': 'Las Vegas for 3 days with your partner',
    //   'date': 'Apr 1 → Apr 3, 2025',
    //   'saves': 18,
    //   'completed': true,
    // },
    // {
    //   'title': 'Istanbul for 3 days',
    //   'date': 'Apr 1 → Apr 3, 2025',
    //   'saves': 15,
    //   'completed': true,
    // },
  ];

  bool _isFabOpen = false;

  void _toggleFab() {
    setState(() {
      _isFabOpen = !_isFabOpen;
    });
  }

  Widget _buildTripTile(Map<String, dynamic> trip) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: Colors.grey.shade800,
        ),
      ),
      title: Text(
        trip['title'],
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(Icons.calendar_today, size: 16, color: Colors.grey[400]),
              const SizedBox(width: 4),
              Text(trip['date'], style: TextStyle(color: Colors.grey[400])),
            ],
          ),
          const SizedBox(height: 2),
          Row(
            children: [
              Icon(Icons.favorite_border, size: 16, color: Colors.grey[400]),
              const SizedBox(width: 4),
              Text('${trip['saves']} saves',
                  style: TextStyle(color: Colors.grey[400])),
            ],
          ),
        ],
      ),
      trailing: const Icon(Icons.more_vert),
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

    final activeTrips =
        trips.where((trip) => trip['completed'] == false).toList();
    final completedTrips =
        trips.where((trip) => trip['completed'] == true).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('My trips'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 100),
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Text(
              'My trips',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          ...activeTrips.map(_buildTripTile),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Text(
              'Completed trips',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          ...completedTrips.map(_buildTripTile),
        ],
      ),
      floatingActionButton: Stack(
        alignment: Alignment.bottomRight,
        children: [
          if (_isFabOpen) ...[
            Positioned(
              right: 16,
              bottom: 150,
              child: _buildFabOption(
                label: "Create a trip",
                icon: Icons.add,
                onPressed: () {
                  print("Manual Trip");
                  _toggleFab();
                },
              ),
            ),
            Positioned(
              right: 16,
              bottom: 90,
              child: _buildFabOption(
                label: "Build a trip with AI",
                icon: Icons.auto_awesome,
                onPressed: () {
                  _toggleFab();
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const BuildWithAIPage()),
                  );
                },
              ),
            ),
          ],
          Positioned(
            right: 16,
            bottom: 20,
            child: FloatingActionButton(
              backgroundColor: Colors.white,
              onPressed: _toggleFab,
              child: Icon(
                _isFabOpen ? Icons.close : Icons.add,
                color: Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
