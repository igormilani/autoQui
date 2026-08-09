import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_it.dart';
import 'app_localizations_pl.dart';
import 'app_localizations_pt.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('de'),
    Locale('en'),
    Locale('es'),
    Locale('fr'),
    Locale('it'),
    Locale('pl'),
    Locale('pt'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'AutoQui'**
  String get appTitle;

  /// No description provided for @settingsTooltip.
  ///
  /// In en, this message translates to:
  /// **'Privacy and permissions'**
  String get settingsTooltip;

  /// No description provided for @locate.
  ///
  /// In en, this message translates to:
  /// **'Locate'**
  String get locate;

  /// No description provided for @saveParking.
  ///
  /// In en, this message translates to:
  /// **'Save parking'**
  String get saveParking;

  /// No description provided for @goToCar.
  ///
  /// In en, this message translates to:
  /// **'Go to car'**
  String get goToCar;

  /// No description provided for @youAreHere.
  ///
  /// In en, this message translates to:
  /// **'You are here'**
  String get youAreHere;

  /// No description provided for @parkedCar.
  ///
  /// In en, this message translates to:
  /// **'Parked car'**
  String get parkedCar;

  /// No description provided for @lastParkingSaved.
  ///
  /// In en, this message translates to:
  /// **'Last saved parking: {savedAt}'**
  String lastParkingSaved(Object savedAt);

  /// No description provided for @parkingSaved.
  ///
  /// In en, this message translates to:
  /// **'Parking position saved'**
  String get parkingSaved;

  /// No description provided for @locationReadError.
  ///
  /// In en, this message translates to:
  /// **'I cannot read the location right now'**
  String get locationReadError;

  /// No description provided for @parkingSaveError.
  ///
  /// In en, this message translates to:
  /// **'I cannot save the parking position right now'**
  String get parkingSaveError;

  /// No description provided for @googleMapsOpenError.
  ///
  /// In en, this message translates to:
  /// **'I cannot open Google Maps'**
  String get googleMapsOpenError;

  /// No description provided for @gpsDisabledError.
  ///
  /// In en, this message translates to:
  /// **'Turn on GPS to use AutoQui'**
  String get gpsDisabledError;

  /// No description provided for @locationPermissionDeniedError.
  ///
  /// In en, this message translates to:
  /// **'Location permission not granted'**
  String get locationPermissionDeniedError;

  /// No description provided for @disclosureTitle.
  ///
  /// In en, this message translates to:
  /// **'Automatic parking detection'**
  String get disclosureTitle;

  /// No description provided for @disclosureBodyLocation.
  ///
  /// In en, this message translates to:
  /// **'AutoQui uses location even when the app is not open to automatically detect when you park your car and help you find it again.'**
  String get disclosureBodyLocation;

  /// No description provided for @disclosureBodyPermissions.
  ///
  /// In en, this message translates to:
  /// **'For this feature, the app uses background location, Activity Recognition to understand when you get out of the car, and local notifications to ask whether you want to save the parking position.'**
  String get disclosureBodyPermissions;

  /// No description provided for @disclosureBodyLocalData.
  ///
  /// In en, this message translates to:
  /// **'Data stays on your device and is not sent to AutoQui servers.'**
  String get disclosureBodyLocalData;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @continueAction.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueAction;

  /// No description provided for @privacyPermissionsTitle.
  ///
  /// In en, this message translates to:
  /// **'Privacy and Permissions'**
  String get privacyPermissionsTitle;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @backgroundLocationTitle.
  ///
  /// In en, this message translates to:
  /// **'Background location'**
  String get backgroundLocationTitle;

  /// No description provided for @backgroundLocationBody.
  ///
  /// In en, this message translates to:
  /// **'AutoQui can use location even when the app is not open to detect a possible parking position and help you find your car.'**
  String get backgroundLocationBody;

  /// No description provided for @automaticDetectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Automatic detection'**
  String get automaticDetectionTitle;

  /// No description provided for @automaticDetectionBody.
  ///
  /// In en, this message translates to:
  /// **'Activity Recognition helps understand when you move from driving to walking or stopping. When this happens, AutoQui prepares a candidate position and asks for confirmation.'**
  String get automaticDetectionBody;

  /// No description provided for @notificationsTitle.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notificationsTitle;

  /// No description provided for @notificationsBody.
  ///
  /// In en, this message translates to:
  /// **'Notifications are local and are used to ask whether you want to save or ignore a detected parking position.'**
  String get notificationsBody;

  /// No description provided for @batteryTitle.
  ///
  /// In en, this message translates to:
  /// **'Battery'**
  String get batteryTitle;

  /// No description provided for @batteryBody.
  ///
  /// In en, this message translates to:
  /// **'Some Android devices may limit background activity. AutoQui does not ask you to disable these optimizations immediately, but informs you if detection is not reliable.'**
  String get batteryBody;

  /// No description provided for @automaticDetectionSwitchSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Uses background location and Activity Recognition.'**
  String get automaticDetectionSwitchSubtitle;

  /// No description provided for @notificationsSwitchSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Shows local alerts for possible parking positions.'**
  String get notificationsSwitchSubtitle;

  /// No description provided for @showPrivacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Show privacy policy'**
  String get showPrivacyPolicy;

  /// No description provided for @adPrivacyOptions.
  ///
  /// In en, this message translates to:
  /// **'Ad privacy options'**
  String get adPrivacyOptions;

  /// No description provided for @batteryBackgroundInfo.
  ///
  /// In en, this message translates to:
  /// **'Battery and background info'**
  String get batteryBackgroundInfo;

  /// No description provided for @showPermissionsDisclosure.
  ///
  /// In en, this message translates to:
  /// **'Show permissions disclosure'**
  String get showPermissionsDisclosure;

  /// No description provided for @languageTitle.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get languageTitle;

  /// No description provided for @languageSubtitle.
  ///
  /// In en, this message translates to:
  /// **'System or manual language'**
  String get languageSubtitle;

  /// No description provided for @languageSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get languageSystem;

  /// No description provided for @automaticDetectionUpdateError.
  ///
  /// In en, this message translates to:
  /// **'I cannot update automatic detection'**
  String get automaticDetectionUpdateError;

  /// No description provided for @notificationsUpdateError.
  ///
  /// In en, this message translates to:
  /// **'I cannot update notifications'**
  String get notificationsUpdateError;

  /// No description provided for @batterySheetBody1.
  ///
  /// In en, this message translates to:
  /// **'To work correctly, some Android devices may limit AutoQui background operation.'**
  String get batterySheetBody1;

  /// No description provided for @batterySheetBody2.
  ///
  /// In en, this message translates to:
  /// **'On Samsung, Xiaomi, Oppo, Realme, Huawei and other devices, battery saving settings may delay or block automatic detection. If the feature is not reliable, check the device battery and background startup settings.'**
  String get batterySheetBody2;

  /// No description provided for @privacyPolicyTitle.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicyTitle;

  /// No description provided for @privacyPolicyText.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy - AutoQui\n\nLast updated: July 12, 2026\n\nAutoQui helps you save your parking position and find your car again.\n\nData used by the app:\n- approximate and precise device location;\n- device Activity Recognition;\n- local notifications;\n- technical data required by Google Maps and AdMob.\n\nWhy AutoQui uses location:\n- to save where you parked;\n- to show where the car is;\n- to help you reach the car with map or navigation;\n- to automatically detect a possible parking position.\n\nFor automatic detection, AutoQui may use location even when the app is not open. This feature is used only to detect a possible parking position and show a local confirmation notification.\n\nAutoQui uses Activity Recognition to receive signals such as in vehicle, on foot or walking. These signals help understand when you may have left the car after driving.\n\nParking data stays locally on the device. AutoQui has no proprietary backend, does not send parking location to AutoQui servers and does not sell user data.\n\nData retention and deletion\n\nAutoQui does not store personal data or location data on its own servers, as the app does not operate a proprietary server.\n\nThe saved parking location is stored only locally on the user\'s device until one of the following occurs:\n- the user saves a new location;\n- the user deletes the saved location;\n- the user clears the app data through the device settings;\n- the app is uninstalled.\n\nAutoQui cannot retrieve or retain this information after it has been deleted from the device.\n\nThird-party services integrated into the app, including Google AdMob, Google Maps and Google Play Services, may collect and retain data according to their own privacy policies and data retention practices. AutoQui does not directly control the retention periods applied by those services.\n\nThe app integrates Google Maps SDK and Google Mobile Ads SDK / AdMob. These Google services may collect data according to their own policies.\n\nYou can grant, deny or revoke Android permissions at any time from device settings.\n\nContact: privacy-autoqui@example.com'**
  String get privacyPolicyText;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
    'de',
    'en',
    'es',
    'fr',
    'it',
    'pl',
    'pt',
  ].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'fr':
      return AppLocalizationsFr();
    case 'it':
      return AppLocalizationsIt();
    case 'pl':
      return AppLocalizationsPl();
    case 'pt':
      return AppLocalizationsPt();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
