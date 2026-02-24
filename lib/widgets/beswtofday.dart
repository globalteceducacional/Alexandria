import 'package:elearn/screens/details_screen.dart';
import 'package:elearn/widgets/imageview.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../consttants.dart';

class BestOfTheDayVertical extends StatelessWidget {
  const BestOfTheDayVertical({
    super.key,
    required this.index,
    required this.image,
    required this.bookDescription,
    required this.rate,
    required this.bookTitle,
    required this.authorDescription,
    required this.authorName,
    required this.fileUrl,
    required this.catId,
  });

  final int index;
  final String image;
  final String fileUrl;
  final String bookDescription;
  final String authorDescription;
  final String bookTitle;
  final String authorName;
  final int catId;
  final String rate;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Get.to(() => DetailsScreen(
            authorName: authorName,
            authorDescription: bookDescription,
            bookCoverImg: image,
            bookDescription: authorDescription,
            id: catId,
            rating: rate,
            bookTitle: bookTitle));
      },
      child: Container(
        height: 200.h,
        width: 300.w,
        alignment: Alignment.center,
        padding: EdgeInsets.all(10.w),
        decoration: BoxDecoration(
          color: comboBlackAndWhite(),
          borderRadius: BorderRadius.circular(20.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(128),
              blurRadius: 10,
              spreadRadius: 2,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Imageview(
              image: image,
              height: 350.r,
              width: 150.r,
              radius: 8.0.r,
            ),
            SizedBox(width: 15.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    bookTitle,
                    style: const TextStyle(
                      fontSize: 30,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontFamily: "Gilroy-Bold",
                    ),
                  ),
                  Text(
                    authorName,
                    style: const TextStyle(
                      fontSize: 15,
                      color: Colors.white70,
                      fontFamily: "Gilroy-Bold",
                    ),
                  ),
                  SizedBox(height: 10.h),
                  Flexible(
                    child: Text(
                      htmlString(html: bookDescription),
                      maxLines: 4,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 20,
                        color: Colors.white60,
                        fontFamily: "Gilroy-SemiBold",
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class BestOfTheDayHorizontal extends StatelessWidget {
  const BestOfTheDayHorizontal({
    super.key,
    required this.index,
    required this.image,
    required this.bookDescription,
    required this.rate,
    required this.bookTitle,
    required this.authorDescription,
    required this.authorName,
    required this.fileUrl,
    required this.catId,
  });

  final int index;
  final String image;
  final String fileUrl;
  final String bookDescription;
  final String authorDescription;
  final String bookTitle;
  final String authorName;
  final int catId;
  final String rate;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Get.to(() => DetailsScreen(
            authorName: authorName,
            authorDescription: bookDescription,
            bookCoverImg: image,
            bookDescription: authorDescription,
            id: catId,
            rating: rate,
            bookTitle: bookTitle));
      },
      child: Container(
        height: 200.h,
        width: MediaQuery.of(context).size.width * 0.5,
        margin: EdgeInsets.symmetric(vertical: 5.h, horizontal: 1.w),
        padding: EdgeInsets.all(5.w),
        decoration: BoxDecoration(
          color: comboBlackAndWhite(),
          borderRadius: BorderRadius.circular(20.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(128),
              blurRadius: 10,
              spreadRadius: 2,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Imageview(
              image: image,
              height: 200.r,
              width: 150.r,
              radius: 8.0.r,
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    bookTitle,
                    style: const TextStyle(
                      fontSize: 30,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontFamily: "Gilroy-Bold",
                    ),
                  ),
                  Text(
                    authorName,
                    style: const TextStyle(
                      fontSize: 15,
                      color: Colors.white70,
                      fontFamily: "Gilroy-Bold",
                    ),
                  ),
                  SizedBox(height: 10.h),
                  Flexible(
                    child: Text(
                      htmlString(html: bookDescription),
                      maxLines: 4,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.white60,
                        fontFamily: "Gilroy-SemiBold",
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
