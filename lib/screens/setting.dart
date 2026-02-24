import 'dart:convert';
import 'dart:io';

import 'package:elearn/widgets/safe_image_widget.dart';
import 'package:elearn/generated/l10n.dart';
import 'package:elearn/language.dart';
import 'package:elearn/model/Profile.dart';
import 'package:elearn/screens/login.dart';
import 'package:elearn/screens/setting/download.dart';
import 'package:elearn/screens/setting/favourite.dart';
import 'package:elearn/screens/setting/profile.dart';
import 'package:elearn/service/httpservice.dart';
import 'package:elearn/widgets/title.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../consttants.dart';
import '../language_constants.dart';
import '../main.dart';

class Setting extends StatefulWidget {
  const Setting({super.key});

  @override
  State<Setting> createState() => _SettingState();
}

class _SettingState extends State<Setting> {
  ProfileModel? profileModel;

  void _changeLanguage(Language language) async {
    Locale locale = await setLocale(language.languageCode);
    if (!mounted) return;
    MyApp.setLocale(context, locale);
  }

  getUserData() async {
    await HttpService().getUserProfile().then((value) {
      profileModel = value;
      setState(() {});
    });
  }

  @override
  void initState() {
    getUserData();
    super.initState();
  }

  final FirebaseAuth _auth = FirebaseAuth.instance;

  String getAppShare() {
    if (Platform.isIOS) {
      return appShareIOS;
    } else {
      return appShareAndroid;
    }
  }

  String getAppShareText() {
    if (Platform.isIOS) {
      return appShareTextIOS;
    } else {
      return appShareTextAndroid;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: comboBlackAndWhite(),
      appBar: AppBar(
        elevation: 0,
        automaticallyImplyLeading: true,
        backgroundColor: comboBlackAndWhite(),
        toolbarHeight: 80.0,
        title: TitleBar(
          title: S.of(context).setting_SETTINGTITLE,
          image: 'assets/images/setting.svg',
        ),
        actions: [
          IconButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => Dialog(
                  backgroundColor: comboBlackAndWhite(),
                  child: Column(
                    children: [
                      AppBar(
                        backgroundColor: Colors.transparent,
                        elevation: 0,
                        iconTheme: IconThemeData(color: comboWhiteAndBlack()),
                      ),
                      Expanded(
                        child: ListView.builder(
                          itemCount: Language.languageList().length,
                          shrinkWrap: true,
                          itemBuilder: (context, index) => ListTile(
                            dense: true,
                            leading: Text(
                              Language.languageList()[index].flag,
                              style: const TextStyle(fontSize: 30),
                            ),
                            title: Text(
                              Language.languageList()[index].name,
                              style: TextStyle(color: comboWhiteAndBlack()),
                            ),
                            onTap: () {
                              _changeLanguage(Language.languageList()[index]);
                              Get.back();
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
            icon: const Icon(Icons.language),
            color: comboWhiteAndBlack(),
          ),
          if (userId != null)
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: IconButton(
                icon: Icon(
                  Icons.favorite,
                  color: comboWhiteAndBlack(),
                  size: 30.r,
                ),
                onPressed: () {
                  Get.to(() => const ReadTodoScreen());
                },
              ),
            )
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            userId != null && profileModel != null
                ? Padding(
                    padding: EdgeInsets.only(top: 30.h, left: 15.w),
                    child: Column(
                      children: [
                        SafeProfileImageWidget(
                          imageUrl: profileModel!.ebookApp[0].userImage,
                          size: 100.w,
                        ),
                        SizedBox(height: 20.h),
                        Text(
                          profileModel!.ebookApp[0].name.toTitleCase(),
                          style: TextStyle(
                            fontSize: 18.sp,
                            fontFamily: "Gilroy-Bold",
                            color: comboWhiteAndBlack(),
                          ),
                        ),
                      ],
                    ),
                  )
                : Padding(
                    padding: EdgeInsets.only(top: 30.h, left: 15.w),
                    child: Column(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(80.r),
                          child: Image.network(
                            "https://vocsyinfotech.in/envato/cc/flutter_ebook/images/add-image.png",
                            fit: BoxFit.cover,
                            width: 100.w,
                            height: 100.w,
                          ),
                        ),
                        SizedBox(height: 20.h),
                        const Text(
                          "Guest",
                          style: TextStyle(
                            fontSize: 18,
                            fontFamily: "Gilroy-Bold",
                          ),
                        ),
                      ],
                    ),
                  ),
            SizedBox(height: 60.h),
            if (userId != null && type == "Normal")
              SettingList(
                title: S.of(context).setting_PROFILE,
                icon: "assets/images/profile.svg",
                onTap: () {
                  Get.to(
                    () => EditProfile(
                      image: profileModel!.ebookApp[0].userImage,
                      name: profileModel!.ebookApp[0].name,
                      email: profileModel!.ebookApp[0].email,
                      phoneNumber: profileModel!.ebookApp[0].phone,
                    ),
                  )!
                      .then((value) {
                    if (value == true) {
                      getUserData();
                    }
                  });
                },
              ),
            SettingList(
                title: mode.value == false
                    ? S.of(context).setting_dark_theme
                    : S.of(context).setting_light_theme,
                icon: mode.value == false
                    ? 'assets/images/dark.svg'
                    : 'assets/images/light.svg',
                onTap: () async {
                  mode.value = !mode.value;
                  SharedPreferences prefs =
                      await SharedPreferences.getInstance();
                  Get.changeThemeMode(
                      mode.value == true ? ThemeMode.dark : ThemeMode.light);
                  prefs.setBool("isDark", mode.value);
                  SystemChrome.setSystemUIOverlayStyle(
                    SystemUiOverlayStyle(
                      statusBarColor: Colors.transparent,
                      statusBarBrightness: mode.value == false
                          ? Brightness.light
                          : Brightness.dark,
                      statusBarIconBrightness: mode.value == false
                          ? Brightness.dark
                          : Brightness.light,
                      systemNavigationBarIconBrightness: mode.value == false
                          ? Brightness.dark
                          : Brightness.light,
                      systemNavigationBarColor: comboBlackAndWhite(),
                    ),
                  );
                  if (!context.mounted) return;
                  Phoenix.rebirth(context);
                }),
            if (userId != null)
              SettingList(
                title: S.of(context).setting_DOWNLOAD,
                icon: "assets/images/down.svg",
                onTap: () {
                  Get.to(() => const Download());
                },
              ),
            SettingList(
              title: S.of(context).setting_SHARE,
              icon: "assets/images/share.svg",
              onTap: () async {
                Share.share(
                    '${getAppShareText()}\n ${getAppShareText()} \n ${getAppShare()} \n ${getAppShareText()}');
              },
            ),
            SettingList(
              title: S.of(context).setting_PRIVACY_POLICY,
              icon: "assets/images/policy.svg",
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) => Dialog(
                    backgroundColor: comboBlackAndWhite(),
                    insetPadding: EdgeInsets.all(10.r),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Spacer(),
                            Text(
                              S.of(context).setting_PRIVACY_POLICY,
                              style: TextStyle(
                                  fontFamily: 'Gilroy-SemiBold',
                                  fontSize: 20.sp,
                                  color: comboWhiteAndBlack()),
                            ),
                            const Spacer(),
                            IconButton(
                              onPressed: () {
                                Get.back();
                              },
                              icon: Icon(Icons.clear,
                                  color: comboWhiteAndBlack()),
                            ),
                          ],
                        ),
                        Expanded(
                            child: SingleChildScrollView(
                          child: Padding(
                            padding: EdgeInsets.all(8.r),
                            child: Text(
                              htmlString(html: privacypolicy!),
                              style: TextStyle(
                                fontFamily: 'Gilroy-SemiBold',
                                fontSize: 15.sp,
                                color: comboWhiteAndBlack(),
                              ),
                            ),
                          ),
                        )),
                      ],
                    ),
                  ),
                );
              },
            ),
            SettingList(
              title: userId == null
                  ? S.of(context).loginPage_LOGIN
                  : S.of(context).setting_LOGOUT,
              icon: "assets/images/logout.svg",
              onTap: () async {
                if (userId == null) {
                  SharedPreferences prefs =
                      await SharedPreferences.getInstance();
                  prefs.remove('guest');
                  prefs.clear();
                  Get.offAll(() => const Login());
                } else {
                  Alert(
                    style: const AlertStyle(backgroundColor: Colors.white),
                    context: context,
                    type: AlertType.none,
                    title: S.of(context).setting_logout_ARE_YOU_SURE,
                    desc: S.of(context).setting_logout_LOGOUT_WITH_EBOOK,
                    buttons: [
                      DialogButton(
                        color: Colors.black,
                        width: 200.w,
                        height: 100.h,
                        child: Text(
                          S.of(context).setting_LOGOUT,
                          style: TextStyle(
                            fontFamily: "Gilroy-Medium",
                            color: Colors.white,
                            fontSize: 22.sp,
                          ),
                        ),
                        onPressed: () async {
                          SharedPreferences prefs =
                              await SharedPreferences.getInstance();
                          _auth.signOut();
                          GoogleSignIn().signOut();
                          prefs.remove('userId');
                          prefs.remove('type');
                          prefs.clear();
                          Get.offAll(() => const Login());
                        },
                      ),
                    ],
                  ).show();
                }
              },
            ),
            if (userId != null)
              SettingList(
                title: S.of(context).setting_DELETE,
                icon: "assets/images/dltbtn.svg",
                onTap: () async {
                  Alert(
                    style: const AlertStyle(backgroundColor: Colors.white),
                    context: context,
                    type: AlertType.none,
                    title: S.of(context).setting_logout_ARE_YOU_SURE,
                    desc: S.of(context).setting_logout_DELETE_WITH_EBOOK,
                    buttons: [
                      DialogButton(
                        color: Colors.black,
                        width: 200.w,
                        height: 100.h,
                        child: Text(
                          S.of(context).setting_DELETE,
                          style: TextStyle(
                              fontFamily: "Gilroy-Medium",
                              color: Colors.white,
                              fontSize: 20.sp),
                        ),
                        onPressed: () async {
                          final response = await http.get(Uri.parse(
                              '$apiLink/api.php?method_name=delete_userdata&user_id=$userId'));
                          if (response.statusCode == 200) {
                            final jsonResponse = jsonDecode(response.body);
                            if (jsonResponse['EBOOK_APP'][0]['success'] ==
                                "1") {
                              SharedPreferences prefs =
                                  await SharedPreferences.getInstance();
                              _auth.signOut();
                              await GoogleSignIn().signOut();
                              prefs.remove('userId');
                              prefs.remove('type');
                              prefs.clear();
                              showToast(
                                  msg: jsonResponse['EBOOK_APP'][0]['MSG']);
                              Get.offAll(() => const Login());
                            } else {
                              showToast(
                                  msg: jsonResponse['EBOOK_APP'][0]['MSG']);
                            }
                          } else {
                            debugPrint(
                                'Request failed with status: ${response.statusCode}.');
                          }
                        },
                      )
                    ],
                  ).show();
                },
              ),
          ],
        ),
      ),
    );
  }
}

class SettingList extends StatelessWidget {
  const SettingList(
      {super.key,
      required this.title,
      required this.icon,
      required this.onTap});

  final String title;
  final String icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 15.0.w, vertical: 10.h),
      child: GestureDetector(
        onTap: onTap,
        child: Row(
          children: [
            SvgPicture.asset(
              icon,
              colorFilter: ColorFilter.mode(
                  mode.value == false
                      ? kDarkThemeBackGroungColor
                      : kLightThemeBackGroundColor,
                  BlendMode.srcIn),
              height: 45.0.h,
              width: 30.0.w,
            ),
            SizedBox(
              width: 15.w,
            ),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                    fontFamily: 'Gilroy-SemiBold',
                    fontSize: 20.sp,
                    color: comboWhiteAndBlack()),
              ),
            )
          ],
        ),
      ),
    );
  }
}
