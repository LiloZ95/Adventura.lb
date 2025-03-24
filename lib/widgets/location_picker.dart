import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as gmap;
import 'package:geolocator/geolocator.dart';

class LocationPicker extends StatefulWidget {
  final gmap.LatLng? initialPosition;

  const LocationPicker({Key? key, this.initialPosition}) : super(key: key);

  @override
  _LocationPickerState createState() => _LocationPickerState();
}

class _LocationPickerState extends State<LocationPicker> {
  late gmap.LatLng _pickedLocation;
  gmap.GoogleMapController? _mapController;

  @override
  void initState() {
    super.initState();
    _pickedLocation = widget.initialPosition ?? gmap.LatLng(33.8547, 35.8623); // Lebanon default
  }

  Future<void> _goToCurrentLocation() async {
    LocationPermission permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.deniedForever ||
        permission == LocationPermission.denied) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Location permission denied.'),
      ));
      return;
    }

    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    gmap.LatLng currentLatLng =
        gmap.LatLng(position.latitude, position.longitude);

    _mapController?.animateCamera(
      gmap.CameraUpdate.newLatLngZoom(currentLatLng, 14),
    );

    setState(() {
      _pickedLocation = currentLatLng;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Pick Location"),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            tooltip: "Save Location",
            onPressed: () {
              Navigator.pop(context, _pickedLocation);
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          gmap.GoogleMap(
            initialCameraPosition: gmap.CameraPosition(
              target: _pickedLocation,
              zoom: 13,
            ),
            onMapCreated: (controller) => _mapController = controller,
            onTap: (position) {
              setState(() {
                _pickedLocation = position;
              });
            },
            markers: {
              gmap.Marker(
                markerId: const gmap.MarkerId('picked-location'),
                position: _pickedLocation,
              ),
            },
            myLocationButtonEnabled: false, // We'll use custom button
            zoomControlsEnabled: true,
          ),
          Positioned(
            top: 80,
            left: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                  ),
                ],
              ),
              child: const Text(
                "Tap on map to set marker",
                style: TextStyle(fontSize: 14),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _goToCurrentLocation,
        backgroundColor: Colors.blue,
        child: const Icon(Icons.my_location),
      ),
    );
  }
}
