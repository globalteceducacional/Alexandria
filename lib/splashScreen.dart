// ignore_for_file: file_names, deprecated_member_use
import 'package:elearn/consttants.dart';
import 'package:elearn/screens/bottom_navigation.dart';
import 'package:elearn/screens/login.dart';
import 'package:elearn/widgets/safe_image_widget.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    dynamicLinkInit();
    loadData().whenComplete(() {
      Future.delayed(const Duration(seconds: 2), () {
        if (initialLink == null) {
          Get.offAll(
            () {
              if (userId == null) {
                if (guest == false) {
                  return const Login();
                } else {
                  return const HomeScreen();
                }
              } else {
                return const HomeScreen();
              }
            },
          );
        } else {
          if (!mounted) return;
          initDynamicLinks(context);
        }
      });
    });

    super.initState();
  }

  Future<void> loadData() async {
    initialLink = await FirebaseDynamicLinks.instance.getInitialLink();
  }

  PendingDynamicLinkData? initialLink;

  dynamicLinkInit() {
    FirebaseDynamicLinks.instance.onLink.listen((dynamicLinkData) {
      switch (dynamicLinkData.link.path) {
        case "/Author":
          {
            Get.offAll(
              () {
                if (userId == null) {
                  if (guest == false) {
                    return const Login();
                  } else {
                    return const HomeScreen();
                  }
                } else {
                  return const HomeScreen();
                }
              },
            );
          }
          break;
        case "/AudioBook":
          {
            Get.offAll(
              () {
                if (userId == null) {
                  if (guest == false) {
                    return const Login();
                  } else {
                    return const HomeScreen();
                  }
                } else {
                  return const HomeScreen();
                }
              },
            );
          }
          break;
        default:
          {}
      }
    });
  }

  initDynamicLinks(BuildContext context) async {
    var deepLink = initialLink!.link;
    loadData().then((sdf) {
      switch (deepLink.path) {
        case "/Author":
          {
            Get.offAll(
              () {
                if (userId == null) {
                  if (guest == false) {
                    return const Login();
                  } else {
                    return const HomeScreen();
                  }
                } else {
                  return const HomeScreen();
                }
              },
            );
          }
          break;
        case "/AudioBook":
          {
            Get.offAll(
              () {
                if (userId == null) {
                  if (guest == false) {
                    return const Login();
                  } else {
                    return const HomeScreen();
                  }
                } else {
                  return const HomeScreen();
                }
              },
            );
          }
          break;
        default:
          {
            Get.offAll(
              () {
                if (userId == null) {
                  if (guest == false) {
                    return const Login();
                  } else {
                    return const HomeScreen();
                  }
                } else {
                  return const HomeScreen();
                }
              },
            );
          }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeImageWidget(
        assetPath: "assets/images/1234.png",
        fit: BoxFit.cover,
        errorWidget: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFF42a5f5),
                Color(0xFF1976d2),
              ],
            ),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.book,
                  size: 80,
                  color: Colors.white,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Alexandria',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Biblioteca Digital',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white.withAlpha(200),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
