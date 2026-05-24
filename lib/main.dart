import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const AutoQuiApp());
}

class AutoQuiApp extends StatelessWidget {
  const AutoQuiApp({super.key, this.showMap = true});

  final bool showMap;

  @override
  Widget build(BuildContext context) {
    const seed = Color(0xFF0E7C66);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'AutoQui',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: seed),
      ),
      home: AutoQuiHome(showMap: showMap),
    );
  }
}

class AutoQuiHome extends StatefulWidget {
  const AutoQuiHome({super.key, this.showMap = true});

  final bool showMap;

  @override
  State<AutoQuiHome> createState() => _AutoQuiHomeState();
}

class _AutoQuiHomeState extends State<AutoQuiHome> {
  static const _parkingLatKey = 'parking_lat';
  static const _parkingLngKey = 'parking_lng';
  static const _fallbackPosition = LatLng(41.9028, 12.4964);

  GoogleMapController? _mapController;
  LatLng? _parkingPosition;
  bool _locating = false;
  bool _saving = false;
  bool _openingRoute = false;

  @override
  void initState() {
    super.initState();
    _loadSavedParking();
  }

  Future<void> _loadSavedParking() async {
    final preferences = await SharedPreferences.getInstance();
    final latitude = preferences.getDouble(_parkingLatKey);
    final longitude = preferences.getDouble(_parkingLngKey);

    if (!mounted || latitude == null || longitude == null) {
      return;
    }

    final parkingPosition = LatLng(latitude, longitude);
    setState(() => _parkingPosition = parkingPosition);

    await _animateTo(parkingPosition);
  }

  Future<Position?> _getCurrentPosition() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _showMessage('Attiva il GPS per usare la posizione corrente');
      return null;
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      _showMessage('Permesso posizione non concesso');
      return null;
    }

    return Geolocator.getCurrentPosition();
  }

  Future<void> _centerOnCurrentLocation() async {
    setState(() => _locating = true);

    try {
      final position = await _getCurrentPosition();
      if (position == null) {
        return;
      }

      await _animateTo(LatLng(position.latitude, position.longitude));
    } catch (_) {
      _showMessage('Non riesco a leggere la posizione ora');
    } finally {
      if (mounted) {
        setState(() => _locating = false);
      }
    }
  }

  Future<void> _saveParkingPosition() async {
    setState(() => _saving = true);

    try {
      final position = await _getCurrentPosition();
      if (position == null) {
        return;
      }

      final parkingPosition = LatLng(position.latitude, position.longitude);
      final preferences = await SharedPreferences.getInstance();
      await preferences.setDouble(_parkingLatKey, parkingPosition.latitude);
      await preferences.setDouble(_parkingLngKey, parkingPosition.longitude);

      if (!mounted) {
        return;
      }

      setState(() => _parkingPosition = parkingPosition);
      await _animateTo(parkingPosition);
      _showMessage('Posizione parcheggio salvata');
    } catch (_) {
      _showMessage('Non riesco a salvare il parcheggio ora');
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  Future<void> _openRouteToParking() async {
    final parkingPosition = _parkingPosition;
    if (parkingPosition == null) {
      return;
    }

    setState(() => _openingRoute = true);

    final navigationUri = Uri.parse(
      'google.navigation:q=${parkingPosition.latitude},'
      '${parkingPosition.longitude}&mode=w',
    );
    final fallbackUri = Uri.https('www.google.com', '/maps/dir/', {
      'api': '1',
      'destination': '${parkingPosition.latitude},${parkingPosition.longitude}',
      'travelmode': 'walking',
    });

    try {
      final openedNavigation = await launchUrl(
        navigationUri,
        mode: LaunchMode.externalApplication,
      );

      if (!openedNavigation) {
        final openedFallback = await launchUrl(
          fallbackUri,
          mode: LaunchMode.externalApplication,
        );

        if (!openedFallback) {
          _showMessage('Non riesco ad aprire Google Maps');
        }
      }
    } catch (_) {
      final openedFallback = await launchUrl(
        fallbackUri,
        mode: LaunchMode.externalApplication,
      );

      if (!openedFallback) {
        _showMessage('Non riesco ad aprire Google Maps');
      }
    } finally {
      if (mounted) {
        setState(() => _openingRoute = false);
      }
    }
  }

  Future<void> _animateTo(LatLng target) async {
    await _mapController?.animateCamera(
      CameraUpdate.newCameraPosition(CameraPosition(target: target, zoom: 16)),
    );
  }

  void _showMessage(String message) {
    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Set<Marker> get _markers {
    final parkingPosition = _parkingPosition;
    if (parkingPosition == null) {
      return const {};
    }

    return {
      Marker(
        markerId: const MarkerId('parked_car'),
        position: parkingPosition,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        infoWindow: const InfoWindow(title: 'Auto parcheggiata'),
      ),
    };
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('AutoQui')),
      body: Stack(
        children: [
          Positioned.fill(
            child: widget.showMap
                ? GoogleMap(
                    initialCameraPosition: CameraPosition(
                      target: _parkingPosition ?? _fallbackPosition,
                      zoom: 15,
                    ),
                    markers: _markers,
                    myLocationButtonEnabled: false,
                    myLocationEnabled: false,
                    zoomControlsEnabled: false,
                    onMapCreated: (controller) {
                      _mapController = controller;
                      final parkingPosition = _parkingPosition;
                      if (parkingPosition != null) {
                        _animateTo(parkingPosition);
                      }
                    },
                  )
                : const ColoredBox(color: Color(0xFFDDE7DD)),
          ),
          Positioned(
            left: 16,
            right: 16,
            bottom: 16,
            child: _ParkingActions(
              hasParking: _parkingPosition != null,
              locating: _locating,
              saving: _saving,
              openingRoute: _openingRoute,
              onLocate: _centerOnCurrentLocation,
              onSaveParking: _saveParkingPosition,
              onOpenRoute: _openRouteToParking,
            ),
          ),
        ],
      ),
    );
  }
}

class _ParkingActions extends StatelessWidget {
  const _ParkingActions({
    required this.hasParking,
    required this.locating,
    required this.saving,
    required this.openingRoute,
    required this.onLocate,
    required this.onSaveParking,
    required this.onOpenRoute,
  });

  final bool hasParking;
  final bool locating;
  final bool saving;
  final bool openingRoute;
  final VoidCallback onLocate;
  final VoidCallback onSaveParking;
  final VoidCallback onOpenRoute;

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 8,
      borderRadius: BorderRadius.circular(8),
      color: Theme.of(context).colorScheme.surface,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Wrap(
          spacing: 8,
          runSpacing: 8,
          alignment: WrapAlignment.center,
          children: [
            OutlinedButton.icon(
              onPressed: locating ? null : onLocate,
              icon: locating
                  ? const _ButtonProgress()
                  : const Icon(Icons.my_location),
              label: const Text('Localizza'),
            ),
            FilledButton.icon(
              onPressed: saving ? null : onSaveParking,
              icon: saving
                  ? const _ButtonProgress()
                  : const Icon(Icons.local_parking),
              label: const Text('Salva parcheggio'),
            ),
            if (hasParking)
              FilledButton.tonalIcon(
                onPressed: openingRoute ? null : onOpenRoute,
                icon: openingRoute
                    ? const _ButtonProgress()
                    : const Icon(Icons.directions_walk),
                label: const Text("Vai all'auto"),
              ),
          ],
        ),
      ),
    );
  }
}

class _ButtonProgress extends StatelessWidget {
  const _ButtonProgress();

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: 18,
      child: CircularProgressIndicator(
        strokeWidth: 2,
        color: Theme.of(context).colorScheme.onPrimary,
      ),
    );
  }
}
