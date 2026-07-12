// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get appTitle => 'AutoQui';

  @override
  String get settingsTooltip => 'Datenschutz und Berechtigungen';

  @override
  String get locate => 'Orten';

  @override
  String get saveParking => 'Parkplatz speichern';

  @override
  String get goToCar => 'Zum Auto';

  @override
  String get youAreHere => 'Du bist hier';

  @override
  String get parkedCar => 'Geparktes Auto';

  @override
  String lastParkingSaved(Object savedAt) {
    return 'Zuletzt gespeicherter Parkplatz: $savedAt';
  }

  @override
  String get parkingSaved => 'Parkposition gespeichert';

  @override
  String get locationReadError => 'Standort kann derzeit nicht gelesen werden';

  @override
  String get parkingSaveError =>
      'Parkposition kann derzeit nicht gespeichert werden';

  @override
  String get googleMapsOpenError => 'Google Maps kann nicht geöffnet werden';

  @override
  String get gpsDisabledError => 'Aktiviere GPS, um AutoQui zu verwenden';

  @override
  String get locationPermissionDeniedError =>
      'Standortberechtigung nicht erteilt';

  @override
  String get disclosureTitle => 'Automatische Parkerkennung';

  @override
  String get disclosureBodyLocation =>
      'AutoQui verwendet den Standort auch dann, wenn die App nicht geöffnet ist, um automatisch zu erkennen, wann du dein Auto parkst, und dir beim Wiederfinden zu helfen.';

  @override
  String get disclosureBodyPermissions =>
      'Für diese Funktion verwendet die App Hintergrundstandort, Activity Recognition und lokale Benachrichtigungen zur Bestätigung.';

  @override
  String get disclosureBodyLocalData =>
      'Die Daten bleiben auf deinem Gerät und werden nicht an AutoQui-Server gesendet.';

  @override
  String get cancel => 'Abbrechen';

  @override
  String get continueAction => 'Weiter';

  @override
  String get privacyPermissionsTitle => 'Datenschutz und Berechtigungen';

  @override
  String get back => 'Zurück';

  @override
  String get backgroundLocationTitle => 'Hintergrundstandort';

  @override
  String get backgroundLocationBody =>
      'AutoQui kann den Standort auch bei geschlossener App verwenden, um eine mögliche Parkposition zu erkennen.';

  @override
  String get automaticDetectionTitle => 'Automatische Erkennung';

  @override
  String get automaticDetectionBody =>
      'Activity Recognition hilft zu erkennen, wenn du vom Fahren zum Gehen oder Anhalten wechselst. AutoQui bereitet dann eine Position vor und fragt nach Bestätigung.';

  @override
  String get notificationsTitle => 'Benachrichtigungen';

  @override
  String get notificationsBody =>
      'Benachrichtigungen sind lokal und fragen, ob du eine erkannte Parkposition speichern oder ignorieren möchtest.';

  @override
  String get batteryTitle => 'Akku';

  @override
  String get batteryBody =>
      'Einige Android-Geräte können Hintergrundaktivitäten einschränken. AutoQui informiert dich, wenn die Erkennung dadurch unzuverlässig ist.';

  @override
  String get automaticDetectionSwitchSubtitle =>
      'Verwendet Hintergrundstandort und Activity Recognition.';

  @override
  String get notificationsSwitchSubtitle =>
      'Zeigt lokale Hinweise zu möglichen Parkpositionen.';

  @override
  String get showPrivacyPolicy => 'Datenschutzerklärung anzeigen';

  @override
  String get batteryBackgroundInfo => 'Akku- und Hintergrundinfos';

  @override
  String get showPermissionsDisclosure => 'Berechtigungshinweis anzeigen';

  @override
  String get languageTitle => 'Sprache';

  @override
  String get languageSubtitle => 'System oder manuelle Sprache';

  @override
  String get languageSystem => 'System';

  @override
  String get automaticDetectionUpdateError =>
      'Automatische Erkennung kann nicht aktualisiert werden';

  @override
  String get notificationsUpdateError =>
      'Benachrichtigungen können nicht aktualisiert werden';

  @override
  String get batterySheetBody1 =>
      'Damit AutoQui korrekt funktioniert, können einige Android-Geräte den Hintergrundbetrieb einschränken.';

  @override
  String get batterySheetBody2 =>
      'Auf Samsung, Xiaomi, Oppo, Realme, Huawei und anderen Geräten können Energiespareinstellungen die automatische Erkennung verzögern oder blockieren. Prüfe bei Problemen die Akku- und Hintergrundstart-Einstellungen.';

  @override
  String get privacyPolicyTitle => 'Datenschutzerklärung';

  @override
  String get privacyPolicyText =>
      'Datenschutzerklärung - AutoQui\n\nLetzte Aktualisierung: 12. Juli 2026\n\nAutoQui hilft, die Parkposition zu speichern und das Auto wiederzufinden.\n\nVerwendete Daten: ungefährer und genauer Standort, Activity Recognition, lokale Benachrichtigungen und technische Daten für Google Maps und AdMob.\n\nDer Standort wird verwendet, um den Parkplatz zu speichern, das Auto anzuzeigen, dorthin zu navigieren und automatisch eine mögliche Parkposition zu erkennen. Dafür kann Hintergrundstandort verwendet werden.\n\nParkdaten bleiben lokal auf dem Gerät. AutoQui hat kein eigenes Backend, sendet keine Standortdaten an AutoQui-Server und verkauft keine Nutzerdaten.\n\nDatenspeicherung und Löschung\n\nAutoQui speichert keine personenbezogenen Daten oder Standortdaten auf eigenen Servern, da die App keinen proprietären Server betreibt.\n\nDer gespeicherte Parkplatz wird ausschließlich lokal auf dem Gerät des Nutzers gespeichert, bis einer der folgenden Fälle eintritt:\n- der Nutzer speichert einen neuen Standort;\n- der Nutzer löscht den gespeicherten Standort;\n- der Nutzer löscht die App-Daten in den Geräteeinstellungen;\n- die App wird deinstalliert.\n\nAutoQui kann diese Informationen nicht abrufen oder weiter aufbewahren, nachdem sie vom Gerät gelöscht wurden.\n\nIn die App integrierte Drittanbieterdienste, einschließlich Google AdMob, Google Maps und Google Play Services, können Daten gemäß ihren eigenen Datenschutzerklärungen und Speicherpraktiken erfassen und speichern. AutoQui kontrolliert die von diesen Diensten angewendeten Aufbewahrungsfristen nicht direkt.\n\nDie App integriert Google Maps SDK und Google Mobile Ads SDK / AdMob, die Daten gemäß ihren Richtlinien erfassen können.\n\nAndroid-Berechtigungen können jederzeit in den Geräteeinstellungen gewährt, verweigert oder widerrufen werden.\n\nKontakt: privacy-autoqui@example.com';
}
