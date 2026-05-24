import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class NavigationService {
  Future<bool> openWalkingRoute(LatLng destination) async {
    final navigationUri = Uri.parse(
      'google.navigation:q=${destination.latitude},'
      '${destination.longitude}&mode=w',
    );
    final fallbackUri = Uri.https('www.google.com', '/maps/dir/', {
      'api': '1',
      'destination': '${destination.latitude},${destination.longitude}',
      'travelmode': 'walking',
    });

    try {
      final openedNavigation = await launchUrl(
        navigationUri,
        mode: LaunchMode.externalApplication,
      );
      if (openedNavigation) {
        return true;
      }
    } catch (_) {
      // Fallback below covers devices without Google Maps or custom URI support.
    }

    return launchUrl(fallbackUri, mode: LaunchMode.externalApplication);
  }
}
