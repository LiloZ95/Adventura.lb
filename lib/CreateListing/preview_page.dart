import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as gmap;

class PreviewPage extends StatelessWidget {
  final String title;
  final String description;
  final String location;
  final List<String> features;
  final List<Map<String, String>> tripPlan;
  final List<String> images;
  final gmap.LatLng mapLatLng;

  const PreviewPage({
    Key? key,
    required this.title,
    required this.description,
    required this.location,
    required this.features,
    required this.tripPlan,
    required this.images,
    required this.mapLatLng,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final List<String> previewImages =
        images.isNotEmpty ? images : ["assets/Pictures/island.jpg"];
    final PageController _pageController = PageController();
    int _currentImageIndex = 0;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: const Text('Preview')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            _buildImageCarousel(previewImages, _pageController),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                fontFamily: 'Poppins',
              ),
            ),
            const SizedBox(height: 12),
            _buildAvailabilityPlaceholder(),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.location_on, size: 18, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  location,
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildTripPlan(),
            const SizedBox(height: 16),
            _sectionTitle("Description"),
            const SizedBox(height: 4),
            Text(description,
                style: const TextStyle(fontSize: 14, color: Colors.black87)),
            const SizedBox(height: 12),
            _sectionTitle("Features"),
            const SizedBox(height: 6),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: features.map((f) => Chip(label: Text(f))).toList(),
            ),
            const SizedBox(height: 16),
            _sectionTitle("Location"),
            const SizedBox(height: 4),
            Text(location,
                style: const TextStyle(fontSize: 14, color: Colors.black87)),
            const SizedBox(height: 8),
            _realGoogleMap(context),
            const SizedBox(height: 16),
            _sectionTitle("Organizer"),
            _fakeOrganizer(),
            const SizedBox(height: 32),
          ],
        ),
      ),
      bottomNavigationBar: _bottomBar(context),
    );
  }

  Widget _buildImageCarousel(List<String> images, PageController controller) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        height: 200,
        width: double.infinity,
        child: PageView.builder(
          controller: controller,
          itemCount: images.length,
          itemBuilder: (context, index) {
            final img = images[index];
            return img.startsWith("http")
                ? Image.network(img, fit: BoxFit.cover)
                : Image.asset(img, fit: BoxFit.cover);
          },
        ),
      ),
    );
  }

  Widget _buildAvailabilityPlaceholder() {
    return Row(
      children: const [
        Icon(Icons.calendar_today, size: 18, color: Colors.grey),
        SizedBox(width: 4),
        Text(
          "No date selected",
          style: TextStyle(fontSize: 14, color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildTripPlan() {
    if (tripPlan.isEmpty) {
      return const Padding(
        padding: EdgeInsets.only(top: 8),
        child: Text("No trip plan added yet."),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text("Trip plan",
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Poppins')),
            const SizedBox(width: 8),
            Expanded(child: Divider(color: Colors.grey.shade400, thickness: 1)),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 80,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: tripPlan.isEmpty ? 0 : tripPlan.length * 2 - 1,
            separatorBuilder: (context, index) => const SizedBox(width: 4),
            itemBuilder: (context, index) {
              if (index.isOdd) {
                return _arrowConnector();
              } else {
                final step = tripPlan[index ~/ 2];
                return _tripCard(
                  step["time"] ?? '',
                  step["description"] ?? '',
                );
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _tripCard(String time, String title) {
    return Container(
      margin: const EdgeInsets.only(right: 8, left: 8),
      padding: const EdgeInsets.only(left: 10, right: 30, top: 12, bottom: 12),
      decoration: BoxDecoration(
        border: Border.all(
            color: const Color.fromARGB(255, 51, 51, 51), width: 0.8),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text("• $time",
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
          const SizedBox(height: 4),
          Text(title,
              style:
                  const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        ],
      ),
    );
  }

  Widget _arrowConnector() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      padding: const EdgeInsets.all(6),
      decoration: const BoxDecoration(
        color: Color.fromARGB(255, 84, 84, 84),
        shape: BoxShape.circle,
      ),
      child: const Icon(Icons.chevron_right, color: Colors.white, size: 16),
    );
  }

  Widget _realGoogleMap(BuildContext context) {
    return SizedBox(
      height: 180,
      child: gmap.GoogleMap(
        initialCameraPosition: gmap.CameraPosition(
          target: mapLatLng,
          zoom: 14,
        ),
        markers: {
          gmap.Marker(
            markerId: const gmap.MarkerId('preview'),
            position: mapLatLng,
          ),
        },
        zoomControlsEnabled: false,
        myLocationButtonEnabled: false,
        onTap: (_) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Google Maps is for preview only.")),
          );
        },
      ),
    );
  }

  Widget _fakeOrganizer() {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        radius: 24,
        backgroundColor: Colors.grey.shade200,
        child: const Icon(Icons.person, size: 28, color: Colors.grey),
      ),
      title: const Text("Preview Organizer"),
      subtitle: const Text("Listing Preview · 5 Stars"),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue.shade50,
              elevation: 0,
              minimumSize: const Size(0, 32),
            ),
            child: const Text("Rate",
                style: TextStyle(color: Colors.blue, fontSize: 13)),
          ),
          const SizedBox(width: 8),
          TextButton(
            onPressed: () {},
            child: const Text("Report",
                style: TextStyle(color: Colors.red, fontSize: 11)),
          ),
        ],
      ),
    );
  }

  Widget _bottomBar(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 15,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
        child: Container(
          color: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text("Price", style: TextStyle(color: Colors.black54)),
                  SizedBox(height: 2),
                  Row(
                    children: [
                      Text(
                        "\$100",
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue),
                      ),
                      SizedBox(width: 4),
                      Text("/Person",
                          style: TextStyle(color: Colors.black54, fontSize: 14))
                    ],
                  ),
                ],
              ),
              ElevatedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text("This is just a preview."),
                  ));
                },
                icon: const Icon(Icons.local_activity_outlined,
                    color: Colors.white, size: 20),
                label: const Text("Book Ticket",
                    style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 25, vertical: 18),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(String text) {
    return Row(
      children: [
        Text(text,
            style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                fontFamily: 'Poppins')),
        const SizedBox(width: 8),
        Expanded(child: Divider(color: Colors.grey.shade400, thickness: 1)),
      ],
    );
  }
}
