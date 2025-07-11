import 'package:elearn/consttants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class Button extends StatelessWidget {
  Button({required this.onTap, required this.buttonname});
  final VoidCallback onTap;
  final String buttonname;
  @override
  Widget build(BuildContext context) {
    return MaterialButton(
      focusColor: buttonColorAccent,
      minWidth: 150.w,
      height: 40,
      elevation: 5,
      highlightElevation: 5,
      highlightColor: Colors.white54,
      splashColor: Colors.transparent,
      colorBrightness: Brightness.light,
      onPressed: onTap,
      color: Color(0xff2055AD),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
      child: Text(
        buttonname,
        style: TextStyle(
          fontFamily: "Gilroy-SemiBold",
          color: Colors.white,
          fontSize: 15.sp,
        ),
      ),
    );
  }
}
