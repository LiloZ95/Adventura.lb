import 'dart:ui';

import 'package:adventura/colors.dart';
import 'package:adventura/widgets/availability_modal.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as gmap;

class PreviewPage extends StatefulWidget {
  final String title;
  final String description;
  final String location;
  final List<String> features;
  final List<Map<String, String>> tripPlan;
  final List<String> images;
  final gmap.LatLng mapLatLng;
  final int seats;
  final String? ageAllowed;
  final int price;
  final String priceType;

  const PreviewPage({
    Key? key,
    required this.title,
    required this.description,
    required this.location,
    required this.features,
    required this.tripPlan,
    required this.images,
    required this.mapLatLng,
    required this.seats,
    required this.ageAllowed,
    required this.price,
    required this.priceType,
  }) : super(key: key);

  @override
  State<PreviewPage> createState() => _PreviewPageState();
}

class _PreviewPageState extends State<PreviewPage> {
  String? confirmedDate;
  String? confirmedSlot;

  void _openAvailabilityModal() async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent, // Needed for the blur to show
      barrierColor: Colors.black.withOpacity(0.25), // Optional dim background
      builder: (context) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15.0, sigmaY: 15.0),
          child: Material(
            color: Colors.white.withOpacity(0.95), // Adjust opacity as needed
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: FractionallySizedBox(
              heightFactor: 0.85, // Adjust based on how much space you want
              child: AvailabilityModal(
                activityId: 0,
                onDateSlotSelected: (String date, String slot) {
                  setState(() {
                    confirmedDate = date;
                    confirmedSlot = slot;
                  });
                },
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final List<String> previewImages = widget.images.isNotEmpty
        ? widget.images
        : ["assets/Pictures/island.jpg"];
    final PageController _pageController = PageController();

    return Scaffold(
      backgroundColor: isDarkMode ? const Color(0xFF121212) : Colors.white,
      appBar: AppBar(
        title: const Text('Preview'),
        backgroundColor: isDarkMode ? const Color(0xFF121212) : Colors.white,
        foregroundColor: isDarkMode ? Colors.white : Colors.black,
        elevation: 0.5,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            _buildImageCarousel(previewImages, _pageController),
            const SizedBox(height: 16),
            Text(
              widget.title,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                fontFamily: 'Poppins',
                color: isDarkMode ? Colors.white : Colors.black,
              ),
            ),
            const SizedBox(height: 12),
            confirmedDate != null && confirmedSlot != null
                ? Row(
                    children: [
                      Icon(Icons.calendar_today,
                          size: 18,
                          color: isDarkMode ? Colors.grey[300] : Colors.grey),
                      const SizedBox(width: 4),
                      Text(
                        "$confirmedDate at $confirmedSlot",
                        style: TextStyle(
                            fontSize: 14,
                            color: isDarkMode ? Colors.grey[300] : Colors.grey),
                      ),
                      const SizedBox(width: 6),
                      TextButton(
                        onPressed: _openAvailabilityModal,
                        child: const Text("Change time",
                            style: TextStyle(
                                fontSize: 13,
                                color: Colors.blue,
                                fontWeight: FontWeight.w500)),
                      ),
                    ],
                  )
                : ElevatedButton(
                    onPressed: _openAvailabilityModal,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.blue,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text("Check Availability",
                        style: TextStyle(color: Colors.white)),
                  ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.location_on,
                    size: 18,
                    color: isDarkMode ? Colors.grey[300] : Colors.grey),
                const SizedBox(width: 4),
                Text(
                  widget.location,
                  style: TextStyle(
                      fontSize: 14,
                      color: isDarkMode ? Colors.grey[300] : Colors.grey),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildTripPlan(widget.tripPlan, isDarkMode),
            const SizedBox(height: 16),
            _sectionTitle("Description", isDarkMode),
            const SizedBox(height: 4),
            Text(widget.description,
                style: TextStyle(
                    fontSize: 14,
                    color: isDarkMode ? Colors.white70 : Colors.black87)),
            const SizedBox(height: 12),
            _sectionTitle("Features", isDarkMode),
            const SizedBox(height: 6),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [
                if (widget.ageAllowed != null && widget.ageAllowed!.isNotEmpty)
                  _tag("Age: ${widget.ageAllowed}",
                      gradient: [Colors.blue, Colors.indigo],
                      isDarkMode: isDarkMode),
                ...widget.features
                    .map((tag) => _tag(tag, isDarkMode: isDarkMode))
                    .toList(),
              ],
            ),
            const SizedBox(height: 16),
            _sectionTitle("Location", isDarkMode),
            const SizedBox(height: 8),
            _realGoogleMap(),
            const SizedBox(height: 16),
            _sectionTitle("Organizer", isDarkMode),
            _fakeOrganizer(isDarkMode),
            const SizedBox(height: 32),
          ],
        ),
      ),
      bottomNavigationBar: _bottomBar(context, isDarkMode),
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

  Widget _tag(String text, {List<Color>? gradient, required bool isDarkMode}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: gradient != null ? LinearGradient(colors: gradient) : null,
        color: gradient == null
            ? (isDarkMode ? const Color(0xFF2C2C2E) : Colors.grey.shade300)
            : null,
      ),
      child: Text(
        text,
        style: TextStyle(
          color: gradient != null
              ? Colors.white
              : (isDarkMode ? Colors.white : Colors.black),
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildTripPlan(List<Map<String, String>> tripPlan, bool isDarkMode) {
    if (tripPlan.isEmpty) {
      return Padding(
        padding: const EdgeInsets.only(top: 8),
        child: Text("No trip plan added yet.",
            style:
                TextStyle(color: isDarkMode ? Colors.white70 : Colors.black)),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text("Trip plan",
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Poppins',
                    color: isDarkMode ? Colors.white : Colors.black)),
            const SizedBox(width: 8),
            Expanded(
              child: Divider(
                  color:
                      isDarkMode ? Colors.grey.shade600 : Colors.grey.shade400,
                  thickness: 1),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 80,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: tripPlan.length * 2 - 1,
            separatorBuilder: (context, index) => const SizedBox(width: 4),
            itemBuilder: (context, index) {
              if (index.isOdd) return _arrowConnector();
              final step = tripPlan[index ~/ 2];
              return _tripCard(step["time"]!, step["description"]!, isDarkMode);
            },
          ),
        ),
      ],
    );
  }

  Widget _tripCard(String time, String title, bool isDarkMode) {
    return Container(
      margin: const EdgeInsets.only(right: 8, left: 8),
      padding: const EdgeInsets.only(left: 10, right: 30, top: 12, bottom: 12),
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF1C1C1E) : Colors.white,
        border: Border.all(
            color: isDarkMode ? Colors.grey.shade600 : Colors.grey.shade400,
            width: 0.8),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text("• $time",
              style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
          const SizedBox(height: 4),
          Text(title,
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: isDarkMode ? Colors.white : Colors.black)),
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

  Widget _realGoogleMap() {
    return SizedBox(
      height: 180,
      child: gmap.GoogleMap(
        initialCameraPosition: gmap.CameraPosition(
          target: widget.mapLatLng,
          zoom: 14,
        ),
        markers: {
          gmap.Marker(
            markerId: const gmap.MarkerId('preview'),
            position: widget.mapLatLng,
          ),
        },
        zoomControlsEnabled: false,
        myLocationButtonEnabled: false,
      ),
    );
  }

  Widget _fakeOrganizer(bool isDarkMode) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        radius: 24,
        backgroundColor: Colors.grey.shade200,
        child: const Icon(Icons.person, size: 28, color: Colors.grey),
      ),
      title: Text("Preview Organizer",
          style: TextStyle(color: isDarkMode ? Colors.white : Colors.black)),
      subtitle: Text("Listing Preview · 5 Stars",
          style: TextStyle(color: isDarkMode ? Colors.grey : Colors.black87)),
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

  Widget _bottomBar(BuildContext context, bool isDarkMode) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: isDarkMode
                ? Colors.black.withOpacity(0.4)
                : Colors.black.withOpacity(0.15),
            blurRadius: 15,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
        child: Container(
          color: isDarkMode ? const Color(0xFF1F1F1F) : Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Price",
                    style: TextStyle(
                      color: isDarkMode ? Colors.white70 : Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Text(
                        "\$${widget.price}",
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        "/${widget.priceType}",
                        style: TextStyle(
                          color: isDarkMode ? Colors.white60 : Colors.black54,
                          fontSize: 14,
                        ),
                      ),
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
                    borderRadius: BorderRadius.circular(12),
                  ),
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

  Widget _sectionTitle(String text, bool isDarkMode) {
    return Row(
      children: [
        Text(text,
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                fontFamily: 'Poppins',
                color: isDarkMode ? Colors.white : Colors.black)),
        const SizedBox(width: 8),
        Expanded(
            child: Divider(
                color: isDarkMode ? Colors.grey.shade600 : Colors.grey.shade400,
                thickness: 1)),
      ],
    );
  }
}
