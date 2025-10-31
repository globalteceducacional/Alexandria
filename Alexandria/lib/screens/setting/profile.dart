import 'dart:convert' as convert;
import 'dart:convert';
import 'dart:io';

import 'package:elearn/widgets/safe_image_widget.dart';
import 'package:elearn/consttants.dart';
import 'package:elearn/generated/l10n.dart';
import 'package:elearn/screens/login.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

class EditProfile extends StatefulWidget {
  EditProfile(
      {required this.name,
      required this.image,
      required this.email,
      required this.phoneNumber});

  final String name;
  final String image;
  final String email;
  final String phoneNumber;

  @override
  _EditProfileState createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  bool spin = false;
  File? imageF;
  final _form = GlobalKey<FormState>();
  ImagePicker imagePicker = ImagePicker();

  @override
  void initState() {
    nameController = TextEditingController(text: widget.name);
    emailController = TextEditingController(text: widget.email);
    phoneController = TextEditingController(text: widget.phoneNumber);
    super.initState();
  }

  Future<void> _getFromGallery() async {
    await imagePicker
        .pickImage(
      source: ImageSource.gallery,
      maxWidth: 1800,
      maxHeight: 1800,
    )
        .then((pickedFile) {
      imageF = File(pickedFile!.path);
      setState(() {});
    });
  }

  Future<void> _getFromCamera() async {
    await imagePicker
        .pickImage(
      source: ImageSource.camera,
      maxWidth: 1800,
      maxHeight: 1800,
    )
        .then((pickedFile) {
      imageF = File(pickedFile!.path);
      setState(() {});
    });
  }

  void saveName() async {
    try {
      final isValid = _form.currentState!.validate();
      if (!isValid) {
        return;
      }
      _form.currentState!.save();

      final String url = "$apiLink/user_profile_update_api.php";
      var request = http.MultipartRequest('POST', Uri.parse(url));
      request.fields['method_name'] = "user_profile_update";
      request.fields['user_id'] = "$userId";
      request.fields['name'] = "${nameController.text}";
      request.fields['email'] = "${widget.email}";
      request.fields['phone'] = "${phoneController.text}";

      http.Response response =
          await http.Response.fromStream(await request.send());
      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        if (data['EBOOK_APP'][0]['success'] == '1') {
          spin = true;
          Navigator.pop(context, spin);
          showToast(msg: data['EBOOK_APP'][0]['msg']);
        } else {
          showToast(msg: data['EBOOK_APP'][0]['msg']);
        }
      } else {}
    } catch (e) {}
  }

  void saveProfile() async {
    final isValid = _form.currentState!.validate();
    if (!isValid) {
      return;
    }
    _form.currentState!.save();

    try {
      final String url = "$apiLink/user_profile_update_api.php";
      final request = http.MultipartRequest('POST', Uri.parse(url));

      request.files
          .add(await http.MultipartFile.fromPath('user_image', imageF!.path));
      request.fields['method_name'] = "user_profile_update";
      request.fields['user_id'] = "$userId";
      request.fields['name'] = "${nameController.text}";
      request.fields['email'] = "${widget.email}";
      request.fields['phone'] = "${phoneController.text}";

      http.Response response =
          await http.Response.fromStream(await request.send());

      if (response.statusCode == 200) {
        var data = convert.jsonDecode(response.body);
        if (data['EBOOK_APP'][0]['success'] == '1') {
          spin = true;
          Navigator.pop(context, spin);
          showToast(msg: data['EBOOK_APP'][0]['msg']);
        } else {
          showToast(msg: data['EBOOK_APP'][0]['msg']);
        }
      }
    } catch (e) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: comboBlackAndWhite(),
      appBar: AppBar(
        backgroundColor: comboBlackAndWhite(),
        title: Text(
          S.of(context).profile_USER_PROFILE,
          style: TextStyle(
              color: comboWhiteAndBlack(),
              fontSize: 15.sp,
              fontFamily: "Gilroy-SemiBold"),
        ),
        elevation: 0.0,
        centerTitle: true,
        leading: IconButton(
          onPressed: () {
            Get.back();
          },
          icon: Icon(Icons.arrow_back_ios),
          color: comboWhiteAndBlack(),
        ),
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(
          children: <Widget>[
            Column(
              children: <Widget>[
                Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        S.of(context).profile_UPDATE_YOUR_NAME,
                        style: TextStyle(
                            color: comboWhiteAndBlack(),
                            fontSize: 15.sp,
                            fontFamily: "Gilroy-Bold"),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding:
                      EdgeInsets.symmetric(vertical: 8.0.h, horizontal: 15.w),
                  child: Form(
                    key: _form,
                    child: TextFormField(
                      validator: (value) {
                        if (value!.isEmpty)
                          return S
                              .of(context)
                              .details_screen_comments_textField_validation;
                        else
                          return null;
                      },
                      controller: nameController,
                      autofocus: false,
                      decoration: InputDecoration(
                        isDense: true,
                        prefixIcon: Padding(
                          padding: EdgeInsets.all(15.r),
                          child: Image.asset(
                            "assets/images/person.png",
                            height: 10.w,
                            width: 10.w,
                            color: comboLightGreyAndGrey(),
                          ),
                        ),
                        contentPadding: EdgeInsets.symmetric(
                            vertical: 15.h, horizontal: 30.w),
                        hintText: "Enter Name",
                        hintStyle: TextStyle(
                          color: comboLightGreyAndGrey(),
                          fontFamily: "Gilroy-SemiBold",
                        ),
                        fillColor: comboBlackAndWhite(),
                        focusedBorder: OutlineInputBorder(
                          gapPadding: 5,
                          borderRadius: BorderRadius.circular(10.0.r),
                          borderSide: BorderSide(
                              color: comboWhiteAndBlack(), width: 0.8.w),
                        ),
                        border: OutlineInputBorder(
                          gapPadding: 5,
                          borderRadius: BorderRadius.circular(10.0.r),
                          borderSide: BorderSide(
                              color: comboWhiteAndBlack(), width: 0.5.w),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0.r),
                          borderSide: BorderSide(
                              color: comboWhiteAndBlack(), width: 0.5.w),
                        ),
                        disabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0.r),
                          borderSide: BorderSide(
                              color: comboWhiteAndBlack(), width: 0.5.w),
                        ),
                      ),
                      keyboardType: TextInputType.emailAddress,
                      style: TextStyle(
                        fontFamily: "Gilroy-SemiBold",
                        color: comboWhiteAndBlack(),
                        fontSize: 16.sp,
                        decoration: TextDecoration.none,
                      ),
                    ),
                  ),
                ),
                CustomTextFiled(
                  hintText: "Enter Email",
                  controller: emailController,
                  readOnly: true,
                  icon: "assets/images/Vector.png",
                ),
                CustomTextFiled(
                  hintText: "Enter Number",
                  controller: phoneController,
                  readOnly: false,
                  icon: "assets/images/Phone.png",
                ),
                SizedBox(height: 5.h),
              ],
            ),
            Container(
              margin: EdgeInsets.symmetric(horizontal: 15.w, vertical: 20.h),
              width: double.infinity,
              child: Padding(
                padding: EdgeInsets.all(8.0.h.w),
                child: Column(
                  children: [
                    Divider(
                      color: comboWhiteAndBlack(),
                      indent: 50.0,
                      thickness: 1.0,
                      endIndent: 50.0,
                    ),
                    Text(
                      "Update Profile Picture",
                      style: TextStyle(
                          color: comboWhiteAndBlack(),
                          fontFamily: "Gilroy-SemiBold",
                          fontSize: 18.0.sp),
                    ),
                    Divider(
                      color: comboWhiteAndBlack(),
                      indent: 50.0,
                      thickness: 1.0,
                      endIndent: 50.0,
                    ),
                    SizedBox(
                      height: 15.0.h,
                    ),
                    imageF == null
                        ? SafeProfileImageWidget(
                            imageUrl: widget.image,
                            size: 100.w,
                          )
                        : ClipRRect(
                            borderRadius: BorderRadius.circular(80.r),
                            child: Image.file(
                              File(imageF!.path),
                              height: 100.w,
                              width: 100.w,
                              fit: BoxFit.cover,
                            ),
                          ),
                    SizedBox(height: 20.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: comboBlackAndWhite(), // background
                            padding: EdgeInsets.symmetric(
                                vertical: 8.h, horizontal: 10.w),
                            shape: RoundedRectangleBorder(
                              side: BorderSide(color: comboLightGreyAndGrey()),
                              borderRadius: BorderRadius.circular(
                                15.r,
                              ),
                            ),
                            elevation: 0.0,
                          ),
                          child: Padding(
                            padding: EdgeInsets.all(8.w),
                            child: Row(
                              children: <Widget>[
                                SvgPicture.asset(
                                  "assets/images/camera.svg",
                                  // ignore: deprecated_member_use
                                  color: comboWhiteAndBlack(),
                                  height: 20.w,
                                  width: 20.w,
                                ),
                                SizedBox(width: 8.w),
                                Text(
                                  S.of(context).profile_CAMERA,
                                  style: TextStyle(
                                      color: comboWhiteAndBlack(),
                                      fontSize: 18.sp,
                                      fontFamily: "Gilroy-SemiBold"),
                                ),
                              ],
                            ),
                          ),
                          onPressed: () {
                            _getFromCamera();
                          },
                        ),
                        SizedBox(width: 10.w),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.symmetric(
                                vertical: 8.h, horizontal: 10.w),
                            shape: RoundedRectangleBorder(
                              side: BorderSide(color: comboLightGreyAndGrey()),
                              borderRadius:
                                  BorderRadius.circular(15.r), // <-- Radius
                            ),
                            backgroundColor: comboBlackAndWhite(),
                            elevation: 0.0,
                          ),
                          child: Padding(
                            padding: EdgeInsets.all(8.0.h.w),
                            child: Row(
                              children: [
                                SvgPicture.asset(
                                  "assets/images/gallery.svg",
                                  // ignore: deprecated_member_use
                                  color: comboWhiteAndBlack(),
                                  height: 20.w,
                                  width: 20.w,
                                ),
                                SizedBox(width: 8.w),
                                Text(
                                  S.of(context).profile_GALLERY,
                                  style: TextStyle(
                                      color: comboWhiteAndBlack(),
                                      fontSize: 18.sp,
                                      fontFamily: "Gilroy-SemiBold"),
                                ),
                              ],
                            ),
                          ),
                          onPressed: () {
                            _getFromGallery();
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: comboBlackAndWhite(),
                padding: EdgeInsets.symmetric(vertical: 20.h, horizontal: 60.w),
                elevation: 00,
                shape: RoundedRectangleBorder(
                  side: BorderSide(color: comboLightGreyAndGrey()),
                  borderRadius: BorderRadius.circular(15.r), // <-- Radius
                ),
              ),
              child: Text(
                S.of(context).profile_SAVE,
                style: TextStyle(
                    color: comboWhiteAndBlack(),
                    fontSize: 18.sp,
                    fontFamily: "Gilroy-SemiBold"),
              ),
              onPressed: () {
                imageF != null ? saveProfile() : saveName();
              },
            ),
          ],
        ),
      ),
    );
  }
}
