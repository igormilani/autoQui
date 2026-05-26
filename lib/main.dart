import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'package:auto_qui/l10n/generated/app_localizations.dart';

import 'models/parking_spot.dart';
import 'services/app_settings_service.dart';
import 'services/ads_service.dart';
import 'services/language_service.dart';
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
  const AutoQuiApp({
    super.key,
    this.showMap = true,
    this.showAds = true,
    this.settingsService,
  });

  final bool showMap;
  final bool showAds;
  final AppSettingsService? settingsService;

  @override
  Widget build(BuildContext context) {
    const seed = Color(0xFF0E7C66);

    final appSettingsService = settingsService ?? AppSettingsService();

    return _LanguageScope(
      settingsService: appSettingsService,
      builder: (context, languageController) {
        return AnimatedBuilder(
          animation: languageController,
          builder: (context, _) {
            return MaterialApp(
              debugShowCheckedModeBanner: false,
              title: 'AutoQui',
              locale: languageController.locale,
              supportedLocales: AppLocalizations.supportedLocales,
              localizationsDelegates: const [
                AppLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
              ],
              localeListResolutionCallback: (locales, supportedLocales) {
                for (final locale in locales ?? const <Locale>[]) {
                  for (final supportedLocale in supportedLocales) {
                    if (supportedLocale.languageCode == locale.languageCode) {
                      return supportedLocale;
                    }
                  }
                }
                return const Locale('en');
              },
              theme: ThemeData(
                useMaterial3: true,
                colorScheme: ColorScheme.fromSeed(seedColor: seed),
              ),
              home: AutoQuiHome(
                showMap: showMap,
                showAds: showAds,
                settingsService: appSettingsService,
                languageController: languageController,
              ),
            );
          },
        );
      },
    );
  }
}

class _LanguageScope extends StatefulWidget {
  const _LanguageScope({required this.settingsService, required this.builder});

  final AppSettingsService settingsService;
  final Widget Function(BuildContext, LanguageController) builder;

  @override
  State<_LanguageScope> createState() => _LanguageScopeState();
}

class _LanguageScopeState extends State<_LanguageScope> {
  late final LanguageController _languageController;

  @override
  void initState() {
    super.initState();
    _languageController = LanguageController(widget.settingsService)..load();
  }

  @override
  void dispose() {
    _languageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(context, _languageController);
  }
}

extension L10nContext on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
}

class AutoQuiHome extends StatefulWidget {
  const AutoQuiHome({
    super.key,
    this.showMap = true,
    this.showAds = true,
    required this.settingsService,
    required this.languageController,
  });

  final bool showMap;
  final bool showAds;
  final AppSettingsService settingsService;
  final LanguageController languageController;

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
  late final AppSettingsService _settingsService = widget.settingsService;

  GoogleMapController? _mapController;
  StreamSubscription? _positionSubscription;
  ParkingSpot? _parkingSpot;
  AppSettings _settings = const AppSettings(
    automaticDetectionEnabled: true,
    notificationsEnabled: true,
    prominentDisclosureAccepted: false,
    languageCode: null,
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
      _showMessage(_locationErrorMessage(error));
    } catch (_) {
      _showMessage(context.l10n.locationReadError);
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
      _showMessage(context.l10n.parkingSaved);
    } on LocationException catch (error) {
      _showMessage(_locationErrorMessage(error));
    } catch (_) {
      _showMessage(context.l10n.parkingSaveError);
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
        _showMessage(context.l10n.googleMapsOpenError);
      }
    } catch (_) {
      _showMessage(context.l10n.googleMapsOpenError);
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
          languageController: widget.languageController,
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

  Future<void> _setLanguageFromHeader(String value) async {
    final languageCode = value == _AutoQuiHeader.systemLanguageValue
        ? null
        : value;

    await widget.languageController.setLanguageCode(languageCode);
    if (!mounted) {
      return;
    }

    setState(() {
      _settings = _settings.copyWith(
        languageCode: languageCode,
        clearLanguageCode: languageCode == null,
      );
    });
  }

  void _showMessage(String message) {
    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  String _locationErrorMessage(LocationException error) {
    return switch (error.code) {
      LocationExceptionCode.gpsDisabled => context.l10n.gpsDisabledError,
      LocationExceptionCode.permissionDenied =>
        context.l10n.locationPermissionDeniedError,
    };
  }

  Set<Marker> get _markers {
    final l10n = context.l10n;
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
          infoWindow: InfoWindow(title: l10n.youAreHere),
        ),
      );
    }

    if (parkingSpot != null) {
      markers.add(
        Marker(
          markerId: const MarkerId('parked_car'),
          position: parkingSpot.latLng,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
          infoWindow: InfoWindow(title: l10n.parkedCar),
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
      appBar: _AutoQuiHeader(
        parkingSpot: _parkingSpot,
        userPosition: _userPosition,
        languageController: widget.languageController,
        settingsLoaded: _settingsLoaded,
        onSettingsPressed: _openPrivacyAndPermissions,
        onLanguageSelected: _setLanguageFromHeader,
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

class _AutoQuiHeader extends StatelessWidget implements PreferredSizeWidget {
  const _AutoQuiHeader({
    required this.parkingSpot,
    required this.userPosition,
    required this.languageController,
    required this.settingsLoaded,
    required this.onSettingsPressed,
    required this.onLanguageSelected,
  });

  static const height = 84.0;
  static const systemLanguageValue = 'system';

  final ParkingSpot? parkingSpot;
  final LatLng? userPosition;
  final LanguageController languageController;
  final bool settingsLoaded;
  final VoidCallback onSettingsPressed;
  final ValueChanged<String> onLanguageSelected;

  @override
  Size get preferredSize => const Size.fromHeight(height);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final currentLanguage = languageController.languageCode;
    final selectedLanguage = currentLanguage ?? systemLanguageValue;
    final foreground = isDark ? colorScheme.onSurface : colorScheme.onPrimary;

    return Material(
      color: Colors.transparent,
      elevation: 0,
      child: Container(
        decoration: BoxDecoration(
          color: isDark
              ? colorScheme.surfaceContainerHigh
              : const Color(0xFF0E7C66),
          borderRadius: const BorderRadius.vertical(
            bottom: Radius.circular(22),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.26 : 0.14),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: SafeArea(
          bottom: false,
          child: SizedBox(
            height: height,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 10, 12),
              child: Row(
                children: [
                  _AutoQuiLogo(isDark: isDark),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'AutoQui',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.titleLarge?.copyWith(
                            color: foreground,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0,
                          ),
                        ),
                        const SizedBox(height: 2),
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 220),
                          switchInCurve: Curves.easeOutCubic,
                          switchOutCurve: Curves.easeInCubic,
                          child: Text(
                            _subtitle(context),
                            key: ValueKey(_subtitle(context)),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: foreground.withValues(alpha: 0.82),
                              fontWeight: FontWeight.w500,
                              letterSpacing: 0,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 6),
                  _HeaderLanguageMenu(
                    selectedLanguage: selectedLanguage,
                    foreground: foreground,
                    onSelected: onLanguageSelected,
                  ),
                  IconButton(
                    tooltip: context.l10n.settingsTooltip,
                    onPressed: settingsLoaded ? onSettingsPressed : null,
                    icon: const Icon(Icons.settings_outlined),
                    color: foreground,
                    disabledColor: foreground.withValues(alpha: 0.38),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _subtitle(BuildContext context) {
    final spot = parkingSpot;
    if (spot == null) {
      return _emptySubtitle(context);
    }

    final position = userPosition;
    if (position == null) {
      return _savedSubtitle(context);
    }

    final meters = Geolocator.distanceBetween(
      position.latitude,
      position.longitude,
      spot.latitude,
      spot.longitude,
    );

    return _distanceSubtitle(context, meters);
  }

  String _emptySubtitle(BuildContext context) {
    return switch (Localizations.localeOf(context).languageCode) {
      'it' => 'Nessun parcheggio salvato',
      'es' => 'Ningun aparcamiento guardado',
      'fr' => 'Aucun stationnement enregistre',
      'de' => 'Kein Parkplatz gespeichert',
      'pl' => 'Brak zapisanego parkingu',
      'pt' => 'Nenhum estacionamento guardado',
      _ => 'No saved parking',
    };
  }

  String _savedSubtitle(BuildContext context) {
    return switch (Localizations.localeOf(context).languageCode) {
      'it' => 'Auto salvata, distanza non disponibile',
      'es' => 'Coche guardado, distancia no disponible',
      'fr' => 'Voiture enregistree, distance indisponible',
      'de' => 'Auto gespeichert, Entfernung nicht verfuegbar',
      'pl' => 'Auto zapisane, odleglosc niedostepna',
      'pt' => 'Carro guardado, distancia indisponivel',
      _ => 'Car saved, distance unavailable',
    };
  }

  String _distanceSubtitle(BuildContext context, double meters) {
    final roundedMeters = meters.round();
    final value = roundedMeters >= 1000
        ? '${(roundedMeters / 1000).toStringAsFixed(1)} km'
        : '$roundedMeters m';

    return switch (Localizations.localeOf(context).languageCode) {
      'it' => 'Auto a $value da te',
      'es' => 'Coche a $value de ti',
      'fr' => 'Voiture a $value de vous',
      'de' => 'Auto $value entfernt',
      'pl' => 'Auto $value od Ciebie',
      'pt' => 'Carro a $value de si',
      _ => 'Car $value away',
    };
  }
}

class _AutoQuiLogo extends StatelessWidget {
  const _AutoQuiLogo({required this.isDark});

  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF123F35) : Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: isDark ? const Color(0xFF2DD4BF) : const Color(0xFFE5F6F2),
        ),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Icon(
            Icons.directions_car_filled_outlined,
            color: isDark ? const Color(0xFF7DD3C7) : const Color(0xFF0E7C66),
            size: 27,
          ),
          Positioned(
            right: 7,
            bottom: 7,
            child: Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF2DD4BF)
                    : const Color(0xFFB7F2E5),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(
                Icons.place,
                color: isDark
                    ? const Color(0xFF07332B)
                    : const Color(0xFF075E52),
                size: 11,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeaderLanguageMenu extends StatelessWidget {
  const _HeaderLanguageMenu({
    required this.selectedLanguage,
    required this.foreground,
    required this.onSelected,
  });

  final String selectedLanguage;
  final Color foreground;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      tooltip: context.l10n.languageTitle,
      initialValue: selectedLanguage,
      onSelected: onSelected,
      icon: Container(
        width: 40,
        height: 40,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: foreground.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: foreground.withValues(alpha: 0.14)),
        ),
        child: Text(
          _languageEmoji(selectedLanguage),
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontSize: 20,
            letterSpacing: 0,
          ),
        ),
      ),
      itemBuilder: (context) => [
        PopupMenuItem<String>(
          value: _AutoQuiHeader.systemLanguageValue,
          child: Text('🌐 ${context.l10n.languageSystem}'),
        ),
        for (final option in supportedLanguageOptions)
          PopupMenuItem<String>(
            value: option.code,
            child: Text(
              '${option.flag} ${option.code.toUpperCase()} - ${option.nativeName}',
            ),
          ),
      ],
    );
  }

  String _languageEmoji(String languageCode) {
    if (languageCode == _AutoQuiHeader.systemLanguageValue) {
      return '🌐';
    }

    for (final option in supportedLanguageOptions) {
      if (option.code == languageCode) {
        return option.flag;
      }
    }

    return '🇬🇧';
  }
}

Future<bool> showParkingDisclosureDialog(BuildContext context) async {
  final l10n = context.l10n;
  final accepted = await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      return AlertDialog(
        icon: const Icon(Icons.privacy_tip_outlined),
        title: Text(l10n.disclosureTitle),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10n.disclosureBodyLocation),
              const SizedBox(height: 12),
              Text(l10n.disclosureBodyPermissions),
              const SizedBox(height: 12),
              Text(l10n.disclosureBodyLocalData),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.continueAction),
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
    required this.languageController,
    required this.permissionService,
    required this.detectionService,
  });

  final AppSettings initialSettings;
  final AppSettingsService settingsService;
  final LanguageController languageController;
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
    final updateErrorMessage = context.l10n.automaticDetectionUpdateError;

    try {
      if (!enabled) {
        await widget.settingsService.setAutomaticDetectionEnabled(false);
        await widget.detectionService.stop();
        if (!mounted) {
          return;
        }
        setState(() {
          _settings = _settings.copyWith(automaticDetectionEnabled: false);
        });
        return;
      }

      if (!_settings.prominentDisclosureAccepted) {
        final accepted = await showParkingDisclosureDialog(context);
        if (!mounted) {
          return;
        }
        if (!accepted) {
          return;
        }
        await widget.settingsService.acceptProminentDisclosure();
        _settings = _settings.copyWith(prominentDisclosureAccepted: true);
      }

      await widget.settingsService.setAutomaticDetectionEnabled(true);
      await widget.permissionService.requestParkingDetectionPermissions();
      await widget.detectionService.start();
      if (!mounted) {
        return;
      }
      setState(() {
        _settings = _settings.copyWith(automaticDetectionEnabled: true);
      });
    } catch (_) {
      _showMessage(updateErrorMessage);
    } finally {
      if (mounted) {
        setState(() => _updatingDetection = false);
      }
    }
  }

  Future<void> _setNotifications(bool enabled) async {
    setState(() => _updatingNotifications = true);
    final updateErrorMessage = context.l10n.notificationsUpdateError;

    try {
      await widget.settingsService.setNotificationsEnabled(enabled);
      if (enabled) {
        await widget.permissionService.requestNotificationPermission();
      }
      if (!mounted) {
        return;
      }
      setState(() {
        _settings = _settings.copyWith(notificationsEnabled: enabled);
      });
    } catch (_) {
      _showMessage(updateErrorMessage);
    } finally {
      if (mounted) {
        setState(() => _updatingNotifications = false);
      }
    }
  }

  Future<void> _showPrivacyPolicy() async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute(builder: (context) => const PrivacyPolicyPage()),
    );
  }

  Future<void> _chooseLanguage() async {
    const systemLanguageValue = 'system';
    final selected = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        final l10n = context.l10n;
        final currentCode = widget.languageController.languageCode;
        final groupValue = currentCode ?? systemLanguageValue;

        return SafeArea(
          child: RadioGroup<String>(
            groupValue: groupValue,
            onChanged: (value) => Navigator.of(context).pop(value),
            child: ListView(
              shrinkWrap: true,
              children: [
                ListTile(
                  title: Text(
                    l10n.languageTitle,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                RadioListTile<String>(
                  value: systemLanguageValue,
                  secondary: const Text('🌐', style: TextStyle(fontSize: 24)),
                  title: Text(l10n.languageSystem),
                  subtitle: const Text('system'),
                ),
                for (final option in supportedLanguageOptions)
                  RadioListTile<String>(
                    value: option.code,
                    secondary: Text(
                      option.flag,
                      style: const TextStyle(fontSize: 24),
                    ),
                    title: Text(option.nativeName),
                    subtitle: Text(option.code),
                  ),
              ],
            ),
          ),
        );
      },
    );

    if (!mounted) {
      return;
    }

    if (selected == null) {
      return;
    }

    final languageCode = selected == systemLanguageValue ? null : selected;
    await widget.languageController.setLanguageCode(languageCode);
    if (!mounted) {
      return;
    }
    setState(() {
      _settings = _settings.copyWith(
        languageCode: languageCode,
        clearLanguageCode: languageCode == null,
      );
    });
  }

  void _showBatteryInfo() {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        final l10n = context.l10n;

        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.batteryBackgroundInfo,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                Text(l10n.batterySheetBody1),
                const SizedBox(height: 12),
                Text(l10n.batterySheetBody2),
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

  String _languageSubtitle(AppLocalizations l10n) {
    final selectedLanguage = widget.languageController.languageCode;
    if (selectedLanguage == null) {
      return l10n.languageSystem;
    }

    for (final option in supportedLanguageOptions) {
      if (option.code == selectedLanguage) {
        return '${option.flag} ${option.nativeName} (${option.code})';
      }
    }

    return selectedLanguage;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final languageSubtitle = _languageSubtitle(l10n);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) {
          Navigator.of(context).pop(_settings);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.privacyPermissionsTitle),
          leading: IconButton(
            tooltip: l10n.back,
            onPressed: () => Navigator.of(context).pop(_settings),
            icon: const Icon(Icons.arrow_back),
          ),
        ),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          children: [
            _InfoBlock(
              icon: Icons.location_on_outlined,
              title: l10n.backgroundLocationTitle,
              body: l10n.backgroundLocationBody,
            ),
            _InfoBlock(
              icon: Icons.directions_car_filled_outlined,
              title: l10n.automaticDetectionTitle,
              body: l10n.automaticDetectionBody,
            ),
            _InfoBlock(
              icon: Icons.notifications_outlined,
              title: l10n.notificationsTitle,
              body: l10n.notificationsBody,
            ),
            _InfoBlock(
              icon: Icons.battery_saver_outlined,
              title: l10n.batteryTitle,
              body: l10n.batteryBody,
            ),
            const SizedBox(height: 8),
            SwitchListTile(
              secondary: const Icon(Icons.route_outlined),
              title: Text(l10n.automaticDetectionTitle),
              subtitle: Text(l10n.automaticDetectionSwitchSubtitle),
              value: _settings.automaticDetectionEnabled,
              onChanged: _updatingDetection ? null : _setAutomaticDetection,
            ),
            SwitchListTile(
              secondary: const Icon(Icons.notifications_active_outlined),
              title: Text(l10n.notificationsTitle),
              subtitle: Text(l10n.notificationsSwitchSubtitle),
              value: _settings.notificationsEnabled,
              onChanged: _updatingNotifications ? null : _setNotifications,
            ),
            ListTile(
              leading: const Icon(Icons.language_outlined),
              title: Text(l10n.languageTitle),
              subtitle: Text(languageSubtitle),
              onTap: _chooseLanguage,
            ),
            const Divider(height: 24),
            ListTile(
              leading: const Icon(Icons.privacy_tip_outlined),
              title: Text(l10n.showPrivacyPolicy),
              onTap: _showPrivacyPolicy,
            ),
            ListTile(
              leading: const Icon(Icons.battery_alert_outlined),
              title: Text(l10n.batteryBackgroundInfo),
              onTap: _showBatteryInfo,
            ),
            ListTile(
              leading: const Icon(Icons.info_outline),
              title: Text(l10n.showPermissionsDisclosure),
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
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.privacyPolicyTitle)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: SelectableText(l10n.privacyPolicyText),
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
    final l10n = context.l10n;

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
                    label: Text(l10n.locate),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: saving ? null : onSaveParking,
                    icon: saving
                        ? const _ButtonProgress()
                        : const Icon(Icons.local_parking),
                    label: Text(l10n.saveParking),
                  ),
                ),
              ],
            ),
            if (parkingSpot != null) ...[
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  l10n.lastParkingSaved(_formatSavedAt(parkingSpot!.savedAt)),
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
                  label: Text(l10n.goToCar),
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
