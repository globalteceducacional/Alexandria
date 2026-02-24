import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String languageCodeKey = 'languageCode';

// Códigos de idioma (ISO 639-1)
const String englishCode = 'Pt';
const String frenchCode = 'fr';
const String arabicCode = 'ar';
const String urduCode = 'ur';
const String hindiCode = 'hi';
const String germanCode = 'de';
const String spanishCode = 'es';
const String japaneseCode = 'ja';
const String kannadaCode = 'kn';
const String koreanCode = 'ko';
const String russianCode = 'ru';
const String tamilCode = 'ta';
const String teluguCode = 'te';
const String thaiCode = 'th';
const String chineseCode = 'zh';

Future<Locale> setLocale(String languageCode) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString(languageCodeKey, languageCode);

  return _locale(languageCode);
}

Future<Locale> getLocale() async {
  final prefs = await SharedPreferences.getInstance();
  final languageCode = prefs.getString(languageCodeKey) ?? englishCode;

  return _locale(languageCode);
}

Locale _locale(String languageCode) {
  switch (languageCode) {
    case englishCode:
      return const Locale(englishCode, 'Br');
    case frenchCode:
      return const Locale(frenchCode, 'FR');
    case arabicCode:
      return const Locale(arabicCode, 'SA');
    case urduCode:
      return const Locale(urduCode, 'PK');
    case hindiCode:
      return const Locale(hindiCode, 'IN');
    case germanCode:
      return const Locale(germanCode, 'DE');
    case spanishCode:
      return const Locale(spanishCode, 'ES');
    case japaneseCode:
      return const Locale(japaneseCode, 'JP');
    case kannadaCode:
      return const Locale(kannadaCode, 'IN');
    case koreanCode:
      return const Locale(koreanCode, 'KR');
    case russianCode:
      return const Locale(russianCode, 'RU');
    case tamilCode:
      return const Locale(tamilCode, 'IN');
    case teluguCode:
      return const Locale(teluguCode, 'IN');
    case thaiCode:
      return const Locale(thaiCode, 'TH');
    case chineseCode:
      return const Locale(chineseCode, 'CN');
    default:
      return const Locale(englishCode, 'US');
  }
}
