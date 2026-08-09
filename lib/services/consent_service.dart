import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class ConsentService {
  Future<bool> gatherConsent() async {
    debugPrint('UMP: requesting consent info');

    try {
      await _requestConsentInfoUpdate();
      debugPrint('UMP: consent info updated');

      debugPrint('UMP: consent form required check');
      await _loadAndShowConsentFormIfRequired();
      debugPrint('UMP: consent form completed');
    } catch (error) {
      debugPrint('UMP ERROR: $error');
    }

    final allowed = await canRequestAds();
    debugPrint('UMP: canRequestAds = $allowed');
    return allowed;
  }

  Future<bool> canRequestAds() async {
    try {
      return await ConsentInformation.instance.canRequestAds();
    } catch (error) {
      debugPrint('UMP ERROR: canRequestAds $error');
      return false;
    }
  }

  Future<bool> privacyOptionsRequired() async {
    try {
      final status = await ConsentInformation.instance
          .getPrivacyOptionsRequirementStatus();
      debugPrint('UMP: privacy options requirement = $status');
      return status == PrivacyOptionsRequirementStatus.required;
    } catch (error) {
      debugPrint('UMP ERROR: privacy options requirement $error');
      return false;
    }
  }

  Future<void> showPrivacyOptionsForm() async {
    try {
      debugPrint('UMP: showing privacy options form');
      final error = await _showPrivacyOptionsForm();
      if (error != null) {
        debugPrint(
          'UMP ERROR: privacy options form ${error.errorCode}: ${error.message}',
        );
        return;
      }

      final canRequestAds = await this.canRequestAds();
      debugPrint('UMP: privacy options form completed');
      debugPrint('UMP: canRequestAds = $canRequestAds');
    } catch (error) {
      debugPrint('UMP ERROR: privacy options form $error');
    }
  }

  Future<void> _requestConsentInfoUpdate() {
    final completer = Completer<void>();

    ConsentInformation.instance.requestConsentInfoUpdate(
      ConsentRequestParameters(
        consentDebugSettings: kDebugMode
            ? ConsentDebugSettings(
                // Debug EEA is enabled only for debug builds. If UMP logs ask
                // for a debug test identifier, add it here temporarily.
                debugGeography: DebugGeography.debugGeographyEea,
              )
            : null,
      ),
      completer.complete,
      (error) => completer.completeError(
        'consent info ${error.errorCode}: ${error.message}',
      ),
    );

    return completer.future;
  }

  Future<void> _loadAndShowConsentFormIfRequired() {
    final completer = Completer<void>();

    ConsentForm.loadAndShowConsentFormIfRequired((error) {
      if (error == null) {
        completer.complete();
        return;
      }

      completer.completeError(
        'consent form ${error.errorCode}: ${error.message}',
      );
    });

    return completer.future;
  }

  Future<FormError?> _showPrivacyOptionsForm() {
    final completer = Completer<FormError?>();

    ConsentForm.showPrivacyOptionsForm(completer.complete);

    return completer.future;
  }
}
