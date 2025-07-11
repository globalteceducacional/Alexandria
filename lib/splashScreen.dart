import 'package:elearn/consttants.dart';
import 'package:elearn/screens/bottom_navigation.dart';
import 'package:elearn/screens/login.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    Future.delayed(Duration(seconds: 2), () {
      Get.offAll(
        () {
          if (userId == null) {
            if (guest == false) {
              return Login();
            } else {
              return HomeScreen();
            }
          } else {
            return HomeScreen();
          }
        },
      );
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/1234.png"),
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}
