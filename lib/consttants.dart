import 'dart:math';

import 'package:elearn/generated/l10n.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:html/parser.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'main.dart' show isTablet;

/// Admin Panel Url

const apiLink = "https://ebook.alenxandriaglobaltec.com/";
String? privacypolicy;
RxBool mode = false.obs;
String? userId;
String? type;
bool guest = false;
RxBool inAsyncCall = false.obs;
Color buttonColorAccent = Color(0xffffffff);
const Color kLightThemeBackGroundColor = Color(0xff00a4cf);
const Color kDarkThemeBackGroungColor = Color(0xff0c0b0b);

const String prefixLink = 'https://audible.page.link';

Future<Uri> createDynamicLink(
    {id, required String path, required String image}) async {
  final DynamicLinkParameters parameters = DynamicLinkParameters(
    uriPrefix: prefixLink,
    link: Uri.parse(id == null
        ? '$prefixLink$path'
        : "$prefixLink$path?id=$id&second=$image"),
    androidParameters: const AndroidParameters(
      packageName: 'com.flutter.audiobook.audible',
    ),
    iosParameters: const IOSParameters(
      appStoreId: "1669453557",
      bundleId: 'com.flutter.audiobook.audible',
    ),
  );
  // ignore: deprecated_member_use
  final dynamicLink = await FirebaseDynamicLinks.instance
      // ignore: deprecated_member_use
      .buildShortLink(parameters, shortLinkType: ShortDynamicLinkType.short);

  return dynamicLink.shortUrl;
}

Color comboBlackAndWhite() {
  return mode.value == false
      ? kLightThemeBackGroundColor
      : kDarkThemeBackGroungColor;
}

Color comboWhiteAndBlack() {
  return mode.value == false
      ? kDarkThemeBackGroungColor
      : kLightThemeBackGroundColor;
}

Color comboToggleButtonColor() {
  return mode.value == false ? kLightThemeBackGroundColor : Color(0xFf34323d);
}

Color comboToggleBackgroundColor() {
  return mode.value == false ? Color(0xFFe7e7e8) : Color(0xFF222029);
}

Color comboLightGreyAndGrey() {
  return mode.value == false ? Color(0xffb3b2b6) : Color(0xff8c8989);
}

Color comboGreyAndBlack() {
  return mode.value ? Color(0xffFFFFFF8A) : Color(0xff0000008A);
}

Color comboWhiteAndLightViolet() {
  return mode.value == false ? Color(0xFF26242e) : kLightThemeBackGroundColor;
}

Color shimmerBaseColor() {
  return mode.value == false
      ? Colors.grey.shade300
      : Color.fromARGB(25, 255, 255, 255); // 0.1 * 255 ≈ 25
}

Color shimmerHighlightColor() {
  return mode.value == false
      ? Colors.grey.shade100
      : Color.fromARGB(204, 0, 0, 0); // 0.8 * 255 ≈ 204
}

class Constants {
  static String appName = 'Flutter Ebook App';

  static formatBytes(dynamic bytes, int decimals) {
    if (bytes == null || bytes < 0) return 'Invalid input';
    if (bytes == 0) return '0.0';
    var k = 1024,
        dm = decimals <= 0 ? 0 : decimals,
        sizes = ['Bytes', 'KB', 'MB', 'GB', 'TB', 'PB', 'EB', 'ZB', 'YB'],
        i = (log(bytes) / log(k)).floor();
    return (((bytes / pow(k, i)).toStringAsFixed(dm)) + ' ' + sizes[i]);
  }
}

/// app share link
const String appShareAndroid = "https://play.google.com/store";
const String appShareIOS = "https://www.apple.com/in/app-store/";

const String appShareTextAndroid =
    "Please share app with you friend. here is download app link : ";
const String appShareTextIOS =
    "Please share app with you friend. here is download app link : ";

getUserId() async {
  final sharedPreferences = await SharedPreferences.getInstance();
  guest = sharedPreferences.getBool('guest') ?? false;
  userId = sharedPreferences.getString('userId');
  type = sharedPreferences.getString('type');

  mode.value = sharedPreferences.getBool("isDark") ?? false;

  print("UserId $userId");
}

/// Verifica se o dispositivo é um tablet
bool isDeviceTablet(BuildContext context) {
  // Verifica usando o MediaQuery - tablets geralmente têm shortestSide >= 600
  final size = MediaQuery.of(context).size;
  return size.shortestSide >= 600 || isTablet;
}

String htmlString({required String html}) {
  final document = parse(html);
  final String parsedString = parse(document.body!.text).documentElement!.text;
  return parsedString;
}

/// Decodifica HTML entities em strings (ex: &ccedil; vira ç)
String decodeHtmlEntities(String text) {
  return text
      .replaceAll('&amp;', '&')
      .replaceAll('&lt;', '<')
      .replaceAll('&gt;', '>')
      .replaceAll('&quot;', '"')
      .replaceAll('&#39;', "'")
      .replaceAll('&nbsp;', ' ')
      // Acentos e caracteres especiais comuns
      .replaceAll('&aacute;', 'á')
      .replaceAll('&Aacute;', 'Á')
      .replaceAll('&agrave;', 'à')
      .replaceAll('&Agrave;', 'À')
      .replaceAll('&acirc;', 'â')
      .replaceAll('&Acirc;', 'Â')
      .replaceAll('&atilde;', 'ã')
      .replaceAll('&Atilde;', 'Ã')
      .replaceAll('&eacute;', 'é')
      .replaceAll('&Eacute;', 'É')
      .replaceAll('&egrave;', 'è')
      .replaceAll('&Egrave;', 'È')
      .replaceAll('&ecirc;', 'ê')
      .replaceAll('&Ecirc;', 'Ê')
      .replaceAll('&iacute;', 'í')
      .replaceAll('&Iacute;', 'Í')
      .replaceAll('&oacute;', 'ó')
      .replaceAll('&Oacute;', 'Ó')
      .replaceAll('&ograve;', 'ò')
      .replaceAll('&Ograve;', 'Ò')
      .replaceAll('&ocirc;', 'ô')
      .replaceAll('&Ocirc;', 'Ô')
      .replaceAll('&otilde;', 'õ')
      .replaceAll('&Otilde;', 'Õ')
      .replaceAll('&uacute;', 'ú')
      .replaceAll('&Uacute;', 'Ú')
      .replaceAll('&ugrave;', 'ù')
      .replaceAll('&Ugrave;', 'Ù')
      .replaceAll('&uuml;', 'ü')
      .replaceAll('&Uuml;', 'Ü')
      .replaceAll('&ccedil;', 'ç')
      .replaceAll('&Ccedil;', 'Ç')
      .replaceAll('&ntilde;', 'ñ')
      .replaceAll('&Ntilde;', 'Ñ');
}

/// Decodifica HTML entities especificamente em URLs de imagens
String fixImageUrl(String url) {
  String fixedUrl = decodeHtmlEntities(url);
  // Garantir que a URL está codificada corretamente
  try {
    final uri = Uri.parse(fixedUrl);
    return uri.toString();
  } catch (e) {
    // Se falhar, retorna a URL decodificada
    return fixedUrl;
  }
}

void customSnackBar(context, {String? title}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      backgroundColor: comboWhiteAndBlack(),
      content: Text(
        title ?? S.of(context).loginPage_login_to_continue,
        style: TextStyle(
            color: comboBlackAndWhite(),
            fontFamily: "Gilroy-SemiBold",
            fontSize: 15.sp),
      ),
      duration: Duration(milliseconds: 1500),
    ),
  );
}

showToast({required String msg}) {
  Fluttertoast.showToast(
    msg: msg,
    backgroundColor: comboWhiteAndBlack(),
    textColor: comboBlackAndWhite(),
    toastLength: Toast.LENGTH_LONG,
    gravity: ToastGravity.BOTTOM,
    fontSize: 16.sp,
  );
}

extension StringCasingExtension on String {
  String toCapitalized() =>
      length > 0 ? '${this[0].toUpperCase()}${substring(1).toLowerCase()}' : '';

  String toTitleCase() => replaceAll(RegExp(' +'), ' ')
      .split(' ')
      .map((str) => str.toCapitalized())
      .join(' ');
}

extension ColorExtension on Color {
  Color withAlpha(double opacity) {
    // Convert opacity (0.0-1.0) to alpha (0-255)
    int alpha = (opacity * 255).round();
    return Color.fromARGB(alpha, r.toInt(), g.toInt(), b.toInt());
  }
}
