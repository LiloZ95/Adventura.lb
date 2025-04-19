// ignore_for_file: deprecated_member_use

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as gmap;
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' as latlong;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_map_cancellable_tile_provider/flutter_map_cancellable_tile_provider.dart';
import 'package:url_launcher/url_launcher.dart';

class LocationSection extends StatelessWidget {
  final TextEditingController locationController;
  final gmap.LatLng? latLng;
  final VoidCallback onPickLocation;

  const LocationSection({
    Key? key,
    required this.locationController,
    required this.latLng,
    required this.onPickLocation,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Location',
              style: TextStyle(
                fontFamily: "poppins",
                fontSize: 20,
                color: isDarkMode ? Colors.white : Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Divider(
                color: isDarkMode ? Colors.grey.shade600 : Colors.grey,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          height: 50,
          decoration: BoxDecoration(
            border: Border.all(
              color: isDarkMode ? Colors.grey.shade700 : const Color(0xFFCFCFCF),
              width: 1,
            ),
            borderRadius: BorderRadius.circular(8),
            color: isDarkMode ? const Color(0xFF2C2C2C) : Colors.transparent,
          ),
          child: TextField(
            controller: locationController,
            style: TextStyle(
              fontSize: 14,
              fontFamily: 'poppins',
              color: isDarkMode ? Colors.white : Colors.black,
            ),
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(horizontal: 12),
              border: InputBorder.none,
              hintText: 'Add Location to Display',
              hintStyle: TextStyle(
                color: isDarkMode ? Colors.grey.shade500 : Colors.grey,
                fontSize: 14,
                fontFamily: 'poppins',
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        if (latLng != null)
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: SizedBox(
              height: 180,
              child: kIsWeb ? _buildWebMap(latLng!) : _buildNativeMap(latLng!),
            ),
          )
        else
          Container(
            height: 180,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              border: Border.all(
                color: isDarkMode ? Colors.grey.shade700 : Colors.grey,
              ),
              borderRadius: BorderRadius.circular(12),
              color: isDarkMode ? const Color(0xFF1F1F1F) : Colors.transparent,
            ),
            child: Text(
              "No coordinates selected yet.",
              style: TextStyle(
                fontFamily: 'poppins',
                color: isDarkMode ? Colors.grey.shade400 : Colors.grey,
              ),
            ),
          ),
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.center,
          child: SizedBox(
            height: 40,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.map_outlined),
              label: Text(
                latLng != null ? "Edit Location" : "Pick Location",
                style: const TextStyle(fontFamily: 'poppins'),
              ),
              onPressed: onPickLocation,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWebMap(gmap.LatLng latLng) {
    final mapboxToken = dotenv.env['MAPBOX_TOKEN'] ?? "fallback-token";

    return FlutterMap(
      options: MapOptions(
        center: latlong.LatLng(latLng.latitude, latLng.longitude),
        zoom: 14,
        interactiveFlags: InteractiveFlag.all,
        onTap: (_, __) async {
          final url = Uri.parse(
              "https://www.google.com/maps/search/?api=1&query=${latLng.latitude},${latLng.longitude}");
          await launchUrl(url, mode: LaunchMode.externalApplication);
        },
      ),
      children: [
        TileLayer(
          urlTemplate:
              'https://api.mapbox.com/styles/v1/mapbox/streets-v11/tiles/{z}/{x}/{y}?access_token=$mapboxToken',
          tileProvider: CancellableNetworkTileProvider(),
        ),
        MarkerLayer(
          markers: [
            Marker(
              point: latlong.LatLng(latLng.latitude, latLng.longitude),
              width: 40,
              height: 40,
              child:
                  const Icon(Icons.location_pin, color: Colors.red, size: 32),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildNativeMap(gmap.LatLng latLng) {
    return GestureDetector(
      onTap: () async {
        final url = Uri.parse(
            "https://www.google.com/maps/search/?api=1&query=${latLng.latitude},${latLng.longitude}");
        await launchUrl(url, mode: LaunchMode.externalApplication);
      },
      child: gmap.GoogleMap(
        key: ValueKey('${latLng.latitude}-${latLng.longitude}'),
        initialCameraPosition: gmap.CameraPosition(
          target: latLng,
          zoom: 14,
        ),
        markers: {
          gmap.Marker(
            markerId: const gmap.MarkerId('location'),
            position: latLng,
            infoWindow: const gmap.InfoWindow(title: "Selected Location"),
          ),
        },
        zoomControlsEnabled: false,
        myLocationButtonEnabled: false,
      ),
    );
  }
}
