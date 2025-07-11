import 'package:elearn/consttants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

class TitleBar extends StatelessWidget {
  TitleBar({
    required this.image,
    required this.title,
    this.imageSizePortrait = 30.0,
    this.textSizePortrait = 25.0,
    this.imageSizeLandscape = 70.0,
    this.textSizeLandscape = 20.0,
  });

  final String image;
  final String title;
  final double imageSizePortrait;
  final double textSizePortrait;
  final double imageSizeLandscape;
  final double textSizeLandscape;

  @override
  Widget build(BuildContext context) {
    final bool isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;
    final double imageSize =
        isPortrait ? imageSizePortrait : imageSizeLandscape;
    final double textSize = isPortrait ? textSizePortrait : textSizeLandscape;

    return Padding(
      padding: EdgeInsets.only(top: 8.0.h, left: 5.w),
      child: Row(
        children: [
          Card(
            shadowColor: Colors.transparent,
            color: Colors.transparent,
            elevation: 0,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(50.r)),
            child: SvgPicture.asset(
              image,
              fit: BoxFit.cover,
              height: imageSize.h,
              width: imageSize.w,
            ),
          ),
          SizedBox(width: 10.w),
          Text(
            title,
            style: TextStyle(
              fontSize: textSize.sp,
              decoration: TextDecoration.none,
              color: comboWhiteAndBlack(),
              fontFamily: 'Gilroy-SemiBold',
            ),
          ),
        ],
      ),
    );
  }
}
