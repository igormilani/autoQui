// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Polish (`pl`).
class AppLocalizationsPl extends AppLocalizations {
  AppLocalizationsPl([String locale = 'pl']) : super(locale);

  @override
  String get appTitle => 'AutoQui';

  @override
  String get settingsTooltip => 'Prywatność i uprawnienia';

  @override
  String get locate => 'Zlokalizuj';

  @override
  String get saveParking => 'Zapisz parking';

  @override
  String get goToCar => 'Do auta';

  @override
  String get youAreHere => 'Jesteś tutaj';

  @override
  String get parkedCar => 'Zaparkowane auto';

  @override
  String lastParkingSaved(Object savedAt) {
    return 'Ostatni zapisany parking: $savedAt';
  }

  @override
  String get parkingSaved => 'Pozycja parkingu zapisana';

  @override
  String get locationReadError => 'Nie mogę teraz odczytać lokalizacji';

  @override
  String get parkingSaveError => 'Nie mogę teraz zapisać parkingu';

  @override
  String get googleMapsOpenError => 'Nie mogę otworzyć Google Maps';

  @override
  String get gpsDisabledError => 'Włącz GPS, aby używać AutoQui';

  @override
  String get locationPermissionDeniedError => 'Brak uprawnienia do lokalizacji';

  @override
  String get disclosureTitle => 'Automatyczne wykrywanie parkowania';

  @override
  String get disclosureBodyLocation =>
      'AutoQui używa lokalizacji także wtedy, gdy aplikacja nie jest otwarta, aby automatycznie wykryć zaparkowanie auta i pomóc je odnaleźć.';

  @override
  String get disclosureBodyPermissions =>
      'Do tej funkcji aplikacja używa lokalizacji w tle, Activity Recognition oraz lokalnych powiadomień z prośbą o potwierdzenie.';

  @override
  String get disclosureBodyLocalData =>
      'Dane pozostają na urządzeniu i nie są wysyłane na serwery AutoQui.';

  @override
  String get cancel => 'Anuluj';

  @override
  String get continueAction => 'Kontynuuj';

  @override
  String get privacyPermissionsTitle => 'Prywatność i uprawnienia';

  @override
  String get back => 'Wstecz';

  @override
  String get backgroundLocationTitle => 'Lokalizacja w tle';

  @override
  String get backgroundLocationBody =>
      'AutoQui może używać lokalizacji, gdy aplikacja nie jest otwarta, aby wykryć możliwe miejsce parkowania i pomóc odnaleźć auto.';

  @override
  String get automaticDetectionTitle => 'Automatyczne wykrywanie';

  @override
  String get automaticDetectionBody =>
      'Activity Recognition pomaga rozpoznać przejście z jazdy do chodzenia lub postoju. AutoQui przygotowuje wtedy pozycję i prosi o potwierdzenie.';

  @override
  String get notificationsTitle => 'Powiadomienia';

  @override
  String get notificationsBody =>
      'Powiadomienia są lokalne i służą do potwierdzenia lub zignorowania wykrytego parkingu.';

  @override
  String get batteryTitle => 'Bateria';

  @override
  String get batteryBody =>
      'Niektóre urządzenia Android mogą ograniczać działanie w tle. AutoQui informuje, jeśli wykrywanie nie jest niezawodne.';

  @override
  String get automaticDetectionSwitchSubtitle =>
      'Używa lokalizacji w tle i Activity Recognition.';

  @override
  String get notificationsSwitchSubtitle =>
      'Pokazuje lokalne alerty o możliwym parkingu.';

  @override
  String get showPrivacyPolicy => 'Pokaż politykę prywatności';

  @override
  String get batteryBackgroundInfo => 'Bateria i działanie w tle';

  @override
  String get showPermissionsDisclosure => 'Pokaż informację o uprawnieniach';

  @override
  String get languageTitle => 'Język';

  @override
  String get languageSubtitle => 'Systemowy lub ręczny';

  @override
  String get languageSystem => 'System';

  @override
  String get automaticDetectionUpdateError =>
      'Nie mogę zaktualizować automatycznego wykrywania';

  @override
  String get notificationsUpdateError => 'Nie mogę zaktualizować powiadomień';

  @override
  String get batterySheetBody1 =>
      'Aby działać poprawnie, niektóre urządzenia Android mogą ograniczać działanie AutoQui w tle.';

  @override
  String get batterySheetBody2 =>
      'Na urządzeniach Samsung, Xiaomi, Oppo, Realme, Huawei i innych oszczędzanie baterii może opóźniać lub blokować automatyczne wykrywanie. W razie problemów sprawdź ustawienia baterii i uruchamiania w tle.';

  @override
  String get privacyPolicyTitle => 'Polityka prywatności';

  @override
  String get privacyPolicyText =>
      'Polityka prywatności - AutoQui\n\nOstatnia aktualizacja: 12 lipca 2026\n\nAutoQui pomaga zapisać pozycję parkowania i odnaleźć auto.\n\nUżywane dane: przybliżona i dokładna lokalizacja, Activity Recognition, lokalne powiadomienia oraz dane techniczne wymagane przez Google Maps i AdMob.\n\nLokalizacja służy do zapisania miejsca parkowania, pokazania auta, nawigacji do niego i automatycznego wykrycia możliwego parkowania. Do tego może być używana lokalizacja w tle.\n\nDane parkowania pozostają lokalnie na urządzeniu. AutoQui nie ma własnego backendu, nie wysyła lokalizacji na serwery AutoQui i nie sprzedaje danych.\n\nPrzechowywanie i usuwanie danych\n\nAutoQui nie przechowuje danych osobowych ani danych lokalizacji na własnych serwerach, ponieważ aplikacja nie korzysta z własnego serwera.\n\nZapisana lokalizacja parkowania jest przechowywana wyłącznie lokalnie na urządzeniu użytkownika do momentu, gdy wystąpi jedna z poniższych sytuacji:\n- użytkownik zapisze nową lokalizację;\n- użytkownik usunie zapisaną lokalizację;\n- użytkownik wyczyści dane aplikacji w ustawieniach urządzenia;\n- aplikacja zostanie odinstalowana.\n\nAutoQui nie może odzyskać ani przechowywać tych informacji po ich usunięciu z urządzenia.\n\nUsługi stron trzecich zintegrowane z aplikacją, w tym Google AdMob, Google Maps i Google Play Services, mogą zbierać i przechowywać dane zgodnie z własnymi politykami prywatności i zasadami przechowywania danych. AutoQui nie kontroluje bezpośrednio okresów przechowywania stosowanych przez te usługi.\n\nAplikacja integruje Google Maps SDK oraz Google Mobile Ads SDK / AdMob, które mogą zbierać dane zgodnie z własnymi zasadami.\n\nUprawnienia Android można w każdej chwili nadać, odmówić lub cofnąć w ustawieniach urządzenia.\n\nKontakt: privacy-autoqui@example.com';
}
