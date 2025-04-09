import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:google_maps_flutter/google_maps_flutter.dart' as gmap;
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_map_cancellable_tile_provider/flutter_map_cancellable_tile_provider.dart';
import 'package:url_launcher/url_launcher.dart';

class ReadOnlyLocationMap extends StatelessWidget {
  final double latitude;
  final double longitude;

  const ReadOnlyLocationMap({
    Key? key,
    required this.latitude,
    required this.longitude,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final latLng = gmap.LatLng(latitude, longitude);

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        height: 180,
        child: kIsWeb ? _buildWebMap() : _buildNativeMap(latLng),
      ),
    );
  }

  Widget _buildWebMap() {
    return FlutterMap(
      options: MapOptions(
        center: LatLng(latitude, longitude),
        zoom: 14,
        onTap: (_, __) async {
          final url = Uri.parse("https://www.google.com/maps/search/?api=1&query=$latitude,$longitude");
          await launchUrl(url, mode: LaunchMode.externalApplication);
        },
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          tileProvider: CancellableNetworkTileProvider(),
        ),
        MarkerLayer(
          markers: [
            Marker(
              point: LatLng(latitude, longitude),
              width: 40,
              height: 40,
              child: const Icon(Icons.location_pin, color: Colors.red, size: 32),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildNativeMap(gmap.LatLng latLng) {
    return GestureDetector(
      onTap: () async {
        final url = Uri.parse("https://www.google.com/maps/search/?api=1&query=${latLng.latitude},${latLng.longitude}");
        await launchUrl(url, mode: LaunchMode.externalApplication);
      },
      child: gmap.GoogleMap(
        initialCameraPosition: gmap.CameraPosition(
          target: latLng,
          zoom: 14,
        ),
        markers: {
          gmap.Marker(
            markerId: const gmap.MarkerId('location'),
            position: latLng,
            infoWindow: const gmap.InfoWindow(title: "Activity Location"),
          ),
        },
        zoomControlsEnabled: false,
        myLocationButtonEnabled: false,
      ),
    );
  }
}
