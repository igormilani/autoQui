import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdsService {
  static const enabled = true;
  static const androidTestBannerAdUnitId =
      'ca-app-pub-3940256099942544/6300978111';

  Future<void> initialize() async {
    if (!enabled) {
      return;
    }

    await MobileAds.instance.initialize();
  }
}
