import 'package:flutter/material.dart';

import 'app_settings_service.dart';

class LanguageController extends ChangeNotifier {
  LanguageController(this._settingsService);

  final AppSettingsService _settingsService;
  String? _languageCode;

  String? get languageCode => _languageCode;

  Locale? get locale => _languageCode == null ? null : Locale(_languageCode);

  Future<void> load() async {
    final settings = await _settingsService.load();
    _languageCode = settings.languageCode;
    notifyListeners();
  }

  Future<void> setLanguageCode(String? languageCode) async {
    _languageCode = languageCode;
    notifyListeners();
    await _settingsService.setLanguageCode(languageCode);
  }
}

class LanguageOption {
  const LanguageOption({
    required this.code,
    required this.flag,
    required this.nativeName,
  });

  final String code;
  final String flag;
  final String nativeName;
}

const supportedLanguageOptions = [
  LanguageOption(code: 'it', flag: '🇮🇹', nativeName: 'Italiano'),
  LanguageOption(code: 'en', flag: '🇬🇧', nativeName: 'English'),
  LanguageOption(code: 'es', flag: '🇪🇸', nativeName: 'Español'),
  LanguageOption(code: 'fr', flag: '🇫🇷', nativeName: 'Français'),
  LanguageOption(code: 'de', flag: '🇩🇪', nativeName: 'Deutsch'),
  LanguageOption(code: 'pl', flag: '🇵🇱', nativeName: 'Polski'),
  LanguageOption(code: 'pt', flag: '🇵🇹', nativeName: 'Português'),
];
