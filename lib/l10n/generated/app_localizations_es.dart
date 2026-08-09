// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'AutoQui';

  @override
  String get settingsTooltip => 'Privacidad y permisos';

  @override
  String get locate => 'Localizar';

  @override
  String get saveParking => 'Guardar aparcamiento';

  @override
  String get goToCar => 'Ir al coche';

  @override
  String get youAreHere => 'Estás aquí';

  @override
  String get parkedCar => 'Coche aparcado';

  @override
  String lastParkingSaved(Object savedAt) {
    return 'Último aparcamiento guardado: $savedAt';
  }

  @override
  String get parkingSaved => 'Posición de aparcamiento guardada';

  @override
  String get locationReadError => 'No puedo leer la ubicación ahora';

  @override
  String get parkingSaveError => 'No puedo guardar el aparcamiento ahora';

  @override
  String get googleMapsOpenError => 'No puedo abrir Google Maps';

  @override
  String get gpsDisabledError => 'Activa el GPS para usar AutoQui';

  @override
  String get locationPermissionDeniedError =>
      'Permiso de ubicación no concedido';

  @override
  String get disclosureTitle => 'Detección automática de aparcamiento';

  @override
  String get disclosureBodyLocation =>
      'AutoQui usa la ubicación incluso cuando la app no está abierta para detectar automáticamente cuándo aparcas el coche y ayudarte a encontrarlo.';

  @override
  String get disclosureBodyPermissions =>
      'Para esta función, la app usa ubicación en segundo plano, Activity Recognition para entender cuándo sales del coche y notificaciones locales para preguntarte si quieres guardar el aparcamiento.';

  @override
  String get disclosureBodyLocalData =>
      'Los datos permanecen en tu dispositivo y no se envían a servidores de AutoQui.';

  @override
  String get cancel => 'Cancelar';

  @override
  String get continueAction => 'Continuar';

  @override
  String get privacyPermissionsTitle => 'Privacidad y permisos';

  @override
  String get back => 'Atrás';

  @override
  String get backgroundLocationTitle => 'Ubicación en segundo plano';

  @override
  String get backgroundLocationBody =>
      'AutoQui puede usar la ubicación aunque la app no esté abierta para detectar un posible aparcamiento y ayudarte a encontrar el coche.';

  @override
  String get automaticDetectionTitle => 'Detección automática';

  @override
  String get automaticDetectionBody =>
      'Activity Recognition ayuda a entender cuándo pasas de conducir a caminar o detenerte. Entonces AutoQui prepara una posición candidata y pide confirmación.';

  @override
  String get notificationsTitle => 'Notificaciones';

  @override
  String get notificationsBody =>
      'Las notificaciones son locales y sirven para preguntar si quieres guardar o ignorar un aparcamiento detectado.';

  @override
  String get batteryTitle => 'Batería';

  @override
  String get batteryBody =>
      'Algunos dispositivos Android pueden limitar la actividad en segundo plano. AutoQui no pide desactivar estas optimizaciones de inmediato, pero te informa si la detección no es fiable.';

  @override
  String get automaticDetectionSwitchSubtitle =>
      'Usa ubicación en segundo plano y Activity Recognition.';

  @override
  String get notificationsSwitchSubtitle =>
      'Muestra avisos locales de posible aparcamiento.';

  @override
  String get showPrivacyPolicy => 'Mostrar política de privacidad';

  @override
  String get adPrivacyOptions => 'Opciones de privacidad publicitaria';

  @override
  String get batteryBackgroundInfo => 'Información de batería y segundo plano';

  @override
  String get showPermissionsDisclosure => 'Mostrar aviso de permisos';

  @override
  String get languageTitle => 'Idioma';

  @override
  String get languageSubtitle => 'Sistema o idioma manual';

  @override
  String get languageSystem => 'Sistema';

  @override
  String get automaticDetectionUpdateError =>
      'No puedo actualizar la detección automática';

  @override
  String get notificationsUpdateError =>
      'No puedo actualizar las notificaciones';

  @override
  String get batterySheetBody1 =>
      'Para funcionar correctamente, algunos dispositivos Android pueden limitar el funcionamiento en segundo plano de AutoQui.';

  @override
  String get batterySheetBody2 =>
      'En dispositivos Samsung, Xiaomi, Oppo, Realme, Huawei y otros, el ahorro de batería puede retrasar o bloquear la detección automática. Si la función no es fiable, revisa los ajustes de batería e inicio en segundo plano.';

  @override
  String get privacyPolicyTitle => 'Política de privacidad';

  @override
  String get privacyPolicyText =>
      'Política de privacidad - AutoQui\n\nÚltima actualización: 12 de julio de 2026\n\nAutoQui te ayuda a guardar la posición del aparcamiento y encontrar el coche.\n\nDatos usados: ubicación aproximada y precisa, Activity Recognition, notificaciones locales y datos técnicos necesarios para Google Maps y AdMob.\n\nLa ubicación se usa para guardar dónde aparcaste, mostrar dónde está el coche, ayudarte a llegar a él y detectar automáticamente un posible aparcamiento. Para la detección automática puede usarse ubicación en segundo plano.\n\nLos datos del aparcamiento se guardan localmente en el dispositivo. AutoQui no tiene backend propio, no envía la ubicación a servidores de AutoQui y no vende datos.\n\nConservación y eliminación de datos\n\nAutoQui no almacena datos personales ni datos de ubicación en servidores propios, ya que la app no opera un servidor propietario.\n\nLa ubicación de aparcamiento guardada se conserva solo localmente en el dispositivo del usuario hasta que ocurre una de estas condiciones:\n- el usuario guarda una nueva ubicación;\n- el usuario elimina la ubicación guardada;\n- el usuario borra los datos de la app desde los ajustes del dispositivo;\n- la app se desinstala.\n\nAutoQui no puede recuperar ni conservar esta información después de que se haya eliminado del dispositivo.\n\nLos servicios de terceros integrados en la app, incluidos Google AdMob, Google Maps y Google Play Services, pueden recopilar y conservar datos de acuerdo con sus propias políticas de privacidad y prácticas de conservación. AutoQui no controla directamente los periodos de conservación aplicados por esos servicios.\n\nLa app integra Google Maps SDK y Google Mobile Ads SDK / AdMob, que pueden recopilar datos según sus políticas.\n\nPuedes conceder, denegar o revocar los permisos Android en cualquier momento desde los ajustes del dispositivo.\n\nContacto: privacy-autoqui@example.com';
}
