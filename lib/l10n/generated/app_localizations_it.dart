// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Italian (`it`).
class AppLocalizationsIt extends AppLocalizations {
  AppLocalizationsIt([String locale = 'it']) : super(locale);

  @override
  String get appTitle => 'AutoQui';

  @override
  String get settingsTooltip => 'Privacy e permessi';

  @override
  String get locate => 'Localizza';

  @override
  String get saveParking => 'Salva parcheggio';

  @override
  String get goToCar => 'Vai all\'auto';

  @override
  String get youAreHere => 'Tu sei qui';

  @override
  String get parkedCar => 'Auto parcheggiata';

  @override
  String lastParkingSaved(Object savedAt) {
    return 'Ultimo parcheggio salvato: $savedAt';
  }

  @override
  String get parkingSaved => 'Posizione parcheggio salvata';

  @override
  String get locationReadError => 'Non riesco a leggere la posizione ora';

  @override
  String get parkingSaveError => 'Non riesco a salvare il parcheggio ora';

  @override
  String get googleMapsOpenError => 'Non riesco ad aprire Google Maps';

  @override
  String get gpsDisabledError => 'Attiva il GPS per usare AutoQui';

  @override
  String get locationPermissionDeniedError => 'Permesso posizione non concesso';

  @override
  String get disclosureTitle => 'Rilevamento automatico parcheggio';

  @override
  String get disclosureBodyLocation =>
      'AutoQui usa la posizione anche quando l\'app non e aperta per rilevare automaticamente quando parcheggi l\'auto e aiutarti a ritrovarla.';

  @override
  String get disclosureBodyPermissions =>
      'Per questa funzione l\'app usa la posizione in background, Activity Recognition per capire quando scendi dall\'auto e notifiche locali per chiederti se vuoi salvare il parcheggio.';

  @override
  String get disclosureBodyLocalData =>
      'I dati restano sul dispositivo e non vengono inviati a server AutoQui.';

  @override
  String get cancel => 'Annulla';

  @override
  String get continueAction => 'Continua';

  @override
  String get privacyPermissionsTitle => 'Privacy e Permessi';

  @override
  String get back => 'Indietro';

  @override
  String get backgroundLocationTitle => 'Posizione in background';

  @override
  String get backgroundLocationBody =>
      'AutoQui puo usare la posizione anche quando l\'app non e aperta per rilevare un possibile parcheggio e aiutarti a ritrovare l\'auto.';

  @override
  String get automaticDetectionTitle => 'Rilevamento automatico';

  @override
  String get automaticDetectionBody =>
      'Activity Recognition aiuta a capire quando passi dalla guida alla camminata o alla sosta. Quando succede, AutoQui prepara una posizione candidata e ti chiede conferma.';

  @override
  String get notificationsTitle => 'Notifiche';

  @override
  String get notificationsBody =>
      'Le notifiche sono locali e servono per chiederti se vuoi salvare o ignorare un parcheggio rilevato.';

  @override
  String get batteryTitle => 'Batteria';

  @override
  String get batteryBody =>
      'Alcuni dispositivi Android possono limitare le attivita in background. AutoQui non chiede subito di disattivare queste ottimizzazioni, ma ti informa se il rilevamento non e stabile.';

  @override
  String get automaticDetectionSwitchSubtitle =>
      'Usa posizione in background e Activity Recognition.';

  @override
  String get notificationsSwitchSubtitle =>
      'Mostra avvisi locali di possibile parcheggio.';

  @override
  String get showPrivacyPolicy => 'Mostra privacy policy';

  @override
  String get adPrivacyOptions => 'Opzioni privacy pubblicitaria';

  @override
  String get batteryBackgroundInfo => 'Info batteria e background';

  @override
  String get showPermissionsDisclosure => 'Mostra informativa permessi';

  @override
  String get languageTitle => 'Lingua';

  @override
  String get languageSubtitle => 'Sistema o lingua manuale';

  @override
  String get languageSystem => 'Sistema';

  @override
  String get automaticDetectionUpdateError =>
      'Non riesco ad aggiornare il rilevamento automatico';

  @override
  String get notificationsUpdateError =>
      'Non riesco ad aggiornare le notifiche';

  @override
  String get batterySheetBody1 =>
      'Per funzionare correttamente, alcuni dispositivi Android potrebbero limitare il funzionamento in background di AutoQui.';

  @override
  String get batterySheetBody2 =>
      'Su dispositivi Samsung, Xiaomi, Oppo, Realme, Huawei e altri produttori, le impostazioni di risparmio energetico possono ritardare o bloccare il rilevamento automatico. Se la funzione non e affidabile, controlla le impostazioni batteria e avvio in background del dispositivo.';

  @override
  String get privacyPolicyTitle => 'Privacy Policy';

  @override
  String get privacyPolicyText =>
      'Privacy Policy - AutoQui\n\nUltimo aggiornamento: 12 luglio 2026\n\nAutoQui aiuta l\'utente a salvare la posizione del parcheggio e a ritrovare l\'auto.\n\nDati usati dall\'app:\n- posizione approssimativa e precisa del dispositivo;\n- rilevamento attivita fisica del dispositivo;\n- notifiche locali;\n- dati tecnici necessari al funzionamento di Google Maps e AdMob.\n\nPerche AutoQui usa la posizione:\n- salvare il punto in cui hai parcheggiato;\n- mostrarti dove si trova l\'auto;\n- aiutarti a raggiungere l\'auto tramite mappa o navigazione;\n- rilevare automaticamente un possibile parcheggio.\n\nPer il rilevamento automatico, AutoQui puo usare la posizione anche quando l\'app non e aperta. Questa funzione serve solo a riconoscere un possibile parcheggio e proporre una notifica locale di conferma.\n\nAutoQui usa Activity Recognition per ricevere segnali come in veicolo, a piedi o camminata. Questi segnali aiutano a capire quando potresti essere uscito dall\'auto dopo aver guidato.\n\nI dati del parcheggio restano localmente sul dispositivo. AutoQui non dispone di un backend proprietario, non invia la posizione a server AutoQui e non vende dati dell\'utente.\n\nConservazione e cancellazione dei dati\n\nAutoQui non memorizza dati personali o dati di localizzazione su propri server, poiche l\'app non dispone di un server proprietario.\n\nLa posizione del parcheggio viene conservata esclusivamente in locale sul dispositivo dell\'utente fino a quando si verifica una delle seguenti condizioni:\n- l\'utente salva una nuova posizione;\n- l\'utente cancella la posizione salvata;\n- l\'utente cancella i dati dell\'app dalle impostazioni del dispositivo;\n- l\'app viene disinstallata.\n\nAutoQui non puo recuperare ne conservare tali dati dopo che sono stati cancellati dal dispositivo.\n\nI servizi di terze parti integrati nell\'app, inclusi Google AdMob, Google Maps e Google Play Services, possono raccogliere e conservare dati in conformita alle rispettive informative sulla privacy e politiche di conservazione. AutoQui non controlla direttamente i periodi di conservazione applicati da tali servizi.\n\nL\'app integra Google Maps SDK e Google Mobile Ads SDK / AdMob. Questi servizi Google possono raccogliere dati secondo le rispettive policy.\n\nPuoi concedere, negare o revocare i permessi Android in qualsiasi momento dalle impostazioni del dispositivo.\n\nContatto: privacy-autoqui@example.com';
}
