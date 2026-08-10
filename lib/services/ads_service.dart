import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'consent_service.dart';

enum AdsStatus {
  consentUnavailable,
  adsNotAllowed,
  adsAllowed,
  mobileAdsInitialized,
}

class AdsService extends ChangeNotifier {
  AdsService._();

  factory AdsService() => instance;

  static final AdsService instance = AdsService._();
  static const enabled = true;
  static const _androidTestBannerAdUnitId =
      'ca-app-pub-3940256099942544/6300978111';
  static const _androidReleaseBannerAdUnitId =
      'ca-app-pub-6373365011893171/2263684330';

  AdsStatus _status = AdsStatus.consentUnavailable;
  Future<void>? _startupFuture;
  Future<void>? _mobileAdsInitializeFuture;
  bool _mobileAdsInitializeStarted = false;

  static String get androidBannerAdUnitId {
    return kReleaseMode
        ? _androidReleaseBannerAdUnitId
        : _androidTestBannerAdUnitId;
  }

  static bool get canRequestAds {
    return enabled &&
        (instance._status == AdsStatus.adsAllowed ||
            instance._status == AdsStatus.mobileAdsInitialized);
  }

  AdsStatus get status => _status;

  bool get mobileAdsInitialized {
    return _status == AdsStatus.mobileAdsInitialized;
  }

  Future<void> initialize() async {
    if (!enabled) {
      return;
    }

    if (_startupFuture != null && _status != AdsStatus.adsNotAllowed) {
      return _startupFuture!;
    }

    _startupFuture = _initializeAfterConsent();
    return _startupFuture!;
  }

  Future<void> _initializeAfterConsent() async {
    final canRequestAds = await ConsentService().gatherConsent();
    if (!canRequestAds) {
      _setStatus(AdsStatus.adsNotAllowed);
      return;
    }

    _setStatus(AdsStatus.adsAllowed);
    await _initializeMobileAdsOnce();
  }

  Future<void> _initializeMobileAdsOnce() {
    if (_mobileAdsInitializeStarted) {
      return _mobileAdsInitializeFuture ?? Future<void>.value();
    }

    _mobileAdsInitializeStarted = true;
    _mobileAdsInitializeFuture = MobileAds.instance
        .initialize()
        .then((_) => _setStatus(AdsStatus.mobileAdsInitialized))
        .catchError((Object error) {
          debugPrint('ADMOB: initialize failed - $error');
        });
    return _mobileAdsInitializeFuture!;
  }

  void _setStatus(AdsStatus status) {
    if (_status == status) {
      return;
    }

    _status = status;
    notifyListeners();
  }
}
