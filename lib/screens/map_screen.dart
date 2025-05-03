import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapScreen extends StatelessWidget {
  final String locationUrl;

  const MapScreen({
    Key? key,
    required this.locationUrl,
  }) : super(key: key);

  /// Parses the coordinates from a Google Maps URL
  LatLng? _parseCoordinates(String url) {
    try {
      final uri = Uri.parse(url);
      final query = uri.queryParameters['q']; // e.g., q=23.456,77.123

      if (query != null) {
        final parts = query.split(',');
        if (parts.length == 2) {
          final lat = double.parse(parts[0]);
          final lng = double.parse(parts[1]);
          return LatLng(lat, lng);
        }
      }
    } catch (e) {
      debugPrint("Error parsing URL: $e");
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final LatLng? targetLocation = _parseCoordinates(locationUrl);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Shared Location Map"),
        backgroundColor: Colors.purple[400],
      ),
      body: targetLocation == null
          ? const Center(child: Text("Invalid location URL"))
          : GoogleMap(
              initialCameraPosition: CameraPosition(
                target: targetLocation,
                zoom: 16,
              ),
              markers: {
                Marker(
                  markerId: const MarkerId("shared_location"),
                  position: targetLocation,
                  infoWindow: const InfoWindow(
                    title: "Pinned Location",
                    snippet: "Shared via URL",
                  ),
                ),
              },
              zoomControlsEnabled: false,
              myLocationButtonEnabled: false,
            ),
    );
  }
}
