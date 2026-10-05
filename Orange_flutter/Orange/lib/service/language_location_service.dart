import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:orange_ui/api_provider/api_provider.dart';
import 'package:orange_ui/screen/languages_screen/languages_screen_view_model.dart';
import 'package:orange_ui/service/session_manager.dart';

class CountryLanguageInfo {
  final String code;
  final String name;
  final String nativeName;

  const CountryLanguageInfo({
    required this.code,
    required this.name,
    required this.nativeName,
  });
}

class LanguageLocationService {
  LanguageLocationService._();

  static final Map<String, String> _translationCache = {};

  /// 21 fully translated UI languages supported by the Flutter app
  static const List<String> supportedUiLanguageCodes = [
    'en', 'ar', 'da', 'de', 'el', 'es', 'fr', 'hi', 'id', 'it',
    'ja', 'ko', 'nb', 'nl', 'pl', 'pt', 'ru', 'th', 'tr', 'vi', 'zh',
  ];

  /// Comprehensive ISO 2-letter Country Code to primary language mapping
  static const Map<String, CountryLanguageInfo> countryToLanguage = {
    // North America
    'US': CountryLanguageInfo(code: 'en', name: 'English', nativeName: 'English'),
    'CA': CountryLanguageInfo(code: 'en', name: 'English', nativeName: 'English'),
    'MX': CountryLanguageInfo(code: 'es', name: 'Spanish', nativeName: 'Español'),

    // Central & South America
    'AR': CountryLanguageInfo(code: 'es', name: 'Spanish', nativeName: 'Español'),
    'BO': CountryLanguageInfo(code: 'es', name: 'Spanish', nativeName: 'Español'),
    'BR': CountryLanguageInfo(code: 'pt', name: 'Portuguese', nativeName: 'Português'),
    'CL': CountryLanguageInfo(code: 'es', name: 'Spanish', nativeName: 'Español'),
    'CO': CountryLanguageInfo(code: 'es', name: 'Spanish', nativeName: 'Español'),
    'CR': CountryLanguageInfo(code: 'es', name: 'Spanish', nativeName: 'Español'),
    'CU': CountryLanguageInfo(code: 'es', name: 'Spanish', nativeName: 'Español'),
    'DO': CountryLanguageInfo(code: 'es', name: 'Spanish', nativeName: 'Español'),
    'EC': CountryLanguageInfo(code: 'es', name: 'Spanish', nativeName: 'Español'),
    'SV': CountryLanguageInfo(code: 'es', name: 'Spanish', nativeName: 'Español'),
    'GT': CountryLanguageInfo(code: 'es', name: 'Spanish', nativeName: 'Español'),
    'HN': CountryLanguageInfo(code: 'es', name: 'Spanish', nativeName: 'Español'),
    'NI': CountryLanguageInfo(code: 'es', name: 'Spanish', nativeName: 'Español'),
    'PA': CountryLanguageInfo(code: 'es', name: 'Spanish', nativeName: 'Español'),
    'PY': CountryLanguageInfo(code: 'es', name: 'Spanish', nativeName: 'Español'),
    'PE': CountryLanguageInfo(code: 'es', name: 'Spanish', nativeName: 'Español'),
    'UY': CountryLanguageInfo(code: 'es', name: 'Spanish', nativeName: 'Español'),
    'VE': CountryLanguageInfo(code: 'es', name: 'Spanish', nativeName: 'Español'),

    // Europe
    'GB': CountryLanguageInfo(code: 'en', name: 'English', nativeName: 'English'),
    'UK': CountryLanguageInfo(code: 'en', name: 'English', nativeName: 'English'),
    'IE': CountryLanguageInfo(code: 'en', name: 'English', nativeName: 'English'),
    'FR': CountryLanguageInfo(code: 'fr', name: 'French', nativeName: 'Français'),
    'DE': CountryLanguageInfo(code: 'de', name: 'German', nativeName: 'Deutsch'),
    'AT': CountryLanguageInfo(code: 'de', name: 'German', nativeName: 'Deutsch'),
    'CH': CountryLanguageInfo(code: 'de', name: 'German', nativeName: 'Deutsch'),
    'ES': CountryLanguageInfo(code: 'es', name: 'Spanish', nativeName: 'Español'),
    'IT': CountryLanguageInfo(code: 'it', name: 'Italian', nativeName: 'Italiano'),
    'PT': CountryLanguageInfo(code: 'pt', name: 'Portuguese', nativeName: 'Português'),
    'RU': CountryLanguageInfo(code: 'ru', name: 'Russian', nativeName: 'Русский'),
    'UA': CountryLanguageInfo(code: 'ru', name: 'Ukrainian', nativeName: 'Українська'),
    'PL': CountryLanguageInfo(code: 'pl', name: 'Polish', nativeName: 'Polski'),
    'NL': CountryLanguageInfo(code: 'nl', name: 'Dutch', nativeName: 'Nederlands'),
    'BE': CountryLanguageInfo(code: 'fr', name: 'French', nativeName: 'Français'),
    'GR': CountryLanguageInfo(code: 'el', name: 'Greek', nativeName: 'Ελληνικά'),
    'DK': CountryLanguageInfo(code: 'da', name: 'Danish', nativeName: 'Dansk'),
    'NO': CountryLanguageInfo(code: 'nb', name: 'Norwegian', nativeName: 'Norsk Bokmål'),
    'SE': CountryLanguageInfo(code: 'en', name: 'Swedish', nativeName: 'Svenska'),
    'FI': CountryLanguageInfo(code: 'en', name: 'Finnish', nativeName: 'Suomi'),
    'CZ': CountryLanguageInfo(code: 'en', name: 'Czech', nativeName: 'Čeština'),
    'SK': CountryLanguageInfo(code: 'en', name: 'Slovak', nativeName: 'Slovenčina'),
    'RO': CountryLanguageInfo(code: 'en', name: 'Romanian', nativeName: 'Română'),
    'HU': CountryLanguageInfo(code: 'en', name: 'Hungarian', nativeName: 'Magyar'),
    'BG': CountryLanguageInfo(code: 'ru', name: 'Bulgarian', nativeName: 'Български'),
    'HR': CountryLanguageInfo(code: 'en', name: 'Croatian', nativeName: 'Hrvatski'),
    'RS': CountryLanguageInfo(code: 'ru', name: 'Serbian', nativeName: 'Српски'),
    'BA': CountryLanguageInfo(code: 'en', name: 'Bosnian', nativeName: 'Bosanski'),
    'SI': CountryLanguageInfo(code: 'en', name: 'Slovenian', nativeName: 'Slovenščina'),
    'AL': CountryLanguageInfo(code: 'en', name: 'Albanian', nativeName: 'Shqip'),
    'BY': CountryLanguageInfo(code: 'ru', name: 'Belarusian', nativeName: 'Беларуская'),
    'EE': CountryLanguageInfo(code: 'en', name: 'Estonian', nativeName: 'Eesti'),
    'LV': CountryLanguageInfo(code: 'en', name: 'Latvian', nativeName: 'Latviešu'),
    'LT': CountryLanguageInfo(code: 'en', name: 'Lithuanian', nativeName: 'Lietuvių'),

    // Asia & Middle East
    'CN': CountryLanguageInfo(code: 'zh', name: 'Mandarin Chinese', nativeName: '简体中文'),
    'TW': CountryLanguageInfo(code: 'zh', name: 'Mandarin Chinese', nativeName: '繁體中文'),
    'HK': CountryLanguageInfo(code: 'zh', name: 'Mandarin Chinese', nativeName: '粵語 / 中文'),
    'JP': CountryLanguageInfo(code: 'ja', name: 'Japanese', nativeName: '日本語'),
    'KR': CountryLanguageInfo(code: 'ko', name: 'Korean', nativeName: '한국어'),
    'IN': CountryLanguageInfo(code: 'hi', name: 'Hindi', nativeName: 'हिन्दी'),
    'PK': CountryLanguageInfo(code: 'ur', name: 'Urdu', nativeName: 'اردو'),
    'BD': CountryLanguageInfo(code: 'bn', name: 'Bengali', nativeName: 'বাংলা'),
    'TR': CountryLanguageInfo(code: 'tr', name: 'Turkish', nativeName: 'Türkçe'),
    'SA': CountryLanguageInfo(code: 'ar', name: 'Arabic', nativeName: 'العربية'),
    'AE': CountryLanguageInfo(code: 'ar', name: 'Arabic', nativeName: 'العربية'),
    'EG': CountryLanguageInfo(code: 'ar', name: 'Arabic', nativeName: 'العربية'),
    'IQ': CountryLanguageInfo(code: 'ar', name: 'Arabic', nativeName: 'العربية'),
    'IR': CountryLanguageInfo(code: 'ar', name: 'Persian (Farsi)', nativeName: 'فارسی'),
    'IL': CountryLanguageInfo(code: 'en', name: 'Hebrew', nativeName: 'עברית'),
    'JO': CountryLanguageInfo(code: 'ar', name: 'Arabic', nativeName: 'العربية'),
    'LB': CountryLanguageInfo(code: 'ar', name: 'Arabic', nativeName: 'العربية'),
    'KW': CountryLanguageInfo(code: 'ar', name: 'Arabic', nativeName: 'العربية'),
    'QA': CountryLanguageInfo(code: 'ar', name: 'Arabic', nativeName: 'العربية'),
    'OM': CountryLanguageInfo(code: 'ar', name: 'Arabic', nativeName: 'العربية'),
    'YE': CountryLanguageInfo(code: 'ar', name: 'Arabic', nativeName: 'العربية'),
    'SY': CountryLanguageInfo(code: 'ar', name: 'Arabic', nativeName: 'العربية'),
    'MA': CountryLanguageInfo(code: 'ar', name: 'Arabic', nativeName: 'العربية'),
    'DZ': CountryLanguageInfo(code: 'ar', name: 'Arabic', nativeName: 'العربية'),
    'TN': CountryLanguageInfo(code: 'ar', name: 'Arabic', nativeName: 'العربية'),
    'ID': CountryLanguageInfo(code: 'id', name: 'Indonesian', nativeName: 'Bahasa Indonesia'),
    'MY': CountryLanguageInfo(code: 'id', name: 'Malay', nativeName: 'Bahasa Melayu'),
    'PH': CountryLanguageInfo(code: 'en', name: 'Tagalog (Filipino)', nativeName: 'Tagalog'),
    'TH': CountryLanguageInfo(code: 'th', name: 'Thai', nativeName: 'แบบไทย'),
    'VN': CountryLanguageInfo(code: 'vi', name: 'Vietnamese', nativeName: 'Tiếng Việt'),
    'MM': CountryLanguageInfo(code: 'en', name: 'Burmese', nativeName: 'မြန်မာ'),
    'KH': CountryLanguageInfo(code: 'en', name: 'Khmer', nativeName: 'ភាសាខ្មែរ'),
    'LA': CountryLanguageInfo(code: 'en', name: 'Lao', nativeName: 'ລາວ'),
    'KZ': CountryLanguageInfo(code: 'ru', name: 'Kazakh', nativeName: 'Қазақша'),
    'UZ': CountryLanguageInfo(code: 'ru', name: 'Uzbek', nativeName: 'Oʻzbek'),
    'AZ': CountryLanguageInfo(code: 'tr', name: 'Azerbaijani', nativeName: 'Azərbaycan'),
    'GE': CountryLanguageInfo(code: 'en', name: 'Georgian', nativeName: 'ქართული'),
    'AM': CountryLanguageInfo(code: 'ru', name: 'Armenian', nativeName: 'Հայերեն'),
    'NP': CountryLanguageInfo(code: 'hi', name: 'Nepali', nativeName: 'नेपाली'),
    'LK': CountryLanguageInfo(code: 'en', name: 'Sinhala', nativeName: 'සිංහල'),

    // Africa
    'NG': CountryLanguageInfo(code: 'en', name: 'English', nativeName: 'English'),
    'ZA': CountryLanguageInfo(code: 'en', name: 'English', nativeName: 'English'),
    'KE': CountryLanguageInfo(code: 'en', name: 'Swahili', nativeName: 'Kiswahili'),
    'TZ': CountryLanguageInfo(code: 'en', name: 'Swahili', nativeName: 'Kiswahili'),
    'UG': CountryLanguageInfo(code: 'en', name: 'English', nativeName: 'English'),
    'GH': CountryLanguageInfo(code: 'en', name: 'English', nativeName: 'English'),
    'ET': CountryLanguageInfo(code: 'en', name: 'Amharic', nativeName: 'አማርኛ'),
    'SN': CountryLanguageInfo(code: 'fr', name: 'French', nativeName: 'Français'),
    'CI': CountryLanguageInfo(code: 'fr', name: 'French', nativeName: 'Français'),
    'CM': CountryLanguageInfo(code: 'fr', name: 'French', nativeName: 'Français'),

    // Oceania
    'AU': CountryLanguageInfo(code: 'en', name: 'English', nativeName: 'English'),
    'NZ': CountryLanguageInfo(code: 'en', name: 'English', nativeName: 'English'),
    'FJ': CountryLanguageInfo(code: 'en', name: 'English', nativeName: 'English'),
    'PG': CountryLanguageInfo(code: 'en', name: 'English', nativeName: 'English'),
  };

  /// Returns true if auto-translation / auto-detection by location is turned on
  static bool get isAutoTranslateEnabled {
    final val = SessionManager.instance.storage.read(SessionKeys.autoTranslateByLocation);
    if (val == null) return true; // Default to enabled
    return val == true;
  }

  /// Sets auto-translate by location preference
  static void setAutoTranslateEnabled(bool enabled) {
    SessionManager.instance.storage.write(SessionKeys.autoTranslateByLocation, enabled);
  }

  /// Gets the currently detected country name or code
  static String get detectedCountryName {
    return SessionManager.instance.getString(key: SessionKeys.detectedCountryName) ??
        SessionManager.instance.getString(key: SessionKeys.detectedCountryCode) ??
        '';
  }

  /// Initialize service on app launch
  static Future<void> init() async {
    // 1. Resolve initial language from location/locale
    try {
      final detectedInfo = resolveSystemLocaleInfo();
      final savedLang = SessionManager.instance.getString(key: SessionKeys.languageCode);

      if (isAutoTranslateEnabled || savedLang == null || savedLang.isEmpty) {
        final targetUiCode = getSupportedUiCode(detectedInfo.code);
        LanguagesScreenViewModel.selectedLanguage = targetUiCode;
        SessionManager.instance.setString(key: SessionKeys.languageCode, value: targetUiCode);
      } else {
        LanguagesScreenViewModel.selectedLanguage = savedLang;
      }
    } catch (e) {
      debugPrint('[LanguageLocationService] init error: $e');
    }

    // 2. Asynchronously probe IP location for refined country detection
    fetchLocationFromIpAsync();
  }

  /// Background detection of IP place details
  static void fetchLocationFromIpAsync() {
    try {
      ApiProvider().getIPPlaceDetail(onCompletion: (detail) {
        if (detail.countryCode != null && detail.countryCode!.isNotEmpty) {
          onLocationDetected(
            countryCode: detail.countryCode,
            countryName: detail.country,
          );
        }
      });
    } catch (e) {
      debugPrint('[LanguageLocationService] IP location error: $e');
    }
  }

  /// Called when device location or IP placemark is detected
  static void onLocationDetected({String? countryCode, String? countryName}) {
    if (countryCode == null || countryCode.isEmpty) return;

    final upperCode = countryCode.toUpperCase();
    SessionManager.instance.setString(key: SessionKeys.detectedCountryCode, value: upperCode);
    if (countryName != null && countryName.isNotEmpty) {
      SessionManager.instance.setString(key: SessionKeys.detectedCountryName, value: countryName);
    }

    if (!isAutoTranslateEnabled) return;

    final langInfo = getLanguageForCountry(upperCode);
    final targetUiCode = getSupportedUiCode(langInfo.code);

    if (LanguagesScreenViewModel.selectedLanguage != targetUiCode) {
      debugPrint('[LanguageLocationService] Auto-switching language to $targetUiCode for country $upperCode');
      LanguagesScreenViewModel.selectedLanguage = targetUiCode;
      SessionManager.instance.setString(key: SessionKeys.languageCode, value: targetUiCode);
      try {
        Get.updateLocale(Locale(targetUiCode));
      } catch (e) {
        debugPrint('[LanguageLocationService] updateLocale error: $e');
      }
      ApiProvider().updateProfile(appLanguage: targetUiCode);
    }
  }

  /// Resolves device system locale info
  static CountryLanguageInfo resolveSystemLocaleInfo() {
    try {
      final localeParts = Platform.localeName.split('_');
      final langPart = localeParts.isNotEmpty ? localeParts[0].toLowerCase() : 'en';
      final countryPart = localeParts.length > 1 ? localeParts[1].toUpperCase() : '';

      if (countryPart.isNotEmpty && countryToLanguage.containsKey(countryPart)) {
        return countryToLanguage[countryPart]!;
      }

      // Check if langPart maps to a supported language
      for (var entry in countryToLanguage.values) {
        if (entry.code == langPart) {
          return entry;
        }
      }
    } catch (e) {
      debugPrint('[LanguageLocationService] resolveSystemLocaleInfo error: $e');
    }

    return const CountryLanguageInfo(code: 'en', name: 'English', nativeName: 'English');
  }

  /// Gets the primary language for an ISO country code
  static CountryLanguageInfo getLanguageForCountry(String countryCode) {
    final upper = countryCode.toUpperCase();
    if (countryToLanguage.containsKey(upper)) {
      return countryToLanguage[upper]!;
    }
    return const CountryLanguageInfo(code: 'en', name: 'English', nativeName: 'English');
  }

  /// Maps a language code to one supported by the UI (defaults to en)
  static String getSupportedUiCode(String code) {
    if (supportedUiLanguageCodes.contains(code)) {
      return code;
    }
    return 'en';
  }

  /// Translates text on the fly using Google Translate free endpoint
  static Future<String> translateText({
    required String text,
    String? targetLang,
  }) async {
    final clean = text.trim();
    if (clean.isEmpty) return clean;

    targetLang ??= LanguagesScreenViewModel.selectedLanguage;
    final cacheKey = '$targetLang:$clean';
    if (_translationCache.containsKey(cacheKey)) {
      return _translationCache[cacheKey]!;
    }

    try {
      final uri = Uri.parse(
        'https://translate.googleapis.com/translate_a/single?client=gtx&sl=auto&tl=$targetLang&dt=t&q=${Uri.encodeComponent(clean)}',
      );
      final response = await http.get(uri).timeout(const Duration(seconds: 4));
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        if (decoded is List && decoded.isNotEmpty && decoded[0] is List) {
          final buffer = StringBuffer();
          for (var item in decoded[0]) {
            if (item is List && item.isNotEmpty && item[0] != null) {
              buffer.write(item[0].toString());
            }
          }
          final result = buffer.toString().trim();
          if (result.isNotEmpty) {
            _translationCache[cacheKey] = result;
            return result;
          }
        }
      }
    } catch (e) {
      debugPrint('[LanguageLocationService] Translate API error: $e');
    }

    return clean;
  }
}
