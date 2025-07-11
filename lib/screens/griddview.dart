import 'dart:math';

import 'package:elearn/model/homecategory.dart';
import 'package:elearn/screens/setting/reading_card_list2.dart';
import 'package:elearn/service/httpservice.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';

import '../consttants.dart';
import '../generated/l10n.dart';
import 'details_screen.dart';

class ViewBookScreen extends StatelessWidget {
  const ViewBookScreen({required this.id, required this.title});

  final String id;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: comboBlackAndWhite(),
      appBar: AppBar(
        backgroundColor: comboBlackAndWhite(),
        elevation: 0.0,
        leading: IconButton(
          splashRadius: 10.r,
          onPressed: () {
            Get.back();
          },
          icon: Icon(
            Icons.arrow_back_ios,
            color: comboWhiteAndBlack(),
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 18.sp,
            color: comboWhiteAndBlack(),
            fontFamily: "Gilroy-Medium",
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 0.w),
        child: FutureBuilder<CategoryById?>(
            future: HttpService().getSingleViewBook(id: id),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                if (snapshot.hasData) {
                  return ListView.builder(
                      shrinkWrap: true,
                      itemCount: snapshot.data!.ebookApp.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: EdgeInsets.only(top: 4.0.h),
                          child: ReadingListCard2(
                            index: index,
                            image: snapshot.data!.ebookApp[index].bookCoverImg,
                            bookTitle: snapshot.data!.ebookApp[index].bookTitle,
                            authorName:
                                snapshot.data!.ebookApp[index].authorName,
                            bookid:
                                int.parse(snapshot.data!.ebookApp[index].id),
                            radius: 35.r,
                            rating: snapshot.data!.ebookApp[index].rateAvg,
                            authorDescription: snapshot
                                .data!.ebookApp[index].authorDescription,
                            bookDescription:
                                snapshot.data!.ebookApp[index].bookDescription,
                            authid: int.parse(
                                snapshot.data!.ebookApp[index].authorId),
                            onTap: () {
                              Get.to(
                                () {
                                  return DetailsScreen(
                                    authorName: snapshot
                                        .data!.ebookApp[index].authorName,
                                    authorDescription: snapshot.data!
                                        .ebookApp[index].authorDescription,
                                    bookCoverImg: snapshot
                                        .data!.ebookApp[index].bookCoverImg,
                                    bookTitle: snapshot
                                        .data!.ebookApp[index].bookTitle,
                                    bookDescription: snapshot
                                        .data!.ebookApp[index].bookDescription,
                                    id: int.parse(
                                        snapshot.data!.ebookApp[index].id),
                                    rating:
                                        snapshot.data!.ebookApp[index].rateAvg,
                                  );
                                },
                              );
                            },
                          ),
                        );
                      });
                } else {
                  return Center(
                      child: Text(S.of(context).search_NO_BOOKS_FOUND));
                }
              } else {
                return ListView.builder(
                  shrinkWrap: true,
                  itemCount: Random().nextInt(10),
                  scrollDirection: Axis.vertical,
                  itemBuilder: (context, index) {
                    return Shimmer.fromColors(
                      child: Container(
                        width: double.infinity,
                        height: 200.w,
                        color: Colors.white,
                        margin: EdgeInsets.all(10.r),
                      ),
                      baseColor: shimmerBaseColor(),
                      highlightColor: shimmerHighlightColor(),
                    );
                  },
                );
              }
            }),
      ),
    );
  }
}
