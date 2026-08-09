import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'consent_service.dart';

class AdsService {
  static const enabled = true;
  static const _temporaryDiagnosticTestDeviceIds = [
    // TEMPORARY AdMob test device IDs for local diagnostics. Remove before
    // the next Play Store release; these are not AdMob app or ad unit IDs.
    'EE0AC6C0CDBC3B40BC40F20E8BB90BE3',
    '7C7A33B660490CEAFEBB280D55958381',
  ];
  static const _androidTestBannerAdUnitId =
      'ca-app-pub-3940256099942544/6300978111';
  static const _androidReleaseBannerAdUnitId =
      'ca-app-pub-6373365011893171/2263684330';
  static bool _canRequestAds = false;

  static String get androidBannerAdUnitId {
    return kReleaseMode
        ? _androidReleaseBannerAdUnitId
        : _androidTestBannerAdUnitId;
  }

  static bool get canRequestAds => enabled && _canRequestAds;

  Future<void> initialize() async {
    if (!enabled) {
      return;
    }

    _canRequestAds = await ConsentService().gatherConsent();
    if (!_canRequestAds) {
      debugPrint('ADMOB: initialization skipped because canRequestAds is false');
      return;
    }

    if (!kReleaseMode) {
      await MobileAds.instance.updateRequestConfiguration(
        RequestConfiguration(testDeviceIds: _temporaryDiagnosticTestDeviceIds),
      );
      debugPrint('ADMOB: test device configuration applied');
    }

    await MobileAds.instance.initialize();
  }
}
