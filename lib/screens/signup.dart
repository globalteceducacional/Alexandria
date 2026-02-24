import 'package:elearn/generated/l10n.dart';
import 'package:elearn/screens/login.dart';
import 'package:elearn/service/httpservice.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../consttants.dart';
import 'bottom_navigation.dart';

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController forgetController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  GoogleSignIn googleSignIn = GoogleSignIn(scopes: ['email']);
  RxBool showPassword = true.obs;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: comboBlackAndWhite(),
      body: Obx(() {
        return ModalProgressHUD(
          inAsyncCall: inAsyncCall.value,
          progressIndicator: CircularProgressIndicator(strokeWidth: 1.w),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ///Skip Button
                Align(
                  alignment: Alignment.topRight,
                  child: Padding(
                    padding: EdgeInsets.only(top: 20.h, right: 10.w),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        BackButton(
                          onPressed: () {
                            Get.back();
                          },
                          color: comboWhiteAndBlack(),
                        ),
                        GestureDetector(
                          onTap: () async {
                            final sharedPreferences =
                                await SharedPreferences.getInstance();
                            sharedPreferences.setBool("guest", true);
                            getUserId();
                            Get.offAll(() => const HomeScreen());
                          },
                          child: SizedBox(
                            width: 50.w,
                            child: Text(
                              S.of(context).loginPage_SKIP,
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontFamily: 'Gilroy-Bold',
                                color: comboWhiteAndBlack(),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 50.h),

                /// TItle
                Padding(
                  padding: EdgeInsets.only(left: 15.0.w),
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          S.of(context).loginPage_WELCOMES,
                          style: TextStyle(
                              fontSize: 20.0.sp,
                              fontFamily: "Gilroy-Bold",
                              color: comboWhiteAndBlack()),
                        ),
                        Text(
                          S.of(context).loginPage_Signup_to_enjoy_the_App,
                          style: TextStyle(
                              fontSize: 20.0.sp,
                              fontFamily: "Gilroy-SemiBold",
                              color: comboWhiteAndBlack()),
                        ),
                      ]),
                ),
                SizedBox(height: 60.h),

                /// Form Field
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomTextFiled(
                      controller: nameController,
                      icon: 'assets/images/User.png',
                      obse: false,
                      hintText: S.of(context).loginPage_nameHint,
                    ),
                    CustomTextFiled(
                      controller: emailController,
                      icon: 'assets/images/Vector.png',
                      obse: false,
                      hintText: S.of(context).loginPage_emailHint,
                    ),
                    Obx(() {
                      return CustomTextFiled(
                        controller: passwordController,
                        icon: 'assets/images/Group.png',
                        obse: showPassword.value,
                        hintText: S.of(context).loginPage_passwordHint,
                        suffixIcon: GestureDetector(
                          onTap: () {
                            showPassword.value = !showPassword.value;
                          },
                          child: Icon(
                              showPassword.value
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              color: comboLightGreyAndGrey()),
                        ),
                      );
                    }),
                    CustomTextFiled(
                      controller: phoneController,
                      icon: 'assets/images/Phone.png',
                      obse: false,
                      hintText: S.of(context).loginPage_phoneHint,
                    ),
                  ],
                ),
                SizedBox(height: 50.h),

                ///signup Button
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: () async {
                        inAsyncCall.value = true;
                        await HttpService.getUserRegister(context,
                            email: emailController.text,
                            password: passwordController.text,
                            name: nameController.text,
                            number: phoneController.text,
                            type: "Normal");
                      },
                      child: Container(
                        alignment: Alignment.center,
                        margin: EdgeInsets.symmetric(horizontal: 15.0.w),
                        height: 100.h,
                        width: 300.w,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15.0.r),
                            color: comboWhiteAndBlack()),
                        child: Text(
                          S.of(context).loginPage_SIGNUP,
                          style: TextStyle(
                              fontSize: 20.0.sp,
                              color: comboBlackAndWhite(),
                              fontFamily: "Gilroy-Bold"),
                        ),
                      ),
                    )
                  ],
                ),
                SizedBox(height: 20.0.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton(
                      onPressed: () {
                        Get.back();
                      },
                      child: Text(
                        S.of(context).loginPage_Already_Have_An_Account,
                        style: TextStyle(
                            color: comboWhiteAndBlack(),
                            fontSize: 10.sp,
                            fontFamily: "Gilroy-Medium"),
                      ),
                    )
                  ],
                ),
                SizedBox(height: 20.0.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GestureDetector(
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
                      child: Text(S.of(context).setting_PRIVACY_POLICY,
                          style: TextStyle(
                              decoration: TextDecoration.underline,
                              color: comboWhiteAndBlack(),
                              fontSize: 10.sp,
                              fontFamily: "Gilroy-Medium")),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}
