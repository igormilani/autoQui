import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'models/parking_spot.dart';
import 'services/app_settings_service.dart';
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
  final _settingsService = AppSettingsService();

  GoogleMapController? _mapController;
  StreamSubscription? _positionSubscription;
  ParkingSpot? _parkingSpot;
  AppSettings _settings = const AppSettings(
    automaticDetectionEnabled: true,
    notificationsEnabled: true,
    prominentDisclosureAccepted: false,
  );
  LatLng? _userPosition;
  bool _locating = false;
  bool _saving = false;
  bool _openingRoute = false;
  bool _settingsLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadSettingsAndStartDetection();
    _loadSavedParking();
    _startUserPositionUpdates();
  }

  Future<void> _loadSettingsAndStartDetection() async {
    final settings = await _settingsService.load();
    if (!mounted) {
      return;
    }

    setState(() {
      _settings = settings;
      _settingsLoaded = true;
    });

    if (!settings.prominentDisclosureAccepted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _showInitialDisclosure();
        }
      });
      return;
    }

    if (settings.automaticDetectionEnabled) {
      await _startParkingDetection();
    }
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

  Future<void> _showInitialDisclosure() async {
    final accepted = await showParkingDisclosureDialog(context);
    if (!mounted) {
      return;
    }

    if (!accepted) {
      await _settingsService.setAutomaticDetectionEnabled(false);
      setState(() {
        _settings = _settings.copyWith(automaticDetectionEnabled: false);
      });
      return;
    }

    await _settingsService.acceptProminentDisclosure();
    final updated = _settings.copyWith(prominentDisclosureAccepted: true);
    setState(() => _settings = updated);

    if (updated.automaticDetectionEnabled) {
      await _startParkingDetection();
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

  Future<void> _openPrivacyAndPermissions() async {
    final updated = await Navigator.of(context).push<AppSettings>(
      MaterialPageRoute(
        builder: (context) => PrivacyPermissionsPage(
          initialSettings: _settings,
          settingsService: _settingsService,
          permissionService: _permissionService,
          detectionService: _detectionService,
        ),
      ),
    );

    if (!mounted || updated == null) {
      return;
    }

    setState(() => _settings = updated);
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
            tooltip: 'Privacy e permessi',
            onPressed: _settingsLoaded ? _openPrivacyAndPermissions : null,
            icon: const Icon(Icons.settings_outlined),
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

Future<bool> showParkingDisclosureDialog(BuildContext context) async {
  final accepted = await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      return AlertDialog(
        icon: const Icon(Icons.privacy_tip_outlined),
        title: const Text('Rilevamento automatico parcheggio'),
        content: const SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'AutoQui usa la posizione anche quando l\'app non e aperta '
                'per rilevare automaticamente quando parcheggi l\'auto e '
                'aiutarti a ritrovarla.',
              ),
              SizedBox(height: 12),
              Text(
                'Per questa funzione l\'app usa la posizione in background, '
                'Activity Recognition per capire quando scendi dall\'auto e '
                'notifiche locali per chiederti se vuoi salvare il parcheggio.',
              ),
              SizedBox(height: 12),
              Text(
                'I dati restano sul dispositivo e non vengono inviati a server '
                'AutoQui.',
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Annulla'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Continua'),
          ),
        ],
      );
    },
  );

  return accepted ?? false;
}

class PrivacyPermissionsPage extends StatefulWidget {
  const PrivacyPermissionsPage({
    super.key,
    required this.initialSettings,
    required this.settingsService,
    required this.permissionService,
    required this.detectionService,
  });

  final AppSettings initialSettings;
  final AppSettingsService settingsService;
  final PermissionService permissionService;
  final ParkingDetectionService detectionService;

  @override
  State<PrivacyPermissionsPage> createState() => _PrivacyPermissionsPageState();
}

class _PrivacyPermissionsPageState extends State<PrivacyPermissionsPage> {
  late AppSettings _settings = widget.initialSettings;
  bool _updatingDetection = false;
  bool _updatingNotifications = false;

  Future<void> _setAutomaticDetection(bool enabled) async {
    setState(() => _updatingDetection = true);

    try {
      if (!enabled) {
        await widget.settingsService.setAutomaticDetectionEnabled(false);
        await widget.detectionService.stop();
        setState(() {
          _settings = _settings.copyWith(automaticDetectionEnabled: false);
        });
        return;
      }

      if (!_settings.prominentDisclosureAccepted) {
        final accepted = await showParkingDisclosureDialog(context);
        if (!accepted) {
          return;
        }
        await widget.settingsService.acceptProminentDisclosure();
        _settings = _settings.copyWith(prominentDisclosureAccepted: true);
      }

      await widget.settingsService.setAutomaticDetectionEnabled(true);
      await widget.permissionService.requestParkingDetectionPermissions();
      await widget.detectionService.start();
      setState(() {
        _settings = _settings.copyWith(automaticDetectionEnabled: true);
      });
    } catch (_) {
      _showMessage('Non riesco ad aggiornare il rilevamento automatico');
    } finally {
      if (mounted) {
        setState(() => _updatingDetection = false);
      }
    }
  }

  Future<void> _setNotifications(bool enabled) async {
    setState(() => _updatingNotifications = true);

    try {
      await widget.settingsService.setNotificationsEnabled(enabled);
      if (enabled) {
        await widget.permissionService.requestNotificationPermission();
      }
      setState(() {
        _settings = _settings.copyWith(notificationsEnabled: enabled);
      });
    } catch (_) {
      _showMessage('Non riesco ad aggiornare le notifiche');
    } finally {
      if (mounted) {
        setState(() => _updatingNotifications = false);
      }
    }
  }

  Future<void> _showPrivacyPolicy() async {
    final policy = await rootBundle.loadString('docs/privacy_policy.md');
    if (!mounted) {
      return;
    }

    await Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (context) => PrivacyPolicyPage(policy: policy),
      ),
    );
  }

  void _showBatteryInfo() {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return const SafeArea(
          child: Padding(
            padding: EdgeInsets.fromLTRB(24, 8, 24, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Batteria e background',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                ),
                SizedBox(height: 12),
                Text(
                  'Per funzionare correttamente, alcuni dispositivi Android '
                  'potrebbero limitare il funzionamento in background di '
                  'AutoQui.',
                ),
                SizedBox(height: 12),
                Text(
                  'Su dispositivi Samsung, Xiaomi, Oppo, Realme, Huawei e '
                  'altri produttori, le impostazioni di risparmio energetico '
                  'possono ritardare o bloccare il rilevamento automatico. '
                  'Se la funzione non e affidabile, controlla le impostazioni '
                  'batteria e avvio in background del dispositivo.',
                ),
              ],
            ),
          ),
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

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) {
          Navigator.of(context).pop(_settings);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Privacy e Permessi'),
          leading: IconButton(
            tooltip: 'Indietro',
            onPressed: () => Navigator.of(context).pop(_settings),
            icon: const Icon(Icons.arrow_back),
          ),
        ),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          children: [
            const _InfoBlock(
              icon: Icons.location_on_outlined,
              title: 'Posizione in background',
              body:
                  'AutoQui puo usare la posizione anche quando l\'app non e '
                  'aperta per rilevare un possibile parcheggio e aiutarti a '
                  'ritrovare l\'auto.',
            ),
            const _InfoBlock(
              icon: Icons.directions_car_filled_outlined,
              title: 'Rilevamento automatico',
              body:
                  'Activity Recognition aiuta a capire quando passi dalla '
                  'guida alla camminata o alla sosta. Quando succede, AutoQui '
                  'prepara una posizione candidata e ti chiede conferma.',
            ),
            const _InfoBlock(
              icon: Icons.notifications_outlined,
              title: 'Notifiche',
              body:
                  'Le notifiche sono locali e servono per chiederti se vuoi '
                  'salvare o ignorare un parcheggio rilevato.',
            ),
            const _InfoBlock(
              icon: Icons.battery_saver_outlined,
              title: 'Batteria',
              body:
                  'Alcuni dispositivi Android possono limitare le attivita in '
                  'background. AutoQui non chiede subito di disattivare queste '
                  'ottimizzazioni, ma ti informa se il rilevamento non e stabile.',
            ),
            const SizedBox(height: 8),
            SwitchListTile(
              secondary: const Icon(Icons.route_outlined),
              title: const Text('Rilevamento automatico'),
              subtitle: const Text(
                'Usa posizione in background e Activity Recognition.',
              ),
              value: _settings.automaticDetectionEnabled,
              onChanged: _updatingDetection ? null : _setAutomaticDetection,
            ),
            SwitchListTile(
              secondary: const Icon(Icons.notifications_active_outlined),
              title: const Text('Notifiche'),
              subtitle: const Text(
                'Mostra avvisi locali di possibile parcheggio.',
              ),
              value: _settings.notificationsEnabled,
              onChanged: _updatingNotifications ? null : _setNotifications,
            ),
            const Divider(height: 24),
            ListTile(
              leading: const Icon(Icons.privacy_tip_outlined),
              title: const Text('Mostra privacy policy'),
              onTap: _showPrivacyPolicy,
            ),
            ListTile(
              leading: const Icon(Icons.battery_alert_outlined),
              title: const Text('Info batteria e background'),
              onTap: _showBatteryInfo,
            ),
            ListTile(
              leading: const Icon(Icons.info_outline),
              title: const Text('Mostra informativa permessi'),
              onTap: () => showParkingDisclosureDialog(context),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoBlock extends StatelessWidget {
  const _InfoBlock({
    required this.icon,
    required this.title,
    required this.body,
  });

  final IconData icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 4),
      leading: Icon(icon),
      title: Text(title),
      subtitle: Text(body),
    );
  }
}

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key, required this.policy});

  final String policy;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Privacy Policy')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: SelectableText(policy),
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
    return '$day/$month $hour:$minute';
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
      adUnitId: AdsService.androidBannerAdUnitId,
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
