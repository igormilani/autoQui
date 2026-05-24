import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'models/parking_spot.dart';
import 'services/ads_service.dart';
import 'services/location_service.dart';
import 'services/navigation_service.dart';
import 'services/parking_detection_service.dart';
import 'services/parking_storage.dart';
import 'services/permission_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AdsService().initialize();
  runApp(const AutoQuiApp());
}

class AutoQuiApp extends StatelessWidget {
  const AutoQuiApp({super.key, this.showMap = true, this.showAds = true});

  final bool showMap;
  final bool showAds;

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
      home: AutoQuiHome(showMap: showMap, showAds: showAds),
    );
  }
}

class AutoQuiHome extends StatefulWidget {
  const AutoQuiHome({super.key, this.showMap = true, this.showAds = true});

  final bool showMap;
  final bool showAds;

  @override
  State<AutoQuiHome> createState() => _AutoQuiHomeState();
}

class _AutoQuiHomeState extends State<AutoQuiHome> {
  static const _fallbackPosition = LatLng(41.9028, 12.4964);

  final _storage = ParkingStorage();
  final _locationService = LocationService();
  final _navigationService = NavigationService();
  final _detectionService = ParkingDetectionService();
  final _permissionService = PermissionService();

  GoogleMapController? _mapController;
  StreamSubscription? _positionSubscription;
  ParkingSpot? _parkingSpot;
  LatLng? _userPosition;
  bool _locating = false;
  bool _saving = false;
  bool _openingRoute = false;

  @override
  void initState() {
    super.initState();
    _loadSavedParking();
    _startParkingDetection();
    _startUserPositionUpdates();
  }

  Future<void> _loadSavedParking() async {
    final parkingSpot = await _storage.loadParkingSpot();
    if (!mounted || parkingSpot == null) {
      return;
    }

    setState(() => _parkingSpot = parkingSpot);
    await _animateTo(parkingSpot.latLng);
  }

  Future<void> _startParkingDetection() async {
    try {
      await _permissionService.requestParkingDetectionPermissions();
      await _detectionService.start();
    } catch (_) {
      // Detection is best-effort: manual parking save remains fully usable.
    }
  }

  Future<void> _startUserPositionUpdates() async {
    try {
      _positionSubscription = _locationService.positionStream().listen((
        position,
      ) {
        if (!mounted) {
          return;
        }

        setState(() {
          _userPosition = LatLng(position.latitude, position.longitude);
        });
      });
    } catch (_) {
      // Permission may not be granted yet; explicit buttons request it later.
    }
  }

  Future<void> _centerOnCurrentLocation() async {
    setState(() => _locating = true);

    try {
      final position = await _locationService.getCurrentPosition();
      if (position == null) {
        return;
      }

      final target = LatLng(position.latitude, position.longitude);
      setState(() => _userPosition = target);
      await _animateTo(target);
    } on LocationException catch (error) {
      _showMessage(error.message);
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
      final position = await _locationService.getCurrentPosition();
      if (position == null) {
        return;
      }

      final parkingSpot = ParkingSpot(
        latitude: position.latitude,
        longitude: position.longitude,
        savedAt: DateTime.now(),
      );

      await _storage.saveParkingSpot(parkingSpot);

      if (!mounted) {
        return;
      }

      setState(() {
        _parkingSpot = parkingSpot;
        _userPosition = parkingSpot.latLng;
      });
      await _animateTo(parkingSpot.latLng);
      _showMessage('Posizione parcheggio salvata');
    } on LocationException catch (error) {
      _showMessage(error.message);
    } catch (_) {
      _showMessage('Non riesco a salvare il parcheggio ora');
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  Future<void> _openRouteToParking() async {
    final parkingSpot = _parkingSpot;
    if (parkingSpot == null) {
      return;
    }

    setState(() => _openingRoute = true);

    try {
      final opened = await _navigationService.openWalkingRoute(
        parkingSpot.latLng,
      );
      if (!opened) {
        _showMessage('Non riesco ad aprire Google Maps');
      }
    } catch (_) {
      _showMessage('Non riesco ad aprire Google Maps');
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

  void _showPrivacyInfo() {
    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Privacy AutoQui'),
          content: const Text(
            'AutoQui usa la posizione esclusivamente per aiutarti a '
            "ritrovare l'auto parcheggiata. I dati restano sul dispositivo "
            'e non vengono inviati a server.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
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
    final markers = <Marker>{};
    final userPosition = _userPosition;
    final parkingSpot = _parkingSpot;

    if (userPosition != null) {
      markers.add(
        Marker(
          markerId: const MarkerId('user_position'),
          position: userPosition,
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueAzure,
          ),
          infoWindow: const InfoWindow(title: 'Tu sei qui'),
        ),
      );
    }

    if (parkingSpot != null) {
      markers.add(
        Marker(
          markerId: const MarkerId('parked_car'),
          position: parkingSpot.latLng,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
          infoWindow: const InfoWindow(title: 'Auto parcheggiata'),
        ),
      );
    }

    return markers;
  }

  @override
  void dispose() {
    _positionSubscription?.cancel();
    _mapController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AutoQui'),
        actions: [
          IconButton(
            tooltip: 'Privacy',
            onPressed: _showPrivacyInfo,
            icon: const Icon(Icons.privacy_tip_outlined),
          ),
        ],
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: widget.showMap
                ? GoogleMap(
                    initialCameraPosition: CameraPosition(
                      target:
                          _parkingSpot?.latLng ??
                          _userPosition ??
                          _fallbackPosition,
                      zoom: 15,
                    ),
                    markers: _markers,
                    circles: _userPosition == null
                        ? const {}
                        : {
                            Circle(
                              circleId: const CircleId('user_accuracy_hint'),
                              center: _userPosition!,
                              radius: 22,
                              fillColor: const Color(0x333B82F6),
                              strokeColor: const Color(0xFF2563EB),
                              strokeWidth: 2,
                            ),
                          },
                    myLocationEnabled: true,
                    myLocationButtonEnabled: false,
                    zoomControlsEnabled: false,
                    onMapCreated: (controller) {
                      _mapController = controller;
                      final parkingSpot = _parkingSpot;
                      if (parkingSpot != null) {
                        _animateTo(parkingSpot.latLng);
                      }
                    },
                  )
                : const ColoredBox(color: Color(0xFFDDE7DD)),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: SafeArea(
              minimum: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _ParkingActions(
                    parkingSpot: _parkingSpot,
                    locating: _locating,
                    saving: _saving,
                    openingRoute: _openingRoute,
                    onLocate: _centerOnCurrentLocation,
                    onSaveParking: _saveParkingPosition,
                    onOpenRoute: _openRouteToParking,
                  ),
                  if (widget.showAds) const _AdBanner(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ParkingActions extends StatelessWidget {
  const _ParkingActions({
    required this.parkingSpot,
    required this.locating,
    required this.saving,
    required this.openingRoute,
    required this.onLocate,
    required this.onSaveParking,
    required this.onOpenRoute,
  });

  final ParkingSpot? parkingSpot;
  final bool locating;
  final bool saving;
  final bool openingRoute;
  final VoidCallback onLocate;
  final VoidCallback onSaveParking;
  final VoidCallback onOpenRoute;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Material(
      elevation: 10,
      shadowColor: Colors.black26,
      borderRadius: BorderRadius.circular(16),
      color: colorScheme.surface,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: locating ? null : onLocate,
                    icon: locating
                        ? const _ButtonProgress()
                        : const Icon(Icons.my_location),
                    label: const Text('Localizza'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: saving ? null : onSaveParking,
                    icon: saving
                        ? const _ButtonProgress()
                        : const Icon(Icons.local_parking),
                    label: const Text('Salva parcheggio'),
                  ),
                ),
              ],
            ),
            if (parkingSpot != null) ...[
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Ultimo parcheggio salvato: ${_formatSavedAt(parkingSpot!.savedAt)}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF1D4ED8),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: openingRoute ? null : onOpenRoute,
                  icon: openingRoute
                      ? const _ButtonProgress()
                      : const Icon(Icons.directions_walk),
                  label: const Text("Vai all'auto"),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatSavedAt(DateTime savedAt) {
    final local = savedAt.toLocal();
    final day = local.day.toString().padLeft(2, '0');
    final month = local.month.toString().padLeft(2, '0');
    final hour = local.hour.toString().padLeft(2, '0');
    final minute = local.minute.toString().padLeft(2, '0');
    return '$day/$month ${hour}:$minute';
  }
}

class _AdBanner extends StatefulWidget {
  const _AdBanner();

  @override
  State<_AdBanner> createState() => _AdBannerState();
}

class _AdBannerState extends State<_AdBanner> {
  BannerAd? _bannerAd;
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    if (!AdsService.enabled) {
      return;
    }

    _bannerAd = BannerAd(
      adUnitId: AdsService.androidTestBannerAdUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) {
          if (mounted) {
            setState(() => _loaded = true);
          }
        },
        onAdFailedToLoad: (ad, _) {
          ad.dispose();
          if (mounted) {
            setState(() {
              _bannerAd = null;
              _loaded = false;
            });
          }
        },
      ),
    )..load();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bannerAd = _bannerAd;
    if (!_loaded || bannerAd == null) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: SizedBox(
        width: bannerAd.size.width.toDouble(),
        height: bannerAd.size.height.toDouble(),
        child: AdWidget(ad: bannerAd),
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
