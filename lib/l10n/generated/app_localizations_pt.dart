// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get appTitle => 'AutoQui';

  @override
  String get settingsTooltip => 'Privacidade e permissões';

  @override
  String get locate => 'Localizar';

  @override
  String get saveParking => 'Guardar estacionamento';

  @override
  String get goToCar => 'Ir até ao carro';

  @override
  String get youAreHere => 'Você está aqui';

  @override
  String get parkedCar => 'Carro estacionado';

  @override
  String lastParkingSaved(Object savedAt) {
    return 'Último estacionamento guardado: $savedAt';
  }

  @override
  String get parkingSaved => 'Posição de estacionamento guardada';

  @override
  String get locationReadError => 'Não consigo ler a localização agora';

  @override
  String get parkingSaveError => 'Não consigo guardar o estacionamento agora';

  @override
  String get googleMapsOpenError => 'Não consigo abrir o Google Maps';

  @override
  String get gpsDisabledError => 'Ative o GPS para usar o AutoQui';

  @override
  String get locationPermissionDeniedError =>
      'Permissão de localização não concedida';

  @override
  String get disclosureTitle => 'Deteção automática de estacionamento';

  @override
  String get disclosureBodyLocation =>
      'O AutoQui usa a localização mesmo quando a app não está aberta para detetar automaticamente quando estaciona o carro e ajudar a encontrá-lo.';

  @override
  String get disclosureBodyPermissions =>
      'Para esta função, a app usa localização em segundo plano, Activity Recognition e notificações locais para pedir confirmação.';

  @override
  String get disclosureBodyLocalData =>
      'Os dados ficam no dispositivo e não são enviados para servidores AutoQui.';

  @override
  String get cancel => 'Cancelar';

  @override
  String get continueAction => 'Continuar';

  @override
  String get privacyPermissionsTitle => 'Privacidade e permissões';

  @override
  String get back => 'Voltar';

  @override
  String get backgroundLocationTitle => 'Localização em segundo plano';

  @override
  String get backgroundLocationBody =>
      'O AutoQui pode usar a localização mesmo quando a app não está aberta para detetar um possível estacionamento e ajudar a encontrar o carro.';

  @override
  String get automaticDetectionTitle => 'Deteção automática';

  @override
  String get automaticDetectionBody =>
      'Activity Recognition ajuda a perceber quando passa de conduzir para caminhar ou parar. O AutoQui prepara uma posição candidata e pede confirmação.';

  @override
  String get notificationsTitle => 'Notificações';

  @override
  String get notificationsBody =>
      'As notificações são locais e servem para perguntar se quer guardar ou ignorar um estacionamento detetado.';

  @override
  String get batteryTitle => 'Bateria';

  @override
  String get batteryBody =>
      'Alguns dispositivos Android podem limitar a atividade em segundo plano. O AutoQui informa se a deteção não for fiável.';

  @override
  String get automaticDetectionSwitchSubtitle =>
      'Usa localização em segundo plano e Activity Recognition.';

  @override
  String get notificationsSwitchSubtitle =>
      'Mostra alertas locais de possível estacionamento.';

  @override
  String get showPrivacyPolicy => 'Mostrar política de privacidade';

  @override
  String get batteryBackgroundInfo => 'Informação de bateria e segundo plano';

  @override
  String get showPermissionsDisclosure => 'Mostrar aviso de permissões';

  @override
  String get languageTitle => 'Idioma';

  @override
  String get languageSubtitle => 'Sistema ou idioma manual';

  @override
  String get languageSystem => 'Sistema';

  @override
  String get automaticDetectionUpdateError =>
      'Não consigo atualizar a deteção automática';

  @override
  String get notificationsUpdateError =>
      'Não consigo atualizar as notificações';

  @override
  String get batterySheetBody1 =>
      'Para funcionar corretamente, alguns dispositivos Android podem limitar o funcionamento em segundo plano do AutoQui.';

  @override
  String get batterySheetBody2 =>
      'Em dispositivos Samsung, Xiaomi, Oppo, Realme, Huawei e outros, as definições de bateria podem atrasar ou bloquear a deteção automática. Se a função não for fiável, verifique as definições de bateria e início em segundo plano.';

  @override
  String get privacyPolicyTitle => 'Política de privacidade';

  @override
  String get privacyPolicyText =>
      'Política de privacidade - AutoQui\n\nÚltima atualização: 25 de maio de 2026\n\nO AutoQui ajuda a guardar a posição de estacionamento e a encontrar o carro.\n\nDados usados: localização aproximada e precisa, Activity Recognition, notificações locais e dados técnicos necessários para Google Maps e AdMob.\n\nA localização é usada para guardar onde estacionou, mostrar onde está o carro, ajudar a chegar até ele e detetar automaticamente um possível estacionamento. Para isso pode ser usada localização em segundo plano.\n\nOs dados de estacionamento ficam localmente no dispositivo. O AutoQui não tem backend próprio, não envia a localização para servidores AutoQui e não vende dados.\n\nA app integra Google Maps SDK e Google Mobile Ads SDK / AdMob, que podem recolher dados segundo as suas políticas.\n\nPode conceder, negar ou revogar permissões Android a qualquer momento nas definições do dispositivo.\n\nContacto: privacy-autoqui@example.com';
}
