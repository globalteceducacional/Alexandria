import 'dart:math';

import 'package:elearn/generated/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:html/parser.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

String htmlString({required String html}) {
  final document = parse(html);
  final String parsedString = parse(document.body!.text).documentElement!.text;
  return parsedString;
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
