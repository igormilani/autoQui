import 'package:google_maps_flutter/google_maps_flutter.dart';

class ParkingSpot {
  const ParkingSpot({
    required this.latitude,
    required this.longitude,
    required this.savedAt,
  });

  final double latitude;
  final double longitude;
  final DateTime savedAt;

  LatLng get latLng => LatLng(latitude, longitude);
}
