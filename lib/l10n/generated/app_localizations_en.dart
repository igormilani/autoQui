// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'AutoQui';

  @override
  String get settingsTooltip => 'Privacy and permissions';

  @override
  String get locate => 'Locate';

  @override
  String get saveParking => 'Save parking';

  @override
  String get goToCar => 'Go to car';

  @override
  String get youAreHere => 'You are here';

  @override
  String get parkedCar => 'Parked car';

  @override
  String lastParkingSaved(Object savedAt) {
    return 'Last saved parking: $savedAt';
  }

  @override
  String get parkingSaved => 'Parking position saved';

  @override
  String get locationReadError => 'I cannot read the location right now';

  @override
  String get parkingSaveError => 'I cannot save the parking position right now';

  @override
  String get googleMapsOpenError => 'I cannot open Google Maps';

  @override
  String get gpsDisabledError => 'Turn on GPS to use AutoQui';

  @override
  String get locationPermissionDeniedError => 'Location permission not granted';

  @override
  String get disclosureTitle => 'Automatic parking detection';

  @override
  String get disclosureBodyLocation =>
      'AutoQui uses location even when the app is not open to automatically detect when you park your car and help you find it again.';

  @override
  String get disclosureBodyPermissions =>
      'For this feature, the app uses background location, Activity Recognition to understand when you get out of the car, and local notifications to ask whether you want to save the parking position.';

  @override
  String get disclosureBodyLocalData =>
      'Data stays on your device and is not sent to AutoQui servers.';

  @override
  String get cancel => 'Cancel';

  @override
  String get continueAction => 'Continue';

  @override
  String get privacyPermissionsTitle => 'Privacy and Permissions';

  @override
  String get back => 'Back';

  @override
  String get backgroundLocationTitle => 'Background location';

  @override
  String get backgroundLocationBody =>
      'AutoQui can use location even when the app is not open to detect a possible parking position and help you find your car.';

  @override
  String get automaticDetectionTitle => 'Automatic detection';

  @override
  String get automaticDetectionBody =>
      'Activity Recognition helps understand when you move from driving to walking or stopping. When this happens, AutoQui prepares a candidate position and asks for confirmation.';

  @override
  String get notificationsTitle => 'Notifications';

  @override
  String get notificationsBody =>
      'Notifications are local and are used to ask whether you want to save or ignore a detected parking position.';

  @override
  String get batteryTitle => 'Battery';

  @override
  String get batteryBody =>
      'Some Android devices may limit background activity. AutoQui does not ask you to disable these optimizations immediately, but informs you if detection is not reliable.';

  @override
  String get automaticDetectionSwitchSubtitle =>
      'Uses background location and Activity Recognition.';

  @override
  String get notificationsSwitchSubtitle =>
      'Shows local alerts for possible parking positions.';

  @override
  String get showPrivacyPolicy => 'Show privacy policy';

  @override
  String get batteryBackgroundInfo => 'Battery and background info';

  @override
  String get showPermissionsDisclosure => 'Show permissions disclosure';

  @override
  String get languageTitle => 'Language';

  @override
  String get languageSubtitle => 'System or manual language';

  @override
  String get languageSystem => 'System';

  @override
  String get automaticDetectionUpdateError =>
      'I cannot update automatic detection';

  @override
  String get notificationsUpdateError => 'I cannot update notifications';

  @override
  String get batterySheetBody1 =>
      'To work correctly, some Android devices may limit AutoQui background operation.';

  @override
  String get batterySheetBody2 =>
      'On Samsung, Xiaomi, Oppo, Realme, Huawei and other devices, battery saving settings may delay or block automatic detection. If the feature is not reliable, check the device battery and background startup settings.';

  @override
  String get privacyPolicyTitle => 'Privacy Policy';

  @override
  String get privacyPolicyText =>
      'Privacy Policy - AutoQui\n\nLast updated: July 12, 2026\n\nAutoQui helps you save your parking position and find your car again.\n\nData used by the app:\n- approximate and precise device location;\n- device Activity Recognition;\n- local notifications;\n- technical data required by Google Maps and AdMob.\n\nWhy AutoQui uses location:\n- to save where you parked;\n- to show where the car is;\n- to help you reach the car with map or navigation;\n- to automatically detect a possible parking position.\n\nFor automatic detection, AutoQui may use location even when the app is not open. This feature is used only to detect a possible parking position and show a local confirmation notification.\n\nAutoQui uses Activity Recognition to receive signals such as in vehicle, on foot or walking. These signals help understand when you may have left the car after driving.\n\nParking data stays locally on the device. AutoQui has no proprietary backend, does not send parking location to AutoQui servers and does not sell user data.\n\nData retention and deletion\n\nAutoQui does not store personal data or location data on its own servers, as the app does not operate a proprietary server.\n\nThe saved parking location is stored only locally on the user\'s device until one of the following occurs:\n- the user saves a new location;\n- the user deletes the saved location;\n- the user clears the app data through the device settings;\n- the app is uninstalled.\n\nAutoQui cannot retrieve or retain this information after it has been deleted from the device.\n\nThird-party services integrated into the app, including Google AdMob, Google Maps and Google Play Services, may collect and retain data according to their own privacy policies and data retention practices. AutoQui does not directly control the retention periods applied by those services.\n\nThe app integrates Google Maps SDK and Google Mobile Ads SDK / AdMob. These Google services may collect data according to their own policies.\n\nYou can grant, deny or revoke Android permissions at any time from device settings.\n\nContact: privacy-autoqui@example.com';
}
