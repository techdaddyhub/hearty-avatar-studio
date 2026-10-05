import 'dart:async';
import 'dart:io';

import 'package:get/get.dart';
import 'package:orange_ui/api_provider/api_provider.dart';
import 'package:orange_ui/screen/restart_app/restart_app.dart';
import 'package:orange_ui/service/language_location_service.dart';
import 'package:orange_ui/service/session_manager.dart';
import 'package:stacked/stacked.dart';

class LanguagesScreenViewModel extends BaseViewModel {
  static String selectedLanguage = Platform.localeName.split('_')[0];

  int? value = 0;
  String searchQuery = '';

  bool get isAutoTranslate => LanguageLocationService.isAutoTranslateEnabled;

  String get detectedCountryText {
    final country = LanguageLocationService.detectedCountryName;
    if (country.isNotEmpty) {
      final info = LanguageLocationService.getLanguageForCountry(country);
      return '$country (${info.name})';
    }
    final info = LanguageLocationService.resolveSystemLocaleInfo();
    return info.name;
  }

  List<String> languages = [
    'عربي',
    'dansk',
    'Nederlands',
    'English',
    'Français',
    'Deutsch',
    'Ελληνικά',
    'हिंदी',
    'bahasa Indonesia',
    'Italiano',
    '日本',
    '한국인',
    'Norsk Bokmal',
    'Polski',
    'Português',
    'Русский',
    '简体中文',
    'Español',
    'แบบไทย',
    'Türkçe',
    'Tiếng Việt',
  ];

  List<String> subLanguage = [
    'Arabic',
    'Danish',
    'Dutch',
    'English',
    'French',
    'German',
    'Greek',
    'Hindi',
    'Indonesian',
    'Italian',
    'Japanese',
    'Korean',
    'Norwegian Bokmal',
    'Polish',
    'Portuguese',
    'Russian',
    'Simplified Chinese',
    'Spanish',
    'Thai',
    'Turkish',
    'Vietnamese',
  ];

  List<String> languageCode = [
    'ar',
    'da',
    'nl',
    'en',
    'fr',
    'de',
    'el',
    'hi',
    'id',
    'it',
    'ja',
    'ko',
    'nb',
    'pl',
    'pt',
    'ru',
    'zh',
    'es',
    'th',
    'tr',
    'vi',
  ];

  List<int> get filteredIndices {
    if (searchQuery.isEmpty) {
      return List.generate(languages.length, (i) => i);
    }
    List<int> results = [];
    for (int i = 0; i < languages.length; i++) {
      if (languages[i].toLowerCase().contains(searchQuery) ||
          subLanguage[i].toLowerCase().contains(searchQuery) ||
          languageCode[i].toLowerCase().contains(searchQuery)) {
        results.add(i);
      }
    }
    return results;
  }

  void onSearchChanged(String query) {
    searchQuery = query.toLowerCase().trim();
    notifyListeners();
  }

  void toggleAutoTranslate(bool val) async {
    LanguageLocationService.setAutoTranslateEnabled(val);
    if (val) {
      await LanguageLocationService.init();
      prefData();
      RestartWidget.restartApp(Get.context!);
    } else {
      notifyListeners();
    }
  }

  void init() {
    prefData();
  }

  Timer? _timer;

  void onLanguageChange(int? value) async {
    this.value = value;
    final selectedCode = languageCode[value ?? 0];
    SessionManager.instance.setString(
        key: SessionKeys.languageCode, value: selectedCode);
    selectedLanguage = selectedCode;
    // When manually selecting, disable auto-detection overwrite
    LanguageLocationService.setAutoTranslateEnabled(false);
    RestartWidget.restartApp(Get.context!);
    notifyListeners();
    ApiProvider().updateProfile(appLanguage: selectedLanguage);
  }

  void prefData() async {
    selectedLanguage =
        SessionManager.instance.getString(key: SessionKeys.languageCode) ??
            Platform.localeName.split('_')[0];
    value = languageCode.indexOf(selectedLanguage);
    if (value == -1) {
      value = languageCode.indexOf('en');
    }
    notifyListeners();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
