import 'dart:math';

import 'package:elearn/consttants.dart';
import 'package:elearn/generated/l10n.dart';
import 'package:elearn/screens/details_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';

import '../../databasefavourite/db.dart';
import '../../widgets/imageview.dart';

class ReadTodoScreen extends StatefulWidget {
  const ReadTodoScreen({super.key});

  @override
  State<ReadTodoScreen> createState() => _ReadTodoScreenState();
}

class _ReadTodoScreenState extends State<ReadTodoScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: comboBlackAndWhite(),
      appBar: AppBar(
          backgroundColor: comboBlackAndWhite(),
          elevation: 10.0,
          centerTitle: true,
          title: Text(
            S.of(context).setting_screen_FAVOURITE,
            style: TextStyle(
                color: comboWhiteAndBlack(), fontFamily: "Gilroy-SemiBold"),
          ),
          leading: Padding(
              padding: EdgeInsets.only(left: 10.0.w),
              child: IconButton(
                onPressed: () {
                  Get.back();
                },
                icon: Icon(Icons.arrow_back_ios_rounded,
                    color: comboWhiteAndBlack()),
              ))),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: DatabaseHelper.instance.retrieveTodos(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.data!.isNotEmpty) {
              return GridView.builder(
                scrollDirection: Axis.vertical,
                itemCount: snapshot.data!.length,
                shrinkWrap: true,
                padding: EdgeInsets.all(8.r),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisSpacing: 10.w,
                  crossAxisCount: 2,
                  mainAxisSpacing: 10.w,
                  childAspectRatio: 160.w / 260.w,
                ),
                itemBuilder: (BuildContext context, int index) {
                  return GestureDetector(
                    onTap: () {
                      Get.to(
                        () => DetailsScreen(
                          id: snapshot.data![index]['id'],
                          bookCoverImg: snapshot.data![index]['image'],
                          bookTitle: snapshot.data![index]['title'],
                          authorDescription: snapshot.data![index]
                              ['authorDescription'],
                          authorName: snapshot.data![index]['authorName'],
                          rating: snapshot.data![index]['rating'],
                          bookDescription: snapshot.data![index]
                              ['bookDescription'],
                        ),
                      )!
                          .whenComplete(() {
                        if (mounted) {
                          setState(() {});
                        }
                      });
                    },
                    child: Column(
                      children: [
                        Stack(
                          alignment: Alignment.topRight,
                          children: [
                            Imageview(
                              image: "${snapshot.data![index]['image']}",
                              height: 240.w,
                              width: 160.w,
                              radius: 10.r,
                            ),
                            InkWell(
                              onTap: () async {
                                await DatabaseHelper.instance.deleteTodo(
                                    id: snapshot.data![index]['id']);
                                setState(() {});
                              },
                              child: Container(
                                width: 35.w,
                                height: 35.w,
                                margin: EdgeInsets.all(8.w),
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(Icons.favorite,
                                    size: 22.w, color: Colors.red),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 10.h),
                        Text(
                          snapshot.data![index]['title'],
                          maxLines: 2,
                          style: TextStyle(
                            overflow: TextOverflow.ellipsis,
                            fontSize: 15.sp,
                            fontFamily: "Gilroy-SemiBold",
                            color: comboWhiteAndBlack(),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            } else {
              return Center(
                child: Text(
                  S.of(context).no_favorite,
                  style: TextStyle(
                      color: comboWhiteAndBlack(), fontFamily: "Gilroy-Medium"),
                ),
              );
            }
          } else {
            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: EdgeInsets.all(8.r),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisSpacing: 10.w,
                  mainAxisSpacing: 10.h,
                  crossAxisCount: 2,
                  childAspectRatio: 0.70),
              itemCount: Random().nextInt(5),
              scrollDirection: Axis.vertical,
              itemBuilder: (context, index) {
                return Shimmer.fromColors(
                  baseColor: shimmerBaseColor(),
                  highlightColor: shimmerHighlightColor(),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
