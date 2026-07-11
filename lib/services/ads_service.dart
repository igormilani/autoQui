import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdsService {
  static const enabled = true;
  static const _androidTestBannerAdUnitId =
      'ca-app-pub-3940256099942544/6300978111';
  static const _androidReleaseBannerAdUnitId =
      'ca-app-pub-6373365011893171/2263684330';

  static String get androidBannerAdUnitId {
    return kReleaseMode
        ? _androidReleaseBannerAdUnitId
        : _androidTestBannerAdUnitId;
  }

  Future<void> initialize() async {
    if (!enabled) {
      return;
    }

    await MobileAds.instance.initialize();
  }
}
