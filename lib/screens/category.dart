import 'dart:math';

import 'package:elearn/model/getsinglecategorybyid.dart';
import 'package:elearn/screens/setting/reading_card_list2.dart';
import 'package:elearn/service/httpservice.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';

import '../consttants.dart';
import '../generated/l10n.dart';
import 'details_screen.dart';

class NewCategoryScreen extends StatefulWidget {
  NewCategoryScreen({
    required this.catId,
    required this.categoryName,
  });

  final int catId;
  final String categoryName;

  @override
  _CategoryState createState() => _CategoryState();
}

class _CategoryState extends State<NewCategoryScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: comboBlackAndWhite(),
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          '${widget.categoryName}',
          style: TextStyle(
            color: comboWhiteAndBlack(),
            fontSize: 20.sp,
            fontFamily: 'Gilroy-SemiBold',
          ),
        ),
        elevation: 0.0,
        backgroundColor: comboBlackAndWhite(),
        leading: IconButton(
          onPressed: () {
            Get.back();
          },
          icon: Icon(
            Icons.arrow_back_ios,
            color: comboWhiteAndBlack(),
          ),
        ),
      ),
      body: FutureBuilder<GetSingleCategoryById?>(
        future: HttpService().getSingleCategoryByCatId(catId: widget.catId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasData) {
              return ListView.builder(
                  shrinkWrap: true,
                  itemCount: snapshot.data!.ebookApp.length,
                  scrollDirection: Axis.vertical,
                  itemBuilder: (context, index) {
                    return ReadingListCard2(
                      index: index,
                      image: snapshot.data!.ebookApp[index].bookCoverImg,
                      rating: snapshot.data!.ebookApp[index].rateAvg,
                      bookid: int.parse(snapshot.data!.ebookApp[index].id),
                      radius: 35.r,
                      authid:
                          int.parse(snapshot.data!.ebookApp[index].authorId),
                      authorDescription:
                          snapshot.data!.ebookApp[index].authorDescription,
                      bookDescription:
                          snapshot.data!.ebookApp[index].bookDescription,
                      bookTitle: snapshot.data!.ebookApp[index].bookTitle,
                      authorName: snapshot.data!.ebookApp[index].authorName,
                      onTap: () {
                        Get.to(() {
                          return DetailsScreen(
                            authorDescription: snapshot
                                .data!.ebookApp[index].authorDescription,
                            bookCoverImg:
                                snapshot.data!.ebookApp[index].bookCoverImg,
                            bookTitle: snapshot.data!.ebookApp[index].bookTitle,
                            bookDescription:
                                snapshot.data!.ebookApp[index].bookDescription,
                            id: int.parse(snapshot.data!.ebookApp[index].id),
                            rating: snapshot.data!.ebookApp[index].rateAvg,
                            authorName:
                                snapshot.data!.ebookApp[index].authorName,
                          );
                        });
                      },
                    );
                  });
            } else {
              return Center(child: Text(S.of(context).search_NO_BOOKS_FOUND));
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
                    height: 160.w,
                    color: Colors.white,
                    margin: EdgeInsets.all(10.r),
                  ),
                  baseColor: shimmerBaseColor(),
                  highlightColor: shimmerHighlightColor(),
                );
              },
            );
          }
        },
      ),
    );
  }
}
