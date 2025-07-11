import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String LAGUAGE_CODE = 'languageCode';

//languages code
const String ENGLISH = 'Pt';
const String FRENCH = 'fr';
const String ARABIC = 'ar';
const String URDU = 'ur';
const String HINDI = 'hi';
const String GERMAN = 'de';
const String SPANISH = 'es';
const String JAPANESE = 'ja';
const String KANNADA = 'kn';
const String KOREAN = 'ko';
const String RUSSIAN = 'ru';
const String TAMIL = 'ta';
const String TELUGU = 'te';
const String THAI = 'th';
const String CHINESE = 'zh';

Future<Locale> setLocale(String languageCode) async {
  SharedPreferences _prefs = await SharedPreferences.getInstance();
  await _prefs.setString(LAGUAGE_CODE, languageCode);

  return _locale(languageCode);
}

Future<Locale> getLocale() async {
  SharedPreferences _prefs = await SharedPreferences.getInstance();
  String languageCode = _prefs.getString(LAGUAGE_CODE) ?? "Pt";

  return _locale(languageCode);
}

Locale _locale(String languageCode) {
  switch (languageCode) {
    case ENGLISH:
      return Locale(ENGLISH, 'Br');
    case FRENCH:
      return Locale(FRENCH, "FR");
    case ARABIC:
      return Locale(ARABIC, "SA");
    case URDU:
      return Locale(URDU, "PK");
    case HINDI:
      return Locale(HINDI, "IN");
    case GERMAN:
      return Locale(GERMAN, "DE");
    case SPANISH:
      return Locale(SPANISH, "ES");
    case JAPANESE:
      return Locale(JAPANESE, "JP");
    case KANNADA:
      return Locale(KANNADA, "IN");
    case KOREAN:
      return Locale(KOREAN, "KR");
    case RUSSIAN:
      return Locale(RUSSIAN, "RU");
    case TAMIL:
      return Locale(TAMIL, "IN");
    case TELUGU:
      return Locale(TELUGU, "IN");
    case THAI:
      return Locale(THAI, "TH");
    case CHINESE:
      return Locale(CHINESE, "CN");
    default:
      return Locale(ENGLISH, 'US');
  }
}
