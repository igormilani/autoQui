import 'package:shared_preferences/shared_preferences.dart';

import '../models/parking_spot.dart';

class ParkingStorage {
  static const parkingLatKey = 'parking_lat';
  static const parkingLngKey = 'parking_lng';
  static const parkingSavedAtKey = 'parking_saved_at';
  static const ignoredDetectionAtKey = 'ignored_detection_at';

  Future<ParkingSpot?> loadParkingSpot() async {
    final preferences = await SharedPreferences.getInstance();
    final latitude = _readDouble(preferences, parkingLatKey);
    final longitude = _readDouble(preferences, parkingLngKey);
    final savedAtMillis = preferences.getInt(parkingSavedAtKey);

    if (latitude == null || longitude == null || savedAtMillis == null) {
      return null;
    }

    return ParkingSpot(
      latitude: latitude,
      longitude: longitude,
      savedAt: DateTime.fromMillisecondsSinceEpoch(savedAtMillis),
    );
  }

  Future<void> saveParkingSpot(ParkingSpot spot) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setDouble(parkingLatKey, spot.latitude);
    await preferences.setDouble(parkingLngKey, spot.longitude);
    await preferences.setInt(
      parkingSavedAtKey,
      spot.savedAt.millisecondsSinceEpoch,
    );
  }

  double? _readDouble(SharedPreferences preferences, String key) {
    final value = preferences.get(key);
    if (value is double) {
      return value;
    }
    if (value is int) {
      return value.toDouble();
    }
    if (value is String) {
      return double.tryParse(value);
    }
    return null;
  }
}
