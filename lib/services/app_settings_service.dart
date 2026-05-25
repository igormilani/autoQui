import 'package:shared_preferences/shared_preferences.dart';

class AppSettingsService {
  static const automaticDetectionEnabledKey = 'automatic_detection_enabled';
  static const notificationsEnabledKey = 'notifications_enabled';
  static const prominentDisclosureAcceptedKey = 'prominent_disclosure_accepted';

  Future<AppSettings> load() async {
    final preferences = await SharedPreferences.getInstance();
    return AppSettings(
      automaticDetectionEnabled:
          preferences.getBool(automaticDetectionEnabledKey) ?? true,
      notificationsEnabled:
          preferences.getBool(notificationsEnabledKey) ?? true,
      prominentDisclosureAccepted:
          preferences.getBool(prominentDisclosureAcceptedKey) ?? false,
    );
  }

  Future<void> setAutomaticDetectionEnabled(bool enabled) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setBool(automaticDetectionEnabledKey, enabled);
  }

  Future<void> setNotificationsEnabled(bool enabled) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setBool(notificationsEnabledKey, enabled);
  }

  Future<void> acceptProminentDisclosure() async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setBool(prominentDisclosureAcceptedKey, true);
  }
}

class AppSettings {
  const AppSettings({
    required this.automaticDetectionEnabled,
    required this.notificationsEnabled,
    required this.prominentDisclosureAccepted,
  });

  final bool automaticDetectionEnabled;
  final bool notificationsEnabled;
  final bool prominentDisclosureAccepted;

  AppSettings copyWith({
    bool? automaticDetectionEnabled,
    bool? notificationsEnabled,
    bool? prominentDisclosureAccepted,
  }) {
    return AppSettings(
      automaticDetectionEnabled:
          automaticDetectionEnabled ?? this.automaticDetectionEnabled,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      prominentDisclosureAccepted:
          prominentDisclosureAccepted ?? this.prominentDisclosureAccepted,
    );
  }
}
