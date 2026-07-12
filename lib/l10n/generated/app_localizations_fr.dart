// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'AutoQui';

  @override
  String get settingsTooltip => 'Confidentialité et autorisations';

  @override
  String get locate => 'Localiser';

  @override
  String get saveParking => 'Enregistrer';

  @override
  String get goToCar => 'Aller à la voiture';

  @override
  String get youAreHere => 'Vous êtes ici';

  @override
  String get parkedCar => 'Voiture garée';

  @override
  String lastParkingSaved(Object savedAt) {
    return 'Dernier stationnement enregistré : $savedAt';
  }

  @override
  String get parkingSaved => 'Position de stationnement enregistrée';

  @override
  String get locationReadError => 'Impossible de lire la position maintenant';

  @override
  String get parkingSaveError =>
      'Impossible d\'enregistrer le stationnement maintenant';

  @override
  String get googleMapsOpenError => 'Impossible d\'ouvrir Google Maps';

  @override
  String get gpsDisabledError => 'Activez le GPS pour utiliser AutoQui';

  @override
  String get locationPermissionDeniedError =>
      'Autorisation de localisation non accordée';

  @override
  String get disclosureTitle => 'Détection automatique du stationnement';

  @override
  String get disclosureBodyLocation =>
      'AutoQui utilise la localisation même lorsque l\'app n\'est pas ouverte afin de détecter automatiquement quand vous garez la voiture et de vous aider à la retrouver.';

  @override
  String get disclosureBodyPermissions =>
      'Pour cette fonction, l\'app utilise la localisation en arrière-plan, Activity Recognition pour comprendre quand vous sortez de la voiture et des notifications locales pour demander confirmation.';

  @override
  String get disclosureBodyLocalData =>
      'Les données restent sur votre appareil et ne sont pas envoyées aux serveurs AutoQui.';

  @override
  String get cancel => 'Annuler';

  @override
  String get continueAction => 'Continuer';

  @override
  String get privacyPermissionsTitle => 'Confidentialité et autorisations';

  @override
  String get back => 'Retour';

  @override
  String get backgroundLocationTitle => 'Localisation en arrière-plan';

  @override
  String get backgroundLocationBody =>
      'AutoQui peut utiliser la localisation même lorsque l\'app n\'est pas ouverte pour détecter un stationnement possible et vous aider à retrouver la voiture.';

  @override
  String get automaticDetectionTitle => 'Détection automatique';

  @override
  String get automaticDetectionBody =>
      'Activity Recognition aide à comprendre le passage de la conduite à la marche ou à l\'arrêt. AutoQui prépare alors une position candidate et demande confirmation.';

  @override
  String get notificationsTitle => 'Notifications';

  @override
  String get notificationsBody =>
      'Les notifications sont locales et servent à demander si vous souhaitez enregistrer ou ignorer un stationnement détecté.';

  @override
  String get batteryTitle => 'Batterie';

  @override
  String get batteryBody =>
      'Certains appareils Android peuvent limiter l\'activité en arrière-plan. AutoQui ne demande pas de désactiver immédiatement ces optimisations, mais vous informe si la détection n\'est pas fiable.';

  @override
  String get automaticDetectionSwitchSubtitle =>
      'Utilise la localisation en arrière-plan et Activity Recognition.';

  @override
  String get notificationsSwitchSubtitle =>
      'Affiche des alertes locales de stationnement possible.';

  @override
  String get showPrivacyPolicy => 'Afficher la politique de confidentialité';

  @override
  String get batteryBackgroundInfo => 'Infos batterie et arrière-plan';

  @override
  String get showPermissionsDisclosure =>
      'Afficher l\'information sur les autorisations';

  @override
  String get languageTitle => 'Langue';

  @override
  String get languageSubtitle => 'Système ou langue manuelle';

  @override
  String get languageSystem => 'Système';

  @override
  String get automaticDetectionUpdateError =>
      'Impossible de mettre à jour la détection automatique';

  @override
  String get notificationsUpdateError =>
      'Impossible de mettre à jour les notifications';

  @override
  String get batterySheetBody1 =>
      'Pour fonctionner correctement, certains appareils Android peuvent limiter le fonctionnement en arrière-plan d\'AutoQui.';

  @override
  String get batterySheetBody2 =>
      'Sur Samsung, Xiaomi, Oppo, Realme, Huawei et d\'autres appareils, les économies d\'énergie peuvent retarder ou bloquer la détection automatique. Si la fonction n\'est pas fiable, vérifiez les réglages batterie et démarrage en arrière-plan.';

  @override
  String get privacyPolicyTitle => 'Politique de confidentialité';

  @override
  String get privacyPolicyText =>
      'Politique de confidentialité - AutoQui\n\nDernière mise à jour : 12 juillet 2026\n\nAutoQui aide à enregistrer la position de stationnement et à retrouver la voiture.\n\nDonnées utilisées : localisation approximative et précise, Activity Recognition, notifications locales et données techniques nécessaires à Google Maps et AdMob.\n\nLa localisation sert à enregistrer l\'endroit où vous avez garé la voiture, à l\'afficher, à vous guider et à détecter automatiquement un stationnement possible. La localisation en arrière-plan peut être utilisée pour cette détection.\n\nLes données restent localement sur l\'appareil. AutoQui n\'a pas de backend propriétaire, n\'envoie pas la localisation à des serveurs AutoQui et ne vend pas les données.\n\nConservation et suppression des données\n\nAutoQui ne stocke pas de données personnelles ni de données de localisation sur ses propres serveurs, car l\'app ne dispose pas d\'un serveur propriétaire.\n\nLa position de stationnement enregistrée est conservée uniquement localement sur l\'appareil de l\'utilisateur jusqu\'à ce que l\'une des situations suivantes se produise :\n- l\'utilisateur enregistre une nouvelle position ;\n- l\'utilisateur supprime la position enregistrée ;\n- l\'utilisateur efface les données de l\'app dans les réglages de l\'appareil ;\n- l\'app est désinstallée.\n\nAutoQui ne peut pas récupérer ni conserver ces informations après leur suppression de l\'appareil.\n\nLes services tiers intégrés dans l\'app, y compris Google AdMob, Google Maps et Google Play Services, peuvent collecter et conserver des données selon leurs propres politiques de confidentialité et pratiques de conservation. AutoQui ne contrôle pas directement les durées de conservation appliquées par ces services.\n\nL\'app intègre Google Maps SDK et Google Mobile Ads SDK / AdMob, qui peuvent collecter des données selon leurs politiques.\n\nVous pouvez accorder, refuser ou révoquer les autorisations Android à tout moment dans les réglages.\n\nContact : privacy-autoqui@example.com';
}
