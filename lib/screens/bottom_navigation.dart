import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:elearn/consttants.dart';
import 'package:elearn/screens/setting.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import 'explore.dart';
import 'home.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  RxInt _page = 0.obs;

  List<Widget> pages = [Home(), Explore(), Setting()];

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarBrightness:
              mode.value == false ? Brightness.light : Brightness.dark,
          statusBarIconBrightness:
              mode.value == false ? Brightness.dark : Brightness.light,
          systemNavigationBarIconBrightness:
              mode.value == false ? Brightness.dark : Brightness.light,
          systemNavigationBarColor: comboBlackAndWhite()),
    );
    return Obx(() {
      return Scaffold(
        bottomNavigationBar: CurvedNavigationBar(
          backgroundColor: comboWhiteAndBlack(),
          animationDuration: Duration(milliseconds: 100),
          buttonBackgroundColor: comboBlackAndWhite(),
          color: comboBlackAndWhite(),
          index: _page.value,
          height: 70.0,
          items: <Widget>[
            SvgPicture.asset(
              'assets/images/Home.svg',
              height: 30.h,
              fit: BoxFit.cover,
              // ignore: deprecated_member_use
              color: comboWhiteAndBlack(),
            ),
            SvgPicture.asset(
              'assets/images/web-browser.svg',
              height: 30.h,
              fit: BoxFit.cover,
              // ignore: deprecated_member_use
              color: comboWhiteAndBlack(),
            ),
            SvgPicture.asset(
              'assets/images/setting.svg',
              height: 30.h,
              fit: BoxFit.cover,
              // ignore: deprecated_member_use
              color: comboWhiteAndBlack(),
            ),
          ],
          onTap: (index) {
            _page.value = index;
          },
        ),
        body: Obx(() {
          return IndexedStack(
            index: _page.value,
            children: pages,
          );
        }),
      );
    });
  }
}
