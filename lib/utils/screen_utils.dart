import 'package:flutter/material.dart';

class ScreenUtils {
  static double getScreenWidth(BuildContext context) {
    return MediaQuery.of(context).size.width;
  }

  static double getScreenHeight(BuildContext context) {
    return MediaQuery.of(context).size.height;
  }

  static double widthPercent(double percent, BuildContext context) {
    return getScreenWidth(context) * (percent / 100);
  }

  static double heightPercent(double percent, BuildContext context) {
    return getScreenHeight(context) * (percent / 100);
  }

  static double textSize(double baseSize, BuildContext context) {
    final width = getScreenWidth(context);
    return baseSize * (width / 375); // 375 é a largura base para design
  }
}
