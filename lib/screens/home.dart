import 'package:elearn/generated/l10n.dart';
import 'package:elearn/model/Profile.dart';
import 'package:elearn/model/allcategory.dart';
import 'package:elearn/model/besthomebook.dart';
import 'package:elearn/model/homecategory.dart';
import 'package:elearn/service/httpservice.dart';
import 'package:elearn/widgets/imageview.dart';
import 'package:elearn/widgets/richtxt.dart';
import 'package:elearn/widgets/safe_image_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shimmer/shimmer.dart';

import '../consttants.dart';
import '../model/categoryid.dart';
import '../widgets/title.dart';
import 'category.dart';
import 'details_screen.dart';
import 'griddview.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  RxList<Book> featuredBooks = <Book>[].obs;
  RxList<Book> latestBooks = <Book>[].obs;

  @override
  void initState() {
    getHomeBooks();
    super.initState();
  }

  Future<BestHomeBook?> getHomeBooks() async {
    try {
      var response =
          await http.get(Uri.parse('$apiLink/api.php?method_name=home'));
      if (response.statusCode == 200) {
        var data = bestHomeBookFromJson(response.body);
        latestBooks.value = data.ebookApp.latestBooks;
        featuredBooks.value = data.ebookApp.featuredBooks;
        return data;
      } else {
        throw 'Request failed with status: ${response.statusCode}';
      }
    } catch (e) {
      debugPrint('Request failed with status:$e');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final orientation = MediaQuery.of(context).orientation;

    double greetingFontSize;
    double categoryFontSize;
    double categoryHeight;
    double categoryImageWidth;
    double categoryImageHeight;
    double categoryTitleFontSize;
    double bookContainerHeight;
    double bookContainerWidth;

    if (orientation == Orientation.portrait) {
      greetingFontSize = 26.sp;
      categoryFontSize = 20.sp;
      categoryHeight = 250.h;
      categoryImageWidth = 350.w;
      categoryImageHeight = 300.w;
      categoryTitleFontSize = 25.sp;
      bookContainerHeight = 240.r;
      bookContainerWidth = 160.r;
    } else {
      greetingFontSize = 22.sp;
      categoryFontSize = 16.sp;
      categoryHeight = 500.h;
      categoryImageWidth = 200.w;
      categoryImageHeight = 330.w;
      categoryTitleFontSize = 22.sp;
      bookContainerHeight = 400.r;
      bookContainerWidth = 300.r;
    }

    return Scaffold(
      backgroundColor: comboBlackAndWhite(),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.only(top: 18.0.h, left: 15.w, right: 15.w),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    userId != null
                        ? FutureBuilder<ProfileModel?>(
                            future: HttpService().getUserProfile(),
                            builder: (context, snapshot) {
                              if (snapshot.hasData) {
                                return CustomRichText(
                                  context: context,
                                  fontsize1: greetingFontSize,
                                  fontsize2: greetingFontSize,
                                  txt1: '${S.of(context).home_GREETINGS}\n',
                                  txt2: snapshot.data!.ebookApp[0].name
                                      .toTitleCase(),
                                );
                              } else {
                                return SizedBox(
                                  height: 50,
                                  child: TitleBar(
                                    title: S.of(context).home_Hello,
                                    image: 'assets/images/Home.svg',
                                  ),
                                );
                              }
                            },
                          )
                        : CustomRichText(
                            context: context,
                            fontsize1: greetingFontSize,
                            fontsize2: greetingFontSize,
                            txt1: '${S.of(context).home_GREETINGS}\n',
                            txt2: 'Olá, convidado',
                          ),
                  ],
                ),
              ),
              SizedBox(height: 20.h),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 10.w),
                child: CustomRichText(
                  context: context,
                  fontsize1: categoryFontSize,
                  fontsize2: categoryFontSize,
                  txt2: S.of(context).home_CATEGORY,
                ),
              ),
              SizedBox(
                height: categoryHeight,
                child: FutureBuilder<AllCategory?>(
                    future: HttpService().getAllCategory(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.done) {
                        if (snapshot.hasData) {
                          return ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: snapshot.data!.ebookApp.length,
                            shrinkWrap: true,
                            primary: false,
                            itemBuilder: (context, index) {
                              return Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: GestureDetector(
                                  onTap: () {
                                    Get.to(
                                      () => NewCategoryScreen(
                                        catId: int.parse(
                                          snapshot.data!.ebookApp[index].cid,
                                        ),
                                        categoryName: snapshot
                                            .data!.ebookApp[index].categoryName,
                                      ),
                                    );
                                  },
                                  child: Stack(
                                    alignment: Alignment.bottomCenter,
                                    children: [
                                      ClipRRect(
                                        borderRadius:
                                            BorderRadius.circular(8.r),
                                        child: SafeCategoryImageWidget(
                                          imageUrl: snapshot.data!
                                              .ebookApp[index].categoryImage,
                                          width: categoryImageWidth,
                                          height: categoryImageHeight,
                                        ),
                                      ),
                                      Container(
                                        width: categoryImageWidth,
                                        alignment: Alignment.bottomCenter,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(8.0.r),
                                          gradient: const LinearGradient(
                                            colors: [
                                              Colors.transparent,
                                              Colors.black12,
                                              Colors.black,
                                            ],
                                            begin: Alignment.center,
                                            end: Alignment.bottomCenter,
                                          ),
                                        ),
                                        child: Padding(
                                          padding:
                                              EdgeInsets.only(bottom: 15.h),
                                          child: Text(
                                            snapshot.data!.ebookApp[index]
                                                .categoryName,
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: categoryTitleFontSize,
                                              fontFamily: "Gilroy-Bold",
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          );
                        } else {
                          return Center(
                            child: Text(S.of(context).search_NO_BOOKS_FOUND),
                          );
                        }
                      } else {
                        return Shimmer.fromColors(
                          baseColor: shimmerBaseColor(),
                          highlightColor: shimmerHighlightColor(),
                          child: Container(
                            width: categoryImageWidth,
                            height: categoryImageHeight,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                            margin: const EdgeInsets.all(8.0),
                          ),
                        );
                      }
                    }),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      SizedBox(height: 20.0.h),
                      FutureBuilder<CategoryId?>(
                        future: HttpService().getCatId(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.done) {
                            if (snapshot.hasData) {
                              return ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: snapshot.data!.ebookApp.length,
                                itemBuilder: (BuildContext context, index) {
                                  return FutureBuilder<CategoryById?>(
                                    future: HttpService().getCategoryById(
                                      bookId:
                                          snapshot.data!.ebookApp[index].id,
                                    ),
                                    builder: (context, bookData) {
                                      if (bookData.connectionState ==
                                          ConnectionState.done) {
                                        if (bookData.hasData &&
                                            bookData.data != null &&
                                            bookData
                                                .data!.ebookApp.isNotEmpty) {
                                          return Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Padding(
                                                padding: EdgeInsets.only(
                                                  bottom: 10.r,
                                                  top: 20.r,
                                                  left: 10.r,
                                                  right: 10.r,
                                                ),
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    SizedBox(
                                                      width: MediaQuery.of(
                                                                  context)
                                                              .size
                                                              .width *
                                                          0.7,
                                                      child: Text(
                                                        snapshot.data!
                                                            .ebookApp[index]
                                                            .sectionTitle,
                                                        style: TextStyle(
                                                          color:
                                                              comboWhiteAndBlack(),
                                                          fontSize: 18.sp,
                                                          fontFamily:
                                                              'Gilroy-SemiBold',
                                                        ),
                                                      ),
                                                    ),
                                                    InkWell(
                                                      onTap: () {
                                                        Get.to(
                                                          ViewBookScreen(
                                                            id: snapshot
                                                                .data!
                                                                .ebookApp[
                                                                    index]
                                                                .id,
                                                            title: snapshot
                                                                .data!
                                                                .ebookApp[
                                                                    index]
                                                                .sectionTitle,
                                                          ),
                                                        );
                                                      },
                                                      child: Text(
                                                        S
                                                            .of(context)
                                                            .home_SeeAll,
                                                        style: TextStyle(
                                                          color:
                                                              comboWhiteAndBlack(),
                                                          fontFamily:
                                                              "Gilroy-Medium",
                                                          fontSize: 15.sp,
                                                        ),
                                                      ),
                                                    )
                                                  ],
                                                ),
                                              ),
                                              SizedBox(
                                                height: bookContainerHeight,
                                                child: ListView.builder(
                                                  physics:
                                                      const BouncingScrollPhysics(),
                                                  scrollDirection:
                                                      Axis.horizontal,
                                                  shrinkWrap: true,
                                                  itemCount: bookData
                                                      .data!.ebookApp.length,
                                                  itemBuilder:
                                                      (context, index222) {
                                                    final book = bookData
                                                        .data!
                                                        .ebookApp[index222];
                                                    return GestureDetector(
                                                      onTap: () {
                                                        Get.to(
                                                          () {
                                                            return DetailsScreen(
                                                              authorName: book
                                                                  .authorName,
                                                              authorDescription:
                                                                  book.authorDescription,
                                                              bookCoverImg: book
                                                                  .bookCoverImg,
                                                              bookTitle: book
                                                                  .bookTitle,
                                                              bookDescription:
                                                                  book.bookDescription,
                                                              id: int.parse(
                                                                  book.id),
                                                              rating: book
                                                                  .rateAvg,
                                                            );
                                                          },
                                                        );
                                                      },
                                                      child: Container(
                                                        height:
                                                            bookContainerHeight,
                                                        width:
                                                            bookContainerWidth,
                                                        margin:
                                                            EdgeInsets.all(
                                                                8.r),
                                                        child: Imageview(
                                                          image: book
                                                              .bookCoverImg,
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                ),
                                              ),
                                            ],
                                          );
                                        } else {
                                          return const SizedBox.shrink();
                                        }
                                      } else {
                                        return Shimmer.fromColors(
                                          baseColor: shimmerBaseColor(),
                                          highlightColor:
                                              shimmerHighlightColor(),
                                          child: Container(
                                            margin: EdgeInsets.symmetric(
                                              vertical: 10.r,
                                              horizontal: 10.r,
                                            ),
                                            height: bookContainerHeight,
                                            color: comboBlackAndWhite(),
                                          ),
                                        );
                                      }
                                    },
                                  );
                                },
                              );
                            } else {
                              return Center(
                                child:
                                    Text(S.of(context).search_NO_BOOKS_FOUND),
                              );
                            }
                          } else {
                            return Shimmer.fromColors(
                              baseColor: shimmerBaseColor(),
                              highlightColor: shimmerHighlightColor(),
                              child: Center(
                                child: SizedBox(
                                  height: 240.w,
                                  width: 160.r,
                                  child: Icon(
                                    Icons.all_inclusive_outlined,
                                    size: 30.h.w,
                                    color: comboBlackAndWhite(),
                                  ),
                                ),
                              ),
                            );
                          }
                        },
                      ),
                      SizedBox(height: 40.h),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 20.h),
            ],
          ),
        ),
      ),
    );
  }
}
